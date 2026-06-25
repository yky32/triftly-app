-- Extend schema for full trip detail sync + child-table RLS

alter table trips add column if not exists outbound_flight jsonb;
alter table trips add column if not exists return_flight jsonb;

alter table spots add column if not exists address text;
alter table spots add column if not exists area text;
alter table spots add column if not exists category text not null default 'other';
alter table spots add column if not exists opening_hours text;
alter table spots add column if not exists estimated_duration text;
alter table spots add column if not exists estimated_cost numeric;
alter table spots add column if not exists cost_currency text;
alter table spots add column if not exists latitude double precision;
alter table spots add column if not exists longitude double precision;
alter table spots add column if not exists notes text;
alter table spots add column if not exists order_index int not null default 0;
alter table spots add column if not exists visited boolean not null default false;

alter table expenses add column if not exists day_id text;
alter table expenses add column if not exists paid_by_id uuid references buddies(id);
alter table expenses add column if not exists category text not null default 'other';
alter table expenses add column if not exists created_at timestamptz not null default now();

alter table expense_splits add column if not exists split_type text not null default 'equal';
alter table expense_splits add column if not exists split_config_value numeric;

alter table trip_days enable row level security;
alter table buddies enable row level security;
alter table spots enable row level security;
alter table expenses enable row level security;
alter table expense_splits enable row level security;
alter table settlement_records enable row level security;

create policy "trip_members_owner" on trip_members
  for all using (
    exists (
      select 1 from trips t
      where t.id = trip_members.trip_id and t.owner_id = auth.uid()
    )
  );

create policy "trip_days_owner" on trip_days
  for all using (
    exists (
      select 1 from trips t
      where t.id = trip_days.trip_id and t.owner_id = auth.uid()
    )
  );

create policy "buddies_owner" on buddies
  for all using (
    exists (
      select 1 from trips t
      where t.id = buddies.trip_id and t.owner_id = auth.uid()
    )
  );

create policy "spots_owner" on spots
  for all using (
    exists (
      select 1 from trips t
      where t.id = spots.trip_id and t.owner_id = auth.uid()
    )
  );

create policy "expenses_owner" on expenses
  for all using (
    exists (
      select 1 from trips t
      where t.id = expenses.trip_id and t.owner_id = auth.uid()
    )
  );

create policy "expense_splits_owner" on expense_splits
  for all using (
    exists (
      select 1 from expenses e
      join trips t on t.id = e.trip_id
      where e.id = expense_splits.expense_id and t.owner_id = auth.uid()
    )
  );

create policy "settlements_owner" on settlement_records
  for all using (
    exists (
      select 1 from trips t
      where t.id = settlement_records.trip_id and t.owner_id = auth.uid()
    )
  );
