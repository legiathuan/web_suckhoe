# ỨNG DỤNG SỨC KHỎE (HealthPulse / Green Health / VitaFlow)

Hệ sinh thái nền tảng chăm sóc sức khỏe, theo dõi sinh hiệu, nhật ký dinh dưỡng và kết nối chuyên gia y tế thông minh.

---

## 📁 Cấu trúc dự án

```text
APP SUC KHOE/
├── index.html              # Trang chủ giới thiệu (Landing Page)
├── index.css               # Phong cách cơ sở cho trang chủ
├── index.js                # Điểm vào hệ thống
├── login.html              # Trang Đăng nhập & Đăng ký tích hợp Supabase Auth
├── login.css               # Phong cách trang đăng nhập
├── register.html           # Chuyển tiếp nhanh sang giao diện Đăng ký
├── register.css            # Phong cách trang đăng ký
├── tong_quan_skhoe.html    # Bảng điều khiển (Dashboard) tổng quan sinh hiệu & chỉ số sức khỏe
├── tong_quan_skhoe.css     # Phong cách trang tổng quan
├── nhat_ky.html            # Nhật ký dinh dưỡng & AI Food Log
├── nhat_ky.css             # Phong cách trang nhật ký
├── thucdon.html            # Thực đơn cá nhân hóa & Kế hoạch dinh dưỡng 7 ngày
├── thucdon.css             # Phong cách trang thực đơn
├── tu_van_chuyen_gia.html  # Đặt lịch & Tư vấn trực tuyến cùng Bác sĩ / Chuyên gia
├── tu_van.css              # Phong cách trang tư vấn
├── quan_tri_thuc_pham.html # Quản trị thực phẩm CRUD kết nối CSDL Supabase
├── quan_tri_thuc_.css      # Phong cách trang quản trị
├── supabaseClient.js       # Module kết nối Supabase Client và các hàm Auth/Database
├── schema.sql              # Kịch bản khởi tạo CSDL PostgreSQL cho Supabase
└── README.md               # Hướng dẫn sử dụng và tài liệu kỹ thuật
```

---

## ⚡ Cấu hình Supabase

- **Project URL**: `https://udkxhzmaotmkxaneoifc.supabase.co`
- **Publishable Key**: `sb_publishable_ohQ5G5LcltJB6-d8_Llgwg_6V3zoRS5`
- **Anon Public Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVka3hoem1hb3Rta3hhbmVvaWZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk4ODkzMjIsImV4cCI6MjEwNTQ2NTMyMn0.7ys0ODiwzPf07_PlLRAiZxDc75vmDtkFBHqGHgm4JUw`
- **Service-Role Key** *(Lưu ý: Chỉ dùng cho backend/server, tuyệt đối không đưa vào mã nguồn chạy ở trình duyệt client)*:
  `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVka3hoem1hb3Rta3hhbmVvaWZjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4OTg4OTMyMiwiZXhwIjoyMTA1NDY1MzIyfQ.sEQdbakuqdF6M46Y0CzA7is8xSvbmVZ8DmS6-ZRcPsA`

---

## 🚀 Hướng dẫn khởi chạy Cơ sở dữ liệu trên Supabase

1. Đăng nhập vào [Supabase Dashboard](https://supabase.com/dashboard).
2. Chọn dự án: `udkxhzmaotmkxaneoifc`.
3. Nhấp vào mục **SQL Editor** ở thanh menu bên trái.
4. Mở file [schema.sql](./schema.sql), sao chép toàn bộ nội dung và dán vào cửa sổ SQL Editor.
5. Nhấn nút **Run**. Supabase sẽ tự động tạo:
   - Bảng `profiles`: Tự động đồng bộ khi người dùng đăng ký mới.
   - Bảng `food_items`: Danh mục thực phẩm kèm dữ liệu chuẩn hóa mẫu.
   - Bảng `food_logs`: Nhật ký ăn uống cá nhân của từng người dùng.
   - Bảng `health_metrics`: Chỉ số tim mạch, huyết áp, cân nặng, BMI.
   - Các chính sách bảo mật **Row Level Security (RLS)** bảo vệ dữ liệu an toàn.

---

## 💻 Cách sử dụng ứng dụng

1. **Mở trực tiếp trên trình duyệt**:
   - Mở file `index.html` hoặc chạy một server tĩnh (Live Server trong VS Code / Python `python3 -m http.server 8000`).
2. **Đăng ký / Đăng nhập**:
   - Truy cập `login.html` (hoặc nhấn nút "Sign In" / "Đăng ký").
   - Người dùng có thể đăng nhập bằng Email/Password, tạo tài khoản mới hoặc đăng nhập nhanh bằng Google.
   - Sau khi đăng nhập thành công, hệ thống tự chuyển hướng đến `tong_quan_skhoe.html`.
3. **Quản lý thực phẩm**:
   - Truy cập `quan_tri_thuc_pham.html`.
   - Nhấn "Thêm món ăn mới" để nhập món ăn, hệ thống sẽ lưu trực tiếp vào CSDL Supabase.
   - Có thể xóa món ăn hoặc xem vi chất chi tiết.
4. **Đăng xuất**:
   - Nhấn nút "Đăng xuất" ở góc trên bên phải tại bất kỳ trang nào để xóa phiên đăng nhập.
