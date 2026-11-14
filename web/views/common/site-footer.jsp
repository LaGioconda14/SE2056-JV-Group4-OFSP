<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!-- Footer Chuẩn Đồng Bộ Website Gốc Vườn -->
        <footer id="about" class="bg-gray-950 text-gray-300 pt-16 pb-8 border-t border-gray-800 mt-12 w-full">
            <div id="contact" class="max-w-[1360px] mx-auto px-4 lg:px-8">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 mb-12">
                    <!-- Cột 1: Thông tin thương hiệu & cam kết -->
                    <div class="lg:col-span-2 space-y-4">
                        <div class="flex items-center gap-3">
                            <!-- Apple Icon SVG đồng bộ 100% chuẩn Header -->
                            <svg class="h-10 w-10 shrink-0" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M19 4C19 4 24 4 23 9C20 9 18 7 19 4Z" fill="#16a34a"/>
                                <path d="M18 6.5C17.5 8.5 16 10.5 15 11.5" stroke="#9ca3af" stroke-width="2" stroke-linecap="round"/>
                                <path d="M18 12.5C16 9.5 11 9.5 8 12.5C4 16.5 5 23.5 9 28.5C12 32.5 15 32.5 18 30.5C21 32.5 24 32.5 27 28.5C31 23.5 32 16.5 28 12.5C25 9.5 20 9.5 18 12.5Z" fill="url(#appleGradFooter)"/>
                                <defs>
                                    <linearGradient id="appleGradFooter" x1="8" y1="11" x2="28" y2="33" gradientUnits="userSpaceOnUse">
                                        <stop stop-color="#fb7185"/>
                                        <stop offset="0.6" stop-color="#ef4444"/>
                                        <stop offset="1" stop-color="#dc2626"/>
                                    </linearGradient>
                                </defs>
                            </svg>
                            <div class="flex flex-col" style="font-family: 'Plus Jakarta Sans', sans-serif;">
                                <span class="text-2xl font-extrabold text-white tracking-tight leading-none">Gốc Vườn</span>
                                <span class="text-[9px] font-bold tracking-widest text-emerald-400 uppercase mt-0.5">NÔNG SẢN TẬN VƯỜN</span>
                            </div>
                        </div>
                        <p class="text-xs sm:text-sm text-gray-400 leading-relaxed max-w-sm">
                            Hệ thống sàn phân phối nông sản &amp; trái cây tươi sạch hàng đầu Việt Nam. Mang thiên nhiên thuần khiết và nguồn dinh dưỡng chuẩn hữu cơ từ nông trại đến từng gia đình.
                        </p>
                        <div class="flex flex-col gap-1.5 text-xs text-emerald-400 font-semibold pt-1">
                            <div class="flex items-center gap-2">
                                <i class="fa-solid fa-shield-halved text-emerald-500"></i>
                                <span>100% Nông sản kiểm định chuẩn VietGAP &amp; GlobalGAP</span>
                            </div>
                            <div class="flex items-center gap-2 text-gray-400 font-normal">
                                <i class="fa-solid fa-truck-fast text-emerald-500"></i>
                                <span>Vận chuyển chuỗi lạnh Fresh-Lock giữ trọn vitamin</span>
                            </div>
                        </div>
                    </div>

                    <!-- Cột 2: Danh mục mua sắm -->
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Danh Mục Mua Sắm</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition flex items-center gap-1.5"><i class="fa-solid fa-chevron-right text-[8px] text-emerald-600"></i> Tất Cả Nông Sản</a></li>
                            <c:forEach var="c" items="${categories}" end="4">
                                <li><a href="${pageContext.request.contextPath}/products?category=${c.slug}" class="hover:text-emerald-400 transition flex items-center gap-1.5"><i class="fa-solid fa-chevron-right text-[8px] text-emerald-600"></i> ${c.categoryName}</a></li>
                            </c:forEach>
                            <c:if test="${empty categories}">
                                <li><a href="${pageContext.request.contextPath}/products?category=trai-cay-viet-nam" class="hover:text-emerald-400 transition flex items-center gap-1.5"><i class="fa-solid fa-chevron-right text-[8px] text-emerald-600"></i> Trái Cây Nội Địa</a></li>
                                <li><a href="${pageContext.request.contextPath}/products?category=trai-cay-nhap-khau" class="hover:text-emerald-400 transition flex items-center gap-1.5"><i class="fa-solid fa-chevron-right text-[8px] text-emerald-600"></i> Trái Cây Nhập Khẩu</a></li>
                                <li><a href="${pageContext.request.contextPath}/products?category=qua-tang-trai-cay" class="hover:text-emerald-400 transition flex items-center gap-1.5"><i class="fa-solid fa-chevron-right text-[8px] text-emerald-600"></i> Hộp Quà &amp; Combo</a></li>
                            </c:if>
                        </ul>
                    </div>

                    <!-- Cột 3: Hỗ trợ & Chính sách -->
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Hỗ Trợ Khách Hàng</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <li><a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-400 transition">Trang Chủ Gốc Vườn</a></li>
                            <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition">Cửa Hàng Nông Sản</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Chính Sách Đổi Trả 1-1 Trong 24h</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Quy Trình Kiểm Tra Chất Lượng</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Điều Khoản Dịch Vụ Sàn</a></li>
                        </ul>
                    </div>

                    <!-- Cột 4: Hotline & Đăng ký bản tin -->
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Hotline &amp; Bản Tin</h3>
                        <div class="space-y-2 text-xs text-gray-400 mb-4">
                            <p class="flex items-center gap-2"><i class="fa-solid fa-phone text-emerald-500"></i> <strong>1900 6868</strong> (8:00 - 21:00)</p>
                            <p class="flex items-center gap-2"><i class="fa-solid fa-envelope text-emerald-500"></i> support@gocvuon.vn</p>
                            <p class="flex items-center gap-2"><i class="fa-solid fa-location-dot text-emerald-500"></i> Lâm Đồng, Sơn La &amp; ĐBSCL</p>
                        </div>
                        <form onsubmit="event.preventDefault(); if (window.showToast) { window.showToast('Cảm ơn bạn đã đăng ký nhận bản tin!'); } else { alert('Cảm ơn bạn đã đăng ký nhận bản tin!'); } this.reset();" class="space-y-2">
                            <input type="email" placeholder="Nhập email của bạn..." class="w-full bg-gray-900 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500" required>
                            <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs py-2.5 rounded-xl transition shadow">Đăng Ký Nhận Ưu Đãi</button>
                        </form>
                    </div>
                </div>

                <!-- Dòng bản quyền cuối trang -->
                <div class="pt-8 border-t border-gray-900 flex flex-col sm:flex-row justify-between items-center text-xs text-gray-500 gap-4">
                    <p>&copy; 2026 Gốc Vườn Marketplace Inc. Bảo lưu mọi quyền.</p>
                    <div class="flex items-center gap-4 text-gray-400">
                        <span>Tiêu chuẩn VietGAP • GlobalGAP • Chuỗi lạnh Fresh-Lock</span>
                    </div>
                </div>
            </div>
        </footer>
