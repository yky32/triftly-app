-- Read-only shared trip bundle for /s/:token (anon-safe via security definer).

create or replace function public.get_shared_trip_bundle(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trip trips%rowtype;
begin
  select * into v_trip
  from trips
  where share_token = p_token and is_active = true
  limit 1;

  if v_trip.id is null then
    return null;
  end if;

  return jsonb_build_object(
    'trip', to_jsonb(v_trip),
    'buddies', coalesce(
      (select jsonb_agg(to_jsonb(b) order by b.name)
       from buddies b where b.trip_id = v_trip.id),
      '[]'::jsonb
    ),
    'days', coalesce(
      (select jsonb_agg(to_jsonb(d) order by d.day_number)
       from trip_days d where d.trip_id = v_trip.id),
      '[]'::jsonb
    ),
    'spots', coalesce(
      (select jsonb_agg(to_jsonb(s) order by s.order_index)
       from spots s where s.trip_id = v_trip.id and s.is_active = true),
      '[]'::jsonb
    ),
    'expenses', coalesce(
      (select jsonb_agg(
         to_jsonb(e) || jsonb_build_object(
           'splits',
           coalesce(
             (select jsonb_agg(to_jsonb(es))
              from expense_splits es where es.expense_id = e.id),
             '[]'::jsonb
           )
         )
       )
       from expenses e
       where e.trip_id = v_trip.id and e.is_active = true),
      '[]'::jsonb
    ),
    'settlements', coalesce(
      (select jsonb_agg(to_jsonb(r) order by r.paid_at)
       from settlement_records r
       where r.trip_id = v_trip.id and r.is_active = true),
      '[]'::jsonb
    )
  );
end;
$$;

revoke all on function public.get_shared_trip_bundle(text) from public;
grant execute on function public.get_shared_trip_bundle(text) to anon, authenticated;
