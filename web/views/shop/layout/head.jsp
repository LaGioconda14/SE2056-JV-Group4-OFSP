<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    HEAD DÙNG CHUNG CHO KÊNH NGƯỜI BÁN (SELLER DASHBOARD)
    Cách dùng: đặt trong <head> của mỗi trang seller, SAU thẻ <title>, TRƯỚC css riêng của trang:
        <jsp:include page="/views/shop/layout/head.jsp" />
--%>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Google Fonts & Font Awesome 6 -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<!-- Tailwind CSS (utility helper) -->
<script src="https://cdn.tailwindcss.com"></script>

<!-- CSS chung: font, sidebar, header, khung nội dung -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-layout.css">

<!-- JS chung: Ctrl+K tìm kiếm, bật/tắt sidebar trên màn hình nhỏ -->
<script src="${pageContext.request.contextPath}/assets/js/shop-layout.js" defer></script>
