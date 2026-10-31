<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Shop Profile & Settings - FreshFruit</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-profile.css"/>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="profile" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <c:choose>
        <c:when test="${shopStatus == 'PAUSED'}"><c:set var="curStatus" value="paused"/></c:when>
        <c:when test="${shopStatus == 'CLOSED'}"><c:set var="curStatus" value="closed"/></c:when>
        <c:otherwise><c:set var="curStatus" value="open"/></c:otherwise>
    </c:choose>
    <c:set var="statusLocked" value="${not empty shopStatus and shopStatus != 'ACTIVE' and shopStatus != 'PAUSED' and shopStatus != 'CLOSED'}"/>

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-700">Shop Profile</span>
            </nav>

            <c:if test="${not empty sessionScope.successMessage}">
                <div class="mb-4 p-4 bg-emerald-50 border border-emerald-200 text-emerald-700 rounded-xl text-sm flex items-center gap-2">
                    <i class="fa-solid fa-circle-check"></i> ${sessionScope.successMessage}
                </div>
                <% session.removeAttribute("successMessage"); %>
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-xl text-sm flex items-center gap-2">
                    <i class="fa-solid fa-circle-exclamation"></i> ${sessionScope.errorMessage}
                </div>
                <% session.removeAttribute("errorMessage"); %>
            </c:if>

            <form id="profileForm" action="${pageContext.request.contextPath}/shop/profile" method="POST" enctype="multipart/form-data">
                <input type="file" id="bannerFile" name="shopBanner" accept="image/*" class="hidden"/>
                <input type="file" id="logoFile" name="shopLogo" accept="image/*" class="hidden"/>
                <input type="hidden" id="shopStatusInput" name="shopStatus" value="${curStatus}"/>

                <jsp:include page="/views/shop/components/profile/profile-hero-card.jsp" />

                <div class="mt-6 flex items-center gap-2 overflow-x-auto pb-1 bg-white p-2 rounded-2xl shadow-sm border border-slate-100">
                    <button type="button" class="tab-button px-4 py-2.5 rounded-xl font-semibold text-sm transition-all flex items-center gap-2 bg-emerald-600 text-white shadow-sm" id="tab-btn-profile" onclick="switchTab('profile')">
                        <i class="fa-solid fa-store"></i> Shop Profile &amp; Bio
                    </button>
                    <button type="button" class="tab-button px-4 py-2.5 rounded-xl font-semibold text-sm transition-all flex items-center gap-2 text-slate-600 hover:bg-slate-50" id="tab-btn-operations" onclick="switchTab('operations')">
                        <i class="fa-solid fa-id-card"></i> Seller &amp; Identity
                    </button>
                    <button type="button" class="tab-button px-4 py-2.5 rounded-xl font-semibold text-sm transition-all flex items-center gap-2 text-slate-600 hover:bg-slate-50" id="tab-btn-fulfillment" onclick="switchTab('fulfillment')">
                        <i class="fa-solid fa-warehouse"></i> Address &amp; Hub
                    </button>
                    <button type="button" class="tab-button px-4 py-2.5 rounded-xl font-semibold text-sm transition-all flex items-center gap-2 text-slate-600 hover:bg-slate-50" id="tab-btn-approval" onclick="switchTab('approval')">
                        <i class="fa-solid fa-building-columns"></i> Bank &amp; Finance
                    </button>
                </div>

                <jsp:include page="/views/shop/components/profile/profile-tab-content.jsp" />
            </form>

            <div class="h-20"></div>
            <button type="button" id="discardBtn"
                    class="fixed bottom-6 right-6 z-40 px-5 py-2.5 rounded-xl bg-white hover:bg-slate-50 text-slate-700 text-sm font-semibold shadow-lg border border-slate-200 flex items-center gap-2 cursor-pointer transition">
                <i class="fa-solid fa-rotate-left"></i> Hủy thay đổi
            </button>
        </div>
    </main>

    <div id="logoLightbox" class="hidden fixed inset-0 z-[100] bg-black/80 items-center justify-center p-6">
        <button type="button" id="logoLightboxClose" class="absolute top-5 right-6 text-white text-3xl cursor-pointer" aria-label="Đóng">&times;</button>
        <img id="logoLightboxImg" class="max-h-[85vh] max-w-[90vw] rounded-2xl shadow-2xl bg-white" src="" alt="Logo shop"/>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/shop-profile.js"></script>
</body>
</html>
