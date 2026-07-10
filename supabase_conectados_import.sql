-- Importacao dos membros dos Conectados a partir do CSV enviado.
-- Rode depois do supabase_conectados.sql.
begin;
drop table if exists public._tmp_conectados_csv;
create table public._tmp_conectados_csv (nome text, conectado text, responsavel text, cor_nome text);
insert into public._tmp_conectados_csv (nome, conectado, responsavel, cor_nome) values
  ('Gabriela de Caldas Monteiro', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Ana Carolina de Lima Padilha', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Cláudia Katharine Campos da Silva', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Andreilly nicolly Oliveira paraíso', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Isabele de Caldas Monteiro', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Laís Hardman de Vasconcelos Silva', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Maria Clara Silva Sales', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Victoria Cristina Oliveira Marques', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Elisa Correia de Araújo Sobreira', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Brenda', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Ana Luísa Sena luna', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Ayssa vitória da Silva Alves', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Ana Glória de Melo Cavalcanti', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Anne Letícia Virgínia Barbosa de Souza', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Maria Júlia Candido de Moraes', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Tacilla Maria Cavalcanti de Almeida', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Rebeca Cândido de Moura Silvestre', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Alice vitória Santana de Lima', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Beatriz falcão de lima noberto', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Emily kallline Ferreira santos', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Geovana Pereira Dos Reis', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Roberta Saldanha Magalhaes', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Mariany nascimento Andrade da Silva', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Amanda Albuquerque Rodrigues', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Larissa Gabrielle de Santana Gonçalves', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Valentina Danda Gomes de Mattos', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Anna Beatriz Ramos da Silva', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Ana Beatriz Machado da paixão', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Julia beatriz crispim de souza', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Jeniffer vitoria felix de oliveira', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('maria eduarda freitas de moraes', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('maria clara santos soares', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Júlia Beatriz crispim de Souza', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('júlya gabrielle pereira', 'LARAMORA', 'Andressa', 'Vermelho'),
  ('Anthony Giovane Santos de Farias', 'PLUGADOS', 'Breno', 'Preto'),
  ('Arthur Bernard Carvalho Nunes', 'PLUGADOS', 'Breno', 'Preto'),
  ('Arthur Miguel Ferreira dos Santos', 'PLUGADOS', 'Breno', 'Preto'),
  ('Arthur Silva Lima', 'PLUGADOS', 'Breno', 'Preto'),
  ('Daniel Albuquerque Revorêdo Lima', 'PLUGADOS', 'Breno', 'Preto'),
  ('Daniel Alves Corrêa', 'PLUGADOS', 'Breno', 'Preto'),
  ('Danilo Barbosa Fay', 'PLUGADOS', 'Breno', 'Preto'),
  ('Eduardo Anacleto Rodrigues da Silva', 'PLUGADOS', 'Breno', 'Preto'),
  ('Everton De Andrade', 'PLUGADOS', 'Breno', 'Preto'),
  ('Gabriel Campos Vasconcelos', 'PLUGADOS', 'Breno', 'Preto'),
  ('Gabriel Lopes', 'PLUGADOS', 'Breno', 'Preto'),
  ('Guilherme André de Holanda Lopes', 'PLUGADOS', 'Breno', 'Preto'),
  ('Izegbe crispim pedrosa', 'PLUGADOS', 'Breno', 'Preto'),
  ('Izidorio Francisco da Silva neto', 'PLUGADOS', 'Breno', 'Preto'),
  ('joão Filipe guedes araujo', 'PLUGADOS', 'Breno', 'Preto'),
  ('João Vicente nunes', 'PLUGADOS', 'Breno', 'Preto'),
  ('Jonatha micael lima de melo', 'PLUGADOS', 'Breno', 'Preto'),
  ('José Miguel Moura Felinto', 'PLUGADOS', 'Breno', 'Preto'),
  ('Lucas Davi Rodrigues De Oliveira', 'PLUGADOS', 'Breno', 'Preto'),
  ('Lucas Vespasiano de Melo', 'PLUGADOS', 'Breno', 'Preto'),
  ('Luiz Henrique Lucena de Arruda Menezes', 'PLUGADOS', 'Breno', 'Preto'),
  ('Mateus Nunes Monteiro Fonseca', 'PLUGADOS', 'Breno', 'Preto'),
  ('Matheus Costa Abreu de Oliveira', 'PLUGADOS', 'Breno', 'Preto'),
  ('miguel antonio rodeigues vasconcelos', 'PLUGADOS', 'Breno', 'Preto'),
  ('Nicolas lima de Moraes', 'PLUGADOS', 'Breno', 'Preto'),
  ('Nicolas Riquelme de Oliveira Feitosa', 'PLUGADOS', 'Breno', 'Preto'),
  ('Pedro Filipe Gonçalves mastrangeli', 'PLUGADOS', 'Breno', 'Preto'),
  ('Pedro Henrique Barbosa de Sousa', 'PLUGADOS', 'Breno', 'Preto'),
  ('Pedro Henrique Tavares Araújo', 'PLUGADOS', 'Breno', 'Preto'),
  ('Pedro vitor braga martins', 'PLUGADOS', 'Breno', 'Preto'),
  ('Raphael Vitor Souza Cabral De Almeida', 'PLUGADOS', 'Breno', 'Preto'),
  ('Ricardo Garcia Maia', 'PLUGADOS', 'Breno', 'Preto'),
  ('Sérgio Nunes da Silva Júnior', 'PLUGADOS', 'Breno', 'Preto'),
  ('Pedro Henrique Varejão da Silva', 'PLUGADOS', 'Breno', 'Preto'),
  ('Ryan Rafael Gonçalves eloi', 'PLUGADOS', 'Breno', 'Preto'),
  ('Higor Pessoa', 'PLUGADOS', 'Breno', 'Preto'),
  ('Icaro Ribeiro Franklin de lira', 'PLUGADOS', 'Breno', 'Preto'),
  ('Kayvson Ruan da Silva Brás', 'PLUGADOS', 'Breno', 'Preto'),
  ('André Filipe Souza de Lima oliveira', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Arthur Filipe Silva dos Santos', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Arthur Leonardo da Silva Ferreira', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Augusto Luis sena Luna', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Caio Ismael longo barbosa', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Emanuel Guilherme Gonçalves da Cunha', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('erick Lucas da Silva virgulino', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Eslley de Vasconcellos Anacleto', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Everton de Andrade Ferreira', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Gabriel Gomes de Souza', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Guilherme Dornelas Camara Souza', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Guilherme Victor Santos de Lima', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Guilherme Victor Santos de Lima', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Jeffersson pereira Tenório da Silva', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('João Antonio Mota e Moura', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('João Paulo da Silva', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('José Mateus leite da Silva', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Lucas Apolinário Valadares Rabelo', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Lucas Henrique Freire da Silva', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Mateus Felipe de Almeida Sá', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Milson Marinho de Araújo Barbosa Neto', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Nycolas Rafael Pimentel da Silva', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Pedro Henrique Souza dos Santos', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Rafael Cavalcante de Souza', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Samuel dos Santos Oliveira', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Samuel Rubem Ferreira de Araújo', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('victor fernando ramos de andrade', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Kauê guilherme Silva do carmo', 'CONECTHANOS', 'Dedé', 'Roxo'),
  ('Ângelo Gabriel de Oliveira Melo', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Arthur Messi Costa De Lima.', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Daniel dos Santos Oliveira', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Daniel Moura do Nascimento', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Davi de barros monteiro', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Davi Leonardo Cavalcante Da Silva', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Davi Lucas Mota Santos', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('David Miguel Gomes da Silva', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Dimas lira Borba da Paz', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Everton Lisboa Ferreira Junior', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Felipe Eidam Franco', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Gabriel Lucas de Holanda Lopes', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Heitor Leonardo da Silva Bezerra', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Heitor Pereira de Amorim', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Hiago Macedo Bunzen', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Ícaro ribeiro Franklin de Lira', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('João Gabriel Ferreira', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('João Paulo portela da Silva', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Lancelot Benuic Souza de Oliveira', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Lucas gaspar verçosa de melo', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Luis Guilherme Martins Didier', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Manoel Marques da Silva junior', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Mateus gonçalves', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Mateus rodolfo dos santos silva', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Matheus Costa Abreu de Oliveira', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Matheus Leonardo dos Santos Silva', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Matheus Sales Carvalheira', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Miguel Francisco Pereira dos Santos', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Miguel Paulino Mariano da Silva', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Nicolas Renan Andrade Almeida', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Nicolas Renan Andrade Almeida', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Pedro Henrique Alves Corrêa', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Pedro Henrique Varejão da Silva', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Pietro Henrique Souza Targino', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Rafael melo', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Romério Dimitri Lima de Moraes', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Ryan Henrique da Silva Nascimento', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Ryan Rafael Gonçalves Eloi', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Silas Martiliano Araújo da cruz', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Tarcísio Gabriel Firmino Araújo', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Vinícius Bernardo Cassiano Barbosa Pereira', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Vinicius Minervino Da Silva Souza', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Vinícius Ramos dos Santos', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Weslley Matias dos Santos Queiroz', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Heitor Sousa de Oliveira', 'GRÃO DE MOSTARDA', 'Gabriel', 'Amarelo'),
  ('Alessandra Beatriz de Melo Rocha', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Ana Isabelle de Lima Vila Nova', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Debora Neves Andrade', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Dielly Victoria Santos e Santos', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Elizabeth Rodrigues Alves morais', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Evelyn Anacleto Bustorff', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Gabriela Duque Santos', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Gabriella Barbosa do nascimento', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Jullya Gabrielly Gomes Anacleto', 'PINKIES', 'Heloísa', 'Rosa'),
  ('júlya gabrielle pereira', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Kamilly Victoria de Andrade Saraiva', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Kauanny Vitória Ferreira de Araújo', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Lais vitória Gaudencio do nascimento', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Lara Geovana Andrade de Oliveira Santos', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Lara Vitória Machado Batista Da Silva', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Larissa Oliveira Solane', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Laura Regina Magalhães de Santana', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Leticia couto coelho', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Lunna Araujo De Oliveira', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Maria Cecília Santana', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Maria Clara Trajano do nascimento', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Maria Sophia Arruda Andrade', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Mariane Pereira Garcia', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Misla Dantas', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Rafaela Ferreira da Costa Albuquerque', 'PINKIES', 'Heloísa', 'Rosa'),
  ('sabrina gois Peçanha Coelho', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Sara Helena Lucena de Aragão Pereira', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Vitória Carla Santos da Silva', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Anna Luysa Santos Alves', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Maria Esther Alves Brandão', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Alexia Lethicia Soares de Lima', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Heloísa Vitória Ferreira de souza', 'PINKIES', 'Heloísa', 'Rosa'),
  ('Alexia Letícia Soares de lima', 'AZULETES', 'Vick', 'Azul'),
  ('Alice Vicktória Chaves de Lima', 'AZULETES', 'Vick', 'Azul'),
  ('Ana Alice Izidio Da Silva', 'AZULETES', 'Vick', 'Azul'),
  ('Ana Beatriz Do Egito Ordonho', 'AZULETES', 'Vick', 'Azul'),
  ('Ana Clara Delmiro da Silva', 'AZULETES', 'Vick', 'Azul'),
  ('Ana Letícia Cabral Guimarães', 'AZULETES', 'Vick', 'Azul'),
  ('Ana Lopes da Silva Coutinho', 'AZULETES', 'Vick', 'Azul'),
  ('Anita Barbosa da Silva', 'AZULETES', 'Vick', 'Azul'),
  ('Cecilía Vitória Felix Da Silva', 'AZULETES', 'Vick', 'Azul'),
  ('Eduarda Chaves Becker', 'AZULETES', 'Vick', 'Azul'),
  ('Elen Sousa de Oliveira', 'AZULETES', 'Vick', 'Azul'),
  ('Ellen Beatriz belarmino da Mota', 'AZULETES', 'Vick', 'Azul'),
  ('Ester Maria Gonçalves da Costa', 'AZULETES', 'Vick', 'Azul'),
  ('Esther Carvalho Barbosa', 'AZULETES', 'Vick', 'Azul'),
  ('Geane Camilly Santos de Lima', 'AZULETES', 'Vick', 'Azul'),
  ('Geovanna Nayara Silva Fernandes', 'AZULETES', 'Vick', 'Azul'),
  ('Helena Cristina de Oliveira Melo', 'AZULETES', 'Vick', 'Azul'),
  ('Isabela Lima Coelho', 'AZULETES', 'Vick', 'Azul'),
  ('Isabella Victória Alves da Silva', 'AZULETES', 'Vick', 'Azul'),
  ('Júlia cavalcanti Arcoverde', 'AZULETES', 'Vick', 'Azul'),
  ('Julia Santiago Marinho', 'AZULETES', 'Vick', 'Azul'),
  ('Larissa Raquel Houly Falcão.', 'AZULETES', 'Vick', 'Azul'),
  ('Laura Fernanda Alves Andrade', 'AZULETES', 'Vick', 'Azul'),
  ('Lavynea grazyelle lima Mendes da Silva', 'AZULETES', 'Vick', 'Azul'),
  ('Lethicia gabrielle Pereira da silva', 'AZULETES', 'Vick', 'Azul'),
  ('Luany Maria da Silva Nascimento', 'AZULETES', 'Vick', 'Azul'),
  ('Maria Alice Cavalcanti dos Santos', 'AZULETES', 'Vick', 'Azul'),
  ('Maria Eduarda Pereira', 'AZULETES', 'Vick', 'Azul'),
  ('Maria Eduarda Rodrigues bento', 'AZULETES', 'Vick', 'Azul'),
  ('Maria Elisa ferreira de Almeida Pereira', 'AZULETES', 'Vick', 'Azul'),
  ('Marina Lacerda Salazar', 'AZULETES', 'Vick', 'Azul'),
  ('Marina Vasconcelos de Oliveira', 'AZULETES', 'Vick', 'Azul'),
  ('Marina Victória da Silva Francelino', 'AZULETES', 'Vick', 'Azul'),
  ('Mirian hadassah gomes da silva', 'AZULETES', 'Vick', 'Azul'),
  ('Nauhana Beatriz Norões', 'AZULETES', 'Vick', 'Azul'),
  ('Raquel Revorêdo Lima', 'AZULETES', 'Vick', 'Azul'),
  ('Rianna Agata Barbosa da Silva', 'AZULETES', 'Vick', 'Azul'),
  ('Sara Sophia Almeida da Silva', 'AZULETES', 'Vick', 'Azul'),
  ('Sarah Araújo Thompson', 'AZULETES', 'Vick', 'Azul'),
  ('Sarah Victoria Dias de Souza', 'AZULETES', 'Vick', 'Azul'),
  ('Sofia Gois Peçanha Coelho', 'AZULETES', 'Vick', 'Azul'),
  ('Sofia Neves Andrade', 'AZULETES', 'Vick', 'Azul'),
  ('Yasmin Egito', 'AZULETES', 'Vick', 'Azul'),
  ('Kaylanny Santos Rocha', 'AZULETES', 'Vick', 'Azul');

create or replace function pg_temp.norm_nome(value text)
returns text
language sql
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
    c.conectado,
    row_number() over (
      partition by a.id
      order by c.conectado
    ) as rn
  from public._tmp_conectados_csv c
  join public.adolescentes a
    on pg_temp.norm_nome(a.nome) = pg_temp.norm_nome(c.nome)
  join public.conectados_grupos g
    on pg_temp.norm_nome(g.nome) = pg_temp.norm_nome(c.conectado)
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
    c.conectado,
    row_number() over (
      partition by a.id
      order by c.conectado
    ) as rn
  from public._tmp_conectados_csv c
  join public.adolescentes a
    on pg_temp.norm_nome(a.nome) = pg_temp.norm_nome(c.nome)
  join public.conectados_grupos g
    on pg_temp.norm_nome(g.nome) = pg_temp.norm_nome(c.conectado)
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
  (select count(*) from public._tmp_conectados_csv) as linhas_csv,
  (select count(distinct a.id)
   from public._tmp_conectados_csv c
   join public.adolescentes a
     on pg_temp.norm_nome(a.nome) = pg_temp.norm_nome(c.nome)
   where a.ativo = true) as adolescentes_encontrados,
  (select count(*)
   from public._tmp_conectados_csv c
   where not exists (
     select 1
     from public.adolescentes a
     where a.ativo = true
       and pg_temp.norm_nome(a.nome) = pg_temp.norm_nome(c.nome)
   )) as nomes_nao_encontrados;

select distinct c.nome, c.conectado
from public._tmp_conectados_csv c
where not exists (
  select 1
  from public.adolescentes a
  where a.ativo = true
    and pg_temp.norm_nome(a.nome) = pg_temp.norm_nome(c.nome)
)
order by c.conectado, c.nome;

drop table if exists public._tmp_conectados_csv;

commit;
