<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<fmt:setLocale value="vi_VN" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Chi Tiết Đơn Hàng Con | Gốc Vườn Seller Center</title>
        <jsp:include page="/views/shop/layout/head.jsp" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-order-detail.css">
        <script src="${pageContext.request.contextPath}/assets/js/shop-order-detail.js"></script>
    </head>

    <body class="bg-[#f8fafc] text-[#0f172a]">

        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="active" value="orders" />
        </jsp:include>

        <jsp:include page="/views/shop/layout/header.jsp" />

        <main class="shop-main-wrapper">
            <div class="shop-content-container">

                <div class="flex items-center justify-between text-xs text-slate-500">
                    <a href="${pageContext.request.contextPath}/shop/orders" 
                       class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-xs font-bold text-slate-600 hover:bg-slate-50 hover:text-emerald-700 transition shadow-2xs">
                        <i class="fa-solid fa-arrow-left text-[11px]"></i> Quay lại danh sách
                    </a>
                </div>

                <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                    <div>
                        <div class="flex items-center flex-wrap gap-3">
                            <h1 class="text-2xl font-black text-slate-900 tracking-tight">
                                Chi Tiết Đơn Hàng Con
                            </h1>
                        </div>
                        <c:set var="headerSlot" value="${subOrder.deliverySlot}" />
                        <c:if test="${not empty headerSlot and fn:contains(headerSlot, '• Lời nhắn:')}">
                            <c:set var="headerSlot" value="${fn:trim(fn:substringBefore(headerSlot, '• Lời nhắn:'))}" />
                        </c:if>
                        <c:if test="${not empty headerSlot and fn:contains(headerSlot, 'Lời nhắn:')}">
                            <c:set var="headerSlot" value="${fn:trim(fn:substringBefore(headerSlot, 'Lời nhắn:'))}" />
                        </c:if>
                        <div class="flex flex-wrap items-center gap-2.5 mt-2 text-xs">
                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-emerald-50 text-emerald-800 font-bold border border-emerald-200">
                                <i class="fa-solid fa-snowflake text-[10px] text-emerald-600"></i> ${not empty headerSlot ? headerSlot : "Tiêu chuẩn"}
                            </span>
                            <span class="text-slate-500 font-medium">
                                <i class="fa-regular fa-clock text-slate-400 mr-1"></i> 
                                <fmt:formatDate value="${subOrder.createdAt}" pattern="HH:mm dd/MM/yyyy" />
                            </span>
                        </div>
                    </div>
                </div>

                <jsp:include page="/views/shop/components/common/flash-message.jsp" />

                <c:if test="${param.error eq 'unpaid_vnpay' or not empty sessionScope.orderDetailError}">
                    <div class="p-4 rounded-2xl bg-rose-50 border border-rose-300 text-rose-900 text-xs flex items-center justify-between gap-3 shadow-xs">
                        <div class="flex items-center gap-3">
                            <div class="w-8 h-8 rounded-xl bg-rose-100 text-rose-700 flex items-center justify-center text-sm font-bold shrink-0">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                            </div>
                            <div>
                                <div class="font-extrabold text-rose-950">Không thể tiếp nhận đóng gói:</div>
                                <div class="text-[11px] text-rose-800 mt-0.5">
                                    ${not empty sessionScope.orderDetailError ? sessionScope.orderDetailError : "Đơn hàng chọn thanh toán qua VNPAY nhưng người mua chưa hoàn tất thanh toán. Gian hàng chỉ được tiếp nhận xác nhận sau khi khách hàng thanh toán thành công!"}
                                </div>
                            </div>
                        </div>
                        <button type="button" onclick="this.closest('div.bg-rose-50').remove()" class="text-rose-400 hover:text-rose-700 p-1 cursor-pointer">
                            <i class="fa-solid fa-xmark text-sm"></i>
                        </button>
                    </div>
                    <c:remove var="orderDetailError" scope="session"/>
                </c:if>

                <jsp:include page="/views/shop/components/order/order-stepper.jsp" />

                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
                    <div class="lg:col-span-8 space-y-5">
                        <jsp:include page="/views/shop/components/order/order-fulfillment-actions.jsp" />
                        <jsp:include page="/views/shop/components/order/order-items-card.jsp" />
                    </div>

                    <div class="lg:col-span-4 space-y-5">
                        <jsp:include page="/views/shop/components/order/order-customer-info.jsp" />
                    </div>
                </div>

            </div>
        </main>

        <jsp:include page="/views/shop/components/order/modal-cancel-order.jsp" />
        <jsp:include page="/views/shop/components/order/modal-return-waste.jsp" />

    </body>
</html>