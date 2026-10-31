<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh Giá Sản Phẩm - OFSP</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
    </style>
</head>
<body class="bg-gray-50 text-gray-800 antialiased min-h-screen flex flex-col justify-between">

    <header class="bg-white border-b border-gray-200 sticky top-0 z-30">
        <div class="max-w-4xl mx-auto px-4 h-16 flex items-center justify-between">
            <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 text-[#00652c] font-black text-xl tracking-tight">
                <i class="fa-solid fa-seedling text-2xl"></i>
                <span>OFSP</span>
            </a>
            <span class="text-sm font-semibold text-gray-600">Đánh Giá Nông Sản</span>
        </div>
    </header>

    <main class="max-w-2xl mx-auto px-4 py-8 flex-1 w-full">
        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
            <div class="p-6 border-b border-gray-100 flex items-center gap-4 bg-emerald-50/40">
                <img src="${item.imageUrl}" alt="${item.productName}" class="w-16 h-16 rounded-xl object-cover border border-emerald-100 shadow-xs">
                <div class="flex-1 min-w-0">
                    <span class="text-xs font-semibold px-2 py-0.5 rounded-full bg-emerald-100 text-[#00652c]">
                        ${item.shopName}
                    </span>
                    <h2 class="text-base font-bold text-gray-900 truncate mt-1">${item.productName}</h2>
                    <p class="text-xs text-gray-500">Phân loại: <span class="font-medium text-gray-700">${item.variantName}</span> | SL: ${item.quantity}</p>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/submit-review" method="POST" class="p-6 space-y-6">
                <input type="hidden" name="orderItemId" value="${item.orderItemId}">
                <input type="hidden" name="shopId" value="${item.shopId}">
                <input type="hidden" name="productId" value="${item.productId}">
                <input type="hidden" name="rating" id="rating-input" value="5">

                <div class="text-center py-2">
                    <p class="text-sm font-bold text-gray-700 mb-2">Chất lượng nông sản bạn nhận được thế nào?</p>
                    <div class="flex items-center justify-center gap-3 text-3xl cursor-pointer" id="star-box">
                        <i class="fa-solid fa-star text-amber-400 hover:scale-110 transition-transform" data-star="1"></i>
                        <i class="fa-solid fa-star text-amber-400 hover:scale-110 transition-transform" data-star="2"></i>
                        <i class="fa-solid fa-star text-amber-400 hover:scale-110 transition-transform" data-star="3"></i>
                        <i class="fa-solid fa-star text-amber-400 hover:scale-110 transition-transform" data-star="4"></i>
                        <i class="fa-solid fa-star text-amber-400 hover:scale-110 transition-transform" data-star="5"></i>
                    </div>
                    <span id="star-label" class="inline-block mt-2 text-xs font-bold text-emerald-700 bg-emerald-50 px-3 py-1 rounded-full border border-emerald-100">
                        Tuyệt vời - Rất hài lòng (5/5)
                    </span>
                </div>

                <div>
                    <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">
                        Nhận xét chi tiết về sản phẩm
                    </label>
                    <textarea name="comment" rows="4" required
                              class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:ring-2 focus:ring-[#00652c] focus:border-[#00652c] text-sm text-gray-800 outline-none transition resize-none"
                              placeholder="Hãy chia sẻ cảm nhận về độ tươi, hương vị, cách thức đóng gói bảo quản lạnh và trải nghiệm giao hàng của bạn..."></textarea>
                </div>

                <div>
                    <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">
                        Hình ảnh thực tế khi nhận hàng (Tùy chọn)
                    </label>
                    <div class="space-y-2">
                        <input type="url" name="image1" placeholder="Link ảnh thực tế 1 (VD: https://...)"
                               class="w-full px-3 py-2 text-xs rounded-lg border border-gray-300 focus:ring-1 focus:ring-[#00652c] outline-none">
                        <input type="url" name="image2" placeholder="Link ảnh thực tế 2 (Tùy chọn)"
                               class="w-full px-3 py-2 text-xs rounded-lg border border-gray-300 focus:ring-1 focus:ring-[#00652c] outline-none">
                    </div>
                    <p class="text-[11px] text-gray-400 mt-1">Đăng kèm ảnh thực tế giúp các khách hàng khác tin tưởng và lựa chọn đúng nông sản chất lượng.</p>
                </div>

                <div class="pt-4 flex items-center justify-end gap-3 border-t border-gray-100">
                    <a href="javascript:history.back()" class="px-5 py-2.5 rounded-xl border border-gray-300 text-gray-700 font-semibold text-sm hover:bg-gray-50 transition">
                        Quay lại
                    </a>
                    <button type="submit" class="px-6 py-2.5 rounded-xl bg-[#00652c] hover:bg-[#005123] text-white font-bold text-sm shadow-md hover:shadow-lg transition">
                        Gửi Đánh Giá
                    </button>
                </div>
            </form>
        </div>
    </main>

    <footer class="bg-white border-t border-gray-200 py-4 text-center text-xs text-gray-400">
        OFSP - Nông sản sạch từ gốc vườn, tươi chuẩn chuỗi lạnh.
    </footer>

    <script>
        const starLabels = {
            1: "Rất tệ - Không hài lòng (1/5)",
            2: "Tệ - Cần cải thiện (2/5)",
            3: "Bình thường - Tạm ổn (3/5)",
            4: "Tốt - Hài lòng (4/5)",
            5: "Tuyệt vời - Rất hài lòng (5/5)"
        };

        const stars = document.querySelectorAll('#star-box i');
        const ratingInput = document.getElementById('rating-input');
        const starLabel = document.getElementById('star-label');

        stars.forEach(star => {
            star.addEventListener('click', function() {
                const val = parseInt(this.getAttribute('data-star'));
                ratingInput.value = val;
                starLabel.innerText = starLabels[val] || (val + "/5");

                stars.forEach((s, idx) => {
                    if (idx < val) {
                        s.classList.remove('fa-regular', 'text-gray-300');
                        s.classList.add('fa-solid', 'text-amber-400');
                    } else {
                        s.classList.remove('fa-solid', 'text-amber-400');
                        s.classList.add('fa-regular', 'text-gray-300');
                    }
                });
            });
        });
    </script>
</body>
</html>

