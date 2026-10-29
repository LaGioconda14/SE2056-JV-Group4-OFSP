<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:useBean id="now" class="java.util.Date" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gửi Đăng Ký Thành Công - FreshFruit</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/home.css">
    <link rel="stylesheet" href="${ctx}/assets/css/register-shop.css">
    <script src="${ctx}/assets/js/home.js" defer></script>
</head>
<body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

    <jsp:include page="/views/common/site-header.jsp" />

    <main class="max-w-3xl mx-auto px-4 py-6 sm:py-8">

        <!-- Breadcrumb -->
        <nav class="rs-breadcrumb mb-6" aria-label="Breadcrumb">
            <a href="${ctx}/home"><i class="fa-solid fa-house text-xs"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right sep"></i>
            <a href="${ctx}/register-shop">Đăng ký shop</a>
            <i class="fa-solid fa-chevron-right sep"></i>
            <span class="current">Hoàn tất</span>
        </nav>

        <div class="rsu-card">
            <!-- Hero -->
            <div class="rsu-hero">
                <div class="rsu-check"><i class="fa-solid fa-check"></i></div>
                <h1 class="text-2xl sm:text-3xl font-extrabold mt-5">Gửi đăng ký thành công!</h1>
                <p class="text-emerald-50 text-sm mt-2 max-w-md mx-auto">
                    Hồ sơ mở gian hàng của bạn đã được gửi tới FreshFruit. Chúng tôi sẽ xem xét và phản hồi sớm nhất có thể.
                </p>
            </div>

            <div class="px-6 sm:px-10 pb-8 pt-2 flex flex-col gap-7">

                <!-- Thông tin hồ sơ -->
                <div>
                    <h2 class="text-sm font-extrabold text-gray-900 uppercase tracking-wide mb-3"><i class="fa-solid fa-file-lines text-emerald-600 mr-1"></i> Thông tin hồ sơ đã gửi</h2>
                    <div class="rsu-info">
                        <div class="rsu-info-item">
                            <span>Tên gian hàng</span>
                            <b><c:out value="${not empty param.shopName ? param.shopName : '—'}"/></b>
                        </div>
                        <div class="rsu-info-item">
                            <span>Mô hình kinh doanh</span>
                            <b>
                                <c:choose>
                                    <c:when test="${param.businessType == 'TRAI_CAY_NOI_DIA'}">Trái Cây Nội Địa</c:when>
                                    <c:when test="${param.businessType == 'TRAI_CAY_NHAP_KHAU'}">Trái Cây Nhập Khẩu</c:when>
                                    <c:when test="${param.businessType == 'TRAI_CAY_HUU_CO'}">Trái Cây Hữu Cơ (Organic)</c:when>
                                    <c:when test="${param.businessType == 'HOA_QUA_SAY'}">Hoa Quả Sấy &amp; Chế Biến</c:when>
                                    <c:when test="${param.businessType == 'COMBO_GIOT_HOA_QUA'}">Giỏ Quà Trái Cây</c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </b>
                        </div>
                        <div class="rsu-info-item">
                            <span>Người đăng ký</span>
                            <b><c:out value="${not empty param.fullName ? param.fullName : sessionScope.user.fullName}"/></b>
                        </div>
                        <div class="rsu-info-item">
                            <span>Thời gian gửi</span>
                            <b><fmt:formatDate value="${now}" pattern="HH:mm - dd/MM/yyyy"/></b>
                        </div>
                    </div>
                </div>

                <!-- Quy trình tiếp theo -->
                <div>
                    <h2 class="text-sm font-extrabold text-gray-900 uppercase tracking-wide mb-4"><i class="fa-solid fa-route text-emerald-600 mr-1"></i> Quy trình tiếp theo</h2>
                    <div class="rsu-timeline">
                        <div class="rsu-tl-item done">
                            <div class="rsu-tl-dot"><i class="fa-solid fa-paper-plane"></i></div>
                            <div class="rsu-tl-title">Đã gửi hồ sơ</div>
                            <div class="rsu-tl-desc">Hồ sơ của bạn đã được ghi nhận</div>
                        </div>
                        <div class="rsu-tl-item now">
                            <div class="rsu-tl-dot"><i class="fa-solid fa-hourglass-half"></i></div>
                            <div class="rsu-tl-title">Admin xét duyệt</div>
                            <div class="rsu-tl-desc">Thẩm định trong 1–3 ngày làm việc</div>
                        </div>
                        <div class="rsu-tl-item">
                            <div class="rsu-tl-dot"><i class="fa-solid fa-store"></i></div>
                            <div class="rsu-tl-title">Bắt đầu bán hàng</div>
                            <div class="rsu-tl-desc">Nhận thông báo và mở gian hàng</div>
                        </div>
                    </div>
                </div>

                <!-- Lưu ý -->
                <div class="rsu-tip">
                    <i class="fa-solid fa-lightbulb text-amber-500 mt-0.5"></i>
                    <div>
                        <b>Trong lúc chờ duyệt, bạn có thể chuẩn bị:</b> hình ảnh thật và thông tin xuất xứ của từng loại trái cây, giá bán, tồn kho và các giấy chứng nhận (VietGAP, GlobalGAP, Organic…) để đăng sản phẩm ngay khi gian hàng được kích hoạt. Kết quả xét duyệt sẽ được gửi vào mục <b>Thông báo</b> trong tài khoản của bạn.
                    </div>
                </div>

                <!-- Hành động -->
                <div class="flex flex-col sm:flex-row items-center justify-center gap-3 pt-1">
                    <a href="${ctx}/home" class="rs-btn-next w-full sm:w-auto justify-center"><i class="fa-solid fa-house text-xs"></i> Về trang chủ</a>
                    <a href="${ctx}/profile" class="rs-btn-back w-full sm:w-auto justify-center"><i class="fa-regular fa-bell text-xs"></i> Xem thông báo của tôi</a>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/views/common/site-footer.jsp" />
</body>
</html>
