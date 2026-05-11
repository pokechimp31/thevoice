-- ============================================================
--  THE VOICE @ THE PENNINGTON SCHOOL
--  Supabase database schema
--  Run this entire file in: Supabase → SQL Editor → New query
-- ============================================================

-- Issue info (one row, updated each week)
create table if not exists issue (
  id            serial primary key,
  issue_date    text,          -- e.g. "Thursday, May 7, 2026"
  day_label     text,          -- e.g. "Day 1"
  rotation_day  text           -- e.g. "Advisory"
);
insert into issue (issue_date, day_label, rotation_day)
values ('Thursday, May 7, 2026', 'Day 1', 'Advisory');

-- Alert banner (one row)
create table if not exists alert (
  id      serial primary key,
  enabled boolean default false,
  text    text default ''
);
insert into alert (enabled, text)
values (true, 'AP Exams run May 4–22. Classes are not cancelled on exam days. Students with exams may dress down.');

-- Quick links bar
create table if not exists quick_links (
  id          serial primary key,
  emoji       text,
  label       text not null,
  url         text not null,
  sort_order  integer default 0
);
insert into quick_links (emoji, label, url, sort_order) values
  ('🍽️', 'Dining Hall Menu',  'http://pennington.flikisdining.com/', 0),
  ('🏅', 'Athletic Schedule', '#', 1),
  ('📅', 'MS Week Ahead',     '#', 2),
  ('🏠', 'Boarding Weekend',  '#', 3);

-- Deadline cards
create table if not exists deadlines (
  id          serial primary key,
  date_label  text,           -- e.g. "Today · May 7"
  title       text not null,
  sort_order  integer default 0
);
insert into deadlines (date_label, title, sort_order) values
  ('Today · May 7',  'Advisor Change Form due by 3 PM', 0),
  ('Mon · May 11',   'Last day to sign up for Gym & Swim', 1),
  ('Mon · May 18',   'All library books due', 2);

-- Sections (e.g. "All school", "Upper school", "Middle school")
create table if not exists sections (
  id          text primary key,  -- e.g. "sec_1234"
  name        text not null,
  sort_order  integer default 0
);
insert into sections (id, name, sort_order) values
  ('sec_allschool',    'All school',    0),
  ('sec_upperschool',  'Upper school',  1),
  ('sec_middleschool', 'Middle school', 2),
  ('sec_boarding',     'Boarding',      3);

-- Stories (accordion items)
create table if not exists stories (
  id          serial primary key,
  section_id  text references sections(id) on delete cascade,
  title       text not null,
  preview     text,           -- collapsed subtitle line
  badge       text,           -- small red pill, e.g. "Tonight"
  body_html   text,           -- full HTML shown when expanded
  sort_order  integer default 0
);
insert into stories (section_id, title, preview, badge, body_html, sort_order) values
  ('sec_allschool', 'Middle School Play — Charlie and the Chocolate Factory',
   'May 7 & 8 at 7 PM · Stainton Hall · Tickets $5', 'Tonight',
   '<p>Directed by Senior Seminar in Theatre – Honors Class members <strong>Brett Siroly ''26</strong> and <strong>Catherine Vincent ''26</strong>, the show runs <strong>Thursday May 7 and Friday May 8 at 7 PM</strong> in the Stainton Hall Lecture Center.</p><p>Tickets are <strong>$5 general admission</strong>.</p><a class="detail-link" href="https://tps.booktix.com" target="_blank">Buy tickets at tps.booktix.com ↗</a>',
   0),
  ('sec_upperschool', 'Last Gym & Swim of the Year — Volunteers Needed',
   'May 15 · Sign up by May 11 · Community Service Club', 'Sign up',
   '<p>The Community Service Club needs <strong>20–25 volunteers</strong> for Gym and Swim on <strong>May 15th</strong>.</p><ul><li><strong>Sign-up deadline:</strong> Monday, May 11 at 3:00 PM</li></ul><a class="detail-link" href="https://forms.gle/9SLRJGEAAanj8hiC9" target="_blank">Sign up here ↗</a>',
   0),
  ('sec_upperschool', 'AP Exam Guidelines — May 4–22',
   'Classes continue · Students may dress down on exam day', 'Ongoing',
   '<ul><li>Classes are <strong>not cancelled</strong> on the day of an AP test.</li><li>Students with an AP exam may <strong>dress down</strong>.</li><li>Students are accountable for essential work missed.</li></ul>',
   1);

-- ============================================================
--  ROW LEVEL SECURITY
--  Public can only READ. Writes require the service role key
--  (which only lives in your admin.html, never public).
-- ============================================================
alter table issue        enable row level security;
alter table alert        enable row level security;
alter table quick_links  enable row level security;
alter table deadlines    enable row level security;
alter table sections     enable row level security;
alter table stories      enable row level security;

create policy "Public read" on issue        for select using (true);
create policy "Public read" on alert        for select using (true);
create policy "Public read" on quick_links  for select using (true);
create policy "Public read" on deadlines    for select using (true);
create policy "Public read" on sections     for select using (true);
create policy "Public read" on stories      for select using (true);
