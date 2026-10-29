<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- Embed INSIDE existing #tab-content-reviews in /views/product/product-detail.jsp.
     <jsp:include page="/views/review/product-widget.jsp">
       <jsp:param name="productId" value="${product.id}"/>
     </jsp:include> --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/review.css">
<div class="rv-root rv-embed rv-app" data-mode="widget" data-type="PRODUCT" data-target-id="${param.productId}" data-ctx="${pageContext.request.contextPath}">
<div class="rv-container"><section class="rv-surface"><div class="rv-surface-header"><div><h2>Đánh giá xác thực từ người mua</h2><p class="rv-sub">Tổng hợp trải nghiệm thực tế với sản phẩm</p></div><span class="rv-pill green">✓ Đã mua hàng</span></div>
<div class="rv-rating-layout" data-score></div><div class="rv-toolbar" data-rating-filter></div>
<div class="rv-card-list" data-list></div><div class="rv-pagination"><button class="rv-btn secondary" data-prev>← Trước</button><span data-page>Trang 1</span><button class="rv-btn secondary" data-next>Sau →</button></div>
<div class="rv-toolbar" style="border-top:1px solid #edf2ee"><span class="rv-mini-note">Chỉ người mua đã nhận hàng mới được đánh giá.</span><a class="rv-btn" href="${pageContext.request.contextPath}/review-center">★ Viết đánh giá</a></div>
</section><div class="rv-message" data-message role="status" aria-live="polite"></div><jsp:include page="/WEB-INF/views/review/dialog.jsp"/></div></div>
<script src="${pageContext.request.contextPath}/assets/js/review.js"></script>
