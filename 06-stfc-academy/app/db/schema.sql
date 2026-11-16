-- STFC Academy : schéma SQLite (développement).
-- Voir schema.postgres.sql pour la version PostgreSQL / Supabase (mêmes tables, mêmes colonnes).

CREATE TABLE IF NOT EXISTS users (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  email         TEXT NOT NULL UNIQUE,
  phone         TEXT,
  password_hash TEXT NOT NULL,
  full_name     TEXT NOT NULL,
  country       TEXT,
  role          TEXT NOT NULL DEFAULT 'learner' CHECK (role IN ('learner','trainer','admin')),
  disabled      INTEGER NOT NULL DEFAULT 0,
  created_at    TEXT NOT NULL,
  last_seen_at  TEXT
);

CREATE TABLE IF NOT EXISTS sessions (
  token_hash TEXT PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TEXT NOT NULL,
  expires_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS modules (
  id         TEXT PRIMARY KEY,
  track_id   TEXT NOT NULL,
  position   INTEGER NOT NULL,
  title      TEXT NOT NULL,
  status     TEXT NOT NULL DEFAULT 'complet',
  data       TEXT NOT NULL,           -- JSON : objectifs, vidéo, leçons, quiz, livrable…
  updated_at TEXT NOT NULL,
  updated_by INTEGER
);

CREATE TABLE IF NOT EXISTS progress (
  user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  module_id    TEXT NOT NULL,
  lesson_index INTEGER NOT NULL,
  completed_at TEXT NOT NULL,
  PRIMARY KEY (user_id, module_id, lesson_index)
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  module_id  TEXT NOT NULL,
  score      INTEGER NOT NULL,
  passed     INTEGER NOT NULL,
  answers    TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS entitlements (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  scope      TEXT NOT NULL,            -- 'all' ou 'track:<id>'
  source     TEXT NOT NULL,            -- payment | code | admin
  ref        TEXT,
  starts_at  TEXT NOT NULL,
  expires_at TEXT                      -- NULL = à vie
);

CREATE TABLE IF NOT EXISTS payments (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id        INTEGER NOT NULL REFERENCES users(id),
  transaction_id TEXT NOT NULL UNIQUE,
  product        TEXT NOT NULL,
  plan           TEXT NOT NULL DEFAULT 'full', -- full | x3 (paiement en 3 fois)
  amount         INTEGER NOT NULL,
  currency       TEXT NOT NULL,
  amount_xof     INTEGER NOT NULL,
  zone           TEXT NOT NULL,
  provider       TEXT NOT NULL,               -- cinetpay | simulation
  status         TEXT NOT NULL DEFAULT 'pending', -- pending | accepted | refused
  method         TEXT,
  raw            TEXT,
  created_at     TEXT NOT NULL,
  updated_at     TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS access_codes (
  code_hash  TEXT PRIMARY KEY,
  scope      TEXT NOT NULL,
  label      TEXT,
  max_uses   INTEGER NOT NULL DEFAULT 1,
  uses       INTEGER NOT NULL DEFAULT 0,
  days       INTEGER,                  -- NULL = à vie
  created_by INTEGER,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS code_redemptions (
  code_hash   TEXT NOT NULL,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  redeemed_at TEXT NOT NULL,
  PRIMARY KEY (code_hash, user_id)
);

CREATE TABLE IF NOT EXISTS certificates (
  ref       TEXT PRIMARY KEY,
  user_id   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kind      TEXT NOT NULL,             -- module | track
  target_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  title     TEXT NOT NULL,
  score     INTEGER,
  issued_at TEXT NOT NULL,
  UNIQUE (user_id, kind, target_id)
);

CREATE TABLE IF NOT EXISTS assessments (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER REFERENCES users(id) ON DELETE SET NULL,
  score      INTEGER NOT NULL,
  level      TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_progress_user ON progress(user_id);
CREATE INDEX IF NOT EXISTS idx_attempts_user ON quiz_attempts(user_id, module_id);
CREATE INDEX IF NOT EXISTS idx_entitlements_user ON entitlements(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
