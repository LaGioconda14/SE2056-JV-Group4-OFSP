<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sửa biến thể - ${variant.variantName}</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 text-slate-800 font-['Plus_Jakarta_Sans',sans-serif]">

    <main class="max-w-4xl mx-auto p-6 md:p-10 space-y-6">

        <div class="flex items-center justify-between">
            <a href="${pageContext.request.contextPath}/shop/product/variants?productId=${variant.productId}" class="inline-flex items-center gap-2 text-xs font-extrabold text-slate-600 hover:text-emerald-700 transition-colors">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách biến thể
            </a>
            <span class="text-xs font-semibold text-slate-400">Kênh Người Bán &gt; Cập nhật phân loại</span>
        </div>

        <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <header class="bg-emerald-900 text-white p-5 flex items-center gap-4">
                <img src="${variant.image}" alt="${variant.productName}" class="w-16 h-16 rounded-xl object-cover border-2 border-emerald-500/50 shrink-0 shadow-xs" onerror="this.src='https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop';">
                <div class="min-w-0 flex-1">
                    <span class="text-[10px] uppercase font-black tracking-wider text-emerald-300">Sản phẩm gốc</span>
                    <h2 class="text-lg font-black leading-tight mt-0.5">${variant.productName}</h2>
                    <p class="text-xs text-emerald-200 mt-1">Đang chỉnh sửa biến thể ID: <strong class="text-white">#${variant.variantId}</strong></p>
                </div>
            </header>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-4 p-5 text-xs">
                <div><p class="text-slate-400 font-semibold">Danh mục</p><p class="mt-1 font-bold text-slate-800">${not empty variant.categoryName ? variant.categoryName : 'Chưa phân loại'}</p></div>
                <div><p class="text-slate-400 font-semibold">Xuất xứ</p><p class="mt-1 font-bold text-slate-800">${not empty variant.origin ? variant.origin : 'Chưa cập nhật'}</p></div>
                <div><p class="text-slate-400 font-semibold">Chứng nhận</p><p class="mt-1 font-bold text-slate-800">${not empty variant.certification ? variant.certification : 'Chưa cập nhật'}</p></div>
                <div><p class="text-slate-400 font-semibold">Bảo quản</p><p class="mt-1 font-bold text-slate-800">${not empty variant.storageTemp ? variant.storageTemp : 'Chưa cập nhật'}</p></div>
                <c:if test="${not empty variant.description}">
                    <div class="col-span-2 md:col-span-3"><p class="text-slate-400 font-semibold">Mô tả sản phẩm</p><p class="mt-1 leading-relaxed text-slate-700 whitespace-pre-line">${variant.description}</p></div>
                </c:if>
            </div>
        </section>

        <c:if test="${not empty errorMessage}">
            <div class="bg-rose-50 border border-rose-300 text-rose-900 px-4 py-3 rounded-2xl flex items-center gap-3 shadow-xs">
                <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                <span class="text-xs font-bold">${errorMessage}</span>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/shop/product/variant/edit" method="POST" class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden space-y-6">

            <input type="hidden" name="variantId" value="${variant.variantId}">
            <input type="hidden" name="productId" value="${variant.productId}">

            <header class="p-6 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
                <div>
                    <h1 class="text-xl font-black text-slate-900">Chỉnh sửa thông tin biến thể</h1>
                    <p class="text-xs text-slate-500 font-medium mt-1">Cập nhật giá bán, số lượng kho hoặc quy cách đóng gói cho phân loại này.</p>
                </div>
                <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-700 flex items-center justify-center font-bold text-lg">
                    <i class="fa-solid fa-pen-to-square"></i>
                </div>
            </header>

            <div class="p-6 space-y-6">

                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div>
                        <label class="block text-xs font-black text-slate-700 uppercase tracking-wider mb-2">
                            Tên biến thể / Quy cách <span class="text-rose-500">*</span>
                        </label>
                        <input type="text" name="variantName" value="${variant.variantName}" required placeholder="Ví dụ: Thùng 5kg, Hộp 1kg..." class="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                        <p class="text-[11px] text-slate-400 mt-1">Tên hiển thị để khách chọn phân loại mua.</p>
                    </div>

                    <div>
                        <label class="block text-xs font-black text-slate-700 uppercase tracking-wider mb-2">
                            Đơn vị tính <span class="text-rose-500">*</span>
                        </label>
                        <select name="unit" required class="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer">
                            <option value="kg" ${variant.unit == 'kg' ? 'selected' : ''}>kg (Kilogram)</option>
                            <option value="hộp" ${variant.unit == 'hộp' ? 'selected' : ''}>hộp</option>
                            <option value="túi" ${variant.unit == 'túi' ? 'selected' : ''}>túi</option>
                            <option value="thùng" ${variant.unit == 'thùng' ? 'selected' : ''}>thùng</option>
                            <option value="quả" ${variant.unit == 'quả' ? 'selected' : ''}>quả</option>
                            <option value="giỏ" ${variant.unit == 'giỏ' ? 'selected' : ''}>giỏ</option>
                            <option value="nải" ${variant.unit == 'nải' ? 'selected' : ''}>nải</option>
                        </select>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div>
                        <label class="block text-xs font-black text-slate-700 uppercase tracking-wider mb-2">
                            Mã SKU quản lý kho
                        </label>
                        <div class="relative">
                            <i class="fa-solid fa-barcode absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                            <input type="text" name="sku" value="${variant.sku}" placeholder="Mã SKU định danh" class="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono font-bold uppercase focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-black text-slate-700 uppercase tracking-wider mb-2">
                            Ngưỡng cảnh báo tồn kho
                        </label>
                        <input type="number" name="lowStockThreshold" value="${not empty variant.lowStockThreshold ? variant.lowStockThreshold : 10}" min="1" class="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                        <p class="text-[11px] text-slate-400 mt-1">Cảnh báo khi tồn kho chạm ngưỡng này.</p>
                    </div>
                </div>

                <hr class="border-slate-100">

                <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
                    <div>
                        <label class="block text-xs font-black text-slate-700 uppercase tracking-wider mb-2">
                            Giá bán thực tế (VNĐ) <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <input type="number" name="price" value="${variant.price}" required min="0" step="500" placeholder="0" class="w-full pl-4 pr-8 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-black text-emerald-800 focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                            <span class="absolute right-3 top-1/2 -translate-y-1/2 font-bold text-xs text-slate-400">₫</span>
                        </div>
                        <p class="text-[11px] text-slate-400 mt-1">Giá thực tế khách hàng trả.</p>
                    </div>

                    <div>
                        <label class="block text-xs font-black text-slate-700 uppercase tracking-wider mb-2">
                            Giá gốc / Giá niêm yết
                        </label>
                        <div class="relative">
                            <input type="number" name="originalPrice" value="${variant.originalPrice}" min="0" step="500" placeholder="Để trống nếu không giảm" class="w-full pl-4 pr-8 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-500 focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                            <span class="absolute right-3 top-1/2 -translate-y-1/2 font-bold text-xs text-slate-400">₫</span>
                        </div>
                        <p class="text-[11px] text-slate-400 mt-1">Hiển thị gạch ngang nếu lớn hơn giá bán.</p>
                    </div>

                    <div>
                        <label class="block text-xs font-black text-slate-700 uppercase tracking-wider mb-2">
                            Số lượng tồn kho <span class="text-rose-500">*</span>
                        </label>
                        <input type="number" name="stockQuantity" value="${variant.stockQuantity}" required min="0" class="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-extrabold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                        <p class="text-[11px] text-slate-400 mt-1">Số lượng hiện có trong kho.</p>
                    </div>
                </div>

                <div class="p-4 bg-slate-50 rounded-xl border border-slate-200/80 flex items-center justify-between">
                    <div>
                        <span class="text-xs font-black text-slate-800 block">Trạng thái kinh doanh</span>
                        <span class="text-[11px] text-slate-500 font-medium">Bật để khách hàng có thể đặt mua phân loại này.</span>
                    </div>
                    <label class="relative inline-flex items-center cursor-pointer">
                        <input type="checkbox" name="isActive" value="true" ${variant.isActive ? 'checked' : ''} class="sr-only peer">
                        <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-600"></div>
                    </label>
                </div>

            </div>

            <footer class="p-6 bg-slate-50 border-t border-slate-100 flex items-center justify-end gap-3">
                <a href="${pageContext.request.contextPath}/shop/product/variants?productId=${variant.productId}" class="px-5 py-2.5 rounded-xl border border-slate-200 font-bold text-xs text-slate-600 hover:bg-slate-100 transition-all">
                    Hủy bỏ
                </a>
                <button type="submit" class="px-6 py-2.5 bg-emerald-700 hover:bg-emerald-800 text-white font-black text-xs rounded-xl shadow-sm shadow-emerald-700/20 flex items-center gap-2 transition-all">
                    <i class="fa-solid fa-floppy-disk text-xs"></i>
                    <span>Cập nhật biến thể</span>
                </button>
            </footer>

        </form>

    </main>

</body>
</html>
