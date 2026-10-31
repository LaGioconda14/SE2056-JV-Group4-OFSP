<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="bg-white rounded-2xl border border-rose-300 p-6 shadow-xs bg-rose-50/20 space-y-5">
    <div class="flex items-start justify-between pb-4 border-b border-rose-200">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-rose-100 text-rose-600 flex items-center justify-center text-lg font-bold border border-rose-200 shadow-2xs">
                <i class="fa-solid fa-rotate-left"></i>
            </div>
            <div>
                <h2 class="text-base font-extrabold text-slate-900">Kiện Hàng Giao Thất Bại &amp; Chuyển Hoàn Về Shop</h2>
                <p class="text-[11px] text-slate-500">Shipper đã mang kiện hàng hoàn về lại Gian hàng. Vui lòng mở thùng kiểm định độ tươi và đá gel.</p>
            </div>
        </div>
        <span class="px-3 py-1 rounded-full text-xs font-black bg-rose-100 text-rose-800 border border-rose-300">
            CHỜ KIỂM ĐỊNH HÀNG HOÀN
        </span>
    </div>

    <div class="p-3.5 rounded-xl bg-white border border-rose-200 text-xs space-y-1 shadow-2xs">
        <div class="font-extrabold text-rose-800 flex items-center gap-1.5">
            <i class="fa-solid fa-triangle-exclamation text-rose-600"></i>
            <span>Lý do chuyển hoàn từ tài xế / Shipper:</span>
        </div>
        <div class="text-slate-800 leading-relaxed font-semibold pl-4 border-l-2 border-rose-400">
            ${not empty subOrder.cancelReason ? subOrder.cancelReason : "Khách hàng từ chối nhận hoa quả hoặc không liên lạc được khi giao."}
        </div>
    </div>

    <c:choose>
        <c:when test="${not empty subOrder.cancelReason and subOrder.cancelReason.contains('[ĐÃ XỬ LÝ')}">
            <div class="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs flex items-center gap-3 shadow-2xs">
                <div class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-700 flex items-center justify-center text-base shrink-0 font-bold">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
                <div>
                    <div class="font-black text-emerald-950 text-sm">Đã Hoàn Tất Kiểm Định Hàng Hoàn</div>
                    <div class="text-[11px] text-emerald-800 mt-0.5">Số liệu tồn kho và sổ hao hụt đã được cập nhật chính xác theo kết quả kiểm định.</div>
                </div>
            </div>
        </c:when>

        <c:otherwise>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-1">
                <div class="p-4 rounded-xl border border-emerald-200 bg-emerald-50/40 flex flex-col justify-between space-y-3">
                    <div class="space-y-1">
                        <div class="flex items-center gap-2 text-emerald-800 font-extrabold text-xs">
                            <i class="fa-solid fa-seedling text-emerald-600"></i>
                            <span>1. Hoa Quả Còn Tươi Nguyên</span>
                        </div>
                        <p class="text-[11px] text-slate-600 leading-relaxed">
                            Đá gel còn lạnh sâu, hoa quả còn tươi cứng, không dập nát ➔ <b>Cộng hoàn lại 100% vào kho bán</b>.
                        </p>
                    </div>
                    <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" onsubmit="return confirm('Bạn có chắc chắn hoa quả còn tươi nguyên và muốn nhập lại kho bán?');">
                        <input type="hidden" name="action" value="return_restock">
                        <input type="hidden" name="code" value="${subOrder.subOrderCode}">
                        <input type="hidden" name="restockNote" value="Kiểm tra kiện hoàn: Đá gel còn lạnh, hoa quả đạt chuẩn xuất kho lại">
                        <button type="submit" class="w-full py-2.5 px-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold text-xs transition shadow-2xs flex items-center justify-center gap-2 cursor-pointer">
                            <i class="fa-solid fa-box-open"></i>
                            <span>Xác Nhận Hàng Tươi - Nhập Lại Kho</span>
                        </button>
                    </form>
                </div>

                <div class="p-4 rounded-xl border border-rose-200 bg-rose-50/40 flex flex-col justify-between space-y-3">
                    <div class="space-y-1">
                        <div class="flex items-center gap-2 text-rose-800 font-extrabold text-xs">
                            <i class="fa-solid fa-triangle-exclamation text-rose-600"></i>
                            <span>2. Đứt Chuỗi Lạnh / Dập Nát Hỏng</span>
                        </div>
                        <p class="text-[11px] text-slate-600 leading-relaxed">
                            Hoa quả bị chảy nước, nát thối do vận chuyển quá lâu hoặc va đập ➔ <b>Tiêu hủy và ghi nhận vào Nhật ký hao hụt</b>.
                        </p>
                    </div>
                    <button type="button" id="btnOpenReturnWasteModal" class="w-full py-2.5 px-3 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-2xs flex items-center justify-center gap-2 cursor-pointer">
                        <i class="fa-solid fa-trash-can"></i>
                        <span>Báo Hỏng / Tiêu Hủy Do Vận Chuyển</span>
                    </button>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

