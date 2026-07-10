-- Modulo Conectados / Discipulados
-- Rode este SQL no Supabase SQL Editor antes de usar a tela Conectados.

create table if not exists public.conectados_grupos (
  id bigserial primary key,
  nome text not null,
  genero text not null check (genero in ('meninos', 'meninas')),
  responsavel text,
  cor_nome text,
  cor_hex text,
  ativo boolean not null default true,
  created_at timestamptz not null default now(),
  unique (nome)
);

alter table public.conectados_grupos
  add column if not exists responsavel text,
  add column if not exists cor_nome text,
  add column if not exists cor_hex text;

create table if not exists public.conectados_membros (
  id bigserial primary key,
  grupo_id bigint not null references public.conectados_grupos(id) on delete restrict,
  adolescente_id bigint not null references public.adolescentes(id) on delete cascade,
  ativo boolean not null default true,
  data_entrada date not null default current_date,
  data_saida date,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create unique index if not exists conectados_membros_um_ativo_por_adolescente
  on public.conectados_membros (adolescente_id)
  where ativo = true;

create index if not exists conectados_membros_grupo_ativo_idx
  on public.conectados_membros (grupo_id, ativo);

create table if not exists public.conectados_encontros (
  id bigserial primary key,
  grupo_id bigint not null references public.conectados_grupos(id) on delete cascade,
  data_encontro date not null,
  observacao text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  unique (grupo_id, data_encontro)
);

create table if not exists public.conectados_presencas (
  id bigserial primary key,
  encontro_id bigint not null references public.conectados_encontros(id) on delete cascade,
  adolescente_id bigint not null references public.adolescentes(id) on delete cascade,
  presente boolean not null default true,
  registrado_por_user uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (encontro_id, adolescente_id)
);

create index if not exists conectados_presencas_encontro_idx
  on public.conectados_presencas (encontro_id, presente);

create table if not exists public.conectados_transferencias (
  id bigserial primary key,
  adolescente_id bigint not null references public.adolescentes(id) on delete cascade,
  grupo_origem_id bigint references public.conectados_grupos(id) on delete set null,
  grupo_destino_id bigint not null references public.conectados_grupos(id) on delete restrict,
  data_transferencia date not null default current_date,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

alter table public.conectados_grupos enable row level security;
alter table public.conectados_membros enable row level security;
alter table public.conectados_encontros enable row level security;
alter table public.conectados_presencas enable row level security;
alter table public.conectados_transferencias enable row level security;

create policy "conectados_grupos_select_auth"
  on public.conectados_grupos for select
  to authenticated
  using (true);

create policy "conectados_membros_select_auth"
  on public.conectados_membros for select
  to authenticated
  using (true);

create policy "conectados_membros_insert_auth"
  on public.conectados_membros for insert
  to authenticated
  with check (true);

create policy "conectados_membros_update_auth"
  on public.conectados_membros for update
  to authenticated
  using (true)
  with check (true);

create policy "conectados_encontros_select_auth"
  on public.conectados_encontros for select
  to authenticated
  using (true);

create policy "conectados_encontros_insert_auth"
  on public.conectados_encontros for insert
  to authenticated
  with check (true);

create policy "conectados_presencas_select_auth"
  on public.conectados_presencas for select
  to authenticated
  using (true);

create policy "conectados_presencas_insert_auth"
  on public.conectados_presencas for insert
  to authenticated
  with check (true);

create policy "conectados_presencas_update_auth"
  on public.conectados_presencas for update
  to authenticated
  using (true)
  with check (true);

create policy "conectados_transferencias_select_auth"
  on public.conectados_transferencias for select
  to authenticated
  using (true);

create policy "conectados_transferencias_insert_auth"
  on public.conectados_transferencias for insert
  to authenticated
  with check (true);

insert into public.conectados_grupos (nome, genero, responsavel, cor_nome, cor_hex)
values
  ('AZULETES', 'meninas', 'Vick', 'Azul', '#2F80ED'),
  ('LARAMORA', 'meninas', 'Andressa', 'Vermelho', '#FF232A'),
  ('PINKIES', 'meninas', 'Heloísa', 'Rosa', '#BC0086'),
  ('CONECTHANOS', 'meninos', 'Dedé', 'Roxo', '#7B2CBF'),
  ('GRÃO DE MOSTARDA', 'meninos', 'Gabriel', 'Amarelo', '#FFCA46'),
  ('PLUGADOS', 'meninos', 'Breno', 'Preto', '#212740')
on conflict (nome) do update set
  genero = excluded.genero,
  responsavel = excluded.responsavel,
  cor_nome = excluded.cor_nome,
  cor_hex = excluded.cor_hex,
  ativo = true;
