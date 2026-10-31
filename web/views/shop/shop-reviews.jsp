<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đánh Giá Khách Hàng - Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${ctx}/assets/css/shop-marketing.css"/>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp"><jsp:param name="active" value="reviews" /></jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container space-y-6">

            <jsp:include page="/views/shop/layout/mk-flash.jsp" />

            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span>Tiếp thị &amp; Khách hàng</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-800 font-semibold">Đánh Giá Từ Khách</span>
            </nav>

            <div>
                <h1 class="text-2xl font-black text-slate-900 tracking-tight">Đánh Giá Từ Khách Hàng</h1>
                <p class="text-sm text-slate-500 mt-1">Theo dõi trải nghiệm khách hàng về chất lượng nông sản, dịch vụ đóng gói và giải đáp phản hồi kịp thời.</p>
            </div>

            <!-- Thống kê đánh giá -->
            <div class="grid grid-cols-2 xl:grid-cols-4 gap-4">
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-emerald-50 text-emerald-600"><i class="fa-solid fa-star"></i></span>
                    <span><span class="mk-stat-num">${countAll}</span><span class="mk-stat-label">Tổng số đánh giá</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-amber-50 text-amber-600"><i class="fa-solid fa-clock-rotate-left"></i></span>
                    <span><span class="mk-stat-num text-amber-600">${countUnreplied}</span><span class="mk-stat-label">Chưa phản hồi</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-sky-50 text-sky-600"><i class="fa-solid fa-face-smile"></i></span>
                    <span><span class="mk-stat-num">${countPositive}</span><span class="mk-stat-label">Hài lòng (4-5 sao)</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-rose-50 text-rose-600"><i class="fa-solid fa-triangle-exclamation"></i></span>
                    <span><span class="mk-stat-num text-rose-600">${countNegative}</span><span class="mk-stat-label">Cần cải thiện (1-3 sao)</span></span>
                </div>
            </div>

            <!-- Tabs bộ lọc -->
            <div class="flex items-center gap-2 border-b border-slate-200 text-xs font-bold pb-2">
                <a href="${ctx}/shop/reviews?tab=all" class="px-4 py-2 rounded-lg transition ${currentTab == 'all' ? 'bg-emerald-600 text-white' : 'text-slate-600 hover:bg-slate-100'}">
                    Tất cả (${countAll})
                </a>
                <a href="${ctx}/shop/reviews?tab=unreplied" class="px-4 py-2 rounded-lg transition ${currentTab == 'unreplied' ? 'bg-emerald-600 text-white' : 'text-slate-600 hover:bg-slate-100'}">
                    Chưa phản hồi (${countUnreplied})
                </a>
                <a href="${ctx}/shop/reviews?tab=positive" class="px-4 py-2 rounded-lg transition ${currentTab == 'positive' ? 'bg-emerald-600 text-white' : 'text-slate-600 hover:bg-slate-100'}">
                    Đánh giá tốt (${countPositive})
                </a>
                <a href="${ctx}/shop/reviews?tab=negative" class="px-4 py-2 rounded-lg transition ${currentTab == 'negative' ? 'bg-emerald-600 text-white' : 'text-slate-600 hover:bg-slate-100'}">
                    Đánh giá thấp (${countNegative})
                </a>
            </div>

            <!-- Danh sách đánh giá -->
            <div class="space-y-4">
                <c:choose>
                    <c:when test="${not empty reviews}">
                        <c:forEach items="${reviews}" var="rev">
                            <div class="bg-white rounded-2xl border border-slate-200/80 p-5 shadow-2xs space-y-4">
                                <div class="flex items-start justify-between gap-4">
                                    <div class="flex items-center gap-3">
                                        <img src="${rev.customerAvatar}" alt="avatar" class="w-10 h-10 rounded-full object-cover border border-slate-100">
                                        <div>
                                            <div class="flex items-center gap-2">
                                                <span class="font-bold text-sm text-slate-900">${rev.customerName}</span>
                                                <span class="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">Đã mua hàng</span>
                                            </div>
                                            <div class="flex text-amber-400 text-xs gap-0.5 mt-0.5">
                                                <c:forEach begin="1" end="${rev.rating}">
                                                    <i class="fa-solid fa-star"></i>
                                                </c:forEach>
                                                <c:forEach begin="${rev.rating + 1}" end="5">
                                                    <i class="fa-regular fa-star text-slate-300"></i>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </div>
                                    <span class="text-xs text-slate-400"><fmt:formatDate value="${rev.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                </div>

                                <div class="flex items-center gap-3 bg-slate-50 p-2.5 rounded-xl border border-slate-100 text-xs">
                                    <img src="${rev.productImage}" alt="${rev.productName}" class="w-10 h-10 rounded-lg object-cover border border-slate-200">
                                    <div>
                                        <div class="font-bold text-slate-800">${rev.productName}</div>
                                        <div class="text-slate-500 text-[11px]">Phân loại: ${rev.variantName}</div>
                                    </div>
                                </div>

                                <p class="text-sm text-slate-700 leading-relaxed">${rev.comment}</p>

                                <c:if test="${not empty rev.images}">
                                    <div class="flex items-center gap-2 flex-wrap">
                                        <c:forEach items="${rev.images}" var="img">
                                            <img src="${img}" alt="Ảnh thực tế" class="w-14 h-14 rounded-xl object-cover border border-slate-200 hover:scale-105 transition-transform cursor-pointer">
                                        </c:forEach>
                                    </div>
                                </c:if>

                                <!-- Phản hồi của shop -->
                                <c:choose>
                                    <c:when test="${not empty rev.replyComment}">
                                        <div class="bg-emerald-50/70 p-3.5 rounded-xl border border-emerald-100 text-xs space-y-1">
                                            <div class="flex items-center justify-between">
                                                <span class="font-bold text-[#00652c] flex items-center gap-1.5">
                                                    <i class="fa-solid fa-reply"></i> Phản hồi của Shop:
                                                </span>
                                                <button type="button" onclick="openReplyModal(${rev.reviewId}, '${rev.replyComment}')" class="text-xs text-[#00652c] hover:underline font-bold">
                                                    Chỉnh sửa
                                                </button>
                                            </div>
                                            <p class="text-slate-700 leading-relaxed">${rev.replyComment}</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="pt-1">
                                            <button type="button" onclick="openReplyModal(${rev.reviewId}, '')" class="px-4 py-2 rounded-xl bg-emerald-50 hover:bg-emerald-100 text-[#00652c] font-bold text-xs flex items-center gap-1.5 transition">
                                                <i class="fa-solid fa-reply"></i> Phản hồi khách hàng
                                            </button>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-16 bg-white rounded-2xl border border-slate-200/80 p-8 space-y-3">
                            <i class="fa-regular fa-comment-dots text-4xl text-slate-300"></i>
                            <h3 class="font-bold text-slate-800 text-base">Không có đánh giá nào</h3>
                            <p class="text-xs text-slate-500 max-w-sm mx-auto">Chưa có đánh giá nào trong danh mục này. Hãy tiếp tục duy trì chất lượng nông sản tốt nhất cho khách hàng!</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Phân trang -->
            <c:if test="${totalPages > 1}">
                <div class="flex items-center justify-center gap-2 pt-4">
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <a href="${ctx}/shop/reviews?tab=${currentTab}&page=${p}" class="w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold transition ${currentPage == p ? 'bg-[#00652c] text-white shadow-xs' : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'}">
                            ${p}
                        </a>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </main>

    <!-- Modal phản hồi đánh giá -->
    <div id="replyModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-xs z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-md w-full p-6 space-y-4 shadow-xl border border-slate-100">
            <div class="flex items-center justify-between pb-2 border-b border-slate-100">
                <h3 class="font-bold text-slate-900 text-base">Phản Hồi Đánh Giá</h3>
                <button type="button" onclick="closeReplyModal()" class="text-slate-400 hover:text-slate-600">
                    <i class="fa-solid fa-xmark text-lg"></i>
                </button>
            </div>
            <form action="${ctx}/shop/reviews" method="POST" class="space-y-4">
                <input type="hidden" name="action" value="reply">
                <input type="hidden" name="currentTab" value="${currentTab}">
                <input type="hidden" name="reviewId" id="modalReviewId" value="">

                <div>
                    <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">Nội dung phản hồi</label>
                    <textarea name="replyComment" id="modalReplyComment" rows="4" required
                              class="w-full px-3 py-2 text-xs rounded-xl border border-slate-300 focus:ring-2 focus:ring-[#00652c] outline-none transition resize-none"
                              placeholder="Cảm ơn khách hàng hoặc hỗ trợ đổi trả nếu sản phẩm có sự cố..."></textarea>
                </div>

                <div class="flex items-center justify-end gap-2 pt-2">
                    <button type="button" onclick="closeReplyModal()" class="px-4 py-2 rounded-xl border border-slate-200 text-slate-600 text-xs font-bold hover:bg-slate-50">
                        Hủy
                    </button>
                    <button type="submit" class="px-5 py-2 rounded-xl bg-[#00652c] text-white text-xs font-bold hover:bg-[#005123] shadow-xs">
                        Gửi phản hồi
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openReplyModal(reviewId, currentReply) {
            document.getElementById('modalReviewId').value = reviewId;
            document.getElementById('modalReplyComment').value = currentReply || '';
            const modal = document.getElementById('replyModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }

        function closeReplyModal() {
            const modal = document.getElementById('replyModal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }
    </script>
</body>
</html>

