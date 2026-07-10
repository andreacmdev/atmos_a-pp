-- Limpeza de adolescentes duplicados - V3
--
-- Rode em duas etapas no Supabase SQL Editor.
-- Esta versao evita temporary tables e tambem evita criar/usar a tabela
-- auxiliar dentro da mesma transacao.

-- ============================================================
-- ETAPA 1: criar mapa dos duplicados
-- Rode este bloco primeiro.
-- ============================================================

create or replace function public._atmos_nome_normalizado(value text)
returns text
language sql
immutable
as $$
  select trim(
    regexp_replace(
      lower(
        translate(
          coalesce(value, ''),
          'áàâãäÁÀÂÃÄéèêëÉÈÊËíìîïÍÌÎÏóòôõöÓÒÔÕÖúùûüÚÙÛÜçÇñÑ',
          'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUcCnN'
        )
      ),
      '\s+',
      ' ',
      'g'
    )
  );
$$;

drop table if exists public.atmos_adolescentes_dup_map;

create table public.atmos_adolescentes_dup_map as
with base as (
  select
    a.*,
    public._atmos_nome_normalizado(a.nome) as nome_normalizado,
    count(*) over (
      partition by public._atmos_nome_normalizado(a.nome)
    ) as qtd,
    first_value(a.id) over (
      partition by public._atmos_nome_normalizado(a.nome)
      order by
        a.ativo desc,
        (a.data_nascimento is not null) desc,
        (nullif(trim(coalesce(a.telefone, '')), '') is not null) desc,
        a.id
    ) as manter_id
  from public.adolescentes a
  where a.ativo = true
)
select
  id as remover_id,
  manter_id,
  nome_normalizado
from base
where qtd > 1
  and id <> manter_id;

select
  'cadastros_que_serao_removidos' as item,
  count(*) as total
from public.atmos_adolescentes_dup_map;

select
  m.nome_normalizado,
  m.manter_id,
  manter.nome as manter_nome,
  m.remover_id,
  remover.nome as remover_nome
from public.atmos_adolescentes_dup_map m
join public.adolescentes manter on manter.id = m.manter_id
join public.adolescentes remover on remover.id = m.remover_id
order by m.nome_normalizado, m.remover_id;

-- ============================================================
-- ETAPA 2: executar merge
-- Rode este bloco somente depois de conferir o resultado da ETAPA 1.
-- ============================================================

begin;

-- Completa dados faltantes no cadastro principal usando algum duplicado.
update public.adolescentes manter
set
  data_nascimento = coalesce(manter.data_nascimento, fonte.data_nascimento),
  telefone = coalesce(
    nullif(trim(manter.telefone), ''),
    nullif(trim(fonte.telefone), ''),
    manter.telefone
  )
from (
  select distinct on (m.manter_id)
    m.manter_id,
    a.data_nascimento,
    a.telefone
  from public.atmos_adolescentes_dup_map m
  join public.adolescentes a on a.id = m.remover_id
  order by
    m.manter_id,
    (a.data_nascimento is not null) desc,
    (nullif(trim(coalesce(a.telefone, '')), '') is not null) desc,
    a.id
) fonte
where manter.id = fonte.manter_id;

-- Presencas gerais: remove conflitos antes de mover.
delete from public.presencas p
using public.atmos_adolescentes_dup_map m
where p.adolescente_id = m.remover_id
  and exists (
    select 1
    from public.presencas p2
    where p2.evento_id = p.evento_id
      and p2.adolescente_id = m.manter_id
  );

update public.presencas p
set adolescente_id = m.manter_id
from public.atmos_adolescentes_dup_map m
where p.adolescente_id = m.remover_id;

-- Presencas dos Conectados: remove conflitos antes de mover.
delete from public.conectados_presencas p
using public.atmos_adolescentes_dup_map m
where p.adolescente_id = m.remover_id
  and exists (
    select 1
    from public.conectados_presencas p2
    where p2.encontro_id = p.encontro_id
      and p2.adolescente_id = m.manter_id
  );

update public.conectados_presencas p
set adolescente_id = m.manter_id
from public.atmos_adolescentes_dup_map m
where p.adolescente_id = m.remover_id;

-- Deixa no maximo um vinculo ativo por adolescente mantido.
with ativos_rankeados as (
  select
    cm.id,
    m.manter_id,
    row_number() over (
      partition by m.manter_id
      order by
        (cm.adolescente_id = m.manter_id) desc,
        cm.data_entrada desc,
        cm.id desc
    ) as rn
  from public.conectados_membros cm
  join (
    select manter_id, manter_id as adolescente_id
    from public.atmos_adolescentes_dup_map
    union
    select manter_id, remover_id as adolescente_id
    from public.atmos_adolescentes_dup_map
  ) m on m.adolescente_id = cm.adolescente_id
  where cm.ativo = true
)
update public.conectados_membros cm
set
  ativo = false,
  data_saida = coalesce(cm.data_saida, current_date)
from ativos_rankeados r
where cm.id = r.id
  and r.rn > 1;

update public.conectados_membros cm
set adolescente_id = m.manter_id
from public.atmos_adolescentes_dup_map m
where cm.adolescente_id = m.remover_id;

update public.conectados_transferencias t
set adolescente_id = m.manter_id
from public.atmos_adolescentes_dup_map m
where t.adolescente_id = m.remover_id;

delete from public.adolescentes a
using public.atmos_adolescentes_dup_map m
where a.id = m.remover_id;

commit;

-- Conferencia final.
select
  'duplicados_remanescentes' as item,
  count(*) as total
from (
  select public._atmos_nome_normalizado(nome)
  from public.adolescentes
  where ativo = true
  group by public._atmos_nome_normalizado(nome)
  having count(*) > 1
) d
union all
select 'adolescentes_ativos', count(*) from public.adolescentes where ativo = true;

drop table if exists public.atmos_adolescentes_dup_map;

-- Opcional:
-- drop function if exists public._atmos_nome_normalizado(text);
