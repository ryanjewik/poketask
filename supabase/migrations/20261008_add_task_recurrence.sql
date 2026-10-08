-- Recurring tasks: every occurrence is its own task_table row, linked by recurrence_id.
alter table public.task_table
  add column if not exists recurrence text
    check (recurrence in ('daily', 'weekly', 'monthly')),
  add column if not exists recurrence_id uuid;

-- "Delete this and all following" filters on recurrence_id + start_date.
create index if not exists task_table_recurrence_id_start_date_idx
  on public.task_table (recurrence_id, start_date)
  where recurrence_id is not null;
