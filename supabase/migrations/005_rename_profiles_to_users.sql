-- Run only if you already applied an older schema that used public.profiles.
-- Fresh installs: use 001 with public.users directly — skip this file.

do $$
begin
  if to_regclass('public.profiles') is not null
     and to_regclass('public.users') is null then
    alter table public.profiles rename to users;
  end if;
end $$;

drop policy if exists "profiles_self" on public.users;

create policy "users_self" on public.users
  for all using (auth.uid() = id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, display_name, email, updated_at)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'display_name',
      split_part(coalesce(new.email, ''), '@', 1),
      'Traveler'
    ),
    new.email,
    now()
  )
  on conflict (id) do update set
    email = excluded.email,
    updated_at = now();
  return new;
end;
$$;
