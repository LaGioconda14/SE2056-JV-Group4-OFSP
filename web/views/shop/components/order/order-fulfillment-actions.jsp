<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />

                        <c:choose>
                            <%-- CASE 1: ĐƠN ĐÃ BỊ HỦY (CANCELLED) --%>
                            <c:when test="${subOrder.status eq 'CANCELLED'}">
                                <div class="bg-white rounded-2xl border border-rose-200 p-6 shadow-xs bg-rose-50/20">
                                    <div class="flex items-start gap-4">
                                        <div class="w-11 h-11 rounded-2xl bg-rose-100 text-rose-600 flex items-center justify-center text-xl font-bold shrink-0 shadow-2xs border border-rose-200">
                                            <i class="fa-solid fa-ban"></i>
                                        </div>
                                        <div class="flex-1 min-w-0">
                                            <div class="flex flex-wrap items-center justify-between gap-2 pb-3 border-b border-rose-100">
                                                <div class="flex items-center gap-2">
                                                    <h2 class="text-base font-extrabold text-rose-950">Đơn Hàng Con Đã Bị Hủy</h2>
                                                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black bg-rose-100 text-rose-700 border border-rose-300 uppercase">
                                                        CANCELLED
                                                    </span>
                                                </div>
                                                <c:if test="${not empty subOrder.cancelledAt}">
                                                    <span class="text-xs text-rose-600 font-medium">
                                                        <i class="fa-regular fa-clock mr-1"></i>
                                                        <fmt:formatDate value="${subOrder.cancelledAt}" pattern="HH:mm dd/MM/yyyy" />
                                                    </span>
                                                </c:if>
                                            </div>

                                            <div class="mt-3 p-3.5 rounded-xl bg-white border border-rose-200/90 text-xs space-y-1.5 shadow-2xs">
                                                <div class="font-extrabold text-rose-800 flex items-center gap-1.5">
                                                    <i class="fa-solid fa-triangle-exclamation text-rose-600"></i> Lý do hủy đơn từ Gian hàng:
                                                </div>
                                                <div class="text-slate-800 leading-relaxed font-semibold pl-4 border-l-2 border-rose-300">
                                                    ${not empty subOrder.cancelReason ? subOrder.cancelReason : "Gian hàng hủy đơn do không đủ điều kiện xuất kho."}
                                                </div>
                                            </div>

                                            <div class="mt-3 flex items-start gap-2.5 text-xs text-emerald-900 bg-emerald-50 border border-emerald-200 p-3 rounded-xl">
                                                <i class="fa-solid fa-circle-check text-emerald-600 text-sm mt-0.5"></i>
                                                <div class="leading-relaxed">
                                                    <b>Tiến trình hệ thống tự động:</b> Hệ thống Gốc Vườn đã gửi thông báo hủy đến khách hàng và kích hoạt quy trình hoàn tiền tự động theo chính sách sàn.
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>

                            <%-- CASE 2: ĐƠN MỚI CHỜ DUYỆT (NEW) --%>
                            <c:when test="${subOrder.status eq 'NEW'}">
                                <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                                    <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                                        <div class="flex items-center gap-2.5">
                                            <div class="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-sm font-bold border border-amber-200">
                                                <i class="fa-solid fa-clipboard-question"></i>
                                            </div>
                                            <div>
                                                <h2 class="text-base font-extrabold text-slate-900">Kiểm Tra Nông Sản &amp; Tiếp Nhận Đơn Hàng</h2>
                                                <p class="text-[11px] text-slate-400">Kiểm tra thực tế kho bảo quản trước khi xác nhận</p>
                                            </div>
                                        </div>
                                        <span class="px-3 py-1 rounded-full text-xs font-extrabold bg-amber-50 text-amber-700 border border-amber-200 animate-pulse">
                                            Đơn mới chờ xác nhận
                                        </span>
                                    </div>

                                    <div class="mt-4 p-4 rounded-xl bg-slate-50 border border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                                        <div class="flex items-center gap-3">
                                            <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center text-lg font-bold shrink-0">
                                                <i class="fa-solid fa-leaf"></i>
                                            </div>
                                            <div>
                                                <div class="text-xs font-black text-slate-900">
                                                    Nông sản tươi có sẵn &amp; đạt chuẩn chất lượng? (Fresh fruit available &amp; qualified?)
                                                </div>
                                                <div class="text-[11px] text-slate-500 mt-0.5">
                                                    Kiểm tra số lượng tồn kho lạnh và chất lượng quả tươi đạt chuẩn trước khi tiếp nhận đóng gói.
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mt-5 grid grid-cols-1 sm:grid-cols-2 gap-3">
                                        <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="m-0">
                                            <input type="hidden" name="action" value="confirm">
                                            <input type="hidden" name="code" value="${subOrder.subOrderCode}">
                                            <button type="submit" class="w-full py-3 px-4 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs flex items-center justify-center gap-2 cursor-pointer">
                                                <i class="fa-solid fa-check"></i>
                                                <span>Đạt Chuẩn - Tiếp Nhận &amp; Đóng Gói</span>
                                            </button>
                                        </form>

                                        <button type="button" class="btn-open-cancel-modal w-full py-3 px-4 rounded-xl bg-white hover:bg-rose-50 text-rose-600 border border-rose-300 hover:border-rose-400 font-extrabold text-xs transition flex items-center justify-center gap-2 cursor-pointer">
                                            <i class="fa-solid fa-ban"></i>
                                            <span>Hết Hàng / Quả Hỏng - Hủy Đơn</span>
                                        </button>
                                    </div>
                                </div>
                            </c:when>

                            <%-- CASE 3: ĐANG ĐÓNG GÓI (PACKING) --%>
                            <c:when test="${subOrder.status eq 'PACKING' or empty subOrder.status}">
                                <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                                    <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                                        <div class="flex items-center gap-2.5">
                                            <div class="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center text-sm font-bold">
                                                <i class="fa-solid fa-boxes-packing"></i>
                                            </div>
                                            <h2 class="text-base font-extrabold text-slate-900">Danh sách kiểm tra</h2>
                                        </div>
                                        <span id="qcProgressBadge" class="px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-xs border border-blue-200/60 transition-all">
                                            Bắt buộc hoàn thành <span id="qcCount">0</span>/4
                                        </span>
                                    </div>

                                    <form id="formReadyToShip" action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="mt-4 space-y-4">
                                        <input type="hidden" name="action" value="ready_to_ship">
                                        <input type="hidden" name="code" value="${subOrder.subOrderCode}">

                                        <div class="space-y-2.5">
                                            <label class="qc-check-label flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                                <input type="checkbox" class="qc-check w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                                <span class="text-xs font-semibold text-slate-800">Đã kiểm tra đúng sản phẩm và số lượng</span>
                                            </label>

                                            <label class="qc-check-label flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                                <input type="checkbox" class="qc-check w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                                <span class="text-xs font-semibold text-slate-800">Đã kiểm tra chất lượng trái cây</span>
                                            </label>

                                            <label class="qc-check-label flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                                <input type="checkbox" class="qc-check w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                                <span class="text-xs font-semibold text-slate-800">Đã chuẩn bị bao bì phù hợp</span>
                                            </label>

                                            <label class="qc-check-label flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                                <input type="checkbox" class="qc-check w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                                <span class="text-xs font-semibold text-slate-800">Đã đáp ứng yêu cầu bảo quản của đơn</span>
                                            </label>
                                        </div>

                                        <c:choose>
                                            <c:when test="${not empty shopShippers}">
                                                <div class="p-3.5 bg-slate-50 rounded-xl border border-slate-200">
                                                    <label for="driverUserIdSelect" class="block text-xs font-bold text-slate-700 mb-1.5">
                                                        <i class="fa-solid fa-motorcycle text-emerald-600 mr-1"></i> Phân công nhân viên giao hàng của Shop: <span class="text-rose-500">*</span>
                                                    </label>
                                                    <select name="driverUserId" id="driverUserIdSelect" required class="w-full p-2.5 text-xs rounded-lg border border-slate-300 bg-white focus:outline-none focus:border-emerald-500">
                                                        <option value="">-- Chọn 1 nhân viên giao hàng của Shop --</option>
                                                        <c:forEach items="${shopShippers}" var="shp">
                                                            <option value="${shp.userId}" ${shp.userId eq subOrder.driverId ? 'selected' : ''}>
                                                                ${shp.fullName} (${shp.phone}) - ${shp.licensePlate} [${shp.availabilityLabel}]
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="p-3.5 bg-amber-50 rounded-xl border border-amber-200 text-amber-900 text-xs">
                                                    <div class="flex items-center gap-2 font-bold mb-1">
                                                        <i class="fa-solid fa-triangle-exclamation text-amber-600"></i>
                                                        <span>Shop chưa có nhân viên giao hàng</span>
                                                    </div>
                                                    <p class="text-[11px] text-amber-700 leading-relaxed mb-2">
                                                        Để chỉ định người giao đơn hoa quả, vui lòng thêm hoặc đăng ký tài khoản cho nhân viên giao hàng của Shop.
                                                    </p>
                                                    <a href="${pageContext.request.contextPath}/shop/shippers" target="_blank" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-[11px] transition">
                                                        <i class="fa-solid fa-user-plus"></i> Thêm nhân viên giao hàng ngay
                                                    </a>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>

                                        <button type="submit" id="btnFinishPacking" disabled class="w-full py-3 px-4 rounded-xl bg-slate-200 text-slate-400 font-extrabold text-sm transition shadow-sm flex items-center justify-center gap-2 cursor-not-allowed">
                                            <i class="fa-solid fa-box-check"></i> Hoàn tất đóng gói &amp; Báo sẵn sàng giao
                                        </button>
                                    </form>
                                </div>
                            </c:when>

                            <%-- CASE 4: GIAO THẤT BẠI / HOÀN HÀNG (FAILED / RETURNED) --%>
                            <c:when test="${isFailedOrder}">
                                <div class="bg-white rounded-2xl border border-rose-200 p-6 shadow-xs bg-rose-50/20">
                                    <div class="flex items-start gap-4">
                                        <div class="w-11 h-11 rounded-2xl bg-rose-100 text-rose-600 flex items-center justify-center text-xl font-bold shrink-0 shadow-2xs border border-rose-200">
                                            <i class="fa-solid fa-truck-ramp-box"></i>
                                        </div>
                                        <div class="flex-1 min-w-0">
                                            <div class="flex flex-wrap items-center justify-between gap-2 pb-3 border-b border-rose-100">
                                                <div class="flex items-center gap-2">
                                                    <h2 class="text-base font-extrabold text-rose-950">Giao Hàng Thất Bại &amp; Kích Hoạt Hoàn Hàng</h2>
                                                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black bg-rose-100 text-rose-700 border border-rose-300 uppercase">
                                                        GIAO THẤT BẠI
                                                    </span>
                                                </div>
                                                <c:if test="${not empty subOrder.deliveredAt or not empty subOrder.updatedAt}">
                                                    <span class="text-xs text-rose-600 font-medium">
                                                        <i class="fa-regular fa-clock mr-1"></i>
                                                        <fmt:formatDate value="${not empty subOrder.deliveredAt ? subOrder.deliveredAt : subOrder.updatedAt}" pattern="HH:mm dd/MM/yyyy" />
                                                    </span>
                                                </c:if>
                                            </div>

                                            <div class="mt-3.5 p-3.5 rounded-xl bg-white border border-rose-200/90 text-xs space-y-2 shadow-2xs">
                                                <div class="flex items-center justify-between">
                                                    <div class="font-extrabold text-rose-800 flex items-center gap-1.5">
                                                        <i class="fa-solid fa-triangle-exclamation text-rose-600"></i> Lý do giao không thành công từ Shipper / Khách:
                                                    </div>
                                                    <span class="font-mono text-[11px] text-slate-500">Mã vận đơn: <b>${subOrder.trackingNumber}</b></span>
                                                </div>
                                                <div class="text-slate-800 leading-relaxed font-semibold pl-4 border-l-2 border-rose-400 bg-rose-50/40 p-2 rounded-r-lg">
                                                    ${not empty subOrder.cancelReason ? subOrder.cancelReason : (not empty subOrder.failureReason ? subOrder.failureReason : 'Khách hàng từ chối nhận hoa quả khi đồng kiểm hoặc không liên lạc được.')}
                                                </div>
                                                <c:if test="${not empty subOrder.driverName}">
                                                    <div class="text-[11px] text-slate-500 pt-1 border-t border-slate-100 flex items-center justify-between">
                                                        <span>Tài xế bàn giao: <b class="text-slate-800">${subOrder.driverName}</b> <c:if test="${not empty subOrder.driverPhone}">(${subOrder.driverPhone})</c:if></span>
                                                        <span class="text-emerald-700 font-bold"><i class="fa-solid fa-snowflake"></i> Xe lạnh bảo ôn Gốc Vườn</span>
                                                    </div>
                                                </c:if>
                                            </div>

                                            <div class="mt-3 flex items-start gap-2.5 text-xs text-slate-700 bg-amber-50/80 border border-amber-200 p-3 rounded-xl">
                                                <i class="fa-solid fa-circle-info text-amber-600 text-sm mt-0.5 shrink-0"></i>
                                                <div class="leading-relaxed">
                                                    <b>Tiến trình hỗ trợ Gian hàng:</b> Hệ thống đã tự động ghi nhận khiếu nại hoàn trả. Kiện hàng nông sản tươi sẽ được tài xế chuyển hoàn về kho/vườn của bạn. Mọi hỗ trợ xin liên hệ tổng đài <b>1900 6868</b>.
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>

                            <%-- CASE 5: ĐÃ GIAO THÀNH CÔNG (DELIVERED / COMPLETED) --%>
                            <c:when test="${isDeliveredOrder}">
                                <div class="bg-white rounded-2xl border border-teal-200 p-6 shadow-xs bg-teal-50/20">
                                    <div class="flex items-center justify-between pb-3 border-b border-teal-100">
                                        <div class="flex items-center gap-2.5">
                                            <div class="w-8 h-8 rounded-lg bg-teal-600 text-white flex items-center justify-center text-sm font-bold shadow-xs">
                                                <i class="fa-solid fa-circle-check"></i>
                                            </div>
                                            <div>
                                                <h2 class="text-base font-extrabold text-slate-900">Đơn Hàng Đã Giao Thành Công</h2>
                                                <p class="text-[11px] text-slate-500">Khách hàng đã nhận và đồng kiểm chất lượng hoa quả tươi đạt chuẩn</p>
                                            </div>
                                        </div>
                                        <span class="px-3 py-1 rounded-full text-xs font-black bg-teal-100 text-teal-800 border border-teal-300">
                                            HOÀN TẤT GIAO HÀNG
                                        </span>
                                    </div>
                                    <div class="mt-4 p-4 rounded-xl bg-white border border-teal-200 text-xs text-slate-700 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                                        <div>
                                            <div class="font-bold text-slate-900">Vận chuyển lạnh Gốc Vườn Express (GVX)</div>
                                            <div class="text-slate-500 text-[11px] mt-0.5">Mã vận đơn: <b class="font-mono text-teal-800 text-xs">${not empty subOrder.trackingNumber ? subOrder.trackingNumber : subOrder.subOrderCode}</b></div>
                                        </div>
                                        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-teal-50 text-teal-700 font-extrabold text-xs">
                                            <i class="fa-solid fa-box-check"></i> Đã tới tay khách hàng
                                        </div>
                                    </div>
                                </div>
                            </c:when>

                            <%-- CASE: GIAO THẤT BẠI - CHUYỂN HOÀN VỀ SHOP (RETURNED / FAILED) --%>
                            <c:when test="${subOrder.status eq 'RETURNED' or subOrder.status eq 'FAILED' or subOrder.deliveryStatus eq 'FAILED'}">
                                <div class="bg-white rounded-2xl border border-rose-300 p-6 shadow-xs bg-rose-50/20 space-y-5">
                                    <div class="flex items-start justify-between pb-4 border-b border-rose-200">
                                        <div class="flex items-center gap-3">
                                            <div class="w-10 h-10 rounded-xl bg-rose-100 text-rose-600 flex items-center justify-center text-lg font-bold border border-rose-200 shadow-2xs">
                                                <i class="fa-solid fa-rotate-left"></i>
                                            </div>
                                            <div>
                                                <h2 class="text-base font-extrabold text-slate-900">Kiện Hàng Giao Thất Bại &amp; Chuyển Hoàn Về Shop</h2>
                                                <p class="text-[11px] text-slate-500">Shipper đã mang kiện hàng hoàn về lại Gian hàng. Vui lòng mở thùng kiểm định độ tươi và đá gel.</p>
                                            </div>
                                        </div>
                                        <span class="px-3 py-1 rounded-full text-xs font-black bg-rose-100 text-rose-800 border border-rose-300">
                                            CHỜ KIỂM ĐỊNH HÀNG HOÀN
                                        </span>
                                    </div>

                                    <!-- Thông tin lý do giao thất bại từ Shipper -->
                                    <div class="p-3.5 rounded-xl bg-white border border-rose-200 text-xs space-y-1 shadow-2xs">
                                        <div class="font-extrabold text-rose-800 flex items-center gap-1.5">
                                            <i class="fa-solid fa-triangle-exclamation text-rose-600"></i>
                                            <span>Lý do chuyển hoàn từ tài xế / Shipper:</span>
                                        </div>
                                        <div class="text-slate-800 leading-relaxed font-semibold pl-4 border-l-2 border-rose-400">
                                            ${not empty subOrder.cancelReason ? subOrder.cancelReason : "Khách hàng từ chối nhận hoa quả hoặc không liên lạc được khi giao."}
                                        </div>
                                    </div>

                                    <c:choose>
                                        <%-- ĐÃ XỬ LÝ KIỂM ĐỊNH XONG --%>
                                        <c:when test="${not empty subOrder.cancelReason and subOrder.cancelReason.contains('[ĐÃ XỬ LÝ')}">
                                            <div class="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs flex items-center gap-3 shadow-2xs">
                                                <div class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-700 flex items-center justify-center text-base shrink-0 font-bold">
                                                    <i class="fa-solid fa-circle-check"></i>
                                                </div>
                                                <div>
                                                    <div class="font-black text-emerald-950 text-sm">Đã Hoàn Tất Kiểm Định Hàng Hoàn</div>
                                                    <div class="text-[11px] text-emerald-800 mt-0.5">Số liệu tồn kho và sổ hao hụt đã được cập nhật chính xác theo kết quả kiểm định.</div>
                                                </div>
                                            </div>
                                        </c:when>

                                        <%-- CHƯA XỬ LÝ -> HIỂN THỊ 2 NÚT THAO TÁC --%>
                                        <c:otherwise>
                                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-1">
                                                <!-- LỰA CHỌN 1: QUẢ CÒN TƯƠI NGUYÊN (NHẬP KHO) -->
                                                <div class="p-4 rounded-xl border border-emerald-200 bg-emerald-50/40 flex flex-col justify-between space-y-3">
                                                    <div class="space-y-1">
                                                        <div class="flex items-center gap-2 text-emerald-800 font-extrabold text-xs">
                                                            <i class="fa-solid fa-seedling text-emerald-600"></i>
                                                            <span>1. Hoa Quả Còn Tươi Nguyên</span>
                                                        </div>
                                                        <p class="text-[11px] text-slate-600 leading-relaxed">
                                                            Đá gel còn lạnh sâu, hoa quả còn tươi cứng, không dập nát ➔ <b>Cộng hoàn lại 100% vào kho bán</b>.
                                                        </p>
                                                    </div>
                                                    <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" onsubmit="return confirm('Bạn có chắc chắn hoa quả còn tươi nguyên và muốn nhập lại kho bán?');">
                                                        <input type="hidden" name="action" value="return_restock">
                                                        <input type="hidden" name="code" value="${subOrder.subOrderCode}">
                                                        <input type="hidden" name="restockNote" value="Kiểm tra kiện hoàn: Đá gel còn lạnh, hoa quả đạt chuẩn xuất kho lại">
                                                        <button type="submit" class="w-full py-2.5 px-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold text-xs transition shadow-2xs flex items-center justify-center gap-2 cursor-pointer">
                                                            <i class="fa-solid fa-box-open"></i>
                                                            <span>Xác Nhận Hàng Tươi - Nhập Lại Kho</span>
                                                        </button>
                                                    </form>
                                                </div>

                                                <!-- LỰA CHỌN 2: BỊ HỎNG DO VẬN CHUYỂN (TIÊU HỦY) -->
                                                <div class="p-4 rounded-xl border border-rose-200 bg-rose-50/40 flex flex-col justify-between space-y-3">
                                                    <div class="space-y-1">
                                                        <div class="flex items-center gap-2 text-rose-800 font-extrabold text-xs">
                                                            <i class="fa-solid fa-triangle-exclamation text-rose-600"></i>
                                                            <span>2. Đứt Chuỗi Lạnh / Dập Nát Hỏng</span>
                                                        </div>
                                                        <p class="text-[11px] text-slate-600 leading-relaxed">
                                                            Hoa quả bị chảy nước, nát thối do vận chuyển quá lâu hoặc va đập ➔ <b>Tiêu hủy và ghi nhận vào Nhật ký hao hụt</b>.
                                                        </p>
                                                    </div>
                                                    <button type="button" id="btnOpenReturnWasteModal" class="w-full py-2.5 px-3 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-2xs flex items-center justify-center gap-2 cursor-pointer">
                                                        <i class="fa-solid fa-trash-can"></i>
                                                        <span>Báo Hỏng / Tiêu Hủy Do Vận Chuyển</span>
                                                    </button>
                                                </div>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:when>

                            <%-- CASE 6: SẴN SÀNG GIAO / CHỜ XE LẠNH / ĐANG VẬN CHUYỂN --%>
                            <c:otherwise>
                                <div class="bg-white rounded-2xl border border-emerald-200 p-6 shadow-xs bg-emerald-50/20">
                                    <div class="flex items-center justify-between pb-3 border-b border-emerald-100">
                                        <div class="flex items-center gap-2.5">
                                            <div class="w-8 h-8 rounded-lg bg-emerald-600 text-white flex items-center justify-center text-sm font-bold shadow-xs">
                                                <i class="fa-solid fa-truck-fast"></i>
                                            </div>
                                            <div>
                                                <h2 class="text-base font-extrabold text-slate-900">Sẵn Sàng Giao - Chờ Bàn Giao Xe Lạnh</h2>
                                                <p class="text-[11px] text-slate-500">Kiện hàng đã hoàn tất đóng gói, bảo quản nhiệt độ mát 2-5°C chờ tài xế</p>
                                            </div>
                                        </div>
                                        <span class="px-3 py-1 rounded-full text-xs font-black bg-emerald-100 text-emerald-800 border border-emerald-300">
                                            CHỜ BÀN GIAO
                                        </span>
                                    </div>
                                    <div class="mt-4 p-4 rounded-xl bg-white border border-emerald-200 text-xs text-slate-700 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                                        <div>
                                            <div class="font-bold text-slate-900">Vận chuyển lạnh Gốc Vườn Express (GVX)</div>
                                            <div class="text-slate-500 text-[11px] mt-0.5">Mã vận đơn: <b class="font-mono text-emerald-800 text-xs">${not empty subOrder.trackingNumber ? subOrder.trackingNumber : subOrder.subOrderCode}</b></div>
                                        </div>
                                        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 font-extrabold text-xs">
                                            <i class="fa-solid fa-snowflake"></i> Thùng bảo ôn 2-5°C
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
