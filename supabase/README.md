# Supabase Edge Functions Deployment Notes

These Edge Functions replace Firebase Cloud Functions in the Free Stack Architecture.

## Prerequisites
1. Install Supabase CLI: `npm install -g supabase`
2. Login: `supabase login`
3. Initialize (if not already): `supabase init`
4. Create a project on [supabase.com](https://supabase.com) if you haven't. Link it: `supabase link --project-ref YOUR_PROJECT_REF`

## Secrets Configuration
Before deploying, you must configure the following secrets via the CLI:

```bash
# 1. Firebase Service Account JSON (compacted to single line)
supabase secrets set FIREBASE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"...}'

# 2. Shared secret for GitHub Actions to authenticate with Edge Functions
supabase secrets set SUPABASE_FUNCTION_SECRET='your_secure_random_string'
```

## Deployment
Deploy all functions:
```bash
supabase functions deploy send-notification --no-verify-jwt
supabase functions deploy recompute-leaderboard --no-verify-jwt
supabase functions deploy daily-notification-check --no-verify-jwt
```
*Note: `--no-verify-jwt` is used because we handle custom authentication (Firebase tokens and GitHub Actions shared secrets) inside the functions, instead of relying on Supabase Auth.*

## GitHub Actions Configuration
In your GitHub repository settings:
1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Add a new Repository Secret named `SUPABASE_FUNCTION_SECRET` with the same string you set in Supabase.
3. Update the `https://your-project.supabase.co/functions/v1/...` URLs in `.github/workflows/*.yml` with your actual Supabase project URL.
