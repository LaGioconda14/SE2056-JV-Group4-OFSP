<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="grid grid-cols-1 lg:grid-cols-12 gap-5 mt-2">
    <div class="lg:col-span-5 sensor-card-widget">
        <div class="flex items-start justify-between pb-3 border-b border-slate-100">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-800 flex items-center justify-center shrink-0">
                    <i class="fa-solid fa-temperature-arrow-down text-lg"></i>
                </div>
                <div>
                    <h4 class="font-extrabold text-sm text-slate-900 leading-tight">Cảm Biến Kho Lạnh Lô Hái</h4>
                    <span class="text-xs text-slate-500 leading-tight block mt-0.5">Khu vực phân loại đóng gói Vườn 01</span>
                </div>
            </div>
            <span class="px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-[11px] font-extrabold flex items-center gap-1.5">
                <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span> Hoạt động tốt
            </span>
        </div>

        <div class="grid grid-cols-3 gap-2 mt-4 text-center">
            <div class="p-2.5 rounded-xl bg-slate-50 border border-slate-100">
                <span class="text-[10px] text-slate-400 block font-bold">Nhiệt độ hiện tại</span>
                <span class="text-lg font-black text-slate-900 mt-1 block">4.2°C</span>
                <span class="text-[10px] text-emerald-600 font-bold block mt-0.5">Chuẩn bảo quản</span>
            </div>
            <div class="p-2.5 rounded-xl bg-slate-50 border border-slate-100">
                <span class="text-[10px] text-slate-400 block font-bold">Độ ẩm buồng mát</span>
                <span class="text-lg font-black text-slate-900 mt-1 block">88%</span>
                <span class="text-[10px] text-emerald-600 font-bold block mt-0.5">Tối ưu mọng nước</span>
            </div>
            <div class="p-2.5 rounded-xl bg-slate-50 border border-slate-100">
                <span class="text-[10px] text-slate-400 block font-bold">Lưu lượng khí O2</span>
                <span class="text-lg font-black text-slate-900 mt-1 block">19.5%</span>
                <span class="text-[10px] text-emerald-600 font-bold block mt-0.5">Khí quyển giảm Ethylene</span>
            </div>
        </div>

        <div class="mt-4 p-3 bg-emerald-50/70 rounded-xl border border-emerald-100 flex items-center justify-between text-xs">
            <div class="flex items-center gap-2 text-emerald-900 font-semibold">
                <i class="fa-solid fa-shield-halved text-emerald-700"></i>
                <span>Chế độ giữ lạnh: Chuẩn xuất khẩu</span>
            </div>
            <a href="#" class="font-bold text-emerald-700 hover:text-emerald-800">Cấu hình</a>
        </div>
    </div>

    <div class="lg:col-span-7 harvest-schedule-widget">
        <div class="flex items-center justify-between pb-3 border-b border-slate-100">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-orange-100 text-orange-700 flex items-center justify-center shrink-0">
                    <i class="fa-solid fa-calendar-check text-lg"></i>
                </div>
                <div>
                    <h4 class="font-extrabold text-sm text-slate-900 leading-tight">Lịch Hái &amp; Bổ Sung Kho Hôm Nay</h4>
                    <span class="text-xs text-slate-500 leading-tight block mt-0.5">3 đợt thu hoạch từ các vườn liên kết</span>
                </div>
            </div>
            <a href="#" class="text-xs font-bold text-emerald-700 hover:text-emerald-800 underline">
                Xem toàn bộ lịch hái
            </a>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mt-4">
            <div class="schedule-item-card">
                <div class="flex items-center justify-between">
                    <span class="font-bold text-xs text-slate-900">Dâu Tây Tochi</span>
                    <span class="px-1.5 py-0.2 rounded bg-pink-100 text-pink-700 text-[10px] font-bold">Đang hái</span>
                </div>
                <div class="mt-2 text-xs text-slate-600">
                    Dự kiến nhập: <strong class="text-slate-900">35 hộp</strong> lúc 11:30
                </div>
                <div class="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden mt-3">
                    <div class="bg-orange-500 h-full rounded-full" style="width: 65%;"></div>
                </div>
            </div>

            <div class="schedule-item-card">
                <div class="flex items-center justify-between">
                    <span class="font-bold text-xs text-slate-900">Nho Hạ Đen</span>
                    <span class="px-1.5 py-0.2 rounded bg-orange-100 text-orange-700 text-[10px] font-bold">Đóng giỏ</span>
                </div>
                <div class="mt-2 text-xs text-slate-600">
                    Dự kiến nhập: <strong class="text-slate-900">50 chùm</strong> lúc 14:00
                </div>
                <div class="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden mt-3">
                    <div class="bg-red-700 h-full rounded-full" style="width: 40%;"></div>
                </div>
            </div>

            <div class="schedule-item-card">
                <div class="flex items-center justify-between">
                    <span class="font-bold text-xs text-slate-900">Bơ Sáp 034</span>
                    <span class="px-1.5 py-0.2 rounded bg-slate-200 text-slate-700 text-[10px] font-bold">Chờ hái chiều</span>
                </div>
                <div class="mt-2 text-xs text-slate-600">
                    Dự kiến nhập: <strong class="text-slate-900">120 kg</strong> lúc 16:30
                </div>
                <div class="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden mt-3">
                    <div class="bg-slate-400 h-full rounded-full" style="width: 15%;"></div>
                </div>
            </div>
        </div>
    </div>
</div>
