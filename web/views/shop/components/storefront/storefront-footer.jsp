<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<footer id="footer" class="bg-gray-950 text-gray-300 pt-16 pb-8 border-t border-gray-800 mt-auto">
    <div class="max-w-7xl mx-auto px-4">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10 mb-12">
            <div>
                <div class="flex items-center gap-2.5 mb-4">
                    <div class="w-9 h-9 bg-emerald-50 rounded-full flex items-center justify-center p-1">
                        <svg viewBox="0 0 100 100" class="w-full h-full">
                            <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                            <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                            <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                            <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                        </svg>
                    </div>
                    <span class="text-xl font-extrabold text-white">Fresh<span class="text-emerald-500">Fruit</span></span>
                </div>
                <p class="text-xs text-gray-400 mb-6 leading-relaxed">
                    Nông sản tươi sạch tuyển chọn từ các nông trại hữu cơ hàng đầu, thu hoạch chín tự nhiên và giao nhanh trong ngày.
                </p>
                <div class="flex items-center space-x-3 text-gray-400 text-sm">
                    <a href="#" class="w-8 h-8 rounded-full bg-gray-900 hover:bg-emerald-600 hover:text-white flex items-center justify-center transition"><i class="fa-brands fa-facebook-f"></i></a>
                    <a href="#" class="w-8 h-8 rounded-full bg-gray-900 hover:bg-emerald-600 hover:text-white flex items-center justify-center transition"><i class="fa-brands fa-instagram"></i></a>
                    <a href="#" class="w-8 h-8 rounded-full bg-gray-900 hover:bg-emerald-600 hover:text-white flex items-center justify-center transition"><i class="fa-brands fa-tiktok"></i></a>
                </div>
            </div>

            <div>
                <h4 class="text-white font-bold text-sm mb-4">Liên Kết Nhanh</h4>
                <ul class="space-y-2 text-xs">
                    <li><a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-400 transition">Trang Chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/store" class="hover:text-emerald-400 transition">Gian Hàng Nông Trại</a></li>
                    <li><a href="#shop-products" class="hover:text-emerald-400 transition">Tất Cả Sản Phẩm</a></li>
                    <li><a href="#reviews" class="hover:text-emerald-400 transition">Khách Hàng Đánh Giá</a></li>
                </ul>
            </div>

            <div>
                <h4 class="text-white font-bold text-sm mb-4">Chăm Sóc Khách Hàng</h4>
                <ul class="space-y-2 text-xs">
                    <li><a href="#" class="hover:text-emerald-400 transition">Chính Sách Đổi Trả 1-1</a></li>
                    <li><a href="#" class="hover:text-emerald-400 transition">Tiêu Chuẩn Chuỗi Lạnh</a></li>
                    <li><a href="#" class="hover:text-emerald-400 transition">Hướng Dẫn Mua Hàng</a></li>
                    <li><a href="#" class="hover:text-emerald-400 transition">Câu Hỏi Thường Gặp (FAQs)</a></li>
                    <li><a href="#" class="hover:text-emerald-400 transition">Hỗ Trợ Trực Tuyến 24/7</a></li>
                </ul>
            </div>

            <div>
                <h4 class="text-white font-bold text-sm mb-4">Liên Hệ & Thanh Toán</h4>
                <ul class="space-y-2 text-xs text-gray-400 mb-4">
                    <li class="flex items-center gap-2"><i class="fa-solid fa-phone text-emerald-500"></i> +1 (800) 673-7438</li>
                    <li class="flex items-center gap-2"><i class="fa-solid fa-envelope text-emerald-500"></i> care@freshfruit.com</li>
                    <li class="flex items-center gap-2"><i class="fa-solid fa-location-dot text-emerald-500"></i> Mộc Châu, Sơn La &bull; TP. Hà Nội</li>
                </ul>
                <div class="flex items-center space-x-2 text-xs text-gray-400">
                    <span class="bg-gray-900 px-2 py-1 rounded border border-gray-800">VISA</span>
                    <span class="bg-gray-900 px-2 py-1 rounded border border-gray-800">MasterCard</span>
                    <span class="bg-gray-900 px-2 py-1 rounded border border-gray-800">Apple Pay</span>
                    <span class="bg-gray-900 px-2 py-1 rounded border border-gray-800">VNPAY</span>
                </div>
            </div>
        </div>

        <div class="pt-8 border-t border-gray-800/80 flex flex-col sm:flex-row justify-between items-center text-xs text-gray-500 gap-4">
            <p>&copy; 2026 FreshFruit Marketplace Inc. All rights reserved.</p>
            <div class="flex space-x-6">
                <a href="#" class="hover:text-gray-400">Chính sách bảo mật</a>
                <a href="#" class="hover:text-gray-400">Điều khoản sử dụng</a>
                <a href="#" class="hover:text-gray-400">Sơ đồ trang</a>
            </div>
        </div>
    </div>
</footer>

