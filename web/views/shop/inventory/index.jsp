<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Kho & Cảnh báo tồn - Kênh Người Bán | Gốc Vườn Market</title>
        <jsp:include page="/views/shop/layout/head.jsp" />
        <style>
            .variant-card {
                margin-bottom: 1.25rem;
                border-radius: 1rem;
                border: 1px solid #e2e8f0;
                background-color: #ffffff;
                box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
                overflow: hidden;
                transition: all 0.2s ease-in-out;
            }
            .variant-card:hover {
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.07);
            }
        </style>
    </head>
    <body class="bg-[#f8fafc] text-[#0f172a]">

        <!-- Sidebar & Header chung của Kênh Người Bán -->
        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="active" value="inventory" />
        </jsp:include>
        <jsp:include page="/views/shop/layout/header.jsp">
            <jsp:param name="searchAction" value="/shop/inventory/batches" />
        </jsp:include>

        <main class="shop-main-wrapper">
            <div class="shop-content-container">

                <!-- Thông báo kết quả thao tác từ Servlet -->
                <c:if test="${not empty inventoryRestockMessage}">
                    <div class="px-4 py-3 rounded-xl text-sm font-semibold mb-4 ${inventoryRestockSuccess ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-rose-50 text-rose-700 border border-rose-200'}">
                        <c:out value="${inventoryRestockMessage}" />
                    </div>
                    <c:remove var="inventoryRestockMessage" scope="session" />
                    <c:remove var="inventoryRestockSuccess" scope="session" />
                </c:if>

                <c:if test="${not empty inventoryAdjustMessage}">
                    <div class="px-4 py-3 rounded-xl text-sm font-semibold mb-4 flex items-center justify-between gap-3 ${inventoryAdjustSuccess ? 'bg-emerald-50 text-emerald-800 border border-emerald-200' : 'bg-rose-50 text-rose-700 border border-rose-200'}">
                        <div class="flex items-center gap-2">
                            <i class="fa-solid ${inventoryAdjustSuccess ? 'fa-circle-check text-emerald-600' : 'fa-triangle-exclamation text-rose-600'}"></i>
                            <span><c:out value="${inventoryAdjustMessage}" /></span>
                        </div>
                        <c:if test="${inventoryAdjustSuccess}">
                            <a href="${pageContext.request.contextPath}/shop/waste" class="inline-flex items-center gap-1.5 px-3 py-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-bold transition text-decoration-none shrink-0 shadow-xs">
                                <span>Xem sổ hao hụt</span>
                                <i class="fa-solid fa-arrow-right text-[10px]"></i>
                            </a>
                        </c:if>
                    </div>
                    <c:remove var="inventoryAdjustMessage" scope="session" />
                    <c:remove var="inventoryAdjustSuccess" scope="session" />
                </c:if>

                <!-- 1. Header Tiêu đề & 4 Thẻ Thống kê KPI -->
                <jsp:include page="/views/shop/components/inventory/kpi-cards.jsp" />

                <!-- 2. Thanh lọc & Tìm kiếm -->
                <jsp:include page="/views/shop/components/inventory/toolbar.jsp" />

                <!-- 3. Danh sách Biến thể & Bảng Lô hàng FEFO (Accordion thuần HTML5 <details>) -->
                <jsp:include page="/views/shop/components/inventory/variant-accordion.jsp" />

            </div>
        </main>

        <!-- ==================== MODALS POPUP (100% SERVER-RENDERED, ZERO JAVASCRIPT) ==================== -->
        <jsp:include page="/views/shop/components/inventory/modal-restock.jsp" />
        <jsp:include page="/views/shop/components/inventory/modal-adjust.jsp" />
        <jsp:include page="/views/shop/components/inventory/modal-dispose.jsp" />
        <jsp:include page="/views/shop/components/inventory/modal-history.jsp" />

    </body>
</html>
