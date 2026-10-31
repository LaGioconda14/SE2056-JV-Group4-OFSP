<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo Cáo Hao Hụt & Tiêu Hủy Nông Sản - FreshFruit Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-inventory.css">
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="waste" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <!-- Breadcrumb & Page Header -->
            <div class="flex flex-col gap-2 mb-6">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span>Sản phẩm &amp; Kho</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-rose-600 font-semibold">Nông sản hư hỏng &amp; Tiêu hủy</span>
                </nav>

                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mt-1">
                    <div>
                        <h1 class="text-2xl font-black text-slate-900 tracking-tight">Báo Cáo Hao Hụt &amp; Nông Sản Hư Hỏng</h1>
                        <p class="text-xs text-slate-500 mt-0.5">Hạch toán chính xác tổn thất bảo quản lạnh, kiểm định QC đóng gói hủy đơn và hàng dập nát khi vận chuyển.</p>
                    </div>

                    <div class="flex items-center flex-wrap gap-2.5">
                        <a href="${pageContext.request.contextPath}/shop/inventory" class="px-3.5 py-2 rounded-xl bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 text-xs font-bold transition flex items-center gap-2 shadow-2xs">
                            <i class="fa-solid fa-boxes-stacked text-emerald-700 text-sm"></i>
                            <span>Xem Tồn Kho Bán</span>
                        </a>

                        <button type="button" id="btnOpenManualWasteModal" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white text-xs font-extrabold transition flex items-center gap-2 shadow-sm cursor-pointer">
                            <i class="fa-solid fa-trash-can text-xs"></i>
                            <span>Báo Tiêu Hủy Kho</span>
                        </button>
                    </div>
                </div>
            </div>

            <c:if test="${param.success eq '1'}">
                <div id="flashMsg" class="mb-5 bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-2xs">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                        <span class="text-xs font-bold">Đã ghi nhận tiêu hủy nông sản hỏng và tự động giảm trừ tồn kho thành công!</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-emerald-600 hover:text-emerald-900">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>

            <c:if test="${param.error eq 'stock_exceeded'}">
                <div id="flashMsg" class="mb-5 bg-rose-50 border border-rose-200 text-rose-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-2xs">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                        <span class="text-xs font-bold">Số lượng tiêu hủy vượt quá tồn kho khả dụng hiện tại!</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-rose-600 hover:text-rose-900">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>

            <c:if test="${param.error eq 'invalid_input'}">
                <div id="flashMsg" class="mb-5 bg-rose-50 border border-rose-200 text-rose-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-2xs">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                        <span class="text-xs font-bold">Vui lòng nhập đầy đủ số lượng (> 0) và lý do tiêu hủy nông sản!</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-rose-600 hover:text-rose-900">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>

            <!-- Bảng báo cáo hàng hỏng & KPI Cards -->
            <jsp:include page="/views/shop/components/inventory/inventory-waste-table.jsp" />

        </div>
    </main>

    <!-- Modal Báo Tiêu Hủy -->
    <jsp:include page="/views/shop/components/inventory/modal-waste.jsp" />

    <script src="${pageContext.request.contextPath}/assets/js/shop-inventory.js"></script>
</body>
</html>

