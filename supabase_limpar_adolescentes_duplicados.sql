-- Limpeza de adolescentes duplicados por nome normalizado
--
-- Preserva um cadastro principal e move referencias dos duplicados para ele.
-- Criterio do cadastro principal:
-- 1. ativo = true
-- 2. tem data de nascimento
-- 3. tem telefone
-- 4. menor id
--
-- Tabelas atualizadas:
-- - public.presencas
-- - public.conectados_presencas
-- - public.conectados_membros
-- - public.conectados_transferencias
--
-- Rode primeiro o DIAGNOSTICO. Se estiver correto, rode a EXECUCAO.

-- ============================================================
-- DIAGNOSTICO
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

with grupos as (
  select
    public._atmos_nome_normalizado(nome) as nome_normalizado,
    count(*) as qtd,
    array_agg(id order by id) as ids,
    array_agg(nome order by id) as nomes
  from public.adolescentes
  where ativo = true
  group by public._atmos_nome_normalizado(nome)
  having count(*) > 1
)
select *
from grupos
order by qtd desc, nome_normalizado;

-- Mostra qual id sera mantido e quais serao removidos.
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
  nome_normalizado,
  manter_id,
  id as candidato_id,
  nome,
  data_nascimento,
  telefone,
  case when id = manter_id then 'MANTER' else 'REMOVER/MERGE' end as acao
from base
where qtd > 1
order by nome_normalizado, acao, candidato_id;

-- ============================================================
-- EXECUCAO
-- ============================================================

begin;

create temporary table tmp_adolescentes_dup_all on commit drop as
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
  id,
  manter_id,
  nome_normalizado
from base
where qtd > 1;

create temporary table tmp_adolescentes_dup_map on commit drop as
select
  id as remover_id,
  manter_id
from tmp_adolescentes_dup_all
where id <> manter_id;

-- Completa dados faltantes no cadastro principal usando algum duplicado.
update public.adolescentes manter
set
  data_nascimento = coalesce(manter.data_nascimento, fonte.data_nascimento),
  telefone = coalesce(nullif(trim(manter.telefone), ''), nullif(trim(fonte.telefone), ''), manter.telefone)
from (
  select distinct on (m.manter_id)
    m.manter_id,
    a.data_nascimento,
    a.telefone
  from tmp_adolescentes_dup_map m
  join public.adolescentes a on a.id = m.remover_id
  order by
    m.manter_id,
    (a.data_nascimento is not null) desc,
    (nullif(trim(coalesce(a.telefone, '')), '') is not null) desc,
    a.id
) fonte
where manter.id = fonte.manter_id;

-- Evita conflitos em presencas gerais quando os dois cadastros marcaram o mesmo evento.
delete from public.presencas p
using tmp_adolescentes_dup_map m
where p.adolescente_id = m.remover_id
  and exists (
    select 1
    from public.presencas p2
    where p2.evento_id = p.evento_id
      and p2.adolescente_id = m.manter_id
  );

update public.presencas p
set adolescente_id = m.manter_id
from tmp_adolescentes_dup_map m
where p.adolescente_id = m.remover_id;

-- Evita conflitos em presencas dos Conectados.
delete from public.conectados_presencas p
using tmp_adolescentes_dup_map m
where p.adolescente_id = m.remover_id
  and exists (
    select 1
    from public.conectados_presencas p2
    where p2.encontro_id = p.encontro_id
      and p2.adolescente_id = m.manter_id
  );

update public.conectados_presencas p
set adolescente_id = m.manter_id
from tmp_adolescentes_dup_map m
where p.adolescente_id = m.remover_id;

-- Garante apenas um vinculo ativo por adolescente antes do merge.
with ativos_rankeados as (
  select
    cm.id,
    d.manter_id,
    row_number() over (
      partition by d.manter_id
      order by
        (cm.adolescente_id = d.manter_id) desc,
        cm.data_entrada desc,
        cm.id desc
    ) as rn
  from public.conectados_membros cm
  join tmp_adolescentes_dup_all d on d.id = cm.adolescente_id
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
from tmp_adolescentes_dup_map m
where cm.adolescente_id = m.remover_id;

update public.conectados_transferencias t
set adolescente_id = m.manter_id
from tmp_adolescentes_dup_map m
where t.adolescente_id = m.remover_id;

-- Agora remove os cadastros duplicados.
delete from public.adolescentes a
using tmp_adolescentes_dup_map m
where a.id = m.remover_id;

-- Resultado da limpeza.
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

commit;

-- Opcional: remover a funcao auxiliar depois da limpeza.
-- drop function if exists public._atmos_nome_normalizado(text);
