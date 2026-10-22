-- Run in Supabase SQL Editor. Add your own auth user UUID to public.admins after signup.
create table if not exists public.admins (user_id uuid primary key references auth.users(id) on delete cascade);
create table if not exists public.rankings (
  format text not null check(format in ('dynasty','redraft')),
  player_id text not null,
  rank integer not null check(rank > 0),
  tier integer not null default 1,
  note text not null default '',
  updated_at timestamptz not null default now(),
  primary key(format,player_id)
);
create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null default 'Opinion',
  excerpt text not null default '',
  body text not null default '',
  published boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.player_notes (
  player_id text primary key,
  outlook text not null default '',
  updated_at timestamptz not null default now()
);
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = public as $$ select exists(select 1 from public.admins where user_id = auth.uid()) $$;
alter table public.admins enable row level security;
alter table public.rankings enable row level security;
alter table public.articles enable row level security;
alter table public.player_notes enable row level security;
create policy "Admins read own" on public.admins for select to authenticated using (user_id=auth.uid());
create policy "Public rankings" on public.rankings for select to anon,authenticated using(true);
create policy "Admin rankings insert" on public.rankings for insert to authenticated with check(public.is_admin());
create policy "Admin rankings update" on public.rankings for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "Admin rankings delete" on public.rankings for delete to authenticated using(public.is_admin());
create policy "Public published articles" on public.articles for select to anon,authenticated using(published or public.is_admin());
create policy "Admin articles insert" on public.articles for insert to authenticated with check(public.is_admin());
create policy "Admin articles update" on public.articles for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "Admin articles delete" on public.articles for delete to authenticated using(public.is_admin());
create policy "Public player notes" on public.player_notes for select to anon,authenticated using(true);
create policy "Admin notes insert" on public.player_notes for insert to authenticated with check(public.is_admin());
create policy "Admin notes update" on public.player_notes for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "Admin notes delete" on public.player_notes for delete to authenticated using(public.is_admin());
