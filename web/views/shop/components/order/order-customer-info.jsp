<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />

                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                                <div class="flex items-center gap-2">
                                    <i class="fa-solid fa-location-dot text-emerald-600 text-sm"></i>
                                    <h3 class="text-sm font-extrabold text-slate-900">Thông Tin Người Nhận</h3>
                                </div>
                                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                    Khách Hàng
                                </span>
                            </div>

                            <div class="mt-4 flex items-center gap-3">
                                <div class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center font-extrabold text-sm shrink-0">
                                    ${not empty subOrder.shippingAddress.recipientName ? subOrder.shippingAddress.recipientName.substring(0, 1).toUpperCase() : 'KH'}
                                </div>
                                <div>
                                    <div class="text-sm font-extrabold text-slate-900">
                                        ${not empty subOrder.shippingAddress.recipientName ? subOrder.shippingAddress.recipientName : 'Khách Mua Hàng'}
                                    </div>
                                    <div class="text-[11px] text-slate-400">
                                        SĐT: ${not empty subOrder.shippingAddress.recipientPhone ? subOrder.shippingAddress.recipientPhone : 'Chưa có SĐT'} (Đã bảo mật)
                                    </div>
                                </div>
                            </div>

                            <div class="mt-4 pt-3 border-t border-slate-100">
                                <div class="text-[10px] font-bold text-slate-400 uppercase">ĐỊA CHỈ GIAO HÀNG TƯƠI:</div>
                                <div class="text-xs font-semibold text-slate-800 mt-1 leading-relaxed">
                                    <c:choose>
                                        <c:when test="${not empty subOrder.shippingAddress.streetAddress}">
                                            ${subOrder.shippingAddress.streetAddress}<c:if test="${not empty subOrder.shippingAddress.ward}">, ${subOrder.shippingAddress.ward}</c:if><c:if test="${not empty subOrder.shippingAddress.district}">, ${subOrder.shippingAddress.district}</c:if><c:if test="${not empty subOrder.shippingAddress.city}">, ${subOrder.shippingAddress.city}</c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-slate-400 italic">Chưa có thông tin địa chỉ chi tiết</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="mt-3.5 p-3 rounded-xl bg-slate-50 border border-slate-200 text-xs">
                                <div class="flex items-center gap-1.5 text-slate-700 font-bold text-[11px] mb-1">
                                    <i class="fa-regular fa-comment-dots"></i> GHI CHÚ GIAO HÀNG TỪ KHÁCH:
                                </div>
                                <p class="text-[11px] text-slate-600 leading-relaxed italic">
                                    <c:choose>
                                        <c:when test="${not empty subOrder.deliverySlot}">
                                            Khung giờ giao yêu cầu: <strong class="text-slate-800 not-italic">${subOrder.deliverySlot}</strong>
                                        </c:when>
                                        <c:otherwise>
                                            (Khách hàng không để lại ghi chú cho đơn hàng này)
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>

                        <c:if test="${not empty subOrder.driverName}">
                            <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                                <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                                    <div class="flex items-center gap-2">
                                        <i class="fa-solid fa-motorcycle text-emerald-600 text-sm"></i>
                                        <h3 class="text-sm font-extrabold text-slate-900">Nhân Viên Giao Hàng</h3>
                                    </div>
                                    <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                        Đã Phân Công
                                    </span>
                                </div>
                                <div class="mt-4 flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center font-extrabold text-base shrink-0">
                                        <i class="fa-solid fa-user-check"></i>
                                    </div>
                                    <div>
                                        <div class="text-sm font-extrabold text-slate-900">${subOrder.driverName}</div>
                                        <div class="text-[11px] text-slate-500">
                                            SĐT: <b class="text-slate-700">${not empty subOrder.driverPhone ? subOrder.driverPhone : 'Chưa có SĐT'}</b>
                                        </div>
                                    </div>
                                </div>
                                <c:if test="${not empty subOrder.driverVehiclePlate}">
                                    <div class="mt-3 pt-3 border-t border-slate-100 text-xs flex items-center justify-between">
                                        <span class="text-slate-500">Biển số phương tiện:</span>
                                        <span class="font-mono font-bold text-slate-800 bg-slate-100 px-2 py-0.5 rounded border border-slate-200">${subOrder.driverVehiclePlate}</span>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>
