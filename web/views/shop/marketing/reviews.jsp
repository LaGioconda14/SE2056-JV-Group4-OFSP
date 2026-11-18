<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đánh Giá Từ Khách - Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${ctx}/assets/css/shop-marketing.css"/>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp"><jsp:param name="active" value="reviews" /></jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp"><jsp:param name="searchAction" value="/shop/reviews" /></jsp:include>

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <jsp:include page="/views/shop/components/common/flash-message.jsp" />

            <!-- Breadcrumb -->
            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span>Tiếp thị &amp; Khách hàng</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-800 font-semibold">Đánh giá từ khách</span>
            </nav>

            <!-- Tiêu đề trang -->
            <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
                <div>
                    <h1 class="text-2xl font-black text-slate-900 tracking-tight">Đánh Giá Từ Khách Hàng</h1>
                    <p class="text-sm text-slate-500 mt-1">Theo dõi nhận xét, điểm xếp hạng và phản hồi thắc mắc, góp ý từ người mua nông sản.</p>
                </div>
            </div>

            <!-- Thống kê tổng quan -->
            <div class="grid grid-cols-2 xl:grid-cols-4 gap-4">
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-amber-50 text-amber-500">
                        <i class="fa-solid fa-star text-lg"></i>
                    </span>
                    <div>
                        <span class="mk-stat-num text-amber-600 flex items-center gap-1.5">
                            ${stats.avgRating} <span class="text-xs text-slate-400 font-bold">/ 5.0</span>
                        </span>
                        <span class="mk-stat-label">Điểm trung bình · ${stats.total} lượt</span>
                    </div>
                </div>

                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-orange-50 text-orange-600">
                        <i class="fa-solid fa-clock-rotate-left text-lg"></i>
                    </span>
                    <div>
                        <span class="mk-stat-num text-orange-600">${stats.unrepliedCount}</span>
                        <span class="mk-stat-label">Chưa phản hồi</span>
                    </div>
                </div>

                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-emerald-50 text-emerald-600">
                        <i class="fa-solid fa-reply-all text-lg"></i>
                    </span>
                    <div>
                        <span class="mk-stat-num text-emerald-600">${stats.repliedCount}</span>
                        <span class="mk-stat-label">Đã gửi phản hồi</span>
                    </div>
                </div>

                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-sky-50 text-sky-600">
                        <i class="fa-solid fa-thumbs-up text-lg"></i>
                    </span>
                    <div>
                        <span class="mk-stat-num text-sky-600">${stats.positivePercent}%</span>
                        <span class="mk-stat-label">Tích cực (4 - 5 sao)</span>
                    </div>
                </div>
            </div>

            <!-- Phân bố số sao -->
            <div class="mk-card p-5">
                <div class="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-chart-bar text-emerald-600"></i>
                        <span class="font-extrabold text-sm text-slate-900">Phân Bố Đánh Giá Theo Số Sao</span>
                    </div>
                    <span class="text-xs text-slate-400 font-medium">Bấm vào từng mức sao để lọc nhanh</span>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-5 gap-3">
                    <c:forEach var="star" begin="1" end="5">
                        <c:set var="starLevel" value="${6 - star}" />
                        <c:set var="cKey" value="c${starLevel}" />
                        <c:set var="pKey" value="p${starLevel}" />
                        <a href="${ctx}/shop/reviews?rating=${starLevel}&status=${selectedStatus}&keyword=${keyword}" 
                           class="flex flex-col p-3 rounded-xl border ${selectedRating == starLevel ? 'border-amber-400 bg-amber-50/40 ring-2 ring-amber-400/20' : 'border-slate-200 bg-slate-50/50 hover:bg-slate-100/70'} transition">
                            <div class="flex items-center justify-between mb-1.5">
                                <span class="flex items-center gap-1 font-black text-xs text-slate-800">
                                    ${starLevel} <i class="fa-solid fa-star text-amber-400 text-xs"></i>
                                </span>
                                <span class="text-xs font-bold text-slate-500">${stats[cKey]} lượt</span>
                            </div>
                            <div class="w-full bg-slate-200 h-2 rounded-full overflow-hidden">
                                <div class="bg-amber-400 h-full rounded-full transition-all duration-300" style="width: ${stats[pKey]}%;"></div>
                            </div>
                            <span class="text-[10px] text-slate-400 font-semibold mt-1 text-right">${stats[pKey]}%</span>
                        </a>
                    </c:forEach>
                </div>
            </div>

            <!-- Bộ lọc Tabs & Tìm kiếm -->
            <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-3">
                <div class="mk-tabs">
                    <a href="${ctx}/shop/reviews?status=ALL&rating=${selectedRating}&keyword=${keyword}" 
                       class="mk-tab ${selectedStatus == 'ALL' ? 'active' : ''}">
                        Tất cả <span class="cnt">${stats.total}</span>
                    </a>
                    <a href="${ctx}/shop/reviews?status=UNREPLIED&rating=${selectedRating}&keyword=${keyword}" 
                       class="mk-tab ${selectedStatus == 'UNREPLIED' ? 'active' : ''}">
                        Chưa phản hồi <span class="cnt text-orange-600 bg-orange-50 font-bold">${stats.unrepliedCount}</span>
                    </a>
                    <a href="${ctx}/shop/reviews?status=REPLIED&rating=${selectedRating}&keyword=${keyword}" 
                       class="mk-tab ${selectedStatus == 'REPLIED' ? 'active' : ''}">
                        Đã phản hồi <span class="cnt">${stats.repliedCount}</span>
                    </a>
                    <c:if test="${not empty selectedRating}">
                        <a href="${ctx}/shop/reviews?status=${selectedStatus}&keyword=${keyword}" 
                           class="mk-tab bg-amber-50 border-amber-300 text-amber-800 hover:bg-amber-100" title="Bỏ lọc sao">
                            Đang lọc: ${selectedRating} <i class="fa-solid fa-star text-amber-500 text-xs"></i>
                            <i class="fa-solid fa-xmark text-slate-400 hover:text-rose-500 ml-1 text-xs"></i>
                        </a>
                    </c:if>
                </div>

                <form method="get" action="${ctx}/shop/reviews" class="relative w-full lg:w-80">
                    <input type="hidden" name="status" value="${selectedStatus}">
                    <c:if test="${not empty selectedRating}">
                        <input type="hidden" name="rating" value="${selectedRating}">
                    </c:if>
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                    <input type="text" name="keyword" value="<c:out value='${keyword}'/>" 
                           class="w-full pl-9 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-500 shadow-2xs" 
                           placeholder="Tìm theo tên khách, sản phẩm, nhận xét...">
                </form>
            </div>

            <!-- Danh sách Đánh giá -->
            <c:choose>
                <c:when test="${empty reviews}">
                    <div class="mk-card mk-empty p-12 text-center">
                        <i class="fa-regular fa-comment-dots text-4xl text-slate-300 mb-3"></i>
                        <p class="font-extrabold text-slate-700 text-base">Chưa có đánh giá nào</p>
                        <p class="text-xs text-slate-400 max-w-md mx-auto mt-1">
                            Không tìm thấy đánh giá nào phù hợp với bộ lọc hiện tại. Khi khách hàng mua sản phẩm và gửi đánh giá, các ý kiến sẽ xuất hiện ở đây.
                        </p>
                        <c:if test="${selectedStatus != 'ALL' || not empty selectedRating || not empty keyword}">
                            <a href="${ctx}/shop/reviews" class="mt-4 px-4 py-2 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-xl text-xs font-bold transition">
                                Xóa tất cả bộ lọc
                            </a>
                        </c:if>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="space-y-4">
                        <c:forEach items="${reviews}" var="r">
                            <div class="mk-card p-5 flex flex-col gap-4 transition hover:shadow-md">
                                <!-- Hàng trên: Thông tin khách hàng, thời gian & Điểm sao -->
                                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-slate-100">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 rounded-full bg-slate-100 border border-slate-200 overflow-hidden flex items-center justify-center text-slate-600 font-bold shrink-0">
                                            <c:choose>
                                                <c:when test="${not empty r.customerAvatar}">
                                                    <img src="<c:out value='${r.customerAvatar}'/>" alt="Avatar" class="w-full h-full object-cover">
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fa-solid fa-user text-sm text-slate-400"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div>
                                            <div class="flex items-center gap-2">
                                                <span class="font-extrabold text-sm text-slate-900 leading-tight">
                                                    <c:out value="${not empty r.customerName ? r.customerName : 'Khách hàng ẩn danh'}"/>
                                                </span>
                                                <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                    <i class="fa-solid fa-check text-[9px]"></i> Đã mua hàng
                                                </span>
                                            </div>
                                            <span class="text-[11px] text-slate-400 block mt-0.5">
                                                <i class="fa-regular fa-clock text-[10px] mr-1"></i>
                                                <fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </span>
                                        </div>
                                    </div>

                                    <!-- Điểm sao -->
                                    <div class="flex items-center gap-1.5 self-start sm:self-auto">
                                        <div class="flex items-center text-amber-400 text-sm">
                                            <c:forEach begin="1" end="5" var="s">
                                                <i class="${s <= r.rating ? 'fa-solid fa-star' : 'fa-regular fa-star text-slate-200'}"></i>
                                            </c:forEach>
                                        </div>
                                        <span class="font-black text-xs text-amber-600 ml-1">${r.rating}.0</span>
                                    </div>
                                </div>

                                <!-- Thông tin sản phẩm đã mua -->
                                <div class="flex items-center gap-3 p-2.5 rounded-xl bg-slate-50/80 border border-slate-100">
                                    <div class="w-12 h-12 rounded-lg bg-white border border-slate-200 overflow-hidden shrink-0">
                                        <img src="<c:out value='${r.productImage}'/>" alt="Sản phẩm" class="w-full h-full object-cover">
                                    </div>
                                    <div class="min-w-0">
                                        <p class="font-bold text-xs text-slate-900 truncate">
                                            <c:out value="${r.productName}"/>
                                        </p>
                                        <c:if test="${not empty r.variantName}">
                                            <p class="text-[11px] text-slate-500 font-medium mt-0.5">
                                                Phân loại: <span class="text-slate-700 font-semibold"><c:out value="${r.variantName}"/></span>
                                            </p>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- Nội dung nhận xét của khách -->
                                <div class="bg-white rounded-xl">
                                    <p class="text-xs text-slate-700 leading-relaxed font-medium">
                                        <c:choose>
                                            <c:when test="${not empty r.comment}">
                                                <c:out value="${r.comment}"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-slate-400 italic">Khách hàng không để lại nhận xét chi tiết.</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>

                                <!-- Khu vực phản hồi của gian hàng -->
                                <c:choose>
                                    <c:when test="${not empty r.replyComment}">
                                        <!-- Đã phản hồi -->
                                        <div class="rounded-xl bg-emerald-50/70 border border-emerald-200/70 p-3.5 flex flex-col gap-2">
                                            <div class="flex items-center justify-between">
                                                <div class="flex items-center gap-2">
                                                    <div class="w-6 h-6 rounded-md bg-[#166534] text-white flex items-center justify-center text-[10px]">
                                                        <i class="fa-solid fa-leaf"></i>
                                                    </div>
                                                    <span class="text-xs font-black text-emerald-900">Phản hồi của Gian Hàng</span>
                                                    <c:if test="${not empty r.updatedAt}">
                                                        <span class="text-[10px] text-emerald-700/70 font-semibold">
                                                            · <fmt:formatDate value="${r.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                        </span>
                                                    </c:if>
                                                </div>
                                                <button type="button" onclick="toggleReplyBox('reply-box-${r.reviewId}')" 
                                                        class="text-[11px] font-bold text-emerald-700 hover:text-emerald-900 hover:underline cursor-pointer flex items-center gap-1">
                                                    <i class="fa-solid fa-pen-to-square text-[10px]"></i> Chỉnh sửa
                                                </button>
                                            </div>
                                            <p class="text-xs text-slate-800 leading-relaxed font-medium pl-8">
                                                <c:out value="${r.replyComment}"/>
                                            </p>
                                        </div>
                                    </c:when>

                                    <c:otherwise>
                                        <!-- Chưa phản hồi -->
                                        <div class="flex items-center justify-between pt-1">
                                            <span class="text-xs text-orange-600 font-bold flex items-center gap-1.5">
                                                <i class="fa-regular fa-circle-dot text-[10px] animate-pulse"></i> Chưa phản hồi đánh giá này
                                            </span>
                                            <button type="button" onclick="toggleReplyBox('reply-box-${r.reviewId}')" 
                                                    class="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-2xs cursor-pointer">
                                                <i class="fa-solid fa-reply text-[11px]"></i> Trả lời đánh giá
                                            </button>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <!-- Khung nhập phản hồi (ẩn/hiện theo toggle) -->
                                <div id="reply-box-${r.reviewId}" class="hidden pt-2 border-t border-slate-100">
                                    <form action="${ctx}/shop/reviews" method="POST" class="space-y-2.5">
                                        <input type="hidden" name="action" value="reply">
                                        <input type="hidden" name="reviewId" value="${r.reviewId}">
                                        <input type="hidden" name="redirectUrl" value="${ctx}/shop/reviews?status=${selectedStatus}&rating=${selectedRating}&keyword=${keyword}&page=${currentPage}">

                                        <label class="block text-xs font-bold text-slate-700">
                                            Nội dung phản hồi khách hàng:
                                        </label>
                                        <textarea name="replyComment" rows="3" required
                                                  class="w-full p-3 text-xs rounded-xl border border-slate-300 focus:outline-none focus:border-emerald-600 font-medium resize-y"
                                                  placeholder="Ví dụ: Cảm ơn bạn đã tin tưởng mua sắm nông sản tại Gốc Vườn Market! Shop sẽ luôn nỗ lực giữ vững chất lượng tốt nhất..."><c:out value="${r.replyComment}"/></textarea>
                                        
                                        <div class="flex items-center justify-end gap-2">
                                            <button type="button" onclick="toggleReplyBox('reply-box-${r.reviewId}')" 
                                                    class="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-xl text-xs font-bold transition cursor-pointer">
                                                Hủy
                                            </button>
                                            <button type="submit" 
                                                    class="px-4 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold transition shadow-xs cursor-pointer flex items-center gap-1.5">
                                                <i class="fa-solid fa-paper-plane text-[10px]"></i> Gửi phản hồi
                                            </button>
                                        </div>
                                    </form>
                                </div>

                            </div>
                        </c:forEach>
                    </div>

                    <!-- Phân trang -->
                    <c:if test="${totalPages > 1}">
                        <div class="flex flex-col sm:flex-row items-center justify-between gap-3 pt-4">
                            <span class="text-xs text-slate-500 font-medium">
                                Hiển thị trang <span class="font-bold text-slate-700">${currentPage}</span> / <span class="font-bold text-slate-700">${totalPages}</span> 
                                (Tổng số <span class="font-bold text-slate-700">${totalCount}</span> đánh giá)
                            </span>

                            <div class="flex items-center gap-1.5">
                                <!-- Nút Trước -->
                                <c:choose>
                                    <c:when test="${currentPage > 1}">
                                        <a href="${ctx}/shop/reviews?page=${currentPage - 1}&status=${selectedStatus}&rating=${selectedRating}&keyword=${keyword}" 
                                           class="px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 text-xs font-bold transition">
                                            <i class="fa-solid fa-chevron-left text-[10px]"></i> Trước
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="px-3 py-1.5 rounded-xl border border-slate-200 bg-slate-100 text-slate-400 text-xs font-bold cursor-not-allowed">
                                            <i class="fa-solid fa-chevron-left text-[10px]"></i> Trước
                                        </span>
                                    </c:otherwise>
                                </c:choose>

                                <!-- Các số trang -->
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <c:if test="${p == 1 || p == totalPages || (p >= currentPage - 2 && p <= currentPage + 2)}">
                                        <a href="${ctx}/shop/reviews?page=${p}&status=${selectedStatus}&rating=${selectedRating}&keyword=${keyword}" 
                                           class="w-8 h-8 rounded-xl flex items-center justify-center text-xs font-bold transition ${p == currentPage ? 'bg-emerald-600 text-white shadow-2xs' : 'border border-slate-200 bg-white text-slate-700 hover:bg-slate-50'}">
                                            ${p}
                                        </a>
                                    </c:if>
                                </c:forEach>

                                <!-- Nút Tiếp -->
                                <c:choose>
                                    <c:when test="${currentPage < totalPages}">
                                        <a href="${ctx}/shop/reviews?page=${currentPage + 1}&status=${selectedStatus}&rating=${selectedRating}&keyword=${keyword}" 
                                           class="px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 text-xs font-bold transition">
                                            Tiếp <i class="fa-solid fa-chevron-right text-[10px]"></i>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="px-3 py-1.5 rounded-xl border border-slate-200 bg-slate-100 text-slate-400 text-xs font-bold cursor-not-allowed">
                                            Tiếp <i class="fa-solid fa-chevron-right text-[10px]"></i>
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>

        </div>
    </main>

    <script>
        function toggleReplyBox(boxId) {
            var box = document.getElementById(boxId);
            if (box) {
                box.classList.toggle('hidden');
                if (!box.classList.contains('hidden')) {
                    var textarea = box.querySelector('textarea');
                    if (textarea) {
                        textarea.focus();
                    }
                }
            }
        }
    </script>
</body>
</html>
