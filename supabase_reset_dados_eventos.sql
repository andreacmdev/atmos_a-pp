-- Reset dos dados de eventos do ATMOS
-- Preserva:
-- - auth.users
-- - public.adolescentes
-- - public.conectados_grupos
-- - public.conectados_membros
--
-- Remove:
-- - eventos gerais e presencas gerais
-- - visitantes
-- - encontros e presencas dos Conectados
--
-- Rode primeiro o bloco de diagnostico. Se os numeros fizerem sentido,
-- rode o bloco de reset.

-- 1) Diagnostico antes de apagar
select 'eventos' as tabela, count(*) as total from public.eventos
union all
select 'presencas', count(*) from public.presencas
union all
select 'visitantes', count(*) from public.visitantes
union all
select 'conectados_encontros', count(*) from public.conectados_encontros
union all
select 'conectados_presencas', count(*) from public.conectados_presencas
union all
select 'adolescentes_preservados', count(*) from public.adolescentes
union all
select 'conectados_membros_preservados', count(*) from public.conectados_membros;

-- 2) Encontrar encontros dos Conectados sem nenhuma presenca real
select
  e.id,
  g.nome as conectado,
  e.data_encontro,
  count(p.id) filter (where p.presente = true) as presencas_reais
from public.conectados_encontros e
join public.conectados_grupos g on g.id = e.grupo_id
left join public.conectados_presencas p on p.encontro_id = e.id
group by e.id, g.nome, e.data_encontro
having count(p.id) filter (where p.presente = true) = 0
order by e.data_encontro desc, g.nome;

-- 3) Limpar apenas encontros vazios/acidentais dos Conectados
-- Use este bloco se quiser limpar antes do reset total.
delete from public.conectados_encontros e
where not exists (
  select 1
  from public.conectados_presencas p
  where p.encontro_id = e.id
    and p.presente = true
);

-- 4) Reset total do historico de eventos
-- ATENCAO: este bloco apaga historico. Mantem adolescentes e conectados.
truncate table
  public.presencas,
  public.eventos,
  public.visitantes,
  public.conectados_presencas,
  public.conectados_encontros
restart identity cascade;

-- 5) Diagnostico depois de apagar
select 'eventos' as tabela, count(*) as total from public.eventos
union all
select 'presencas', count(*) from public.presencas
union all
select 'visitantes', count(*) from public.visitantes
union all
select 'conectados_encontros', count(*) from public.conectados_encontros
union all
select 'conectados_presencas', count(*) from public.conectados_presencas
union all
select 'adolescentes_preservados', count(*) from public.adolescentes
union all
select 'conectados_membros_preservados', count(*) from public.conectados_membros;
