-- Join via share link: trip_members + member read RLS.

create or replace function public.user_is_trip_member(p_trip_id uuid, p_user_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from trip_members tm
    where tm.trip_id = p_trip_id and tm.user_id = p_user_id
  );
$$;

create or replace function public.accept_trip_share(p_token text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trip_id uuid;
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  select id into v_trip_id
  from trips
  where share_token = p_token and is_active = true
  limit 1;

  if v_trip_id is null then
    return null;
  end if;

  if exists (select 1 from trips where id = v_trip_id and owner_id = v_user_id) then
    return v_trip_id;
  end if;

  insert into trip_members (trip_id, user_id, role)
  values (v_trip_id, v_user_id, 'viewer')
  on conflict (trip_id, user_id) do update set role = excluded.role;

  return v_trip_id;
end;
$$;

revoke all on function public.accept_trip_share(text) from public;
grant execute on function public.accept_trip_share(text) to authenticated;

-- Members can read trips they joined (owners already covered by trips_owner).
create policy "trips_member_read" on trips
  for select using (
    public.user_is_trip_member(id, auth.uid())
  );

create policy "trip_days_member_read" on trip_days
  for select using (
    public.user_is_trip_member(trip_id, auth.uid())
  );

create policy "buddies_member_read" on buddies
  for select using (
    public.user_is_trip_member(trip_id, auth.uid())
  );

create policy "spots_member_read" on spots
  for select using (
    public.user_is_trip_member(trip_id, auth.uid())
  );

create policy "expenses_member_read" on expenses
  for select using (
    public.user_is_trip_member(trip_id, auth.uid())
  );

create policy "expense_splits_member_read" on expense_splits
  for select using (
    exists (
      select 1 from expenses e
      where e.id = expense_splits.expense_id
        and public.user_is_trip_member(e.trip_id, auth.uid())
    )
  );

create policy "settlements_member_read" on settlement_records
  for select using (
    public.user_is_trip_member(trip_id, auth.uid())
  );
