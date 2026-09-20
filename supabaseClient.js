/**
 * Supabase Client & Helper Functions
 * Dự án: APP SỨC KHỎE (HealthPulse / Green Health)
 */

const SUPABASE_URL = "https://udkxhzmaotmkxaneoifc.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVka3hoem1hb3Rta3hhbmVvaWZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk4ODkzMjIsImV4cCI6MjEwNTQ2NTMyMn0.7ys0ODiwzPf07_PlLRAiZxDc75vmDtkFBHqGHgm4JUw";

// Khởi tạo Supabase client nếu thư viện @supabase/supabase-js đã được nạp
let supabaseClient = null;
if (window.supabase && typeof window.supabase.createClient === "function") {
    supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
} else {
    console.warn("Thư viện Supabase JS chưa được tải. Vui lòng thêm CDN @supabase/supabase-js vào thẻ <head>.");
}

// -------------------------------------------------------------
// XÁC THỰC (AUTHENTICATION)
// -------------------------------------------------------------

/**
 * Đăng ký tài khoản mới bằng Email và Mật khẩu
 */
async function signUpUser(email, password, fullName) {
    if (!supabaseClient) throw new Error("Supabase client chưa sẵn sàng");

    const { data, error } = await supabaseClient.auth.signUp({
        email: email,
        password: password,
        options: {
            data: {
                full_name: fullName,
                avatar_url: `https://api.dicebear.com/7.x/initials/svg?seed=${encodeURIComponent(fullName || email)}`
            }
        }
    });

    if (error) throw error;
    return data;
}

/**
 * Đăng nhập bằng Email và Mật khẩu
 */
async function signInUser(email, password) {
    if (!supabaseClient) throw new Error("Supabase client chưa sẵn sàng");

    const { data, error } = await supabaseClient.auth.signInWithPassword({
        email: email,
        password: password
    });

    if (error) throw error;
    return data;
}

/**
 * Đăng nhập bằng Google OAuth
 */
async function signInWithGoogle() {
    if (!supabaseClient) throw new Error("Supabase client chưa sẵn sàng");

    // Google OAuth không hỗ trợ protocol file://
    if (window.location.protocol === "file:") {
        throw new Error("Google OAuth yêu cầu chạy ứng dụng qua máy chủ web nội bộ (ví dụ Live Server: http://127.0.0.1:5500/login.html), không hỗ trợ mở trực tiếp file://");
    }

    // Tự động xác định đường dẫn đến tong_quan_skhoe.html
    const redirectUrl = window.location.origin + window.location.pathname.replace(/\/[^/]*$/, "/tong_quan_skhoe.html");

    const { data, error } = await supabaseClient.auth.signInWithOAuth({
        provider: "google",
        options: {
            redirectTo: redirectUrl,
            queryParams: {
                access_type: "offline",
                prompt: "consent"
            }
        }
    });

    if (error) throw error;
    return data;
}

/**
 * Đăng xuất
 */
async function signOutUser() {
    if (!supabaseClient) throw new Error("Supabase client chưa sẵn sàng");
    const { error } = await supabaseClient.auth.signOut();
    if (error) throw error;
    window.location.href = "login.html";
}

/**
 * Lấy thông tin người dùng hiện tại đang đăng nhập
 */
async function getCurrentUser() {
    if (!supabaseClient) return null;
    const { data: { user }, error } = await supabaseClient.auth.getUser();
    if (error || !user) return null;
    return user;
}

/**
 * Lắng nghe thay đổi trạng thái đăng nhập
 */
function onAuthStateChange(callback) {
    if (!supabaseClient) return;
    return supabaseClient.auth.onAuthStateChange((event, session) => {
        callback(event, session);
    });
}

/**
 * Gửi email yêu cầu đặt lại mật khẩu
 */
async function resetPasswordForEmail(email) {
    if (!supabaseClient) throw new Error("Supabase client chưa sẵn sàng");
    const { data, error } = await supabaseClient.auth.resetPasswordForEmail(email, {
        redirectTo: window.location.origin + window.location.pathname.replace(/\/[^/]*$/, "/login.html")
    });
    if (error) throw error;
    return data;
}

// -------------------------------------------------------------
// QUẢN LÝ DỮ LIỆU THỰC PHẨM (FOOD ITEMS)
// -------------------------------------------------------------

/**
 * Lấy danh sách thực phẩm
 */
async function getFoodItems() {
    if (!supabaseClient) return [];
    const { data, error } = await supabaseClient
        .from("food_items")
        .select("*")
        .order("created_at", { ascending: false });

    if (error) {
        console.warn("Lỗi khi tải thực phẩm từ Supabase:", error.message);
        return null;
    }
    return data;
}

/**
 * Thêm thực phẩm mới
 */
async function addFoodItem(food) {
    if (!supabaseClient) throw new Error("Supabase client chưa sẵn sàng");
    const { data, error } = await supabaseClient
        .from("food_items")
        .insert([food])
        .select();

    if (error) throw error;
    return data;
}

/**
 * Xóa thực phẩm
 */
async function deleteFoodItem(id) {
    if (!supabaseClient) throw new Error("Supabase client chưa sẵn sàng");
    const { error } = await supabaseClient
        .from("food_items")
        .delete()
        .eq("id", id);

    if (error) throw error;
    return true;
}

// -------------------------------------------------------------
// NHẬT KÝ ĂN UỐNG & CHỈ SỐ SỨC KHỎE
// -------------------------------------------------------------

/**
 * Lấy nhật ký ăn uống theo ngày của người dùng
 */
async function getFoodLogs(userId, dateStr) {
    if (!supabaseClient || !userId) return [];
    let query = supabaseClient
        .from("food_logs")
        .select("*")
        .eq("user_id", userId);

    if (dateStr) {
        query = query.eq("log_date", dateStr);
    }

    const { data, error } = await query.order("created_at", { ascending: false });
    if (error) {
        console.warn("Lỗi khi tải nhật ký ăn uống:", error.message);
        return [];
    }
    return data;
}

/**
 * Thêm bữa ăn vào nhật ký
 */
async function addFoodLog(logData) {
    if (!supabaseClient) throw new Error("Supabase client chưa sẵn sàng");
    const { data, error } = await supabaseClient
        .from("food_logs")
        .insert([logData])
        .select();

    if (error) throw error;
    return data;
}

/**
 * Lấy các chỉ số sức khỏe gần nhất của người dùng
 */
async function getLatestHealthMetrics(userId) {
    if (!supabaseClient || !userId) return null;
    const { data, error } = await supabaseClient
        .from("health_metrics")
        .select("*")
        .eq("user_id", userId)
        .order("recorded_at", { ascending: false })
        .limit(1);

    if (error) {
        console.warn("Lỗi khi tải chỉ số sức khỏe:", error.message);
        return null;
    }
    return data?.[0] || null;
}

// Xuất ra window để các file HTML có thể truy cập trực tiếp
window.APP_SUPABASE = {
    client: supabaseClient,
    signUpUser,
    signInUser,
    signInWithGoogle,
    signOutUser,
    getCurrentUser,
    onAuthStateChange,
    resetPasswordForEmail,
    getFoodItems,
    addFoodItem,
    deleteFoodItem,
    getFoodLogs,
    addFoodLog,
    getLatestHealthMetrics
};
