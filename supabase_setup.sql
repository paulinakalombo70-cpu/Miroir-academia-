-- MIROIR ACADEMIA : à exécuter dans Supabase > SQL Editor.
create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  image_url text,
  published boolean not null default false,
  author_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.articles enable row level security;

-- Tout le monde peut lire uniquement les articles publiés.
drop policy if exists "Public can read published articles" on public.articles;
create policy "Public can read published articles"
on public.articles for select
using (published = true or auth.uid() = author_id);

-- Un utilisateur connecté ne peut gérer que ses propres articles.
drop policy if exists "Authors can insert own articles" on public.articles;
create policy "Authors can insert own articles"
on public.articles for insert to authenticated
with check (auth.uid() = author_id);

drop policy if exists "Authors can update own articles" on public.articles;
create policy "Authors can update own articles"
on public.articles for update to authenticated
using (auth.uid() = author_id)
with check (auth.uid() = author_id);

drop policy if exists "Authors can delete own articles" on public.articles;
create policy "Authors can delete own articles"
on public.articles for delete to authenticated
using (auth.uid() = author_id);
