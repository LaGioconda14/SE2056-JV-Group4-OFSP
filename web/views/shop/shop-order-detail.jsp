<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Chi Tiết Đơn Hàng Con #${subOrder.subOrderCode} | Gốc Vườn Seller Center</title>
        <jsp:include page="/views/shop/layout/head.jsp" />





        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-order-detail.css">
        <script src="${pageContext.request.contextPath}/assets/js/shop-order-detail.js"></script>
    </head>

    <body class="bg-[#f8fafc] text-[#0f172a]">

        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="active" value="orders" />
        </jsp:include>

        <div class="shop-main-wrapper">

            <jsp:include page="/views/shop/layout/header.jsp" />

            <main class="shop-content-container">

                <div class="flex items-center justify-between text-xs text-slate-500">
                    <div class="flex items-center gap-2">
                        <a href="${pageContext.request.contextPath}/shop/products" class="hover:text-emerald-700 transition">Kênh Người Bán</a>
                        <span>&gt;</span>
                        <a href="${pageContext.request.contextPath}/shop/orders" class="hover:text-emerald-700 transition">Quản lý đơn hàng</a>
                        <span>&gt;</span>
                        <span class="font-bold text-slate-800">Chi tiết đơn con #${subOrder.subOrderCode}</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/shop/orders" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-xs font-semibold text-slate-600 hover:bg-slate-50 hover:text-emerald-700 transition shadow-2xs">
                        <i class="fa-solid fa-arrow-left text-[10px]"></i> Quay lại danh sách
                    </a>
                </div>

                <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                    <div>
                        <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight">
                            Chi tiết đơn hàng con: #${subOrder.subOrderCode}
                        </h1>
                        <div class="flex flex-wrap items-center gap-2.5 mt-2 text-xs">
                            <span class="px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 font-bold border border-slate-200">
                                Đơn Tổng: #${subOrder.orderCode}
                            </span>
                            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-md bg-emerald-50 text-emerald-700 font-bold border border-emerald-200">
                                <i class="fa-solid fa-snowflake text-[10px] text-emerald-600"></i> ${not empty subOrder.deliverySlot ? subOrder.deliverySlot : "Tiêu chuẩn"}
                            </span>
                            <span class="text-slate-500 font-medium">
                                <i class="fa-regular fa-clock text-slate-400 mr-1"></i> 
                                <fmt:formatDate value="${subOrder.createdAt}" pattern="HH:mm dd/MM/yyyy" />
                            </span>
          
                        </div>
                    </div>
                </div>

                <c:set var="isFailedOrder" value="${subOrder.status eq 'RETURNED' or subOrder.status eq 'FAILED' or subOrder.deliveryStatus eq 'FAILED'}" />
                <c:set var="isDeliveredOrder" value="${subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED'}" />
                <div class="bg-white rounded-2xl border border-slate-200 p-5 shadow-xs">
                    <div class="flex items-start justify-between relative">
                        
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <div class="w-9 h-9 rounded-full bg-emerald-600 text-white flex items-center justify-center font-bold text-sm shadow-sm ring-4 ring-emerald-50">
                                <i class="fa-solid fa-check"></i>
                            </div>
                            <div class="mt-2.5 font-extrabold text-xs text-slate-900">Đã Tạo Đơn Con</div>
                            <div class="text-[11px] text-slate-400 mt-0.5"><fmt:formatDate value="${subOrder.createdAt}" pattern="HH:mm dd/MM" /></div>
                        </div>

                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <c:choose>
                                <c:when test="${subOrder.status eq 'CANCELLED'}">
                                    <div class="w-9 h-9 rounded-full bg-rose-600 text-white ring-4 ring-rose-100 flex items-center justify-center font-bold text-sm shadow-sm">
                                        <i class="fa-solid fa-ban"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-rose-600">Đã Hủy Đơn</div>
                                    <div class="text-[11px] text-rose-500 font-semibold mt-0.5 truncate max-w-[140px]" title="${subOrder.cancelReason}">
                                        ${not empty subOrder.cancelReason ? subOrder.cancelReason : "Đơn hàng đã bị hủy"}
                                    </div>
                                </c:when>
                                <c:when test="${subOrder.status eq 'NEW'}">
                                    <div class="w-9 h-9 rounded-full bg-amber-500 text-white ring-4 ring-amber-100 flex items-center justify-center font-bold text-sm shadow-sm animate-pulse">
                                        <i class="fa-solid fa-clock"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-amber-700">Chờ Shop Duyệt</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">Kiểm định tồn kho</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm shadow-sm">
                                        <i class="fa-solid fa-check"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-slate-900">Shop Xác Nhận</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">Tiếp nhận nông sản</div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <c:choose>
                                <c:when test="${subOrder.status eq 'PACKING'}">
                                    <div class="w-9 h-9 rounded-full bg-emerald-700 text-white ring-4 ring-emerald-100 shadow-md scale-110 flex items-center justify-center font-bold text-sm animate-pulse">
                                        <i class="fa-solid fa-box-open"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-emerald-700">Đang Đóng Gói</div>
                                    <div class="text-[11px] text-emerald-700 font-semibold mt-0.5">QC độ tươi &amp; đá gel</div>
                                </c:when>
                                <c:when test="${subOrder.status eq 'SHIPPING' or isDeliveredOrder or isFailedOrder}">
                                    <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm shadow-sm">
                                        <i class="fa-solid fa-check"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-slate-900">Đã Đóng Gói</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">Đạt chuẩn xuất kho</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="w-9 h-9 rounded-full bg-slate-200 text-slate-400 flex items-center justify-center font-bold text-sm">
                                        <i class="fa-solid fa-box-open"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-slate-400">Đang Đóng Gói</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">QC độ tươi &amp; đá gel</div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <c:choose>
                                <c:when test="${subOrder.status eq 'SHIPPING'}">
                                    <div class="w-9 h-9 rounded-full bg-emerald-700 text-white ring-4 ring-emerald-100 shadow-md scale-110 flex items-center justify-center font-bold text-sm animate-pulse">
                                        <i class="fa-solid fa-truck-fast"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-emerald-700">Đang Vận Chuyển</div>
                                    <div class="text-[11px] text-emerald-700 font-semibold mt-0.5">Xe lạnh tiếp nhận</div>
                                </c:when>
                                <c:when test="${isDeliveredOrder or isFailedOrder}">
                                    <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm shadow-sm">
                                        <i class="fa-solid fa-check"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-slate-900">Đã Bàn Giao Xe Lạnh</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">Tài xế giao hàng</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="w-9 h-9 rounded-full bg-slate-200 text-slate-400 flex items-center justify-center font-bold text-sm">
                                        <i class="fa-solid fa-truck-fast"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-slate-400">Chờ Bàn Giao Xe Lạnh</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">Xe lạnh tiếp nhận</div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <c:choose>
                                <c:when test="${isFailedOrder}">
                                    <div class="w-9 h-9 rounded-full bg-rose-600 text-white ring-4 ring-rose-100 shadow-md flex items-center justify-center font-bold text-sm">
                                        <i class="fa-solid fa-circle-xmark"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-rose-600">Giao Hàng Thất Bại</div>
                                    <div class="text-[11px] text-rose-500 font-semibold mt-0.5 truncate max-w-[140px]" title="${not empty subOrder.cancelReason ? subOrder.cancelReason : 'Khách từ chối nhận'}">
                                        <c:out value="${not empty subOrder.cancelReason ? subOrder.cancelReason : 'Khách từ chối nhận'}"/>
                                    </div>
                                </c:when>
                                <c:when test="${isDeliveredOrder}">
                                    <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm">
                                        <i class="fa-solid fa-circle-check"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-emerald-700">Giao Thành Công</div>
                                    <div class="text-[11px] text-emerald-600 font-medium mt-0.5">Đã tới tay khách</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="w-9 h-9 rounded-full bg-slate-200 text-slate-400 flex items-center justify-center font-bold text-sm">
                                        <i class="fa-solid fa-circle-check"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-slate-400">Giao Thành Công</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">Chờ giao khách</div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="absolute top-4 left-16 right-16 h-1 bg-slate-200 -z-0">
                            <div class="h-full ${subOrder.status eq 'CANCELLED' or isFailedOrder ? 'bg-rose-500' : 'bg-emerald-600'} transition-all duration-500 ${subOrder.status eq 'CANCELLED' or subOrder.status eq 'NEW' ? 'w-1/4' : (subOrder.status eq 'PACKING' ? 'w-2/4' : (subOrder.status eq 'SHIPPING' ? 'w-3/4' : 'w-full'))}"></div>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">

                    <div class="lg:col-span-8 space-y-5">

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
                                                <i class="fa-solid fa-box-open"></i>
                                            </div>
                                            <div>
                                                <h2 class="text-base font-extrabold text-slate-900">Quy Chuẩn Kiểm Soát Đóng Gói Lạnh</h2>
                                                <p class="text-[11px] text-slate-400">Kiểm tra và tick chọn 4 tiêu chuẩn bảo quản xuất xưởng</p>
                                            </div>
                                        </div>
                                        <span id="qcProgressBadge" class="px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-xs border border-blue-200/60">
                                                Bắt buộc hoàn thành <span id="qcCount">0</span>/4
                                            </span>
                                    </div>

                                    <div class="mt-4 space-y-3">
                                        
                                        <label class="qc-check-label flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                            <input type="checkbox" class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                            <div class="flex-1 text-xs">
                                                <div class="font-bold text-slate-900">Đã kiểm tra chất lượng &amp; loại bỏ quả dập/hỏng</div>
                                                <div class="text-slate-500 text-[11px] mt-0.5">Soi kỹ bề mặt vỏ, kiểm tra độ đàn hồi, loại bỏ toàn bộ quả thâm úng để bảo quản lạnh an toàn.</div>
                                            </div>
                                        </label>

                                        <label class="qc-check-label flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                            <input type="checkbox" class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                            <div class="flex-1 text-xs">
                                                <div class="font-bold text-slate-900">Đã cân đủ trọng lượng tịnh &amp; kiểm tra số lượng</div>
                                                <div class="text-slate-500 text-[11px] mt-0.5">
                                                    Chi tiết đóng gói: 
                                                    <c:forEach items="${subOrder.items}" var="it" varStatus="st">
                                                        <span class="font-medium text-slate-800">${it.productNameSnapshot} (x${it.quantity} ${it.unit})</span>${!st.last ? ', ' : ''}
                                                    </c:forEach>
                                                </div>
                                            </div>
                                        </label>

                                        <label class="qc-check-label flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                            <input type="checkbox" class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                            <div class="flex-1 text-xs">
                                                <div class="font-bold text-slate-900">Đã đóng gói thùng xốp chuyên dụng &amp; chèn túi đá gel bảo ôn mát</div>
                                                <div class="text-slate-500 text-[11px] mt-0.5">Đặt túi đá gel cách nhiệt có vách ngăn xốp chống đọng ẩm trực tiếp lên quả tươi.</div>
                                            </div>
                                        </label>

                                        <label class="qc-check-label flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                            <input type="checkbox" class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                            <div class="flex-1 text-xs">
                                                <div class="font-bold text-slate-900">Đã dán tem niêm phong và mã vận đơn #${subOrder.subOrderCode}</div>
                                                <div class="text-slate-500 text-[11px] mt-0.5">Mã barcode ${subOrder.trackingNumber} in rõ nét trên nắp thùng và mặt bên.</div>
                                            </div>
                                        </label>
                                    </div>

                                    <div class="mt-4 pt-3 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs border-t border-slate-100">
                                        <button type="button" class="btn-open-cancel-modal text-rose-600 hover:text-rose-700 font-bold text-xs inline-flex items-center gap-1.5 cursor-pointer">
                                            <i class="fa-solid fa-triangle-exclamation"></i> Phát hiện hàng lỗi hỏng không đủ cung cấp? Hủy đơn
                                        </button>
                                        <div class="flex items-center gap-1.5 text-emerald-700 font-semibold text-[11px]">
                                            <i class="fa-solid fa-shield-check text-emerald-600"></i> Bảo chứng chất lượng VietGAP &amp; OCOP
                                        </div>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="mt-3 space-y-3">
                                        <input type="hidden" name="action" value="ready_to_ship">
                                        <input type="hidden" name="code" value="${subOrder.subOrderCode}">
                                        <c:if test="${not empty shopShippers}">
                                            <div class="p-3 bg-slate-50 rounded-xl border border-slate-200">
                                                <label class="block text-xs font-bold text-slate-700 mb-1">
                                                    <i class="fa-solid fa-motorcycle text-emerald-600 mr-1"></i> Phân công nhân viên giao hàng của Shop:
                                                </label>
                                                <select name="driverUserId" class="w-full p-2 text-xs rounded-lg border border-slate-300 bg-white focus:outline-none focus:border-emerald-500">
                                                    <option value="">-- Tự động chọn shipper sẵn sàng gần nhất của Shop --</option>
                                                    <c:forEach items="${shopShippers}" var="shp">
                                                        <option value="${shp.userId}" ${shp.userId eq subOrder.driverId ? 'selected' : ''}>
                                                            ${shp.fullName} (${shp.phone}) - ${shp.licensePlate} [${shp.availabilityLabel}]
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                        </c:if>
                                        <button type="submit" id="btnFinishPacking" class="w-full py-3 px-4 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-sm transition shadow-sm flex items-center justify-center gap-2 cursor-pointer">
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
                                            <i class="fa-solid fa-snowflake animate-spin"></i> Thùng bảo ôn 2-5°C
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                            <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                                <div class="flex items-center gap-2.5">
                                    <div class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center text-sm font-bold">
                                        <i class="fa-solid fa-bag-shopping"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-base font-extrabold text-slate-900">Thông Tin Sản Phẩm Nông Sản (${not empty subOrder.items ? subOrder.items.size() : 0} món)</h2>
                                        <p class="text-[11px] text-slate-400">Được bảo chứng nguồn gốc và kiểm định chất lượng xuất xưởng</p>
                                    </div>
                                </div>
                            </div>

                            <div class="mt-4 overflow-x-auto">
                                <table class="w-full text-left text-xs">
                                    <thead>
                                        <tr class="text-slate-400 font-bold border-b border-slate-100 text-[11px]">
                                            <th class="pb-2.5 w-64">SẢN PHẨM</th>
                                            <th class="pb-2.5 text-center">ĐƠN VỊ</th>
                                            <th class="pb-2.5 text-center">SỐ LƯỢNG</th>
                                            <th class="pb-2.5 text-right">ĐƠN GIÁ</th>
                                            <th class="pb-2.5 text-right">THÀNH TIỀN</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-100">
                                        <c:forEach items="${subOrder.items}" var="item">
                                            <tr>
                                                <td class="py-3.5">
                                                    <div class="flex items-center gap-3">
                                                        <c:choose>
                                                            <c:when test="${not empty item.imageUrl}">
                                                                <img src="${item.imageUrl}" alt="${item.productNameSnapshot}" class="w-14 h-14 rounded-xl object-cover border border-slate-100 shrink-0">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="w-14 h-14 rounded-xl bg-slate-100 border border-slate-200/60 flex items-center justify-center text-slate-400 shrink-0">
                                                                    <i class="fa-solid fa-image text-lg"></i>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <div>
                                                            <div class="flex items-center gap-2">
                                                                <span class="font-extrabold text-slate-900 text-xs">${item.productNameSnapshot}</span>
                                                                <c:if test="${not empty item.variantNameSnapshot}">
                                                                    <span class="px-1.5 py-0.5 rounded text-[9px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                                        ${item.variantNameSnapshot}
                                                                    </span>
                                                                </c:if>
                                                            </div>
                                                            <div class="text-[11px] text-slate-500 mt-0.5 flex flex-wrap items-center gap-2">
                                                                <span>SKU: <span class="font-mono text-slate-700">${item.skuSnapshot}</span></span>
                                                                <c:if test="${item.weightKg != null}">
                                                                    <span>• Trọng lượng: <b class="text-slate-700">${item.weightKg}kg/${item.unit}</b></span>
                                                                </c:if>
                                                                <span>• Tồn kho khả dụng: <span class="font-bold ${item.stockQuantity < 10 ? 'text-rose-600' : 'text-emerald-700'}">${item.stockQuantity} ${item.unit}</span></span>
                                                            </div>
                                                            <div class="text-[10px] text-emerald-700 font-semibold mt-1 flex flex-wrap items-center gap-2">
                                                                <span class="flex items-center gap-1">
                                                                    <i class="fa-solid fa-leaf text-[9px]"></i> 
                                                                    Xuất xứ: ${not empty item.origin ? item.origin : 'Nông trại đạt chuẩn'}
                                                                </span>
                                                                <c:if test="${not empty item.certification}">
                                                                    <span class="text-amber-700 font-bold">• ${item.certification}</span>
                                                                </c:if>
                                                                <c:if test="${not empty item.storageTemp}">
                                                                    <span class="text-blue-700 font-bold">• <i class="fa-solid fa-snowflake text-[8px]"></i> Bảo quản: ${item.storageTemp}</span>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="py-3.5 text-center font-medium text-slate-600">${item.unit}</td>
                                                <td class="py-3.5 text-center font-extrabold text-slate-900 text-sm">${item.quantity}</td>
                                                <td class="py-3.5 text-right font-medium text-slate-600">
                                                    <fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </td>
                                                <td class="py-3.5 text-right font-extrabold text-slate-900">
                                                    <fmt:formatNumber value="${item.totalPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <div class="mt-4 pt-3 border-t border-slate-100 space-y-1.5 text-xs">
                                <div class="flex justify-between text-slate-600">
                                    <span>Tiền hàng (Tạm tính ${not empty subOrder.items ? subOrder.items.size() : 0} sản phẩm):</span>
                                    <span class="font-bold text-slate-800">
                                        <fmt:formatNumber value="${subOrder.shopSubtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </span>
                                </div>
                                <div class="flex justify-between text-slate-600">
                                    <span class="flex items-center gap-1.5">
                                        Phí vận chuyển giao lạnh chuyên dụng: 
                                        <c:if test="${empty subOrder.shopShippingFee or subOrder.shopShippingFee == 0}">
                                            <span class="text-[10px] text-emerald-700 bg-emerald-50 px-1 rounded font-bold">Tài trợ bởi Shop</span>
                                        </c:if>
                                    </span>
                                    <span class="text-emerald-700 font-bold">
                                        <c:choose>
                                            <c:when test="${subOrder.shopShippingFee != null && subOrder.shopShippingFee > 0}">
                                                <fmt:formatNumber value="${subOrder.shopShippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </c:when>
                                            <c:otherwise>
                                                Miễn phí (₫0)
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="flex justify-between text-slate-600">
                                    <span>Chiết khấu Voucher Người bán:</span>
                                    <span class="text-slate-400">
                                        -<fmt:formatNumber value="${subOrder.shopDiscount != null ? subOrder.shopDiscount : 0}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </span>
                                </div>
                                <div class="pt-3 border-t border-slate-100 flex items-baseline justify-between">
                                    <div>
                                        <c:choose>
                                            <c:when test="${subOrder.paymentStatus eq 'PAID' or (not empty subOrder.paymentMethod and !subOrder.paymentMethod.toUpperCase().contains('COD'))}">
                                                <div class="text-sm font-extrabold text-slate-900">Tổng Tiền Đã Thanh Toán</div>
                                                <div class="text-[11px] text-emerald-600 font-bold">
                                                    <i class="fa-solid fa-circle-check"></i> Đã thanh toán qua ${subOrder.paymentMethod} (Không thu COD)
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="text-sm font-extrabold text-slate-900">Tổng Thu Hộ COD</div>
                                                <div class="text-[11px] text-slate-400">Người mua thanh toán tiền mặt khi nhận hàng tươi</div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="text-2xl font-black text-emerald-700">
                                        <fmt:formatNumber value="${subOrder.shopTotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                    <div class="lg:col-span-4 space-y-5">

                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                                <div class="flex items-center gap-2">
                                    <i class="fa-solid fa-location-dot text-emerald-600 text-sm"></i>
                                    <h3 class="text-sm font-extrabold text-slate-900">Thông Tin Người Nhận</h3>
                                </div>
                                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                    Khách Hàng
                                </span>
                            </div>

                            <div class="mt-4 flex items-center gap-3">
                                <div class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center font-extrabold text-sm shrink-0">
                                    ${not empty subOrder.shippingAddress.recipientName ? subOrder.shippingAddress.recipientName.substring(0, 1).toUpperCase() : 'KH'}
                                </div>
                                <div>
                                    <div class="text-sm font-extrabold text-slate-900">
                                        ${not empty subOrder.shippingAddress.recipientName ? subOrder.shippingAddress.recipientName : 'Khách Mua Hàng'}
                                    </div>
                                    <div class="text-[11px] text-slate-400">
                                        SĐT: ${not empty subOrder.shippingAddress.recipientPhone ? subOrder.shippingAddress.recipientPhone : 'Chưa có SĐT'} (Đã bảo mật)
                                    </div>
                                </div>
                            </div>

                            <div class="mt-4 pt-3 border-t border-slate-100">
                                <div class="text-[10px] font-bold text-slate-400 uppercase">ĐỊA CHỈ GIAO HÀNG TƯƠI:</div>
                                <div class="text-xs font-semibold text-slate-800 mt-1 leading-relaxed">
                                    <c:choose>
                                        <c:when test="${not empty subOrder.shippingAddress.streetAddress}">
                                            ${subOrder.shippingAddress.streetAddress}<c:if test="${not empty subOrder.shippingAddress.ward}">, ${subOrder.shippingAddress.ward}</c:if><c:if test="${not empty subOrder.shippingAddress.district}">, ${subOrder.shippingAddress.district}</c:if><c:if test="${not empty subOrder.shippingAddress.city}">, ${subOrder.shippingAddress.city}</c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-slate-400 italic">Chưa có thông tin địa chỉ chi tiết</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="mt-3.5 p-3 rounded-xl bg-slate-50 border border-slate-200 text-xs">
                                <div class="flex items-center gap-1.5 text-slate-700 font-bold text-[11px] mb-1">
                                    <i class="fa-regular fa-comment-dots"></i> GHI CHÚ GIAO HÀNG TỪ KHÁCH:
                                </div>
                                <p class="text-[11px] text-slate-600 leading-relaxed italic">
                                    <c:choose>
                                        <c:when test="${not empty subOrder.deliverySlot}">
                                            Khung giờ giao yêu cầu: <strong class="text-slate-800 not-italic">${subOrder.deliverySlot}</strong>
                                        </c:when>
                                        <c:otherwise>
                                            (Khách hàng không để lại ghi chú cho đơn hàng này)
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>

                        <!-- CARD: NHÂN VIÊN GIAO HÀNG CỦA SHOP -->
                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs space-y-4">
                            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                                <div class="flex items-center gap-2">
                                    <div class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center text-xs font-bold">
                                        <i class="fa-solid fa-motorcycle"></i>
                                    </div>
                                    <h3 class="text-sm font-extrabold text-slate-900">Nhân Viên Giao Hàng Của Shop</h3>
                                </div>
                                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-50 text-emerald-800 border border-emerald-200">
                                    Nội Bộ Shop
                                </span>
                            </div>

                            <c:choose>
                                <c:when test="${not empty subOrder.driverName}">
                                    <div class="flex items-start gap-3">
                                        <div class="relative">
                                            <img src="${not empty subOrder.driverAvatarUrl ? subOrder.driverAvatarUrl : 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&h=100&fit=crop'}" 
                                                 alt="${subOrder.driverName}" class="w-11 h-11 rounded-2xl object-cover border border-slate-200 shadow-2xs">
                                            <span class="absolute -bottom-1 -right-1 w-3.5 h-3.5 rounded-full border-2 border-white bg-emerald-500"></span>
                                        </div>
                                        <div class="flex-1 min-w-0">
                                            <div class="flex items-center justify-between">
                                                <div class="text-sm font-extrabold text-slate-900 truncate">
                                                    ${subOrder.driverName}
                                                </div>
                                                <a href="tel:${subOrder.driverPhone}" class="text-xs text-emerald-700 hover:text-emerald-800 font-bold flex items-center gap-1 bg-emerald-50 px-2 py-1 rounded-lg border border-emerald-200">
                                                    <i class="fa-solid fa-phone"></i> Gọi
                                                </a>
                                            </div>
                                            <div class="text-[11px] text-slate-500 mt-0.5">
                                                SĐT: <span class="font-semibold text-slate-800">${subOrder.driverPhone}</span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="p-3 rounded-xl bg-slate-50 border border-slate-200/80 space-y-1.5 text-xs">
                                        <div class="flex items-center justify-between text-slate-600">
                                            <span class="text-[11px] text-slate-400">Phương tiện:</span>
                                            <span class="font-bold text-slate-800">${not empty subOrder.driverVehicleType ? subOrder.driverVehicleType : 'Xe máy thùng lạnh'}</span>
                                        </div>
                                        <div class="flex items-center justify-between text-slate-600">
                                            <span class="text-[11px] text-slate-400">Biển số xe:</span>
                                            <span class="font-mono font-bold text-slate-900 bg-white px-2 py-0.5 rounded border border-slate-200 text-[11px]">
                                                ${not empty subOrder.driverVehiclePlate ? subOrder.driverVehiclePlate : '29-F1 888.88'}
                                            </span>
                                        </div>
                                        <div class="flex items-center justify-between text-slate-600">
                                            <span class="text-[11px] text-slate-400">Trạng thái vận chuyển:</span>
                                            <span class="font-bold text-emerald-700 text-[11px]">
                                                <c:choose>
                                                    <c:when test="${subOrder.deliveryStatus eq 'DELIVERED' or isDeliveredOrder}">Đã giao thành công</c:when>
                                                    <c:when test="${subOrder.deliveryStatus eq 'DELIVERING'}">Đang trên đường giao</c:when>
                                                    <c:when test="${subOrder.deliveryStatus eq 'FAILED' or isFailedOrder}">Giao không thành công</c:when>
                                                    <c:otherwise>Đã nhận lệnh - Chờ xuất kho</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </div>

                                    <c:if test="${subOrder.status ne 'CANCELLED' and not isDeliveredOrder and not isFailedOrder}">
                                        <button type="button" onclick="openAssignShipperModal()" class="w-full py-2 px-3 rounded-xl border border-slate-200 hover:border-slate-300 bg-white hover:bg-slate-50 text-slate-700 font-bold text-xs transition flex items-center justify-center gap-1.5 cursor-pointer">
                                            <i class="fa-solid fa-arrows-rotate text-slate-400"></i>
                                            <span>Đổi nhân viên giao hàng khác</span>
                                        </button>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-2">
                                        <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center mx-auto mb-2 text-base">
                                            <i class="fa-solid fa-user-clock"></i>
                                        </div>
                                        <div class="text-xs font-bold text-slate-800">Chưa phân công nhân viên giao hàng</div>
                                        <div class="text-[11px] text-slate-400 mt-0.5">Chọn một shipper của gian hàng để trực tiếp giao đơn này</div>

                                        <button type="button" onclick="openAssignShipperModal()" class="mt-3 w-full py-2.5 px-3 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs flex items-center justify-center gap-2 cursor-pointer">
                                            <i class="fa-solid fa-user-plus"></i>
                                            <span>Phân công shipper của shop ngay</span>
                                        </button>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <div class="pt-2 border-t border-slate-100 flex items-center justify-between text-[11px]">
                                <a href="${pageContext.request.contextPath}/shop/shippers" class="text-emerald-700 hover:text-emerald-800 font-bold flex items-center gap-1">
                                    <i class="fa-solid fa-users-gear"></i> Quản lý toàn bộ shipper của Shop
                                </a>
                                <span class="text-slate-400">(${not empty shopShippers ? shopShippers.size() : 0} shipper)</span>
                            </div>
                        </div>

                    </div>

                </div>

            </div>
        </main>

        <div id="cancelModalBackdrop" class="modal-backdrop hidden"></div>
        <div id="cancelOrderModal" class="modal-dialog hidden">
            <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-sm font-bold border border-rose-200">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900">Hủy Đơn Hàng Con #${subOrder.subOrderCode}</h3>
                        <p class="text-[10px] text-slate-400">Nông sản không đủ tồn kho hoặc không đạt chuẩn tươi</p>
                    </div>
                </div>
                <button type="button" id="btnCloseCancelModal" class="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="p-5 space-y-4">
                <input type="hidden" name="action" value="cancel_sub_order">
                <input type="hidden" name="code" value="${subOrder.subOrderCode}">

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-2">
                        1. Phân loại lý do hủy đơn <span class="text-rose-500">*</span>
                    </label>
                    <div class="space-y-2">
                        <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition is-selected">
                            <input type="radio" name="cancelReasonCategory" value="Hết hàng nông sản tồn kho" class="mt-0.5 text-rose-600" checked>
                            <div class="text-xs">
                                <div class="font-bold text-slate-800">Hết hàng nông sản tồn trong kho</div>
                                <div class="text-[11px] text-slate-400">Số lượng thực tế trong kho không đủ đáp ứng số lượng khách đặt.</div>
                            </div>
                        </label>
                        <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition">
                            <input type="radio" name="cancelReasonCategory" value="Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng)" class="mt-0.5 text-rose-600">
                            <div class="text-xs">
                                <div class="font-bold text-slate-800">Nông sản không đạt tiêu chuẩn chất lượng</div>
                                <div class="text-[11px] text-slate-400">Soi kiểm tra QC thấy hoa quả bị thâm úng, biến chất, sâu bệnh hoặc dập nát.</div>
                            </div>
                        </label>
                        <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition">
                            <input type="radio" name="cancelReasonCategory" value="Thời tiết bất thường / Không thu hoạch kịp" class="mt-0.5 text-rose-600">
                            <div class="text-xs">
                                <div class="font-bold text-slate-800">Thời tiết bất thường / Không thu hoạch kịp</div>
                                <div class="text-[11px] text-slate-400">Vườn không kịp thu hoạch quả tươi đạt chuẩn trong khung giờ hẹn.</div>
                            </div>
                        </label>
                        <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition">
                            <input type="radio" name="cancelReasonCategory" value="Lý do khác" class="mt-0.5 text-rose-600">
                            <div class="text-xs">
                                <div class="font-bold text-slate-800">Lý do phát sinh khác</div>
                            </div>
                        </label>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">
                        2. Ghi chú chi tiết cho khách hàng &amp; sàn <span class="text-rose-500">*</span>
                    </label>
                    <textarea name="cancelReasonNote" rows="3" required placeholder="Ghi chú chi tiết gửi khách hàng (VD: Lô dâu tây sáng nay về bị dập bề mặt do mưa, nhà vườn xin phép hủy đơn và hỗ trợ hoàn tiền)..." class="w-full p-2.5 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:border-rose-500"></textarea>
                </div>

                <div class="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-start gap-2">
                    <i class="fa-solid fa-circle-info text-amber-600 mt-0.5 text-sm"></i>
                    <div class="leading-relaxed">
                        <b>Quy trình tự động:</b> Sau khi xác nhận hủy, hệ thống Gốc Vườn sẽ <b>gửi thông báo ngay</b> đến khách hàng và <b>kích hoạt quy trình hoàn tiền</b>.
                    </div>
                </div>

                <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                    <button type="button" id="btnDismissCancelModal" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                        Đóng
                    </button>
                    <button type="submit" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer">
                        Xác Nhận Hủy Đơn
                    </button>
                </div>
            </form>
        </div>

        <!-- MODAL: PHÂN CÔNG NHÂN VIÊN GIAO HÀNG CHO ĐƠN CON -->
        <div id="assignShipperBackdrop" class="modal-backdrop hidden" onclick="closeAssignShipperModal()"></div>
        <div id="assignShipperModal" class="modal-dialog hidden w-full max-w-lg bg-white rounded-2xl border border-slate-200 shadow-2xl">
            <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                <div class="flex items-center gap-2.5">
                    <div class="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center text-base font-bold border border-emerald-200">
                        <i class="fa-solid fa-motorcycle"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900">Phân Công Nhân Viên Giao Hàng Của Shop</h3>
                        <p class="text-[11px] text-slate-400">Đơn hàng con: #${subOrder.subOrderCode}</p>
                    </div>
                </div>
                <button type="button" onclick="closeAssignShipperModal()" class="w-8 h-8 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="p-5 space-y-4">
                <input type="hidden" name="action" value="assign_shipper">
                <input type="hidden" name="code" value="${subOrder.subOrderCode}">

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-2">
                        Chọn một nhân viên giao hàng thuộc Shop <span class="text-rose-500">*</span>
                    </label>

                    <c:choose>
                        <c:when test="${not empty shopShippers}">
                            <div class="space-y-2 max-h-72 overflow-y-auto pr-1">
                                <c:forEach items="${shopShippers}" var="shp" varStatus="st">
                                    <label class="flex items-center justify-between p-3 rounded-xl border border-slate-200 hover:border-emerald-400 cursor-pointer transition bg-white has-[:checked]:border-emerald-500 has-[:checked]:bg-emerald-50/30">
                                        <div class="flex items-center gap-3">
                                            <input type="radio" name="driverUserId" value="${shp.userId}" class="text-emerald-600" ${st.first ? 'checked' : ''}>
                                            <img src="${not empty shp.avatarUrl ? shp.avatarUrl : 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&h=100&fit=crop'}" 
                                                 alt="${shp.fullName}" class="w-9 h-9 rounded-xl object-cover border border-slate-100">
                                            <div class="text-xs">
                                                <div class="font-extrabold text-slate-900 flex items-center gap-2">
                                                    <span>${shp.fullName}</span>
                                                    <span class="px-1.5 py-0.2 rounded text-[9px] font-black uppercase ${shp.availabilityBadgeClass}">
                                                        ${shp.availabilityLabel}
                                                    </span>
                                                </div>
                                                <div class="text-[11px] text-slate-500 mt-0.5">
                                                    SĐT: <b>${shp.phone}</b> • Biển số: <span class="font-mono font-bold">${shp.licensePlate}</span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="text-right text-[11px]">
                                            <span class="font-bold text-slate-700">${shp.activeOrderCount} đơn</span>
                                            <div class="text-[10px] text-slate-400">đang phụ trách</div>
                                        </div>
                                    </label>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="p-6 text-center border border-dashed border-slate-200 rounded-xl">
                                <i class="fa-solid fa-triangle-exclamation text-amber-500 text-2xl mb-2"></i>
                                <div class="text-xs font-bold text-slate-800">Shop chưa có nhân viên giao hàng nào</div>
                                <div class="text-[11px] text-slate-400 mt-1">Vui lòng thêm nhân viên giao hàng cho shop trước khi phân công.</div>
                                <a href="${pageContext.request.contextPath}/shop/shippers" class="mt-3 inline-block px-3 py-1.5 rounded-lg bg-emerald-700 text-white font-bold text-xs hover:bg-emerald-800">
                                    Thêm nhân viên ngay
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="p-3 rounded-xl bg-slate-50 border border-slate-200 text-slate-700 text-xs flex items-start gap-2">
                    <i class="fa-solid fa-circle-info text-emerald-600 mt-0.5 text-sm shrink-0"></i>
                    <div class="leading-relaxed">
                        Sau khi phân công, trạng thái đơn con sẽ được chuyển sang <b>Đang giao hàng (SHIPPING)</b> và tài xế của Shop sẽ trực tiếp nhận lệnh giao kiện hàng nông sản này.
                    </div>
                </div>

                <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                    <button type="button" onclick="closeAssignShipperModal()" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                        Đóng
                    </button>
                    <c:if test="${not empty shopShippers}">
                        <button type="submit" class="px-4 py-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer flex items-center gap-1.5">
                            <i class="fa-solid fa-check"></i>
                            <span>Xác Nhận Phân Công</span>
                        </button>
                    </c:if>
                </div>
            </form>
        </div>

        <script>
            function openAssignShipperModal() {
                var backdrop = document.getElementById('assignShipperBackdrop');
                var modal = document.getElementById('assignShipperModal');
                if (backdrop) backdrop.classList.remove('hidden');
                if (modal) modal.classList.remove('hidden');
            }
            function closeAssignShipperModal() {
                var backdrop = document.getElementById('assignShipperBackdrop');
                var modal = document.getElementById('assignShipperModal');
                if (backdrop) backdrop.classList.add('hidden');
                if (modal) modal.classList.add('hidden');
            }
        </script>
    </body>
</html>
