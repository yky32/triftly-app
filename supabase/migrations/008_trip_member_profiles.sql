-- Owner / members can list joined accounts with display name + email (users RLS is self-only).

create or replace function public.get_trip_member_profiles(p_trip_id uuid)
returns jsonb
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

  if not exists (
    select 1 from trips t
    where t.id = p_trip_id and t.is_active = true
      and (t.owner_id = v_user_id or public.user_is_trip_member(p_trip_id, v_user_id))
  ) then
    return '[]'::jsonb;
  end if;

  return coalesce(
    (
      select jsonb_agg(
        jsonb_build_object(
          'user_id', tm.user_id,
          'role', tm.role,
          'display_name', u.display_name,
          'email', u.email
        )
        order by tm.role desc, u.display_name
      )
      from trip_members tm
      join users u on u.id = tm.user_id
      where tm.trip_id = p_trip_id
        and tm.role in ('viewer', 'editor')
    ),
    '[]'::jsonb
  );
end;
$$;

revoke all on function public.get_trip_member_profiles(uuid) from public;
grant execute on function public.get_trip_member_profiles(uuid) to authenticated;
