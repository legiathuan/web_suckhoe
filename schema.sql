-- =============================================================
-- HỆ THỐNG CƠ SỞ DỮ LIỆU APP SỨC KHỎE (HealthPulse / Green Health)
-- Hướng dẫn: Copy toàn bộ nội dung file này và dán vào
-- Supabase Dashboard -> SQL Editor -> Run.
-- =============================================================

-- 1. BẢNG HỒ SƠ NGƯỜI DÙNG (PROFILES)
create table if not exists public.profiles (
    id uuid references auth.users on delete cascade primary key,
    full_name text,
    avatar_url text,
    role text default 'user' check (role in ('user', 'admin', 'expert')),
    age integer,
    gender text check (gender in ('male', 'female', 'other')),
    height_cm numeric,
    weight_kg numeric,
    daily_calorie_target integer default 2000,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Kích hoạt RLS cho bảng profiles
alter table public.profiles enable row level security;

-- Policies cho bảng profiles
create policy "Cho phép người dùng xem hồ sơ của mình"
    on public.profiles for select
    using (auth.uid() = id);

create policy "Cho phép người dùng cập nhật hồ sơ của mình"
    on public.profiles for update
    using (auth.uid() = id);

create policy "Cho phép người dùng tạo hồ sơ khi đăng ký"
    on public.profiles for insert
    with check (auth.uid() = id);

-- Tự động tạo bản ghi trong bảng profiles khi có tài khoản mới đăng ký qua auth.users
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id, full_name, avatar_url, role)
    values (
        new.id,
        coalesce(new.raw_user_meta_data->>'full_name', 'Người dùng mới'),
        coalesce(new.raw_user_meta_data->>'avatar_url', 'https://api.dicebear.com/7.x/initials/svg?seed=' || coalesce(new.email, 'User')),
        'user'
    );
    return new;
end;
$$ language plpgsql security definer;

-- Trigger chạy sau khi người dùng đăng ký auth
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();

-- =============================================================
-- 2. BẢNG DANH MỤC THỰC PHẨM (FOOD_ITEMS)
-- =============================================================
create table if not exists public.food_items (
    id uuid default gen_random_uuid() primary key,
    name text not null,
    category text default 'Khác',
    serving_size text default '100g',
    calories numeric not null,
    protein numeric default 0,
    carbs numeric default 0,
    fat numeric default 0,
    micros text,
    status text default 'approved' check (status in ('approved', 'pending', 'rejected')),
    created_by uuid references auth.users on delete set null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Kích hoạt RLS cho food_items
alter table public.food_items enable row level security;

-- Mọi người đều có thể đọc danh sách thực phẩm
create policy "Mọi người có thể xem danh mục thực phẩm"
    on public.food_items for select
    using (true);

-- Người dùng đã đăng nhập có thể đóng góp món ăn mới
create policy "Người dùng đăng nhập có thể thêm thực phẩm"
    on public.food_items for insert
    with check (auth.role() = 'authenticated');

-- Người tạo hoặc Admin có quyền sửa/xóa thực phẩm
create policy "Người tạo có thể cập nhật thực phẩm của mình"
    on public.food_items for update
    using (auth.uid() = created_by);

create policy "Người tạo có thể xóa thực phẩm của mình"
    on public.food_items for delete
    using (auth.uid() = created_by);

-- =============================================================
-- 3. BẢNG NHẬT KÝ ĂN UỐNG (FOOD_LOGS)
-- =============================================================
create table if not exists public.food_logs (
    id uuid default gen_random_uuid() primary key,
    user_id uuid references auth.users on delete cascade not null,
    meal_type text check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack')) not null,
    food_name text not null,
    serving_amount numeric default 1,
    unit text default 'phần',
    calories numeric not null,
    protein numeric default 0,
    carbs numeric default 0,
    fat numeric default 0,
    log_date date default current_date not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.food_logs enable row level security;

create policy "Người dùng chỉ xem nhật ký ăn uống của chính mình"
    on public.food_logs for select
    using (auth.uid() = user_id);

create policy "Người dùng thêm món vào nhật ký của chính mình"
    on public.food_logs for insert
    with check (auth.uid() = user_id);

create policy "Người dùng cập nhật nhật ký của mình"
    on public.food_logs for update
    using (auth.uid() = user_id);

create policy "Người dùng xóa mục nhật ký của mình"
    on public.food_logs for delete
    using (auth.uid() = user_id);

-- =============================================================
-- 4. BẢNG CHỈ SỐ SỨC KHỎE (HEALTH_METRICS)
-- =============================================================
create table if not exists public.health_metrics (
    id uuid default gen_random_uuid() primary key,
    user_id uuid references auth.users on delete cascade not null,
    blood_pressure_sys integer, -- Huyết áp tâm thu (mmHg)
    blood_pressure_dia integer, -- Huyết áp tâm trương (mmHg)
    heart_rate integer,        -- Nhịp tim (bpm)
    weight_kg numeric,         -- Cân nặng (kg)
    height_cm numeric,         -- Chiều cao (cm)
    bmi numeric,               -- Chỉ số khối cơ thể
    blood_sugar numeric,       -- Đường huyết (mg/dL)
    sp_o2 integer,             -- Nồng độ oxy trong máu (%)
    recorded_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.health_metrics enable row level security;

create policy "Người dùng chỉ xem chỉ số sức khỏe của chính mình"
    on public.health_metrics for select
    using (auth.uid() = user_id);

create policy "Người dùng ghi chỉ số sức khỏe của mình"
    on public.health_metrics for insert
    with check (auth.uid() = user_id);

-- =============================================================
-- 5. DỮ LIỆU MẪU BAN ĐẦU CHO BẢNG FOOD_ITEMS
-- =============================================================
insert into public.food_items (name, category, serving_size, calories, protein, carbs, fat, micros, status)
values
('Ức gà phi lê hấp chín', 'Thịt & Gia cầm', '100g', 165, 31.0, 0, 3.6, '0.4mg B6, 2.1mcg B12, 1.2mg Sắt, 1.1mg Kẽm', 'approved'),
('Yến mạch cán dẹt nguyên chất', 'Ngũ cốc & Hạt', '50g', 187, 6.8, 33.0, 3.2, '54mg Magiê, 1.9mg Sắt, 0.2mg B1', 'approved'),
('Quả bơ sáp Đắk Lắk tươi', 'Trái cây & Rau củ', '100g', 160, 2.0, 8.5, 14.7, '485mg Kali, 10mg Vitamin C, 2.07mg Vitamin E', 'approved'),
('Cá hồi Nauy áp chảo', 'Hải sản', '100g', 208, 20.4, 0, 13.4, '2.3g Omega-3, 11mcg Vitamin D, 29mg Magiê', 'approved'),
('Phở bò tái nạm gia truyền', 'Món ăn truyền thống', '1 tô (650g)', 540, 32.0, 68.0, 14.0, '3.5mg Sắt, 450mg Natri, 28mg Canxi', 'approved'),
('Trứng gà ta luộc', 'Trứng & Sữa', '1 quả (50g)', 78, 6.3, 0.6, 5.3, '147mg Choline, 25mg Canxi, 0.9mg Sắt', 'approved'),
('Bông cải xanh (Súp lơ) luộc', 'Trái cây & Rau củ', '100g', 35, 2.4, 7.2, 0.4, '89mg Vitamin C, 101mcg Vitamin K, 47mg Canxi', 'approved'),
('Khoai lang mật nướng', 'Củ & Tinh bột chậm', '100g', 86, 1.6, 20.1, 0.1, '14187 IU Vitamin A, 337mg Kali, 25mg Magiê', 'approved')
on conflict do nothing;
