<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Đánh giá của tôi • Gốc Vườn</title>
        <link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reviews.css">
    </head><body style="margin:0">
        <jsp:include page="/views/common/header.jsp"/>
        <div class="rv-root rv-app" data-mode="center" data-ctx="${pageContext.request.contextPath}">
            <div class="rv-container">
                <nav class="rv-crumb"><a href="${pageContext.request.contextPath}/home">Trang chủ</a><span>›</span><a href="${pageContext.request.contextPath}/profile">Tài khoản</a><span>›</span><span>Đánh giá của tôi</span></nav>
                <section class="rv-hero rv-hero-customer"><div class="rv-hero-copy"><div class="rv-eyebrow"><span class="rv-dot"></span> TRẢI NGHIỆM MUA SẮM</div><h1>Trải nghiệm thật.<br><em>Giá trị lan tỏa.</em></h1><p>Đánh giá trái cây bạn đã mua, giúp cộng đồng chọn đúng sản phẩm ngon từ nhà vườn uy tín.</p><div class="rv-hero-points"><span>✓ Đơn hàng xác thực</span><span>✓ Chia sẻ minh bạch</span></div></div><div class="rv-hero-art" aria-hidden="true"><span class="rv-fruit rv-fruit-a">🍊</span><span class="rv-fruit rv-fruit-b">🍎</span><span class="rv-fruit rv-fruit-c">🍐</span><span class="rv-fruit-leaf">✦</span></div></section>
                <section class="rv-stat-grid"><div class="rv-stat"><div class="rv-stat-icon">✓</div><div><strong data-stat-eligible>–</strong><span>Đang chờ bạn đánh giá</span></div></div><div class="rv-stat"><div class="rv-stat-icon">★</div><div><strong data-stat-reviewed>–</strong><span>Đánh giá của bạn</span></div></div><div class="rv-stat"><div class="rv-stat-icon">🌱</div><div><strong>5 <small>★</small></strong><span>Thang điểm đánh giá</span></div></div></section>
                <section class="rv-surface"><div class="rv-surface-header"><div><h2>Đánh giá của tôi</h2><p class="rv-sub">Theo dõi các trải nghiệm đã chia sẻ và đơn hàng chờ đánh giá</p></div><span class="rv-pill green">✓ Người mua xác thực</span></div>
                    <div class="rv-section-tag">CHỌN LOẠI ĐÁNH GIÁ</div><div class="rv-tabs"><button class="rv-tab" type="button" data-type="PRODUCT" aria-selected="true">🍏  Sản phẩm đã mua</button><button class="rv-tab" type="button" data-type="SHOP" aria-selected="false">🌿  Gian hàng</button></div>
                    <div class="rv-toolbar"><div class="rv-actions"><button class="rv-btn secondary active" type="button" data-view="purchases">Chờ đánh giá</button><button class="rv-btn secondary" type="button" data-view="mine">Đã đánh giá</button></div><span class="rv-mini-note">✦ Chỉ những đơn đã giao mới được đánh giá</span></div>
                    <div class="rv-card-list" data-list></div><div class="rv-pagination"><button class="rv-btn secondary" type="button" data-prev>← Trước</button><span data-page>Trang 1</span><button class="rv-btn secondary" type="button" data-next>Sau →</button></div></section>
                <div data-message class="rv-message" role="status" aria-live="polite"></div>
                <jsp:include page="dialog.jsp"/>
            </div></div><script src="${pageContext.request.contextPath}/assets/js/reviews.js"></script>
    </body></html>
