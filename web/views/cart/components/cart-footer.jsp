<%@page pageEncoding="UTF-8"%>
<%-- id about và contact là điểm neo để các liên kết điều hướng tới nội dung ở chân trang. --%>
<%-- Chân trang giới thiệu thương hiệu và thông tin hỗ trợ. --%>
<footer id="about" class="w-full mt-10 border-t border-[#00652c]/10 bg-[#f2f7f2] text-[#3f493f]">
    <div id="contact" class="max-w-[1360px] mx-auto px-4 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-16 py-10">
            <%-- Logo và lời giới thiệu Gốc Vườn. --%>
            <div class="max-w-md">
                <div class="flex items-center gap-3 mb-4">
                    <span class="inline-flex items-center justify-center w-11 h-11 rounded-2xl bg-[#00652c] text-white shrink-0">
                        <span class="material-symbols-outlined text-[25px]" aria-hidden="true">eco</span>
                    </span>
                    <div>
                        <p class="text-xl font-bold tracking-tight text-[#00652c]">Gốc Vườn</p>
                        <p class="text-[11px] font-semibold tracking-widest uppercase text-[#00652c]/70">Tươi ngon mỗi ngày</p>
                    </div>
                </div>
                <p class="text-sm leading-relaxed">Một chút tươi xanh cho bữa ăn, một chút ngọt lành cho ngày mới. Cảm ơn bạn đã chọn Gốc Vườn cho giỏ hàng của mình.</p>
            </div>
            <%-- Nội dung hướng dẫn liên hệ hỗ trợ đơn hàng. --%>
            <div class="flex flex-col items-start md:justify-self-end">
                <div>
                    <p class="text-xs font-bold tracking-widest uppercase text-[#00652c] mb-2">Đồng hành cùng bạn</p>
                    <h2 class="text-lg font-semibold text-[#131b2e]">Cần hỗ trợ đơn hàng?</h2>
                    <p class="text-sm leading-relaxed mt-1 max-w-xs">Liên hệ để được hỗ trợ về sản phẩm, giao nhận và đơn hàng của bạn.</p>
                </div>
            </div>
        </div>
        <%-- Bản quyền và lời cảm ơn ở cuối trang. --%>
        <div class="border-t border-[#00652c]/10 py-5 flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-xs">
            <p>© 2026 Gốc Vườn Marketplace. Bảo lưu mọi quyền.</p>
            <span class="inline-flex items-center gap-1.5 text-[#00652c]">
                <span class="material-symbols-outlined text-[16px]" aria-hidden="true">favorite</span>Cảm ơn bạn đã mua sắm cùng Gốc Vườn
            </span>
        </div>
    </div>
</footer>
