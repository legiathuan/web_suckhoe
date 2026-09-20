/**
 * Entry point: APP SỨC KHỎE (HealthPulse / Green Health)
 * File này kết nối các module chính và đảm bảo Supabase Client luôn sẵn sàng.
 */

// Đảm bảo client Supabase sẵn sàng
if (typeof window !== "undefined" && !window.APP_SUPABASE) {
    console.log("APP SỨC KHỎE: Khởi tạo hệ thống...");
}
