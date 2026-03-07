-- Family Budget Tracker Schema for Supabase
-- Run this in Supabase SQL Editor after creating your project

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Profiles (extends Supabase auth.users)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  display_name text not null,
  avatar_url text,
  created_at timestamptz default now()
);

-- Categories
create table categories (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  icon text default '📦',
  color text default '#8b5cf6',
  budget_limit numeric(12,2),
  is_income boolean default false,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- Payment Methods
create table payment_methods (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  type text not null default 'cash' check (type in ('credit_card','debit_card','cash','digital_wallet','bank_transfer')),
  owner text default 'household' check (owner in ('bob','elle','household')),
  last_four text check (last_four is null or length(last_four) = 4),
  is_active boolean default true,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- Expenses
create table expenses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  category_id uuid references categories on delete set null,
  payment_method_id uuid references payment_methods on delete set null,
  amount numeric(12,2) not null,
  description text,
  notes text,
  tags text[] default '{}',
  owner text default 'household' check (owner in ('bob','elle','household')),
  expense_date date default current_date,
  recurring_expense_id uuid,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Income
create table income (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  amount numeric(12,2) not null,
  source text not null,
  description text,
  notes text,
  tags text[] default '{}',
  owner text default 'household' check (owner in ('bob','elle','household')),
  income_date date default current_date,
  is_recurring boolean default false,
  created_at timestamptz default now()
);

-- Recurring Expenses
create table recurring_expenses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  category_id uuid references categories on delete set null,
  amount numeric(12,2) not null,
  description text not null,
  owner text default 'household' check (owner in ('bob','elle','household')),
  payment_method_id uuid references payment_methods on delete set null,
  frequency text default 'monthly' check (frequency in ('weekly','biweekly','monthly','quarterly','yearly')),
  day_of_month int default 1,
  is_active boolean default true,
  last_generated date,
  next_due date,
  created_at timestamptz default now()
);

-- Savings Goals
create table savings_goals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  target_amount numeric(12,2) not null,
  current_amount numeric(12,2) default 0,
  icon text default '🎯',
  target_date date,
  is_completed boolean default false,
  created_at timestamptz default now()
);

-- Debts
create table debts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  type text default 'other' check (type in ('credit_card','auto_loan','mortgage','personal_loan','student_loan','medical','other')),
  original_balance numeric(12,2),
  current_balance numeric(12,2) not null default 0,
  interest_rate numeric(5,2) default 0,
  minimum_payment numeric(12,2) default 0,
  due_day int default 1,
  owner text default 'household' check (owner in ('bob','elle','household')),
  status text default 'active' check (status in ('active','paid_off')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Debt Payments
create table debt_payments (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  debt_id uuid references debts on delete cascade not null,
  amount numeric(12,2) not null,
  payment_date date default current_date,
  note text,
  created_at timestamptz default now()
);

-- Row Level Security
alter table profiles enable row level security;
alter table payment_methods enable row level security;
alter table categories enable row level security;
alter table expenses enable row level security;
alter table income enable row level security;
alter table recurring_expenses enable row level security;
alter table savings_goals enable row level security;
alter table debts enable row level security;
alter table debt_payments enable row level security;

-- RLS Policies - all family members see everything (shared household)
create policy "Users can view all profiles" on profiles for select using (true);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);

create policy "Family can view all payment_methods" on payment_methods for select using (true);
create policy "Users can insert payment_methods" on payment_methods for insert with check (auth.uid() = user_id);
create policy "Users can update own payment_methods" on payment_methods for update using (auth.uid() = user_id);
create policy "Users can delete own payment_methods" on payment_methods for delete using (auth.uid() = user_id);

create policy "Family can view all categories" on categories for select using (true);
create policy "Users can insert categories" on categories for insert with check (auth.uid() = user_id);
create policy "Users can update own categories" on categories for update using (auth.uid() = user_id);
create policy "Users can delete own categories" on categories for delete using (auth.uid() = user_id);

create policy "Family can view all expenses" on expenses for select using (true);
create policy "Users can insert expenses" on expenses for insert with check (auth.uid() = user_id);
create policy "Users can update own expenses" on expenses for update using (auth.uid() = user_id);
create policy "Users can delete own expenses" on expenses for delete using (auth.uid() = user_id);

create policy "Family can view all income" on income for select using (true);
create policy "Users can insert income" on income for insert with check (auth.uid() = user_id);
create policy "Users can update own income" on income for update using (auth.uid() = user_id);
create policy "Users can delete own income" on income for delete using (auth.uid() = user_id);

create policy "Family can view all recurring" on recurring_expenses for select using (true);
create policy "Users can insert recurring" on recurring_expenses for insert with check (auth.uid() = user_id);
create policy "Users can update own recurring" on recurring_expenses for update using (auth.uid() = user_id);
create policy "Users can delete own recurring" on recurring_expenses for delete using (auth.uid() = user_id);

create policy "Family can view all debts" on debts for select using (true);
create policy "Users can insert debts" on debts for insert with check (auth.uid() = user_id);
create policy "Users can update own debts" on debts for update using (auth.uid() = user_id);
create policy "Users can delete own debts" on debts for delete using (auth.uid() = user_id);

create policy "Family can view all debt_payments" on debt_payments for select using (true);
create policy "Users can insert debt_payments" on debt_payments for insert with check (auth.uid() = user_id);
create policy "Users can update own debt_payments" on debt_payments for update using (auth.uid() = user_id);
create policy "Users can delete own debt_payments" on debt_payments for delete using (auth.uid() = user_id);

create policy "Family can view all goals" on savings_goals for select using (true);
create policy "Users can insert goals" on savings_goals for insert with check (auth.uid() = user_id);
create policy "Users can update own goals" on savings_goals for update using (auth.uid() = user_id);
create policy "Users can delete own goals" on savings_goals for delete using (auth.uid() = user_id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Default categories seeder (run after first user signs up, or call manually)
create or replace function seed_default_categories(p_user_id uuid)
returns void as $$
begin
  insert into categories (user_id, name, icon, color, is_income, sort_order) values
    (p_user_id, 'Housing', '🏠', '#8b5cf6', false, 1),
    (p_user_id, 'Groceries', '🛒', '#06b6d4', false, 2),
    (p_user_id, 'Utilities', '💡', '#f59e0b', false, 3),
    (p_user_id, 'Transportation', '🚗', '#ef4444', false, 4),
    (p_user_id, 'Insurance', '🛡️', '#3b82f6', false, 5),
    (p_user_id, 'Healthcare', '🏥', '#ec4899', false, 6),
    (p_user_id, 'Entertainment', '🎬', '#a855f7', false, 7),
    (p_user_id, 'Dining Out', '🍽️', '#f97316', false, 8),
    (p_user_id, 'Shopping', '🛍️', '#14b8a6', false, 9),
    (p_user_id, 'Subscriptions', '📱', '#6366f1', false, 10),
    (p_user_id, 'Kids', '👶', '#84cc16', false, 11),
    (p_user_id, 'Pets', '🐾', '#d946ef', false, 12),
    (p_user_id, 'Savings', '💰', '#22c55e', false, 13),
    (p_user_id, 'Other', '📦', '#64748b', false, 14),
    (p_user_id, 'Salary', '💵', '#22c55e', true, 1),
    (p_user_id, 'Freelance', '💻', '#06b6d4', true, 2),
    (p_user_id, 'Other Income', '💸', '#8b5cf6', true, 3);
end;
$$ language plpgsql security definer;

-- Default payment methods seeder
create or replace function seed_default_payment_methods(p_user_id uuid)
returns void as $$
begin
  insert into payment_methods (user_id, name, type, owner, sort_order) values
    (p_user_id, 'Cash', 'cash', 'household', 1),
    (p_user_id, 'Debit Card', 'debit_card', 'household', 2),
    (p_user_id, 'Credit Card', 'credit_card', 'household', 3),
    (p_user_id, 'Digital Wallet', 'digital_wallet', 'household', 4);
end;
$$ language plpgsql security definer;

-- Realtime
alter publication supabase_realtime add table expenses;
alter publication supabase_realtime add table income;
alter publication supabase_realtime add table categories;
alter publication supabase_realtime add table savings_goals;
alter publication supabase_realtime add table recurring_expenses;
alter publication supabase_realtime add table debts;
alter publication supabase_realtime add table debt_payments;
alter publication supabase_realtime add table payment_methods;
