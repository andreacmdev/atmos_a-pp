-- Importacao via CSV pelo Supabase Table Editor
--
-- Passo 1:
-- Rode este bloco para criar a tabela de apoio.
--
-- Passo 2:
-- No Supabase, importe o CSV para public.conectados_import_csv.
-- As colunas precisam ser:
-- nome, conectados, responsavel, Cor
--
-- Passo 3:
-- Rode o bloco "Processar importacao" no final deste arquivo.

create table if not exists public.conectados_import_csv (
  nome text,
  conectados text,
  responsavel text,
  "Cor" text
);

truncate table public.conectados_import_csv;

-- Processar importacao
-- Rode este bloco depois de importar o CSV na tabela acima.

create or replace function public.norm_nome_conectados(value text)
returns text
language sql
immutable
as $$
  select regexp_replace(
    translate(
      lower(trim(coalesce(value, ''))),
      'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ',
      'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN'
    ),
    '\s+',
    ' ',
    'g'
  );
$$;

with matched_raw as (
  select
    a.id as adolescente_id,
    g.id as grupo_id,
    c.conectados,
    row_number() over (
      partition by a.id
      order by c.conectados
    ) as rn
  from public.conectados_import_csv c
  join public.adolescentes a
    on public.norm_nome_conectados(a.nome) = public.norm_nome_conectados(c.nome)
  join public.conectados_grupos g
    on public.norm_nome_conectados(g.nome) = public.norm_nome_conectados(c.conectados)
  where a.ativo = true
),
matched as (
  select adolescente_id, grupo_id
  from matched_raw
  where rn = 1
)
update public.conectados_membros atual
set ativo = false,
    data_saida = current_date
from matched m
where atual.adolescente_id = m.adolescente_id
  and atual.ativo = true
  and atual.grupo_id <> m.grupo_id;

with matched_raw as (
  select
    a.id as adolescente_id,
    g.id as grupo_id,
    c.conectados,
    row_number() over (
      partition by a.id
      order by c.conectados
    ) as rn
  from public.conectados_import_csv c
  join public.adolescentes a
    on public.norm_nome_conectados(a.nome) = public.norm_nome_conectados(c.nome)
  join public.conectados_grupos g
    on public.norm_nome_conectados(g.nome) = public.norm_nome_conectados(c.conectados)
  where a.ativo = true
),
matched as (
  select adolescente_id, grupo_id
  from matched_raw
  where rn = 1
)
insert into public.conectados_membros (grupo_id, adolescente_id, data_entrada, ativo)
select m.grupo_id, m.adolescente_id, current_date, true
from matched m
where not exists (
  select 1
  from public.conectados_membros atual
  where atual.adolescente_id = m.adolescente_id
    and atual.ativo = true
)
on conflict (adolescente_id) where ativo = true do nothing;

select
  (select count(*) from public.conectados_import_csv) as linhas_csv,
  (select count(distinct a.id)
   from public.conectados_import_csv c
   join public.adolescentes a
     on public.norm_nome_conectados(a.nome) = public.norm_nome_conectados(c.nome)
   where a.ativo = true) as adolescentes_encontrados,
  (select count(*)
   from public.conectados_import_csv c
   where not exists (
     select 1
     from public.adolescentes a
     where a.ativo = true
       and public.norm_nome_conectados(a.nome) = public.norm_nome_conectados(c.nome)
   )) as nomes_nao_encontrados;

select distinct c.nome, c.conectados
from public.conectados_import_csv c
where not exists (
  select 1
  from public.adolescentes a
  where a.ativo = true
    and public.norm_nome_conectados(a.nome) = public.norm_nome_conectados(c.nome)
)
order by c.conectados, c.nome;
