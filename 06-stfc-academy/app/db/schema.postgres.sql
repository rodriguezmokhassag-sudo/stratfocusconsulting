-- STFC Academy : schéma PostgreSQL / Supabase (production).
-- Mêmes tables et colonnes que schema.sql. À exécuter dans l'éditeur SQL de Supabase.
-- Les dates sont stockées en timestamptz ; l'application les manipule en ISO 8601.

create table if not exists users (
  id            bigserial primary key,
  email         text not null unique,
  phone         text,
  password_hash text not null,
  full_name     text not null,
  country       text,
  role          text not null default 'learner' check (role in ('learner','trainer','admin')),
  disabled      integer not null default 0,
  created_at    timestamptz not null default now(),
  last_seen_at  timestamptz
);

create table if not exists sessions (
  token_hash text primary key,
  user_id    bigint not null references users(id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null
);

create table if not exists modules (
  id         text primary key,
  track_id   text not null,
  position   integer not null,
  title      text not null,
  status     text not null default 'complet',
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by bigint
);

create table if not exists progress (
  user_id      bigint not null references users(id) on delete cascade,
  module_id    text not null,
  lesson_index integer not null,
  completed_at timestamptz not null default now(),
  primary key (user_id, module_id, lesson_index)
);

create table if not exists quiz_attempts (
  id         bigserial primary key,
  user_id    bigint not null references users(id) on delete cascade,
  module_id  text not null,
  score      integer not null,
  passed     integer not null,
  answers    jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists entitlements (
  id         bigserial primary key,
  user_id    bigint not null references users(id) on delete cascade,
  scope      text not null,
  source     text not null,
  ref        text,
  starts_at  timestamptz not null default now(),
  expires_at timestamptz
);

create table if not exists payments (
  id             bigserial primary key,
  user_id        bigint not null references users(id),
  transaction_id text not null unique,
  product        text not null,
  plan           text not null default 'full',
  amount         integer not null,
  currency       text not null,
  amount_xof     integer not null,
  zone           text not null,
  provider       text not null,
  status         text not null default 'pending',
  method         text,
  raw            jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create table if not exists access_codes (
  code_hash  text primary key,
  scope      text not null,
  label      text,
  max_uses   integer not null default 1,
  uses       integer not null default 0,
  days       integer,
  created_by bigint,
  created_at timestamptz not null default now()
);

create table if not exists code_redemptions (
  code_hash   text not null,
  user_id     bigint not null references users(id) on delete cascade,
  redeemed_at timestamptz not null default now(),
  primary key (code_hash, user_id)
);

create table if not exists certificates (
  ref       text primary key,
  user_id   bigint not null references users(id) on delete cascade,
  kind      text not null,
  target_id text not null,
  full_name text not null,
  title     text not null,
  score     integer,
  issued_at timestamptz not null default now(),
  unique (user_id, kind, target_id)
);

create table if not exists assessments (
  id         bigserial primary key,
  user_id    bigint references users(id) on delete set null,
  score      integer not null,
  level      text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_progress_user on progress(user_id);
create index if not exists idx_attempts_user on quiz_attempts(user_id, module_id);
create index if not exists idx_entitlements_user on entitlements(user_id);
create index if not exists idx_payments_user on payments(user_id);
create index if not exists idx_sessions_user on sessions(user_id);

-- Le serveur Node accède à la base avec la clé service (côté serveur uniquement).
-- Activer RLS sans politique publique empêche tout accès direct depuis le navigateur.
alter table users enable row level security;
alter table sessions enable row level security;
alter table modules enable row level security;
alter table progress enable row level security;
alter table quiz_attempts enable row level security;
alter table entitlements enable row level security;
alter table payments enable row level security;
alter table access_codes enable row level security;
alter table code_redemptions enable row level security;
alter table certificates enable row level security;
alter table assessments enable row level security;
