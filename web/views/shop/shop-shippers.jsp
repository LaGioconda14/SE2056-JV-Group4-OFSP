<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đội Ngũ Giao Hàng - Gốc Vườn Seller Center</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-shippers.css">
    </head>
    <body class="bg-slate-50 text-slate-800 antialiased font-['Inter'] min-h-screen flex m-0">

        <!-- Sidebar Layout -->
        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="activeMenu" value="shippers" />
        </jsp:include>

        <div class="flex-1 flex flex-col min-w-0 overflow-y-auto">

            <!-- Header Layout -->
            <jsp:include page="/views/shop/layout/header.jsp" />

            <main class="flex-1 p-6 max-w-7xl w-full mx-auto space-y-6">

                <!-- Alert Notifications -->
                <c:if test="${param.success eq 'created'}">
                    <div class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-bold flex items-center justify-between shadow-2xs">
                        <div class="flex items-center gap-2.5">
                            <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                            <span>Thêm nhân viên giao hàng mới cho Shop thành công! Tài khoản đã sẵn sàng nhận phân công đơn.</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/shop/shippers" class="text-emerald-700 hover:text-emerald-900"><i class="fa-solid fa-xmark"></i></a>
                    </div>
                </c:if>
                <c:if test="${param.success eq 'updated'}">
                    <div class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-bold flex items-center justify-between shadow-2xs">
                        <div class="flex items-center gap-2.5">
                            <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                            <span>Cập nhật thông tin nhân viên giao hàng thành công!</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/shop/shippers" class="text-emerald-700 hover:text-emerald-900"><i class="fa-solid fa-xmark"></i></a>
                    </div>
                </c:if>
                <c:if test="${param.success eq 'status_changed'}">
                    <div class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-bold flex items-center justify-between shadow-2xs">
                        <div class="flex items-center gap-2.5">
                            <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                            <span>Chuyển đổi trạng thái hoạt động của nhân viên thành công!</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/shop/shippers" class="text-emerald-700 hover:text-emerald-900"><i class="fa-solid fa-xmark"></i></a>
                    </div>
                </c:if>
                <c:if test="${param.success eq 'deleted'}">
                    <div class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-bold flex items-center justify-between shadow-2xs">
                        <div class="flex items-center gap-2.5">
                            <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                            <span>Đã gỡ nhân viên giao hàng khỏi danh sách Shop thành công!</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/shop/shippers" class="text-emerald-700 hover:text-emerald-900"><i class="fa-solid fa-xmark"></i></a>
                    </div>
                </c:if>
                <c:if test="${param.error eq 'cannot_delete_active_shipper'}">
                    <div class="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-xs font-bold flex items-center justify-between shadow-2xs">
                        <div class="flex items-center gap-2.5">
                            <i class="fa-solid fa-triangle-exclamation text-rose-600 text-base"></i>
                            <span>Không thể gỡ nhân viên này vì đang có đơn hàng nông sản đang trên đường giao! Vui lòng chờ hoàn tất đơn.</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/shop/shippers" class="text-rose-700 hover:text-rose-900"><i class="fa-solid fa-xmark"></i></a>
                    </div>
                </c:if>

                <!-- Page Header -->
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <div class="flex items-center gap-2">
                            <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight">Đội Ngũ Nhân Viên Giao Hàng Của Shop</h1>
                            <span class="px-2.5 py-0.5 rounded-full text-[11px] font-black bg-emerald-100 text-emerald-800 border border-emerald-200">
                                Quản lý nội bộ
                            </span>
                        </div>
                        <p class="text-xs text-slate-500 mt-1">Đội ngũ shipper riêng do Gian Hàng trực tiếp quản lý, điều phối đơn hoa quả tươi chuỗi lạnh</p>
                    </div>

                    <button type="button" onclick="openCreateModal()" class="px-4 py-2.5 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs flex items-center gap-2 self-start md:self-center cursor-pointer">
                        <i class="fa-solid fa-user-plus"></i>
                        <span>Thêm Nhân Viên Giao Hàng</span>
                    </button>
                </div>

                <!-- Shippers Grid List -->
                <c:choose>
                    <c:when test="${not empty drivers}">
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                            <c:forEach items="${drivers}" var="d">
                                <div class="bg-white rounded-2xl border border-slate-200 p-5 shadow-xs hover:border-emerald-300 transition-all flex flex-col justify-between">
                                    <div>
                                        <!-- Header row of card -->
                                        <div class="flex items-start justify-between gap-3 pb-3 border-b border-slate-100">
                                            <div class="flex items-center gap-3">
                                                <div class="relative">
                                                    <img src="${not empty d.avatarUrl ? d.avatarUrl : 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&h=100&fit=crop'}" 
                                                         alt="${d.fullName}" class="w-12 h-12 rounded-2xl object-cover border border-slate-100 shadow-2xs">
                                                    <span class="absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white flex items-center justify-center ${d.available ? 'bg-emerald-500' : (d.busy ? 'bg-blue-500' : 'bg-slate-400')}" 
                                                          title="${d.availabilityLabel}">
                                                    </span>
                                                </div>
                                                <div>
                                                    <h3 class="text-sm font-extrabold text-slate-900 leading-snug">${d.fullName}</h3>
                                                    <div class="text-[11px] text-slate-500 mt-0.5 flex items-center gap-1.5">
                                                        <i class="fa-solid fa-phone text-emerald-600 text-[10px]"></i>
                                                        <a href="tel:${d.phone}" class="font-semibold hover:text-emerald-700">${d.phone}</a>
                                                    </div>
                                                </div>
                                            </div>

                                            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black border uppercase ${d.availabilityBadgeClass}">
                                                ${d.availabilityLabel}
                                            </span>
                                        </div>

                                        <!-- Details -->
                                        <div class="mt-3.5 space-y-2 text-xs">
                                            <div class="flex items-center justify-between text-slate-600">
                                                <span class="text-[11px] text-slate-400">Phương tiện:</span>
                                                <span class="font-bold text-slate-800">${not empty d.vehicleType ? d.vehicleType : 'Xe máy chuyên dụng'}</span>
                                            </div>
                                            <div class="flex items-center justify-between text-slate-600">
                                                <span class="text-[11px] text-slate-400">Biển số xe:</span>
                                                <span class="font-mono font-bold text-slate-900 bg-slate-100 px-2 py-0.5 rounded-md border border-slate-200">
                                                    ${not empty d.licensePlate ? d.licensePlate : 'Chưa có'}
                                                </span>
                                            </div>
                                            <div class="flex items-start justify-between text-slate-600 gap-2">
                                                <span class="text-[11px] text-slate-400 shrink-0">Bảo quản lạnh:</span>
                                                <span class="font-semibold text-emerald-800 text-right text-[11px] truncate max-w-[170px]" title="${d.coldStorageType}">
                                                    <i class="fa-solid fa-snowflake text-blue-500 mr-1"></i>${not empty d.coldStorageType ? d.coldStorageType : 'Thùng giữ nhiệt FreshBox'}
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Action buttons -->
                                    <div class="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between gap-2">
                                        <!-- Edit button -->
                                        <button type="button" 
                                                onclick="openEditModal('${d.driverId}', '${d.fullName}', '${d.phone}', '${d.vehicleType}', '${d.licensePlate}', '${d.coldStorageType}', '${d.availabilityStatus}')"
                                                class="px-3 py-1.5 rounded-lg border border-slate-200 hover:border-slate-300 bg-white text-slate-700 hover:bg-slate-50 font-bold text-xs transition flex items-center gap-1.5 cursor-pointer">
                                            <i class="fa-solid fa-pen-to-square text-slate-400"></i>
                                            <span>Sửa</span>
                                        </button>

                                        <!-- Toggle Status button -->
                                        <form action="${pageContext.request.contextPath}/shop/shippers" method="POST" class="m-0">
                                            <input type="hidden" name="action" value="toggle_status">
                                            <input type="hidden" name="driverId" value="${d.driverId}">
                                            <input type="hidden" name="newStatus" value="${d.available ? 'OFFLINE' : 'AVAILABLE'}">
                                            <button type="submit" 
                                                    class="px-3 py-1.5 rounded-lg font-bold text-xs transition cursor-pointer flex items-center gap-1.5 ${d.available ? 'bg-slate-100 hover:bg-slate-200 text-slate-700' : 'bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-200'}">
                                                <i class="fa-solid ${d.available ? 'fa-pause' : 'fa-play'} text-[10px]"></i>
                                                <span>${d.available ? 'Tạm nghỉ' : 'Kích hoạt'}</span>
                                            </button>
                                        </form>

                                        <!-- Delete button -->
                                        <form action="${pageContext.request.contextPath}/shop/shippers" method="POST" class="m-0" onsubmit="return confirm('Bạn có chắc muốn gỡ nhân viên này khỏi danh sách giao hàng của Shop?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="driverId" value="${d.driverId}">
                                            <button type="submit" 
                                                    class="p-1.5 w-8 h-8 rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center transition cursor-pointer" 
                                                    title="Gỡ khỏi Shop">
                                                <i class="fa-regular fa-trash-can text-sm"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center shadow-xs">
                            <div class="w-16 h-16 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center text-3xl mx-auto mb-4">
                                <i class="fa-solid fa-motorcycle"></i>
                            </div>
                            <h3 class="text-base font-extrabold text-slate-900">Chưa có nhân viên giao hàng nào</h3>
                            <p class="text-xs text-slate-500 max-w-md mx-auto mt-1">
                                Thêm nhân viên giao hàng của shop để chủ động giao các đơn hàng nông sản, hoa quả tươi chuỗi lạnh đến tận tay khách hàng.
                            </p>
                            <button type="button" onclick="openCreateModal()" class="mt-4 px-4 py-2.5 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs inline-flex items-center gap-2 cursor-pointer">
                                <i class="fa-solid fa-user-plus"></i>
                                <span>Thêm Nhân Viên Giao Hàng Ngay</span>
                            </button>
                        </div>
                    </c:otherwise>
                </c:choose>

            </main>
        </div>

        <!-- MODAL 1: THÊM MỚI NHÂN VIÊN GIAO HÀNG CHO SHOP -->
        <div id="createModalBackdrop" class="modal-backdrop hidden" onclick="closeCreateModal()"></div>
        <div id="createShipperModal" class="modal-dialog hidden w-full max-w-lg bg-white rounded-2xl border border-slate-200 shadow-2xl">
            <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                <div class="flex items-center gap-2.5">
                    <div class="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center text-base font-bold border border-emerald-200">
                        <i class="fa-solid fa-user-plus"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900">Thêm Nhân Viên Giao Hàng Cho Shop</h3>
                        <p class="text-[11px] text-slate-400">Tạo tài khoản tài xế riêng thuộc sự quản lý của Gian hàng</p>
                    </div>
                </div>
                <button type="button" onclick="closeCreateModal()" class="w-8 h-8 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/shop/shippers" method="POST" class="p-5 space-y-4">
                <input type="hidden" name="action" value="create">

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Họ và tên tài xế <span class="text-rose-500">*</span></label>
                        <input type="text" name="fullName" required placeholder="VD: Nguyễn Văn Nam" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Số điện thoại <span class="text-rose-500">*</span></label>
                        <input type="tel" name="phone" required placeholder="VD: 0912345678" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Email đăng nhập <span class="text-rose-500">*</span></label>
                        <input type="email" name="email" required placeholder="VD: shipper.nam@dalatfarm.vn" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Mật khẩu khởi tạo</label>
                        <input type="text" name="password" value="123456" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Loại phương tiện <span class="text-rose-500">*</span></label>
                        <select name="vehicleType" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500 bg-white">
                            <option value="Xe máy chuyên dụng FreshBox">Xe máy chuyên dụng FreshBox</option>
                            <option value="Xe máy có thùng giữ nhiệt">Xe máy có thùng giữ nhiệt</option>
                            <option value="Xe tải bảo ôn 1.25 tấn">Xe tải bảo ôn 1.25 tấn</option>
                            <option value="Xe tải lạnh 2.5 tấn">Xe tải lạnh 2.5 tấn</option>
                            <option value="Xe bán tải lạnh">Xe bán tải lạnh</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Biển số xe <span class="text-rose-500">*</span></label>
                        <input type="text" name="vehiclePlate" required placeholder="VD: 29-F1 888.88" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500 uppercase">
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Thiết bị bảo quản lạnh</label>
                    <input type="text" name="coldStorageType" value="Thùng giữ nhiệt FreshBox 2-5°C" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                </div>

                <div class="p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs flex items-start gap-2">
                    <i class="fa-solid fa-circle-info text-emerald-600 mt-0.5 text-sm shrink-0"></i>
                    <div class="leading-relaxed">
                        <b>Lưu ý:</b> Tài khoản sau khi tạo sẽ trực tiếp thuộc quyền quản lý của Gian hàng. Khi đơn hàng con sẵn sàng giao, bạn có thể phân công trực tiếp cho shipper này.
                    </div>
                </div>

                <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                    <button type="button" onclick="closeCreateModal()" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                        Hủy
                    </button>
                    <button type="submit" class="px-4 py-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer flex items-center gap-1.5">
                        <i class="fa-solid fa-check"></i>
                        <span>Tạo Nhân Viên</span>
                    </button>
                </div>
            </form>
        </div>

        <!-- MODAL 2: CHỈNH SỬA THÔNG TIN NHÂN VIÊN GIAO HÀNG -->
        <div id="editModalBackdrop" class="modal-backdrop hidden" onclick="closeEditModal()"></div>
        <div id="editShipperModal" class="modal-dialog hidden w-full max-w-lg bg-white rounded-2xl border border-slate-200 shadow-2xl">
            <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                <div class="flex items-center gap-2.5">
                    <div class="w-9 h-9 rounded-xl bg-blue-50 text-blue-700 flex items-center justify-center text-base font-bold border border-blue-200">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900">Chỉnh Sửa Thông Tin Nhân Viên</h3>
                        <p class="text-[11px] text-slate-400">Cập nhật thông tin phương tiện, thiết bị và trạng thái</p>
                    </div>
                </div>
                <button type="button" onclick="closeEditModal()" class="w-8 h-8 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/shop/shippers" method="POST" class="p-5 space-y-4">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="driverId" id="editDriverId">

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Họ và tên <span class="text-rose-500">*</span></label>
                        <input type="text" name="fullName" id="editFullName" required class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Số điện thoại <span class="text-rose-500">*</span></label>
                        <input type="tel" name="phone" id="editPhone" required class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Loại phương tiện</label>
                        <input type="text" name="vehicleType" id="editVehicleType" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Biển số xe</label>
                        <input type="text" name="vehiclePlate" id="editVehiclePlate" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500 uppercase">
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Thiết bị bảo quản lạnh</label>
                        <input type="text" name="coldStorageType" id="editColdStorageType" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Trạng thái hoạt động</label>
                        <select name="availabilityStatus" id="editAvailabilityStatus" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500 bg-white">
                            <option value="AVAILABLE">Sẵn sàng nhận đơn</option>
                            <option value="BUSY">Đang đi giao hàng</option>
                            <option value="OFFLINE">Tạm nghỉ / Offline</option>
                        </select>
                    </div>
                </div>

                <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                    <button type="button" onclick="closeEditModal()" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                        Hủy
                    </button>
                    <button type="submit" class="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer flex items-center gap-1.5">
                        <i class="fa-solid fa-check"></i>
                        <span>Lưu Thay Đổi</span>
                    </button>
                </div>
            </form>
        </div>

        <!-- Scripts -->
        <script src="${pageContext.request.contextPath}/assets/js/shop-shippers.js"></script>
    </body>
</html>
