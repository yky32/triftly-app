-- Auto-add a plan buddy when someone joins via share link.

create or replace function public.accept_trip_share(p_token text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trip_id uuid;
  v_user_id uuid := auth.uid();
  v_display_name text;
  v_avatar_colors text[] := array[
    'FF6B6B', '4ECDC4', '45B7D1', '96CEB4',
    'FFEAA7', 'DDA0DD', '74B9FF', 'A29BFE'
  ];
  v_avatar_color text;
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

  if not exists (
    select 1 from buddies b
    where b.trip_id = v_trip_id and b.user_id = v_user_id
  ) then
    select coalesce(
      nullif(trim(u.display_name), ''),
      nullif(split_part(u.email, '@', 1), ''),
      'Traveler'
    )
    into v_display_name
    from users u
    where u.id = v_user_id;

    v_avatar_color := v_avatar_colors[
      1 + (abs(hashtext(v_user_id::text)) % array_length(v_avatar_colors, 1))
    ];

    insert into buddies (id, trip_id, name, avatar_color, user_id, is_me)
    values (gen_random_uuid(), v_trip_id, v_display_name, v_avatar_color, v_user_id, false);
  end if;

  update trips
  set updated_at = now()
  where id = v_trip_id;

  return v_trip_id;
end;
$$;
