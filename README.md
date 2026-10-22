# FantasyChampions v3

A responsive React/Vite fantasy football site with public dynasty/redraft rankings, drag-and-drop reordering, player profiles, editorial articles, a content studio, optional Supabase admin authentication/database, and a Sleeper NFL player catalog via a Vercel serverless proxy.

## Quick start

1. Install Node.js 20+.
2. Run `npm install` then `npm run dev`.
3. Open the local address printed by Vite.
4. Without Supabase, **local demo mode** is active. The Studio is editable by anyone using that browser; data is stored only in localStorage. It is **not secure for public publishing**. Export JSON backups from Studio.

## Public launch / secure admin

1. Create a [Supabase](https://supabase.com) project.
2. In SQL Editor run `supabase/schema.sql` **once on a fresh project**. If re-running on an existing database, review duplicate policy statements first.
3. In Authentication settings, disable public signup if you want an invite-only admin site. Create your admin user via Supabase Authentication (Dashboard > Users > Add user). Set a strong password.
4. Copy `.env.example` to `.env.local`, add the **project URL** and **publishable/anon key**. Never put a service-role or secret key in client environment variables.
5. Get the admin user's UUID from Authentication > Users. In Supabase SQL Editor run `insert into public.admins (user_id) values ('YOUR-AUTH-USER-UUID');`. Only trusted administrators should be added.
6. Deploy this project on [Vercel](https://vercel.com) (import a Git repository). Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in the Vercel project environment variables and redeploy.
7. Add your deployed domain to Supabase Auth URL configuration, and test login, publish, and public read access in a private browser window.
8. Connect a custom domain through Vercel when ready.

## Player feed

`GET /api/players` is a Vercel serverless route that fetches Sleeper's public NFL player dictionary, filters to QB/RB/WR/TE, and returns a normalized roster. It caches at the CDN for six hours. It is not a real-time stats, injury, or depth-chart service. Player identity, team and status can be inaccurate or delayed upstream. In local `npm run dev`, the endpoint isn't served by Vite; the UI gracefully uses its built-in starter catalog. To test the feed locally, install the Vercel CLI and use `vercel dev` or deploy to Vercel.

The built-in sample rankings are **illustrative only** and must not be presented as the owner's opinions. Once a Sleeper roster is loaded, players without published ranks are appended automatically. A full catalog may contain thousands of records; the table renders at most 400 matching rows. Filter by position or search to find players.

## Editing and persistence

- In cloud mode, only users in `public.admins` may modify rankings, notes or articles; Supabase row-level security enforces this.
- Rankings are edited locally in the browser and **published** when the admin clicks Publish ranks. Each format is saved separately.
- Articles can be drafts or published; visitors only see published articles.
- Player profile notes are saved individually.
- JSON export backs up currently loaded state. Cloud import is intentionally disabled; use admin UI.
- `localStorage` is not a production database; public visitors need Supabase configured for shared content.

## Important limitations / next steps

- This is a working deployment-ready **starter**, not a fully managed production service. Configure and test Supabase and Vercel yourself.
- The default sample article is only a placeholder. Remove or replace it before launch.
- The current UI doesn't support rich-text article formatting, multi-admin role management, full-text indexing, projections, or automated statistics.
- Sleeper IDs in the offline starter dataset are examples; use the synced player catalog for authoritative IDs. Publishing ranks against the starter dataset before the first sync can create mismatched IDs; sync first.
- For very large player datasets, add virtual scrolling and paginated catalog search for better performance.
- The player catalog endpoint depends on Sleeper's API availability and terms.

## Files

- `src/main.jsx`: site UI, ranking drag-and-drop, admin editor, Supabase integration.
- `src/style.css`: responsive dark/neon styling.
- `src/data.js`: offline starter catalog and sample article.
- `api/players.js`: serverless NFL player catalog proxy.
- `supabase/schema.sql`: database tables and RLS permissions.
- `.env.example`: environment variable template.
