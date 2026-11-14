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

        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="active" value="inventory" />
        </jsp:include>
        <jsp:include page="/views/shop/layout/header.jsp">
            <jsp:param name="searchAction" value="/shop/inventory/batches" />
        </jsp:include>

        <main class="shop-main-wrapper">
            <div class="shop-content-container">
                    <!-- Thông báo Flash message từ Servlet -->
                    <c:if test="${not empty inventoryRestockMessage}">
                        <div class="px-4 py-3 rounded-xl text-sm font-semibold ${inventoryRestockSuccess ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-rose-50 text-rose-700 border border-rose-200'}">
                            <c:out value="${inventoryRestockMessage}" />
                        </div>
                        <c:remove var="inventoryRestockMessage" scope="session" />
                        <c:remove var="inventoryRestockSuccess" scope="session" />
                    </c:if>
                    <c:if test="${not empty inventoryAdjustMessage}">
                        <div class="px-4 py-3 rounded-xl text-sm font-semibold ${inventoryAdjustSuccess ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-rose-50 text-rose-700 border border-rose-200'}">
                            <c:out value="${inventoryAdjustMessage}" />
                        </div>
                        <c:remove var="inventoryAdjustMessage" scope="session" />
                        <c:remove var="inventoryAdjustSuccess" scope="session" />
                    </c:if>

                    <!-- Header Tiêu đề & Nút thao tác -->
                    <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4">
                        <div>
                            <h1 class="text-2xl font-black text-slate-900 tracking-tight">Quản lý Kho Hàng & Lô Nông Sản</h1>
                            <p class="text-xs text-slate-500 font-medium mt-1">Theo dõi tồn kho theo thời gian thực, hạn sử dụng và lịch sử biến động lô hàng.</p>
                        </div>
                        <div class="flex items-center flex-wrap gap-2.5">
                            <button type="button" onclick="openModal('modalAdjust')" class="px-4 py-2.5 bg-white border border-slate-200 text-slate-700 hover:bg-rose-50 hover:text-rose-700 rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm transition-all"><i class="fa-solid fa-minus text-rose-500"></i>Trừ hàng hỏng / Dập</button>
                            <button type="button" onclick="openRestockModal(null)" class="px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm transition-all"><i class="fa-solid fa-plus"></i>Nhập Kho Lô Mới</button>
                        </div>
                    </div>

                    <!-- 4 Thẻ Thống Kê Tổng Quan -->
                    <section class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                        <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between">
                            <div>
                                <p class="text-[10px] uppercase tracking-wider text-slate-500 font-bold">Tổng sản lượng tồn kho</p>
                                <p class="text-2xl font-black text-slate-900 mt-1">${not empty totalStock ? totalStock : '0'} <span class="text-xs font-semibold text-slate-400">đơn vị</span></p>
                                <p class="text-[10px] text-emerald-600 font-semibold mt-1"><i class="fa-solid fa-arrow-trend-up mr-1"></i>Tồn kho thời gian thực</p>
                            </div>
                            <span class="w-11 h-11 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center"><i class="fa-solid fa-boxes-stacked"></i></span>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between">
                            <div>
                                <p class="text-[10px] uppercase tracking-wider text-slate-500 font-bold">Cảnh báo sắp hết hàng</p>
                                <p class="text-2xl font-black text-slate-900 mt-1">${not empty lowStockCount ? lowStockCount : '0'} <span class="text-xs font-semibold text-slate-400">sản phẩm</span></p>
                                <p class="text-[10px] text-rose-500 font-semibold mt-1">Cần nhập kho gấp</p>
                            </div>
                            <span class="w-11 h-11 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center"><i class="fa-solid fa-triangle-exclamation"></i></span>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between">
                            <div>
                                <p class="text-[10px] uppercase tracking-wider text-slate-500 font-bold">Tổng số lô hàng</p>
                                <p class="text-2xl font-black text-slate-900 mt-1">${not empty totalBatches ? totalBatches : '0'} <span class="text-xs font-semibold text-slate-400">lô</span></p>
                                <p class="text-[10px] text-amber-600 font-semibold mt-1">Đang lưu trữ trong kho</p>
                            </div>
                            <span class="w-11 h-11 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center"><i class="fa-solid fa-warehouse"></i></span>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between">
                            <div>
                                <p class="text-[10px] uppercase tracking-wider text-slate-500 font-bold">Lô cận Date / Quá hạn</p>
                                <p class="text-2xl font-black text-amber-600 mt-1">${not empty nearExpiryCount ? nearExpiryCount : '0'} <span class="text-xs font-semibold text-slate-400">lô</span></p>
                                <p class="text-[10px] text-amber-600 font-semibold mt-1">Ưu tiên xuất kho / Hủy</p>
                            </div>
                            <span class="w-11 h-11 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center"><i class="fa-solid fa-hourglass-half"></i></span>
                        </div>
                    </section>

                    <!-- Lọc & Tìm kiếm -->
                    <section class="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm flex flex-col lg:flex-row lg:items-center justify-between gap-3">
                        <div class="relative w-full lg:max-w-md"><i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i><input id="searchInput" onkeyup="filterTable()" type="search" placeholder="Tìm tên trái cây, mã SKU, mã lô..." class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-500"></div>
                        <div class="flex items-center gap-2">
                            <select class="px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700"><option>Tất cả danh mục</option></select>
                            <button type="button" onclick="filterTable()" class="w-10 h-10 rounded-xl text-slate-400 hover:text-emerald-700 hover:bg-emerald-50 border border-slate-200"><i class="fa-solid fa-rotate"></i></button>
                        </div>
                    </section>

                    <!-- Danh Sách Biến Thể Gom Nhóm Nhiều Lô -->
                    <section class="space-y-4" id="variantListContainer">
                        <c:forEach var="entry" items="${variantBatchMap}">
                            <c:set var="variantId" value="${entry.key}" />
                            <c:set var="batches" value="${entry.value}" />
                            <c:set var="firstBatch" value="${batches[0]}" />

                            <div class="variant-card">
                                <!-- Header Biến thể -->
                                <div class="p-4 bg-slate-50/70 border-b border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-4 cursor-pointer select-none" onclick="toggleAccordion('batches-v-${variantId}')">
                                    <div class="flex items-center gap-3">
                                        <button type="button" class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-500 flex items-center justify-center transition-transform" id="icon-v-${variantId}">
                                            <i class="fa-solid fa-chevron-down text-xs"></i>
                                        </button>
                                        <div class="w-11 h-11 rounded-xl bg-emerald-50 border border-slate-100 overflow-hidden shrink-0 flex items-center justify-center">
                                            <c:choose>
                                                <c:when test="${not empty firstBatch.imageUrl}">
                                                    <img src="${firstBatch.imageUrl}" alt="Product" class="w-full h-full object-cover">
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fa-solid fa-apple-whole text-emerald-600 text-lg"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div>
                                            <div class="flex items-center gap-2">
                                                <h3 class="font-extrabold text-sm text-slate-900">${firstBatch.productName}</h3>
                                                <span class="px-2 py-0.5 rounded bg-slate-200/60 text-slate-600 text-[10px] font-mono font-bold">${firstBatch.sku}</span>
                                            </div>
                                            <div class="text-[11px] text-slate-500 font-medium mt-0.5 flex items-center gap-2">
                                                <span>${batches.size()} lô hàng</span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="flex items-center gap-4 self-end sm:self-center" onclick="event.stopPropagation();">
                                        <div class="flex items-center gap-1.5 pl-2 border-l border-slate-200">
                                            <button type="button"
                                                    data-variant-id="${variantId}"
                                                    data-product-name="<c:out value='${firstBatch.productName}'/>"
                                                    data-sku="${firstBatch.sku}"
                                                    onclick="openRestockModal(this)"
                                                    class="px-3 py-1.5 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-lg text-xs font-bold transition-all flex items-center gap-1.5">
                                                <i class="fa-solid fa-plus text-[10px]"></i>Nhập lô mới
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- Bảng chứa danh sách Lô con -->
                                <div id="batches-v-${variantId}" class="overflow-x-auto transition-all">
                                    <table class="w-full text-left text-xs min-w-[950px] table-fixed">
                                        <thead>
                                            <tr class="bg-slate-100/50 text-[10px] uppercase text-slate-400 font-extrabold border-b border-slate-100">
                                                <th class="py-3 px-4 pl-6 w-[18%]">Mã Lô (Batch)</th>
                                                <th class="py-3 px-4 w-[18%]">Hạn Sử Dụng (FEFO)</th>
                                                <th class="py-3 px-4 text-center w-[14%]">Tồn Kho</th>
                                                <th class="py-3 px-4 w-[14%]">Trạng Thái</th>
                                                <th class="py-3 px-4 w-[14%]">Tình Trạng</th>
                                                <th class="py-3 px-4 text-right pr-6 w-[22%]">Thao Tác</th>
                                            </tr>
                                        </thead>
                                        <tbody class="divide-y divide-slate-100 text-slate-700">
                                            <c:forEach var="batch" items="${batches}">
                                                <tr class="hover:bg-slate-50/80 transition-colors">
                                                    <td class="py-3.5 px-4 pl-6">
                                                        <div class="flex items-center gap-2 truncate">
                                                            <span class="font-mono font-bold text-slate-900">${batch.batchCode}</span>
                                                        </div>
                                                    </td>
                                                    <td class="py-3.5 px-4 font-semibold">
                                                        <div class="font-bold text-slate-900">${batch.expiryDate}</div>
                                                        <div class="text-[10px] font-bold mt-0.5">
                                                            <c:choose>
                                                                <c:when test="${batch.daysRemaining > 0}">
                                                                    <span class="text-emerald-600">Còn ${batch.daysRemaining} ngày</span>
                                                                </c:when>
                                                                <c:when test="${batch.daysRemaining == 0}">
                                                                    <span class="text-amber-600">Hôm nay hết hạn</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-rose-600">Quá hạn ${-batch.daysRemaining} ngày</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </td>
                                                    <td class="py-3.5 px-4 text-center font-bold text-slate-900">
                                                        ${batch.currentQuantity} / <span class="text-slate-400 font-normal">${batch.initialQuantity}</span>
                                                    </td>

                                                    <!-- CỘT TRẠNG THÁI -->
                                                    <td class="py-3.5 px-4">
                                                        <c:choose>
                                                            <c:when test="${batch.status == 'ACTIVE'}">
                                                                <span class="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 text-[10px] font-bold inline-block">Đang bán</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="px-2.5 py-1 rounded-full bg-slate-100 text-slate-600 border border-slate-200 text-[10px] font-bold inline-block">Dừng bán</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>

                                                    <!-- CỘT TÌNH TRẠNG -->
                                                    <td class="py-3.5 px-4">
                                                        <span class="px-2.5 py-1 rounded-full text-[10px] font-bold inline-block
                                                              <c:choose>
                                                                  <c:when test="${batch.statusText == 'Quá hạn'}">bg-rose-50 text-rose-700 border border-rose-200</c:when>
                                                                  <c:when test="${batch.statusText == 'Cận date'}">bg-amber-50 text-amber-700 border border-amber-200</c:when>
                                                                  <c:otherwise>bg-emerald-50 text-emerald-700 border border-emerald-200</c:otherwise>
                                                              </c:choose>">
                                                            ${batch.statusText}
                                                        </span>
                                                    </td>

                                                    <!-- CỘT THAO TÁC -->
                                                    <td class="py-3.5 px-4 text-right pr-6">
                                                        <div class="flex items-center justify-end gap-1.5">
                                                            <!-- 1. Nút Trừ hàng (Mở modalAdjust) -->
                                                            <button type="button"
                                                                    data-batch-id="${batch.batchId}"
                                                                    data-variant-id="${variantId}"
                                                                    data-product-name="<c:out value='${firstBatch.productName}'/>"
                                                                    data-sku="${firstBatch.sku}"
                                                                    data-batch-code="${batch.batchCode}"
                                                                    data-current-qty="${batch.currentQuantity}"
                                                                    onclick="openAdjustModal(this)"
                                                                    class="px-2.5 py-1 bg-amber-50 hover:bg-amber-100 text-amber-700 rounded-lg text-[11px] font-bold transition-all flex items-center gap-1 shadow-2xs" title="Trừ số lượng hỏng / dập nát">
                                                                <i class="fa-solid fa-minus text-[10px]"></i> Trừ hàng
                                                            </button>

                                                            <c:if test="${batch.currentQuantity > 0}">
                                                                <button type="button"
                                                                        data-batch-id="${batch.batchId}"
                                                                        data-variant-id="${batch.variantId != null ? batch.variantId : variantId}"
                                                                        data-product-name="<c:out value='${firstBatch.productName}'/>"
                                                                        data-sku="${firstBatch.sku}"
                                                                        data-batch-code="${batch.batchCode}"
                                                                        data-current-qty="${batch.currentQuantity}"
                                                                        onclick="openDisposeModal(this)"
                                                                        class="px-2.5 py-1 bg-rose-600 hover:bg-rose-700 text-white rounded-lg text-[11px] font-bold transition-all flex items-center gap-1 shadow-2xs" title="Hủy toàn bộ lô hàng ngay lập tức">
                                                                    <i class="fa-solid fa-ban text-[10px]"></i> Hủy lô
                                                                </button>
                                                            </c:if>

                                                            <!-- 3. Nút Lịch sử -->
                                                            <c:url var="historyUrl" value="/shop/inventory/history">
                                                                <c:param name="variantId" value="${variantId}"/>
                                                                <c:param name="batchId" value="${batch.batchId}"/>
                                                                <c:param name="productName" value="${firstBatch.productName}"/>
                                                            </c:url>
                                                            <a href="${historyUrl}" class="px-2.5 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-[11px] font-bold transition-all flex items-center gap-1 shadow-2xs">
                                                                <i class="fa-solid fa-clock text-[10px] text-slate-500"></i> Lịch sử
                                                            </a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty variantBatchMap}">
                            <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center">
                                <div class="w-12 h-12 mx-auto rounded-2xl bg-slate-50 text-slate-300 flex items-center justify-center mb-3">
                                    <i class="fa-solid fa-box-open text-xl"></i>
                                </div>
                                <p class="text-xs font-bold text-slate-600">Chưa có dữ liệu lô hàng nào trong kho</p>
                            </div>
                        </c:if>
                    </section>
            </div>
        </main>

        <!-- ==================== MODALS CHỨC NĂNG ==================== -->
        <!-- 1. Modal Nhập Kho Lô Mới -->
        <div id="modalRestock" class="fixed inset-0 bg-slate-900/50 backdrop-blur-xs hidden items-center justify-center z-50 p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-xl overflow-hidden border border-slate-100">
                <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                    <div class="flex items-center gap-2.5">
                        <span class="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold"><i class="fa-solid fa-plus text-sm"></i></span>
                        <h3 class="text-base font-black text-slate-900">Nhập Kho Lô Nông Sản Mới</h3>
                    </div>
                    <button type="button" onclick="closeModal('modalRestock')" class="w-8 h-8 rounded-xl text-slate-400 hover:bg-slate-100 flex items-center justify-center"><i class="fa-solid fa-xmark text-sm"></i></button>
                </div>
                <form action="${pageContext.request.contextPath}/shop/inventory/restock" method="POST" class="p-6 space-y-4">
                    <input type="hidden" name="variantId" id="restockVariantId">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">SẢN PHẨM / BIẾN THỂ</label>
                        <input type="text" id="restockProductName" readonly class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-semibold text-slate-600 cursor-not-allowed">
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">MÃ LÔ HÀNG</label>
                            <input type="text" readonly value="Hệ thống tự sinh (LOT-...)" class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-mono font-bold text-slate-400 cursor-not-allowed">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">SỐ LƯỢNG NHẬP MỚI</label>
                            <input type="number" name="quantity" required min="1" placeholder="Ví dụ: 100" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-emerald-500">
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">NGÀY THU HOẠCH</label>
                            <input type="date" name="harvestDate" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">HẠN SỬ DỤNG (BẮT BUỘC)</label>
                            <input type="date" name="expiryDate" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500">
                        </div>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">GHI CHÚ NHẬP KHO</label>
                        <textarea name="note" rows="3" placeholder="Ghi chú thêm..." class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 resize-none"></textarea>
                    </div>
                    <div class="flex items-center justify-end gap-3 pt-2">
                        <button type="button" onclick="closeModal('modalRestock')" class="px-5 py-2.5 bg-slate-100 text-slate-700 rounded-xl text-xs font-bold">Hủy</button>
                        <button type="submit" class="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shadow-sm">Xác Nhận Tạo Lô Mới</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- 2. Modal TRỪ HÀNG (Trừ hao hụt một phần) -->
        <div id="modalAdjust" class="fixed inset-0 bg-slate-900/50 backdrop-blur-xs hidden items-center justify-center z-50 p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-xl overflow-hidden border border-slate-100">
                <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                    <div class="flex items-center gap-2.5">
                        <span class="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center font-bold"><i class="fa-solid fa-minus text-sm"></i></span>
                        <h3 class="text-base font-black text-slate-900">Trừ Hao Hụt Kho</h3>
                    </div>
                    <button type="button" onclick="closeModal('modalAdjust')" class="w-8 h-8 rounded-xl text-slate-400 hover:bg-slate-100 flex items-center justify-center"><i class="fa-solid fa-xmark text-sm"></i></button>
                </div>
                <form action="${pageContext.request.contextPath}/shop/inventory/adjust" method="POST" class="p-6 space-y-4">
                    <input type="hidden" name="variantId" id="adjustVariantId">
                    <input type="hidden" name="batchId" id="adjustBatchId">
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">SẢN PHẨM</label>
                            <input type="text" id="adjustProductName" readonly class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-semibold text-slate-600 cursor-not-allowed">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">MÃ LÔ HÀNG</label>
                            <input type="text" id="adjustBatchCode" readonly class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 cursor-not-allowed">
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">TỒN KHO LÔ HIỆN TẠI</label>
                            <input type="text" id="adjustCurrentQty" readonly class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 cursor-not-allowed">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">SỐ LƯỢNG GIẢM</label>
                            <input type="number" name="deductQuantity" id="adjustDeductQty" required min="1" placeholder="Số lượng trừ" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-amber-500">
                        </div>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">LÝ DO TRỪ HÀNG</label>
                        <select name="reason" id="adjustReasonSelect" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-amber-500">
                            <option value="">-- Chọn lý do --</option>
                            <option value="DAMAGED">Trái cây bị dập nát, hư hỏng cơ học</option>
                            <option value="STORAGE_ISSUE">Sự cố bảo quản kho mát / mất điện đột xuất</option>
                            <option value="QUALITY_FAIL">Không đạt tiêu chuẩn ATVSTP kiểm định</option>
                            <option value="LOST">Kiểm kê thất thoát kho</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">CHI TIẾT MÔ TẢ THÊM</label>
                        <textarea name="description" rows="3" placeholder="Ghi chú cụ thể..." class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 resize-none"></textarea>
                    </div>
                    <div class="flex items-center justify-end gap-3 pt-2">
                        <button type="button" onclick="closeModal('modalAdjust')" class="px-5 py-2.5 bg-slate-100 text-slate-700 rounded-xl text-xs font-bold">Hủy</button>
                        <button type="submit" class="px-5 py-2.5 bg-amber-600 hover:bg-amber-700 text-white rounded-xl text-xs font-bold shadow-sm">Xác Nhận Trừ Kho</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- 3. Modal HỦY LÔ -->
        <div id="modalDispose" class="fixed inset-0 bg-slate-900/50 backdrop-blur-xs hidden items-center justify-center z-50 p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-xl overflow-hidden border border-slate-100">
                <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                    <div class="flex items-center gap-2.5">
                        <span class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center font-bold"><i class="fa-solid fa-ban text-sm"></i></span>
                        <h3 class="text-base font-black text-slate-900">Xuất Hủy Trọn Gói Lô Hàng</h3>
                    </div>
                    <button type="button" onclick="closeModal('modalDispose')" class="w-8 h-8 rounded-xl text-slate-400 hover:bg-slate-100 flex items-center justify-center"><i class="fa-solid fa-xmark text-sm"></i></button>
                </div>

                <!-- Thêm onsubmit kiểm tra dữ liệu trước khi gửi -->
                <form action="${pageContext.request.contextPath}/shop/inventory/dispose" method="POST" onsubmit="return validateDisposeForm()" class="p-6 space-y-4">

                    <input type="hidden" name="variantId" id="disposeVariantId">
                    <input type="hidden" name="batchId" id="disposeBatchId">

                    <div class="px-3.5 py-3 bg-rose-50 border border-rose-200 rounded-xl text-[11px] font-semibold text-rose-700 leading-relaxed">
                        Toàn bộ số lượng còn lại của lô sẽ về 0 và bị trừ khỏi tồn kho của sản phẩm. Thao tác này không thể hoàn tác.
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">SẢN PHẨM</label>
                            <input type="text" id="disposeProductName" readonly class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-semibold text-slate-600 cursor-not-allowed">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">MÃ LÔ HÀNG</label>
                            <input type="text" id="disposeBatchCode" readonly class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 cursor-not-allowed">
                        </div>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">SỐ LƯỢNG HỦY TOÀN BỘ LÔ</label>
                        <input type="text" id="disposeCurrentQty" readonly class="w-full px-3.5 py-2.5 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-bold cursor-not-allowed">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">LÝ DO XUẤT HỦY LÔ</label>
                        <select name="reason" id="disposeReasonSelect" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-rose-500">
                            <option value="EXPIRED">Hàng hết hạn sử dụng (Hủy toàn bộ lô)</option>
                            <option value="DAMAGED">Trái cây bị dập nát, hư hỏng cơ học</option>
                            <option value="STORAGE_ISSUE">Sự cố bảo quản kho mát / mất điện đột xuất</option>
                            <option value="QUALITY_FAIL">Không đạt tiêu chuẩn ATVSTP kiểm định</option>
                            <option value="LOST">Kiểm kê thất thoát kho</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">CHI TIẾT MÔ TẢ THÊM</label>
                        <textarea name="description" rows="3" placeholder="Ghi chú cụ thể..." class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 resize-none"></textarea>
                    </div>
                    <div class="flex items-center justify-end gap-3 pt-2">
                        <button type="button" onclick="closeModal('modalDispose')" class="px-5 py-2.5 bg-slate-100 text-slate-700 rounded-xl text-xs font-bold">Hủy</button>
                        <button type="submit" class="px-5 py-2.5 bg-rose-600 hover:bg-rose-700 text-white rounded-xl text-xs font-bold shadow-sm">Xác Nhận Hủy Lô</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- 4. Modal Lịch Sử Biến Động Kho -->
        <div id="modalHistory" class="fixed inset-0 bg-slate-900/50 backdrop-blur-xs hidden items-center justify-center z-50 p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden border border-slate-100">
                <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                    <div>
                        <h3 class="text-base font-black text-slate-900">Lịch Sử Biến Động Kho</h3>
                        <p id="historyProductName" class="text-[11px] text-slate-500 font-medium mt-0.5">Sản phẩm: <c:out value="${currentProductName}" default="--"/></p>
                    </div>
                    <button type="button" onclick="closeModal('modalHistory')" class="w-8 h-8 rounded-xl text-slate-400 hover:bg-slate-100 flex items-center justify-center"><i class="fa-solid fa-xmark text-sm"></i></button>
                </div>
                <div class="p-6 space-y-3 max-h-[60vh] overflow-y-auto">
                    <c:choose>
                        <c:when test="${not empty transactionHistoryList}">
                            <c:forEach var="trans" items="${transactionHistoryList}">
                                <div class="flex items-center justify-between p-3.5 bg-slate-50 rounded-2xl border border-slate-100">
                                    <div class="flex items-center gap-3">
                                        <span class="w-9 h-9 rounded-xl flex items-center justify-center font-bold shrink-0 ${trans.quantityChanged > 0 ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'}">
                                            <i class="fa-solid ${trans.quantityChanged > 0 ? 'fa-plus' : 'fa-minus'} text-xs"></i>
                                        </span>
                                        <div>
                                            <div class="text-xs font-bold text-slate-900">${trans.transactionType}</div>
                                            <div class="text-[10px] text-slate-400 mt-0.5"><fmt:formatDate value="${trans.createdAt}" pattern="dd/MM/yyyy HH:mm"/> | Thực hiện: <span class="font-semibold text-slate-600">${trans.fullName}</span></div>
                                            <div class="text-[11px] text-slate-500 mt-1">Tồn: <span class="font-semibold">${trans.previousStock}</span> → <span class="font-semibold">${trans.newStock}</span></div>
                                        </div>
                                    </div>
                                    <span class="text-xs font-black ${trans.quantityChanged > 0 ? 'text-emerald-600' : 'text-rose-600'}">${trans.quantityChanged > 0 ? '+' : ''}${trans.quantityChanged} đơn vị</span>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-8 text-xs text-slate-400 font-medium">Chưa có lịch sử biến động kho cho lô này.</div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="flex items-center justify-end px-6 py-4 border-t border-slate-100 bg-slate-50/50">
                    <button type="button" onclick="closeModal('modalHistory')" class="px-5 py-2.5 bg-slate-200 text-slate-700 rounded-xl text-xs font-bold">Đóng</button>
                </div>
            </div>
        </div>

        <!-- JavaScript Điều khiển UI -->
        <script>
            function toggleAccordion(elementId) {
                const batchesContainer = document.getElementById(elementId);
                const variantId = elementId.replace('batches-v-', '');
                const icon = document.getElementById('icon-v-' + variantId);
                if (batchesContainer) {
                    if (batchesContainer.classList.contains('hidden')) {
                        batchesContainer.classList.remove('hidden');
                        if (icon)
                            icon.style.transform = 'rotate(0deg)';
                    } else {
                        batchesContainer.classList.add('hidden');
                        if (icon)
                            icon.style.transform = 'rotate(-90deg)';
                    }
                }
            }

            function openModal(modalId) {
                const modal = document.getElementById(modalId);
                if (modal) {
                    modal.classList.remove('hidden');
                    modal.classList.add('flex');
                }
            }

            function closeModal(modalId) {
                const modal = document.getElementById(modalId);
                if (modal) {
                    modal.classList.remove('flex');
                    modal.classList.add('hidden');
                }
            }

            // Hàm mở Modal Trừ hàng
            function openAdjustModal(btn) {
                if (btn && btn.dataset) {
                    document.getElementById('adjustVariantId').value = btn.dataset.variantId || '';
                    document.getElementById('adjustBatchId').value = btn.dataset.batchId || '';
                    document.getElementById('adjustProductName').value = (btn.dataset.productName || '') + ' (' + (btn.dataset.sku || '') + ')';
                    document.getElementById('adjustBatchCode').value = btn.dataset.batchCode || '';
                    document.getElementById('adjustCurrentQty').value = (btn.dataset.currentQty || '0') + ' đơn vị';

                    const deductInput = document.getElementById('adjustDeductQty');
                    if (deductInput) {
                        deductInput.max = btn.dataset.currentQty || '';
                        deductInput.value = '';
                    }
                }
                openModal('modalAdjust');
            }

            // Hàm mở Modal Hủy lô
            function openDisposeModal(btn) {
                if (btn && btn.dataset) {
                    document.getElementById('disposeVariantId').value = btn.dataset.variantId || '';
                    document.getElementById('disposeBatchId').value = btn.dataset.batchId || '';
                    document.getElementById('disposeProductName').value = (btn.dataset.productName || '') + ' (' + (btn.dataset.sku || '') + ')';
                    document.getElementById('disposeBatchCode').value = btn.dataset.batchCode || '';
                    document.getElementById('disposeCurrentQty').value = (btn.dataset.currentQty || '0') + ' đơn vị';
                }
                openModal('modalDispose');
            }

            // Kiểm tra an toàn trước khi submit hủy lô
            function validateDisposeForm() {
                const batchId = document.getElementById('disposeBatchId').value;
                const variantId = document.getElementById('disposeVariantId').value;
                if (!batchId || !variantId || batchId === "" || variantId === "") {
                    alert("Lỗi: Không tìm thấy thông tin định danh lô hàng!");
                    return false;
                }
                return true;
            }

            function openRestockModal(btn) {
                if (btn && btn.dataset) {
                    document.getElementById('restockVariantId').value = btn.dataset.variantId || '';
                    document.getElementById('restockProductName').value = (btn.dataset.productName || '') + ' (' + (btn.dataset.sku || '') + ')';
                } else {
                    document.getElementById('restockVariantId').value = '';
                    document.getElementById('restockProductName').value = '';
                }
                openModal('modalRestock');
            }

            function filterTable() {
                const value = document.getElementById('searchInput').value.toLowerCase();
                document.querySelectorAll('#variantListContainer .variant-card').forEach(card => {
                    card.style.display = card.innerText.toLowerCase().includes(value) ? '' : 'none';
                });
            }

            document.addEventListener("DOMContentLoaded", function () {
            <c:if test="${isOpenHistoryModal == true}">
                openModal('modalHistory');
            </c:if>
            });
        </script>
    </body>
</html> 