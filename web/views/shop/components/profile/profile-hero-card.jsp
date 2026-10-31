<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="relative w-full rounded-2xl bg-white shadow-sm border border-slate-100">
    <div id="bannerBox" class="relative h-60 md:h-72 w-full bg-cover bg-center rounded-t-2xl" style="background-image: url('${not empty shop.shopBannerUrl ? shop.shopBannerUrl : 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80'}')">
        <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent rounded-t-2xl"></div>

        <button type="button" onclick="document.getElementById('bannerFile').click()"
                class="absolute top-4 right-4 px-3.5 py-2 rounded-xl bg-white/90 hover:bg-white text-slate-800 text-sm font-semibold shadow flex items-center gap-2 cursor-pointer transition">
            <i class="fa-solid fa-camera"></i> Thay ảnh banner
        </button>

        <div class="absolute bottom-4 left-4 md:left-8 flex flex-col md:flex-row md:items-end gap-4 text-white">
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

