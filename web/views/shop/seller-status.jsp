<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%--
    Trang theo dõi hồ sơ đăng ký bán hàng. sellerState (do SellerPortalServlet set):
        PENDING  : đang chờ admin duyệt (tài khoản vẫn là khách hàng)
        REJECTED : bị từ chối -> sửa và gửi lại
        APPROVED : đã được duyệt -> nút "Vào trang người bán"
--%>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ đăng ký bán hàng</title>
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

        <nav class="rs-breadcrumb mb-6" aria-label="Breadcrumb">
            <a href="${ctx}/home"><i class="fa-solid fa-house text-xs"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right sep"></i>
            <span class="current">Hồ sơ người bán</span>
        </nav>

        <c:if test="${param.submitted == '1'}">
            <div class="mb-4 flex items-center gap-3 bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-3 rounded-2xl text-sm font-semibold">
                <i class="fa-solid fa-circle-check"></i> Gửi đăng ký thành công! Hồ sơ của bạn đã được ghi nhận.
            </div>
        </c:if>

        <div class="rsu-card">
            <!-- Hero theo trạng thái -->
            <c:choose>
                <c:when test="${sellerState == 'APPROVED'}">
                    <div class="rsu-hero">
                        <div class="rsu-check"><i class="fa-solid fa-store"></i></div>
                        <h1 class="text-2xl sm:text-3xl font-extrabold mt-5">Gian hàng của bạn đã được duyệt!</h1>
                        <p class="text-emerald-50 text-sm mt-2 max-w-md mx-auto">
                            Chúc mừng! Bạn đã trở thành người bán. Từ giờ mỗi lần đăng nhập bạn sẽ vào thẳng trang quản lý gian hàng.
                        </p>
                    </div>
                </c:when>
                <c:when test="${sellerState == 'REJECTED'}">
                    <div class="rsu-hero" style="background:linear-gradient(135deg,#7f1d1d 0%,#dc2626 60%,#f87171 100%)">
                        <div class="rsu-check" style="color:#dc2626"><i class="fa-solid fa-xmark"></i></div>
                        <h1 class="text-2xl sm:text-3xl font-extrabold mt-5">Hồ sơ chưa được duyệt</h1>
                        <p class="text-red-50 text-sm mt-2 max-w-md mx-auto">
                            Rất tiếc, hồ sơ đăng ký bán hàng của bạn chưa đạt yêu cầu. Bạn có thể chỉnh sửa và gửi lại.
                        </p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="rsu-hero">
                        <div class="rsu-check"><i class="fa-solid fa-hourglass-half"></i></div>
                        <h1 class="text-2xl sm:text-3xl font-extrabold mt-5">Hồ sơ đang chờ duyệt</h1>
                        <p class="text-emerald-50 text-sm mt-2 max-w-md mx-auto">
                            Ban quản trị đang xem xét hồ sơ của bạn. Trong lúc chờ, tài khoản của bạn vẫn là khách hàng và có thể mua sắm bình thường.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>

            <div class="px-6 sm:px-10 pb-8 pt-2 flex flex-col gap-7">

                <!-- Thông tin hồ sơ -->
                <c:if test="${not empty shopRequest}">
                    <div>
                        <h2 class="text-sm font-extrabold text-gray-900 uppercase tracking-wide mb-3"><i class="fa-solid fa-file-lines text-emerald-600 mr-1"></i> Thông tin hồ sơ</h2>
                        <div class="rsu-info">
                            <div class="rsu-info-item">
                                <span>Tên gian hàng</span>
                                <b><c:out value="${shopRequest.shopName}"/></b>
                            </div>
                            <div class="rsu-info-item">
                                <span>Mô hình kinh doanh</span>
                                <b>
                                    <c:choose>
                                        <c:when test="${shopRequest.businessType == 'TRAI_CAY_NOI_DIA'}">Trái Cây Nội Địa</c:when>
                                        <c:when test="${shopRequest.businessType == 'TRAI_CAY_NHAP_KHAU'}">Trái Cây Nhập Khẩu</c:when>
                                        <c:when test="${shopRequest.businessType == 'TRAI_CAY_HUU_CO'}">Trái Cây Hữu Cơ (Organic)</c:when>
                                        <c:when test="${shopRequest.businessType == 'HOA_QUA_SAY'}">Hoa Quả Sấy &amp; Chế Biến</c:when>
                                        <c:when test="${shopRequest.businessType == 'COMBO_GIOT_HOA_QUA'}">Giỏ Quà Trái Cây</c:when>
                                        <c:otherwise><c:out value="${shopRequest.businessType}"/></c:otherwise>
                                    </c:choose>
                                </b>
                            </div>
                            <div class="rsu-info-item">
                                <span>Người đăng ký</span>
                                <b><c:out value="${sessionScope.user.fullName}"/></b>
                            </div>
                            <div class="rsu-info-item">
                                <span>Thời gian gửi</span>
                                <b>
                                    <c:choose>
                                        <c:when test="${not empty shopRequest.createdAt}"><fmt:formatDate value="${shopRequest.createdAt}" pattern="HH:mm - dd/MM/yyyy"/></c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </b>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- Lý do từ chối -->
                <c:if test="${sellerState == 'REJECTED'}">
                    <div class="rsu-tip" style="background:#fef2f2;border-color:#fecaca;color:#991b1b">
                        <i class="fa-solid fa-circle-exclamation mt-0.5"></i>
                        <div>
                            <b>Lý do từ chối:</b>
                            <c:out value="${not empty shopRequest.reason ? shopRequest.reason : 'Ban quản trị chưa ghi rõ lý do. Vui lòng kiểm tra lại thông tin và giấy tờ.'}"/>
                        </div>
                    </div>
                </c:if>

                <!-- Quy trình -->
                <c:if test="${sellerState != 'REJECTED'}">
                    <div>
                        <h2 class="text-sm font-extrabold text-gray-900 uppercase tracking-wide mb-4"><i class="fa-solid fa-route text-emerald-600 mr-1"></i> Tiến trình</h2>
                        <div class="rsu-timeline">
                            <div class="rsu-tl-item done">
                                <div class="rsu-tl-dot"><i class="fa-solid fa-paper-plane"></i></div>
                                <div class="rsu-tl-title">Đã gửi hồ sơ</div>
                                <div class="rsu-tl-desc">Hồ sơ của bạn đã được ghi nhận</div>
                            </div>
                            <div class="rsu-tl-item ${sellerState == 'APPROVED' ? 'done' : 'now'}">
                                <div class="rsu-tl-dot"><i class="fa-solid ${sellerState == 'APPROVED' ? 'fa-check' : 'fa-hourglass-half'}"></i></div>
                                <div class="rsu-tl-title">Admin xét duyệt</div>
                                <div class="rsu-tl-desc">${sellerState == 'APPROVED' ? 'Hồ sơ đã được phê duyệt' : 'Thẩm định trong 1–3 ngày làm việc'}</div>
                            </div>
                            <div class="rsu-tl-item ${sellerState == 'APPROVED' ? 'done' : ''}">
                                <div class="rsu-tl-dot"><i class="fa-solid fa-store"></i></div>
                                <div class="rsu-tl-title">Bắt đầu bán hàng</div>
                                <div class="rsu-tl-desc">${sellerState == 'APPROVED' ? 'Gian hàng đã sẵn sàng' : 'Vào trang người bán ngay khi được duyệt'}</div>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- Hành động -->
                <div class="flex flex-col sm:flex-row items-center justify-center gap-3 pt-1">
                    <c:choose>
                        <c:when test="${sellerState == 'APPROVED'}">
                            <a href="${ctx}/seller/enter" class="rs-btn-next w-full sm:w-auto justify-center">
                                <i class="fa-solid fa-store text-xs"></i> Vào trang người bán
                            </a>
                            <a href="${ctx}/home" class="rs-btn-back w-full sm:w-auto justify-center">
                                <i class="fa-solid fa-house text-xs"></i> Về trang chủ
                            </a>
                        </c:when>
                        <c:when test="${sellerState == 'REJECTED'}">
                            <a href="${ctx}/register-shop" class="rs-btn-next w-full sm:w-auto justify-center">
                                <i class="fa-solid fa-pen-to-square text-xs"></i> Chỉnh sửa &amp; gửi lại hồ sơ
                            </a>
                            <a href="${ctx}/home" class="rs-btn-back w-full sm:w-auto justify-center">
                                <i class="fa-solid fa-house text-xs"></i> Về trang chủ
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${ctx}/home" class="rs-btn-next w-full sm:w-auto justify-center">
                                <i class="fa-solid fa-basket-shopping text-xs"></i> Tiếp tục mua sắm
                            </a>
                            <a href="${ctx}/seller/status" class="rs-btn-back w-full sm:w-auto justify-center">
                                <i class="fa-solid fa-rotate text-xs"></i> Kiểm tra lại trạng thái
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/views/common/site-footer.jsp" />
</body>
</html>
