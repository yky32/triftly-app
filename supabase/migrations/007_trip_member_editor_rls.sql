-- P3: Editor co-edit writes + member role / leave management.

create or replace function public.user_is_trip_editor(p_trip_id uuid, p_user_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from trips t
    where t.id = p_trip_id and t.owner_id = p_user_id and t.is_active = true
  )
  or exists (
    select 1 from trip_members tm
    where tm.trip_id = p_trip_id
      and tm.user_id = p_user_id
      and tm.role = 'editor'
  );
$$;

-- Re-join must not downgrade editor → viewer.
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
  on conflict (trip_id, user_id) do nothing;

  return v_trip_id;
end;
$$;

create or replace function public.leave_trip_share(p_trip_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if exists (select 1 from trips where id = p_trip_id and owner_id = v_user_id) then
    return false;
  end if;

  delete from trip_members
  where trip_id = p_trip_id and user_id = v_user_id;

  return found;
end;
$$;

revoke all on function public.leave_trip_share(uuid) from public;
grant execute on function public.leave_trip_share(uuid) to authenticated;

create or replace function public.set_trip_member_role(
  p_trip_id uuid,
  p_member_user_id uuid,
  p_role text
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  if p_role not in ('viewer', 'editor') then
    raise exception 'invalid role';
  end if;

  if not exists (
    select 1 from trips where id = p_trip_id and owner_id = auth.uid() and is_active = true
  ) then
    return false;
  end if;

  update trip_members
  set role = p_role
  where trip_id = p_trip_id and user_id = p_member_user_id and role <> 'owner';

  return found;
end;
$$;

revoke all on function public.set_trip_member_role(uuid, uuid, text) from public;
grant execute on function public.set_trip_member_role(uuid, uuid, text) to authenticated;

-- Editor write on trip content (owners already have *_owner policies).
create policy "trip_days_editor_write" on trip_days
  for all using (public.user_is_trip_editor(trip_id, auth.uid()))
  with check (public.user_is_trip_editor(trip_id, auth.uid()));

create policy "spots_editor_write" on spots
  for all using (public.user_is_trip_editor(trip_id, auth.uid()))
  with check (public.user_is_trip_editor(trip_id, auth.uid()));

create policy "expenses_editor_write" on expenses
  for all using (public.user_is_trip_editor(trip_id, auth.uid()))
  with check (public.user_is_trip_editor(trip_id, auth.uid()));

create policy "expense_splits_editor_write" on expense_splits
  for all using (
    exists (
      select 1 from expenses e
      where e.id = expense_splits.expense_id
        and public.user_is_trip_editor(e.trip_id, auth.uid())
    )
  )
  with check (
    exists (
      select 1 from expenses e
      where e.id = expense_splits.expense_id
        and public.user_is_trip_editor(e.trip_id, auth.uid())
    )
  );

create policy "settlements_editor_write" on settlement_records
  for all using (public.user_is_trip_editor(trip_id, auth.uid()))
  with check (public.user_is_trip_editor(trip_id, auth.uid()));
