# 💜 Family Budget Tracker

Bob & Elle's 2026 budget tracker with Supabase backend.

## Setup Instructions

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com) and create a free account
2. Click **New Project** → name it "family-budget" → set a database password → create
3. Wait for it to provision (~2 minutes)

### 2. Run the Schema
1. In your Supabase dashboard, go to **SQL Editor**
2. Click **New Query**
3. Paste the entire contents of `schema.sql`
4. Click **Run** (ignore any warnings about realtime — those are fine)

### 3. Get Your API Keys
1. Go to **Project Settings** → **API**
2. Copy the **Project URL** (looks like `https://xxxxx.supabase.co`)
3. Copy the **anon/public** key (starts with `eyJ...`)

### 4. Deploy to GitHub Pages
```bash
# Create repo on GitHub: misterb0b/family-budget
# Then:
cd family-budget-app
git init
git add .
git commit -m "Family budget tracker"
git remote add origin https://github.com/misterb0b/family-budget.git
git push -u origin main
```
Then in GitHub repo → Settings → Pages → Source: main branch → Save.

Your app will be at: `https://misterb0b.github.io/family-budget/`

### 5. First Login
1. Open the app URL
2. Enter your Supabase URL and anon key when prompted (one-time setup, saved in browser)
3. Click "Sign Up" to create accounts for Bob and Elle
4. After signing in, go to Settings → "Seed Default Categories" to get starter categories

### 6. Set Up Recurring Bills
Go to the Recurring tab and add your monthly bills:
- Mortgage, car payments, insurance, subscriptions, etc.
- Each month, go to Settings → "Generate Recurring" to auto-create that month's expenses

## Features
- 📊 Dashboard with cash flow summary & budget bars
- 💳 Quick expense/income entry (<10 seconds)
- 🔄 Recurring bills management
- 🏷️ Custom categories with budget limits
- 🎯 Savings goals with progress tracking
- 👨👩🏠 Bob/Elle/Household expense tagging
- 🏷️ Tags & notes on every transaction
- 📱 Mobile-first design
- 💜 Purple/teal neon theme

## Tech
- Single HTML file, no build step
- Lightweight Supabase REST client (no SDK dependency)
- PWA-capable (add to home screen)
- Real-time data via Supabase
