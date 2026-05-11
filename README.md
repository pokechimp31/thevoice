# The Voice @ The Pennington School
A modern, admin-editable school newsletter web app.

## 🗂 Project structure

```
the-voice/
├── index.html              ← Public-facing Voice page
├── admin.html              ← Admin editor (login via Netlify Identity)
├── schema.sql              ← Supabase database setup (run once)
├── netlify.toml            ← Netlify configuration
└── netlify/
    └── functions/
        └── update.js       ← Serverless function (holds secret keys server-side)
```

## 🔐 Security model

| What | Where it lives | Safe? |
|---|---|---|
| SUPABASE_ANON_KEY | index.html + admin.html | Yes - designed to be public; RLS limits it to reads |
| SUPABASE_URL | index.html + admin.html | Yes - public |
| SUPABASE_SERVICE_KEY | Netlify environment variable only | Yes - never touches the browser |
| Admin login | Netlify Identity (hashed, managed) | Yes - no password in code |

---

## 🚀 Deployment guide

### Step 1 — Create a Supabase project (5 min)

1. Go to supabase.com, sign up, click New project
2. Name it the-voice, choose US East region, click Create
3. Wait ~2 minutes
4. Go to Project Settings → API and copy:
   - Project URL (https://xyzxyz.supabase.co)
   - anon / public key (starts with eyJ...)
   - service_role key (keep this secret!)

---

### Step 2 — Run the database schema (2 min)

1. In Supabase → SQL Editor → New query
2. Open schema.sql, copy everything, paste in, click Run
3. You should see "Success. No rows returned."

---

### Step 3 — Add your public keys to the HTML files (2 min)

Open index.html and admin.html in a text editor.
In both files, find these lines near the bottom and replace:

  const SUPABASE_URL      = 'YOUR_SUPABASE_URL';
  const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';

The anon key is safe to put here - it is read-only by design.

---

### Step 4 — Deploy to Netlify (5 min)

1. Go to netlify.com, sign up
2. Drag your entire project folder onto the deploy box on the dashboard
3. Wait ~10 seconds for your live URL

---

### Step 5 — Add secret keys as environment variables (3 min)

This keeps the service key off your HTML files entirely.

1. In Netlify → your site → Site configuration → Environment variables
2. Click Add a variable and add these two:

   SUPABASE_URL          your Supabase project URL
   SUPABASE_SERVICE_KEY  your Supabase service_role key

3. Click Save, then go to Deploys → Trigger deploy → Deploy site

---

### Step 6 — Enable Netlify Identity and invite yourself (3 min)

1. In Netlify → your site → Identity tab → click Enable Identity
2. Under Registration, set it to Invite only (blocks public signups)
3. Click Invite users, enter your email, click Send
4. Check your email and click the invite link to set your password
5. You can now log into your-site.netlify.app/admin.html

To add more admins later, invite more emails from the Identity tab.

---

### Step 7 — Keep Supabase awake (free tier)

Free Supabase projects pause after 7 days of no activity.

1. Go to cron-job.org, create a free account
2. Add your Netlify URL, set it to run every 3 days
3. Done

---

## Updating The Voice each week

1. Go to your-site.netlify.app/admin.html
2. Log in with your email and password
3. Update issue info, toggle the alert, edit deadlines and stories
4. Click Save all changes - public page updates instantly

---

## Troubleshooting

Public page shows "Could not load content"
  → Check SUPABASE_URL and SUPABASE_ANON_KEY in index.html

Admin save returns 401
  → Make sure you are logged in via Netlify Identity

Admin save returns 500
  → Check SUPABASE_URL and SUPABASE_SERVICE_KEY in Netlify env vars

Identity login button does nothing
  → Make sure Identity is enabled in the Netlify dashboard

Site loads slowly on first visit
  → Supabase may have paused - set up cron-job.org pinger (Step 7)
