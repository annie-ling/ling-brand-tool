-- LING V10 member license database
-- Run this entire file in Supabase > SQL Editor.

create table if not exists public.ling_licenses (
  code text primary key,
  status text not null default 'active' check (status in ('active','revoked')),
  device_id text,
  customer_name text,
  customer_note text,
  created_at timestamptz not null default now(),
  activated_at timestamptz,
  last_seen_at timestamptz
);

alter table public.ling_licenses enable row level security;

revoke all on table public.ling_licenses from anon, authenticated;

create or replace function public.claim_ling_license(p_code text, p_device_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  rec public.ling_licenses%rowtype;
begin
  select * into rec
  from public.ling_licenses
  where upper(code)=upper(trim(p_code));

  if not found then
    return jsonb_build_object('ok',false,'message','找不到這組序號');
  end if;

  if rec.status <> 'active' then
    return jsonb_build_object('ok',false,'message','這組序號目前已停用');
  end if;

  if rec.device_id is null then
    update public.ling_licenses
    set device_id=p_device_id,
        activated_at=coalesce(activated_at,now()),
        last_seen_at=now()
    where code=rec.code;
    return jsonb_build_object('ok',true,'message','啟用成功');
  end if;

  if rec.device_id = p_device_id then
    update public.ling_licenses set last_seen_at=now() where code=rec.code;
    return jsonb_build_object('ok',true,'message','驗證成功');
  end if;

  return jsonb_build_object('ok',false,'message','此序號已綁定其他裝置');
end;
$$;

create or replace function public.validate_ling_license(p_code text, p_device_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  rec public.ling_licenses%rowtype;
begin
  select * into rec
  from public.ling_licenses
  where upper(code)=upper(trim(p_code));

  if not found or rec.status <> 'active' or rec.device_id is distinct from p_device_id then
    return jsonb_build_object('ok',false);
  end if;

  update public.ling_licenses set last_seen_at=now() where code=rec.code;
  return jsonb_build_object('ok',true);
end;
$$;

grant execute on function public.claim_ling_license(text,text) to anon;
grant execute on function public.validate_ling_license(text,text) to anon;

-- Example: create your first license codes.
insert into public.ling_licenses(code) values
('LING-899-A001'),
('LING-899-A002'),
('LING-899-A003'),
('LING-899-A004'),
('LING-899-A005')
on conflict (code) do nothing;

-- To disable a customer's code:
-- update public.ling_licenses set status='revoked' where code='LING-899-A001';

-- To let the same customer move to a new device:
-- update public.ling_licenses set device_id=null where code='LING-899-A001';
