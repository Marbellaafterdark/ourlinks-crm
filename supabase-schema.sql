-- Выполните скрипт в Supabase: SQL Editor → New query → Run.
-- Одна строка хранит всю CRM одного вошедшего пользователя.

create table if not exists public.crm_states (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{"users":[],"projects":[],"activeId":null}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.crm_states enable row level security;

-- Права Data API выдаются только вошедшим пользователям.
grant usage on schema public to authenticated;
grant select, insert, update on table public.crm_states to authenticated;

drop policy if exists "crm owner reads own state" on public.crm_states;
create policy "crm owner reads own state"
on public.crm_states for select
to authenticated
using ((select auth.uid()) = owner_id);

drop policy if exists "crm owner creates own state" on public.crm_states;
create policy "crm owner creates own state"
on public.crm_states for insert
to authenticated
with check ((select auth.uid()) = owner_id);

drop policy if exists "crm owner updates own state" on public.crm_states;
create policy "crm owner updates own state"
on public.crm_states for update
to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);
