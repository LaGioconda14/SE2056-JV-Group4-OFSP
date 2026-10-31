<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
    <div class="flex items-center justify-between pb-4 border-b border-slate-100">
        <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-sm font-bold border border-amber-200">
                <i class="fa-solid fa-clipboard-question"></i>
            </div>
            <div>
                <h2 class="text-base font-extrabold text-slate-900">Kiểm Tra Nông Sản &amp; Tiếp Nhận Đơn Hàng</h2>
                <p class="text-[11px] text-slate-400">Kiểm tra thực tế kho bảo quản trước khi xác nhận</p>
            </div>
        </div>
        <span class="px-3 py-1 rounded-full text-xs font-extrabold bg-amber-50 text-amber-700 border border-amber-200 animate-pulse">
            Đơn mới chờ xác nhận
        </span>
    </div>

    <div class="mt-4 p-4 rounded-xl bg-slate-50 border border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center text-lg font-bold shrink-0">
                <i class="fa-solid fa-leaf"></i>
            </div>
            <div>
                <div class="text-xs font-black text-slate-900">
                    Nông sản tươi có sẵn &amp; đạt chuẩn chất lượng? (Fresh fruit available &amp; qualified?)
                </div>
                <div class="text-[11px] text-slate-500 mt-0.5">
                    Kiểm tra số lượng tồn kho lạnh và chất lượng quả tươi đạt chuẩn trước khi tiếp nhận đóng gói.
                </div>
            </div>
        </div>
    </div>

    <div class="mt-5 grid grid-cols-1 sm:grid-cols-2 gap-3">
        <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="m-0">
            <input type="hidden" name="action" value="confirm">
            <input type="hidden" name="code" value="${subOrder.subOrderCode}">
            <button type="submit" class="w-full py-3 px-4 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs flex items-center justify-center gap-2 cursor-pointer">
                <i class="fa-solid fa-check"></i>
                <span>Đạt Chuẩn - Tiếp Nhận &amp; Đóng Gói</span>
            </button>
        </form>

        <button type="button" class="btn-open-cancel-modal w-full py-3 px-4 rounded-xl bg-white hover:bg-rose-50 text-rose-600 border border-rose-300 hover:border-rose-400 font-extrabold text-xs transition flex items-center justify-center gap-2 cursor-pointer">
            <i class="fa-solid fa-ban"></i>
            <span>Hết Hàng / Quả Hỏng - Hủy Đơn</span>
        </button>
    </div>
</div>

