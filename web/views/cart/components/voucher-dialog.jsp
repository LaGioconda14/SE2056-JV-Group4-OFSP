<dialog id="voucher-modal" aria-labelledby="voucher-modal-title" data-vouchers-url="<c:out value='${vouchersUrl}'/>" class="p-0 rounded-2xl w-[min(520px,calc(100%-24px))] backdrop:bg-black/50 backdrop:backdrop-blur-sm">
    <div class="bg-surface-container-lowest w-full max-w-lg rounded-2xl shadow-2xl border border-outline-variant/30 overflow-hidden transform transition-all">
        <div class="px-6 py-4 border-b border-outline-variant/20 flex items-center justify-between bg-surface-container-low/50">
            <div class="flex items-center gap-2"><span class="material-symbols-outlined text-primary text-[24px]">confirmation_number</span><h3 id="voucher-modal-title" class="font-headline-sm text-headline-sm text-on-surface">Chọn voucher</h3></div>
            <button type="button" aria-label="Đóng danh sách voucher" data-voucher-action="close" class="w-8 h-8 rounded-full hover:bg-surface-container flex items-center justify-center text-on-surface-variant transition-colors cursor-pointer"><span class="material-symbols-outlined text-[20px]">close</span></button>
        </div>
        <div id="voucher-tabs-container" class="hidden border-b border-outline-variant/20 px-6 pt-2 bg-surface-container-low/30 gap-6">
            <button type="button" id="tab-voucher-platform" data-voucher-action="filter" data-scope="PLATFORM" class="pb-2.5 text-sm font-bold border-b-2 border-primary text-primary transition-colors cursor-pointer">Voucher Sàn</button>
            <button type="button" id="tab-voucher-shop" data-voucher-action="filter" data-scope="SHOP" class="pb-2.5 text-sm font-semibold border-b-2 border-transparent text-on-surface-variant hover:text-primary transition-colors cursor-pointer">Voucher Shop</button>
        </div>
        <div class="p-6 max-h-[60vh] overflow-y-auto flex flex-col gap-3"><p id="voucher-status" class="text-sm text-on-surface-variant" role="status" aria-live="polite"></p><div id="voucher-list" class="flex flex-col gap-3"></div><p class="text-xs text-outline">Điều kiện được xét trên các sản phẩm đang chọn. Phí ship và số tiền giảm là tạm tính.</p></div>
        <div class="px-6 py-3 border-t border-outline-variant/20 bg-surface-container-low/30 text-right"><button type="button" data-voucher-action="close" class="px-4 py-1.5 rounded-xl border border-outline-variant/40 text-sm font-semibold text-on-surface hover:bg-surface-container transition-colors">Đóng</button></div>
    </div>
</dialog>
