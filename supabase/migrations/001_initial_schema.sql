-- Triftly initial schema (Supabase Postgres + RLS)

create table if not exists users (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  email text,
  default_currency text not null default 'HKD',
  locale text not null default 'en',
  updated_at timestamptz not null default now()
);

create table if not exists trips (
  id uuid primary key,
  owner_id uuid references users(id),
  name text not null,
  destination text not null,
  start_date date not null,
  end_date date not null,
  default_currency text not null,
  share_token text unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create table if not exists trip_members (
  trip_id uuid references trips(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  role text not null check (role in ('owner', 'editor', 'viewer')),
  primary key (trip_id, user_id)
);

create table if not exists trip_days (
  id text primary key,
  trip_id uuid references trips(id) on delete cascade,
  day_number int not null,
  title text,
  date date not null
);

create table if not exists buddies (
  id uuid primary key,
  trip_id uuid references trips(id) on delete cascade,
  name text not null,
  avatar_color text,
  user_id uuid references users(id),
  is_me boolean not null default false
);

create table if not exists spots (
  id uuid primary key,
  trip_id uuid references trips(id) on delete cascade,
  day_id text references trip_days(id) on delete cascade,
  name text not null,
  is_active boolean not null default true,
  updated_at timestamptz
);

create table if not exists expenses (
  id uuid primary key,
  trip_id uuid references trips(id) on delete cascade,
  title text not null,
  amount numeric not null,
  currency text not null,
  is_active boolean not null default true,
  updated_at timestamptz
);

create table if not exists expense_splits (
  id uuid primary key,
  expense_id uuid references expenses(id) on delete cascade,
  buddy_id uuid references buddies(id) on delete cascade,
  share_amount numeric not null
);

create table if not exists settlement_records (
  id uuid primary key,
  trip_id uuid references trips(id) on delete cascade,
  from_buddy_id uuid references buddies(id),
  to_buddy_id uuid references buddies(id),
  amount numeric not null,
  currency text not null,
  paid_at timestamptz not null,
  is_active boolean not null default true
);

alter table users enable row level security;
alter table trips enable row level security;
alter table trip_members enable row level security;

create policy "users_self" on users
  for all using (auth.uid() = id);

create policy "trips_owner" on trips
  for all using (auth.uid() = owner_id);

create policy "trip_members_read" on trip_members
  for select using (auth.uid() = user_id);
