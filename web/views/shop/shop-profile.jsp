<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Shop Profile & Settings - FreshFruit</title>

    <!-- Head chung: meta, font, Font Awesome, Tailwind, shop-layout.css/js -->
    <jsp:include page="/views/shop/layout/head.jsp" />

    <!-- CSS riêng của trang -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-profile.css"/>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="profile" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <%-- Trạng thái shop hiện tại: ACTIVE -> open, PAUSED -> paused, CLOSED -> closed --%>
    <c:choose>
        <c:when test="${shopStatus == 'PAUSED'}"><c:set var="curStatus" value="paused"/></c:when>
        <c:when test="${shopStatus == 'CLOSED'}"><c:set var="curStatus" value="closed"/></c:when>
        <c:otherwise><c:set var="curStatus" value="open"/></c:otherwise>
    </c:choose>
    <c:set var="statusLocked" value="${not empty shopStatus and shopStatus != 'ACTIVE' and shopStatus != 'PAUSED' and shopStatus != 'CLOSED'}"/>

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <!-- Breadcrumb -->
            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-700">Shop Profile</span>
            </nav>

            <!-- Toast thông báo -->
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

            <!-- FORM (multipart để upload logo/banner) -->
            <form id="profileForm" action="${pageContext.request.contextPath}/shop/profile" method="POST" enctype="multipart/form-data">

                <!-- input file ẩn cho logo / banner -->
                <input type="file" id="bannerFile" name="shopBanner" accept="image/*" class="hidden"/>
                <input type="file" id="logoFile" name="shopLogo" accept="image/*" class="hidden"/>
                <input type="hidden" id="shopStatusInput" name="shopStatus" value="${curStatus}"/>

                <!-- BANNER & HEADER SHOP -->
                <div class="relative w-full rounded-2xl bg-white shadow-sm border border-slate-100">
                    <div id="bannerBox" class="relative h-60 md:h-72 w-full bg-cover bg-center rounded-t-2xl" style="background-image: url('${not empty shop.shopBannerUrl ? shop.shopBannerUrl : 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80'}')">
                        <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent rounded-t-2xl"></div>

                        <!-- Nút đổi ảnh banner (góc phải trên) -->
                        <button type="button" onclick="document.getElementById('bannerFile').click()"
                                class="absolute top-4 right-4 px-3.5 py-2 rounded-xl bg-white/90 hover:bg-white text-slate-800 text-sm font-semibold shadow flex items-center gap-2 cursor-pointer transition">
                            <i class="fa-solid fa-camera"></i> Thay ảnh banner
                        </button>

                        <div class="absolute bottom-4 left-4 md:left-8 flex flex-col md:flex-row md:items-end gap-4 text-white">
                            <!-- Logo: bấm vào hiện menu kiểu Facebook -->
                            <div class="relative">
                                <button type="button" id="logoBtn" class="relative block w-20 h-20 md:w-24 md:h-24 rounded-2xl overflow-hidden bg-white p-1 shadow-lg cursor-pointer group">
                                    <img id="logoImg" class="w-full h-full object-cover rounded-xl" src="${not empty shop.shopLogoUrl ? shop.shopLogoUrl : 'https://images.unsplash.com/photo-1595855759920-86582396756a?auto=format&fit=crop&w=300&q=80'}" alt="Logo"/>
                                    <span class="absolute inset-1 rounded-xl bg-black/40 text-white text-lg hidden group-hover:flex items-center justify-center"><i class="fa-solid fa-camera"></i></span>
                                </button>
                                <div id="logoMenu" class="hidden absolute left-0 top-full mt-2 w-60 bg-white text-slate-800 rounded-xl shadow-xl border border-slate-100 py-1.5 z-30">
                                    <button type="button" id="logoViewBtn" class="w-full text-left px-4 py-2.5 text-sm hover:bg-slate-50 flex items-center gap-3 cursor-pointer">
                                        <i class="fa-regular fa-image w-4 text-slate-500"></i> Xem ảnh logo
                                    </button>
                                    <button type="button" id="logoChangeBtn" class="w-full text-left px-4 py-2.5 text-sm hover:bg-slate-50 flex items-center gap-3 cursor-pointer">
                                        <i class="fa-solid fa-camera w-4 text-slate-500"></i> Thay đổi logo
                                    </button>
                                </div>
                            </div>
                            <div class="flex flex-col mb-1">
                                <h1 class="text-2xl font-bold">${not empty shop.shopName ? shop.shopName : 'Đà Lạt Organic'}</h1>
                                <p class="text-sm text-slate-200"><i class="fa-solid fa-location-dot mr-1"></i> ${not empty shop.province ? shop.province : 'Hà Nội'}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Hàng trạng thái + nút lưu -->
                    <div class="px-6 py-4 bg-white rounded-b-2xl flex flex-col md:flex-row md:items-center justify-between gap-3">
                        <div class="flex flex-wrap items-center gap-3">
                            <div class="flex flex-col leading-tight">
                                <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wide">Trạng thái shop</span>
                                <span id="statusText" class="font-bold text-sm text-emerald-600">Đang hoạt động (Open For Orders)</span>
                            </div>
                            <div class="inline-flex items-center bg-slate-100 rounded-xl p-1 gap-1 ${statusLocked ? 'opacity-50 pointer-events-none' : ''}">
                                <button type="button" data-status="open" class="status-btn px-3.5 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 cursor-pointer transition"><span class="w-2 h-2 rounded-full bg-emerald-500"></span> Open</button>
                                <button type="button" data-status="paused" class="status-btn px-3.5 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 cursor-pointer transition"><span class="w-2 h-2 rounded-full bg-amber-500"></span> Pause</button>
                                <button type="button" data-status="closed" class="status-btn px-3.5 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 cursor-pointer transition"><span class="w-2 h-2 rounded-full bg-red-500"></span> Close</button>
                            </div>
                            <c:if test="${statusLocked}">
                                <span class="text-xs text-slate-500">Shop đang ở trạng thái <b>${shopStatus}</b>, liên hệ Admin để thay đổi.</span>
                            </c:if>
                        </div>
                        <button type="button" onclick="saveAllSettings()" class="px-5 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-medium shadow-sm transition flex items-center gap-2 cursor-pointer">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                        </button>
                    </div>
                </div>

                <!-- NAVIGATION TABS -->
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

                <!-- TAB 1: PROFILE & BIO -->
                <div class="tab-content active flex-col gap-6 mt-6" id="tab-profile">
                    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
                        <div class="lg:col-span-8 bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
                            <h2 class="text-lg font-bold text-slate-900 border-b pb-3">Store Identity &amp; Editorial Bio</h2>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Registered Shop Name</label>
                                    <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="shopName" value="<c:out value='${shop.shopName}'/>"/>
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Business Type</label>
                                    <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="businessType" value="<c:out value='${shop.businessType}'/>"/>
                                </div>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Shop Description</label>
                                <textarea class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500 resize-none" name="shopDescription" rows="4"><c:out value="${shop.shopDescription}"/></textarea>
                            </div>
                        </div>
                        <div class="lg:col-span-4 bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
                            <h3 class="text-base font-bold text-slate-900 border-b pb-3">Owner &amp; Principal</h3>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Họ và tên</label>
                                <input class="w-full bg-slate-100 border border-slate-200 rounded-xl px-4 py-2 text-sm text-slate-600" type="text" value="<c:out value='${sessionScope.user.fullName}'/>" readonly/>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Số điện thoại</label>
                                <input class="w-full bg-slate-100 border border-slate-200 rounded-xl px-4 py-2 text-sm text-slate-600" type="text" value="<c:out value='${sessionScope.user.phone}'/>" readonly/>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Email (Gmail)</label>
                                <input class="w-full bg-slate-100 border border-slate-200 rounded-xl px-4 py-2 text-sm text-slate-600" type="email" value="<c:out value='${owner.email}'/>" readonly/>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Ngày sinh</label>
                                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-sm outline-none focus:border-emerald-500" type="date" name="birthDate" value="${owner.birthDate}" max="<%= java.time.LocalDate.now() %>"/>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 2: SELLER IDENTITY -->
                <div class="tab-content hidden flex-col gap-6 mt-6" id="tab-operations">
                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
                        <h2 class="text-lg font-bold text-slate-900 border-b pb-3">Thông Tin Định Danh Người Bán</h2>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Số CCCD / CMND</label>
                                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="idCardNumber" value="<c:out value='${shop.idCardNumber}'/>"/>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Mã số thuế</label>
                                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="taxCode" value="<c:out value='${shop.taxCode}'/>"/>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4">
                            <div class="text-center p-4 border border-dashed rounded-xl bg-slate-50">
                                <p class="text-xs font-semibold text-slate-500 mb-2">Ảnh CCCD Mặt Trước</p>
                                <img src="${not empty shop.idCardFrontUrl ? shop.idCardFrontUrl : 'https://via.placeholder.com/300x180'}" class="mx-auto h-32 object-cover rounded-lg border"/>
                            </div>
                            <div class="text-center p-4 border border-dashed rounded-xl bg-slate-50">
                                <p class="text-xs font-semibold text-slate-500 mb-2">Ảnh CCCD Mặt Sau</p>
                                <img src="${not empty shop.idCardBackUrl ? shop.idCardBackUrl : 'https://via.placeholder.com/300x180'}" class="mx-auto h-32 object-cover rounded-lg border"/>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 3: ADDRESS & HUB -->
                <div class="tab-content hidden flex-col gap-6 mt-6" id="tab-fulfillment">
                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
                        <h2 class="text-lg font-bold text-slate-900 border-b pb-3">Địa Chỉ &amp; Kho Hàng</h2>
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Tỉnh / Thành phố</label>
                                <div class="combo" id="comboProvince">
                                    <input class="combo-input" type="text" name="province" autocomplete="off" placeholder="Chọn hoặc gõ để tìm tỉnh / thành phố" value="<c:out value='${shop.province}'/>"/>
                                    <i class="fa-solid fa-chevron-down combo-arrow"></i>
                                    <div class="combo-list hidden"></div>
                                </div>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Quận / Huyện</label>
                                <div class="combo" id="comboDistrict">
                                    <input class="combo-input" type="text" name="district" autocomplete="off" placeholder="Chọn hoặc gõ để tìm quận / huyện" value="<c:out value='${shop.district}'/>"/>
                                    <i class="fa-solid fa-chevron-down combo-arrow"></i>
                                    <div class="combo-list hidden"></div>
                                </div>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Phường / Xã</label>
                                <div class="combo" id="comboWard">
                                    <input class="combo-input" type="text" name="ward" autocomplete="off" placeholder="Chọn hoặc gõ để tìm phường / xã" value="<c:out value='${shop.ward}'/>"/>
                                    <i class="fa-solid fa-chevron-down combo-arrow"></i>
                                    <div class="combo-list hidden"></div>
                                </div>
                            </div>
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Địa chỉ chi tiết</label>
                            <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="streetAddress" value="<c:out value='${shop.streetAddress}'/>"/>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Địa chỉ lấy hàng</label>
                                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="pickupAddress" value="<c:out value='${shop.pickupAddress}'/>"/>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Địa chỉ hoàn trả</label>
                                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="returnAddress" value="<c:out value='${shop.returnAddress}'/>"/>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 4: BANK & FINANCE -->
                <div class="tab-content hidden flex-col gap-6 mt-6" id="tab-approval">
                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
                        <h2 class="text-lg font-bold text-slate-900 border-b pb-3">Ngân Hàng &amp; Tài Chính</h2>
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Tên Ngân Hàng</label>
                                <div class="combo" id="comboBank">
                                    <input class="combo-input" type="text" name="bankName" autocomplete="off" placeholder="Chọn hoặc gõ để tìm ngân hàng" value="<c:out value='${shop.bankName}'/>"/>
                                    <i class="fa-solid fa-chevron-down combo-arrow"></i>
                                    <div class="combo-list hidden"></div>
                                </div>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Số Tài Khoản</label>
                                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="bankAccountNumber" value="<c:out value='${shop.bankAccountNumber}'/>"/>
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Chủ Tài Khoản</label>
                                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm uppercase outline-none focus:border-emerald-500" type="text" name="bankAccountHolder" value="<c:out value='${shop.bankAccountHolder}'/>"/>
                            </div>
                        </div>
                    </div>
                </div>

            </form>

            <!-- Nút hủy thay đổi (góc dưới bên phải) -->
            <div class="h-20"></div>
            <button type="button" id="discardBtn"
                    class="fixed bottom-6 right-6 z-40 px-5 py-2.5 rounded-xl bg-white hover:bg-slate-50 text-slate-700 text-sm font-semibold shadow-lg border border-slate-200 flex items-center gap-2 cursor-pointer transition">
                <i class="fa-solid fa-rotate-left"></i> Hủy thay đổi
            </button>
        </div>
    </main>

    <!-- Lightbox xem logo -->
    <div id="logoLightbox" class="hidden fixed inset-0 z-[100] bg-black/80 items-center justify-center p-6">
        <button type="button" id="logoLightboxClose" class="absolute top-5 right-6 text-white text-3xl cursor-pointer" aria-label="Đóng">&times;</button>
        <img id="logoLightboxImg" class="max-h-[85vh] max-w-[90vw] rounded-2xl shadow-2xl bg-white" src="" alt="Logo shop"/>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/shop-profile.js"></script>
</body>
</html>
