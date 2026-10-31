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
