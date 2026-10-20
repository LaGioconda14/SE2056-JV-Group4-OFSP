<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chỉnh Sửa Nông Sản - Kênh Người Bán</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-[#f1f5f9] text-slate-800 font-['Plus_Jakarta_Sans',sans-serif] min-h-screen flex m-0">

        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="activeMenu" value="products" />
        </jsp:include>

        <div class="flex-1 min-w-0 flex flex-col">

            <jsp:include page="/views/shop/layout/header.jsp" />

            <main class="p-6 flex-1 overflow-y-auto">
                <div class="max-w-7xl mx-auto space-y-6">

                    <c:if test="${not empty errorMessage}">
                        <div class="bg-rose-50 border border-rose-300 text-rose-900 px-4 py-3 rounded-2xl flex items-center justify-between shadow-xs">
                            <div class="flex items-center gap-3">
                                <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                                <span class="text-xs font-bold">${errorMessage}</span>
                            </div>
                            <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-900">
                                <i class="fa-solid fa-xmark text-sm"></i>
                            </button>
                        </div>
                    </c:if>

                    <div class="flex flex-col gap-3">
                        <nav class="flex items-center gap-2 text-xs text-slate-400 font-semibold">
                            <span>Kênh Người Bán</span>
                            <i class="fa-solid fa-chevron-right text-[9px] text-slate-300"></i>
                            <span>Sản phẩm & Kho</span>
                            <i class="fa-solid fa-chevron-right text-[9px] text-slate-300"></i>
                            <span class="text-slate-800 font-bold">Sửa thông tin nông sản</span>
                        </nav>

                        <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4">
                            <div>
                                <h1 class="text-2xl font-black text-slate-900 tracking-tight">Chỉnh Sửa Thông Tin Nông Sản</h1>
                                <p class="text-xs text-slate-500 font-medium mt-1">
                                    Cập nhật giá bán, tồn kho, quy cách và trạng thái mở bán nông sản.
                                </p>
                            </div>

                            <div>
                                <a href="${pageContext.request.contextPath}/shop/products" class="px-4 py-2 bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 rounded-xl text-xs font-bold flex items-center gap-2 shadow-2xs transition-all">
                                    <i class="fa-solid fa-arrow-left"></i>
                                    <span>Quay lại danh sách</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/shop/product/edit" method="POST" class="bg-white p-8 rounded-2xl border border-slate-200 shadow-2xs space-y-8">
                        
                        <input type="hidden" name="variantId" value="${product.variantId}">

                        <div class="space-y-4">
                            <div class="flex items-center gap-2 pb-2 border-b border-slate-100">
                                <span class="w-6 h-6 rounded-lg bg-emerald-100 text-emerald-800 text-xs font-black flex items-center justify-center">1</span>
                                <h3 class="text-sm font-black text-slate-900 uppercase tracking-wider">Thông tin chung nông sản</h3>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Tên nông sản <span class="text-rose-500">*</span></label>
                                    <input type="text" name="name" value="${product.productName}" required placeholder="Ví dụ: Dâu Tây Hana Đà Lạt Loại A1" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Danh mục quả <span class="text-rose-500">*</span></label>
                                    <select name="categoryId" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer">
                                        <option value="">-- Chọn danh mục quả --</option>
                                        <c:forEach var="c" items="${categories}">
                                            <option value="${c.categoryId}" ${product.categoryId == c.categoryId ? 'selected' : ''}>${c.categoryName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Xuất xứ / Vùng trồng</label>
                                    <input type="text" name="origin" value="${product.origin}" placeholder="Ví dụ: Nông trại Đà Lạt, Lâm Đồng" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Chứng nhận chất lượng</label>
                                    <select name="certification" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer">
                                        <option value="">-- Chọn chứng nhận --</option>
                                        <c:forEach var="cert" items="${certifications}">
                                            <option value="${cert}" ${product.certification == cert ? 'selected' : ''}>${cert}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-slate-700 mb-1.5">Bảo quản & Nhiệt độ</label>
                                <div class="relative">
                                    <input type="text" name="storageTemp" value="${product.storageTemp}" list="storageTempList" placeholder="Chọn hoặc tự gõ nhiệt độ bảo quản (VD: 2 - 4°C)..." 
                                           class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">

                                    <datalist id="storageTempList">
                                        <c:forEach var="temp" items="${storageTemps}">
                                            <option value="${temp}">
                                        </c:forEach>
                                        <option value="2 - 4°C (Kho lạnh chuyên dụng)">
                                        <option value="Nhiệt độ phòng (khô ráo)">
                                        <option value="12 - 15°C (Mát)">
                                        <option value="5 - 8°C">
                                    </datalist>
                                </div>
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-slate-700 mb-1.5">Mô tả chi tiết</label>
                                <textarea name="description" rows="3" placeholder="Đặc điểm hương vị, độ tươi, cách thưởng thức..." class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">${product.description}</textarea>
                            </div>
                        </div>

                        <div class="space-y-4 pt-4">
                            <div class="flex items-center gap-2 pb-2 border-b border-slate-100">
                                <span class="w-6 h-6 rounded-lg bg-emerald-100 text-emerald-800 text-xs font-black flex items-center justify-center">2</span>
                                <h3 class="text-sm font-black text-slate-900 uppercase tracking-wider">Quy cách đóng gói & Giá bán (SKU)</h3>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Mã SKU</label>
                                    <input type="text" name="sku" value="${product.sku}" placeholder="Tự sinh nếu để trống" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Tên phiên bản / Quy cách</label>
                                    <input type="text" name="variantName" value="${product.variantName}" placeholder="Ví dụ: Hộp 500g (Loại 1)" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Đơn vị tính <span class="text-rose-500">*</span></label>
                                    <select name="unit" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer">
                                        <option value="">-- Chọn đơn vị tính --</option>
                                        <c:forEach var="u" items="${units}">
                                            <option value="${u}" ${product.unit == u ? 'selected' : ''}>${u}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Giá bán lẻ (VNĐ) <span class="text-rose-500">*</span></label>
                                    <input type="number" name="price" value="${product.price}" required placeholder="160000" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Giá gốc niêm yết (VNĐ)</label>
                                    <input type="number" name="originalPrice" value="${product.originalPrice}" placeholder="180000" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Số lượng tồn kho thực tế <span class="text-rose-500">*</span></label>
                                    <input type="number" name="stockQuantity" value="${product.stockQuantity}" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                                </div>
                            </div>
                        </div>

                        <div class="space-y-4 pt-4">
                            <div class="flex items-center justify-between pb-2 border-b border-slate-100">
                                <div class="flex items-center gap-2">
                                    <span class="w-6 h-6 rounded-lg bg-emerald-100 text-emerald-800 text-xs font-black flex items-center justify-center">3</span>
                                    <h3 class="text-sm font-black text-slate-900 uppercase tracking-wider">Hình ảnh nông sản (Tối đa 5 ảnh)</h3>
                                </div>
                                <span class="text-xs text-slate-400 font-semibold">Ô 1 là Ảnh chính diện | Hỗ trợ kéo thả hoặc dán URL</span>
                            </div>

                            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">

                                <div class="space-y-1.5">
                                    <label class="block text-[11px] font-black text-emerald-700 uppercase tracking-wider">
                                        Ảnh chính diện <span class="text-rose-500">*</span>
                                    </label>
                                    <div id="drop-zone-0" onclick="triggerInput(0)" ondragover="handleDragOver(event, 0)" ondragleave="handleDragLeave(0)" ondrop="handleDrop(event, 0)"
                                         class="relative h-36 rounded-2xl border-2 border-dashed border-emerald-400 bg-emerald-100/60 hover:bg-emerald-200/60 transition-all cursor-pointer flex flex-col items-center justify-center p-2 text-center group overflow-hidden shadow-xs">
                                        
                                        <img id="placeholder-0" src="https://images.unsplash.com/photo-1543528176-61b239494933?w=300&auto=format&fit=crop&q=80" alt="Placeholder" 
                                             class="absolute inset-0 w-full h-full object-cover opacity-30 group-hover:opacity-40 transition-opacity pointer-events-none ${not empty product.image ? 'hidden' : ''}">

                                        <img id="preview-0" src="${product.image}" alt="Preview 0" class="absolute inset-0 w-full h-full object-cover rounded-xl ${empty product.image ? 'hidden' : ''} z-10">

                                        <div id="ui-content-0" class="relative z-20 flex flex-col items-center gap-1 ${not empty product.image ? 'opacity-0' : ''}">
                                            <div class="w-8 h-8 rounded-full bg-emerald-600 text-white flex items-center justify-center text-xs shadow-sm group-hover:scale-110 transition-transform">
                                                <i class="fa-solid fa-camera"></i>
                                            </div>
                                            <span class="text-[11px] font-extrabold text-emerald-900">Ảnh chính diện</span>
                                            <span class="text-[9px] text-emerald-700 font-bold">Kéo thả / Dán URL</span>
                                        </div>

                                        <input type="text" id="input-url-0" name="coverImageUrl" value="${product.image}" placeholder="Nhập URL..." onclick="event.stopPropagation()" onchange="previewFromInput(0)"
                                               class="absolute bottom-1 left-1 right-1 px-2 py-1 bg-white/95 backdrop-blur-xs border border-emerald-300 rounded-lg text-[10px] font-semibold focus:outline-none focus:border-emerald-600 text-center shadow-xs z-30">
                                    </div>
                                </div>

                                <div class="space-y-1.5">
                                    <label class="block text-[11px] font-black text-sky-700 uppercase tracking-wider">Góc nghiêng</label>
                                    <div id="drop-zone-1" onclick="triggerInput(1)" ondragover="handleDragOver(event, 1)" ondragleave="handleDragLeave(1)" ondrop="handleDrop(event, 1)"
                                         class="relative h-36 rounded-2xl border-2 border-dashed border-sky-400 bg-sky-100/60 hover:bg-sky-200/60 transition-all cursor-pointer flex flex-col items-center justify-center p-2 text-center group overflow-hidden shadow-xs">
                                        
                                        <img id="placeholder-1" src="https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&auto=format&fit=crop&q=80" alt="Placeholder" 
                                             class="absolute inset-0 w-full h-full object-cover opacity-30 group-hover:opacity-40 transition-opacity pointer-events-none">
                                        <img id="preview-1" src="" alt="Preview 1" class="absolute inset-0 w-full h-full object-cover rounded-xl hidden z-10">

                                        <div id="ui-content-1" class="relative z-20 flex flex-col items-center gap-1">
                                            <div class="w-8 h-8 rounded-full bg-sky-600 text-white flex items-center justify-center text-xs shadow-sm group-hover:scale-110 transition-transform">
                                                <i class="fa-solid fa-arrows-split-up-and-left"></i>
                                            </div>
                                            <span class="text-[11px] font-extrabold text-sky-900">Góc nghiêng</span>
                                            <span class="text-[9px] text-sky-700 font-bold">Thêm ảnh phụ</span>
                                        </div>
                                        <input type="text" id="input-url-1" name="detailImage1" placeholder="Nhập URL..." onclick="event.stopPropagation()" onchange="previewFromInput(1)"
                                               class="absolute bottom-1 left-1 right-1 px-2 py-1 bg-white/95 backdrop-blur-xs border border-sky-300 rounded-lg text-[10px] font-semibold focus:outline-none focus:border-sky-600 text-center shadow-xs z-30">
                                    </div>
                                </div>

                                <div class="space-y-1.5">
                                    <label class="block text-[11px] font-black text-amber-700 uppercase tracking-wider">Góc cận cảnh</label>
                                    <div id="drop-zone-2" onclick="triggerInput(2)" ondragover="handleDragOver(event, 2)" ondragleave="handleDragLeave(2)" ondrop="handleDrop(event, 2)"
                                         class="relative h-36 rounded-2xl border-2 border-dashed border-amber-400 bg-amber-100/60 hover:bg-amber-200/60 transition-all cursor-pointer flex flex-col items-center justify-center p-2 text-center group overflow-hidden shadow-xs">
                                        
                                        <img id="placeholder-2" src="https://images.unsplash.com/photo-1595855759920-86582396756a?w=300&auto=format&fit=crop&q=80" alt="Placeholder" 
                                             class="absolute inset-0 w-full h-full object-cover opacity-30 group-hover:opacity-40 transition-opacity pointer-events-none">
                                        <img id="preview-2" src="" alt="Preview 2" class="absolute inset-0 w-full h-full object-cover rounded-xl hidden z-10">

                                        <div id="ui-content-2" class="relative z-20 flex flex-col items-center gap-1">
                                            <div class="w-8 h-8 rounded-full bg-amber-600 text-white flex items-center justify-center text-xs shadow-sm group-hover:scale-110 transition-transform">
                                                <i class="fa-solid fa-magnifying-glass"></i>
                                            </div>
                                            <span class="text-[11px] font-extrabold text-amber-900">Góc cận cảnh</span>
                                            <span class="text-[9px] text-amber-700 font-bold">Thêm ảnh phụ</span>
                                        </div>
                                        <input type="text" id="input-url-2" name="detailImage2" placeholder="Nhập URL..." onclick="event.stopPropagation()" onchange="previewFromInput(2)"
                                               class="absolute bottom-1 left-1 right-1 px-2 py-1 bg-white/95 backdrop-blur-xs border border-amber-300 rounded-lg text-[10px] font-semibold focus:outline-none focus:border-amber-600 text-center shadow-xs z-30">
                                    </div>
                                </div>

                                <div class="space-y-1.5">
                                    <label class="block text-[11px] font-black text-purple-700 uppercase tracking-wider">Góc chi tiết</label>
                                    <div id="drop-zone-3" onclick="triggerInput(3)" ondragover="handleDragOver(event, 3)" ondragleave="handleDragLeave(3)" ondrop="handleDrop(event, 3)"
                                         class="relative h-36 rounded-2xl border-2 border-dashed border-purple-400 bg-purple-100/60 hover:bg-purple-200/60 transition-all cursor-pointer flex flex-col items-center justify-center p-2 text-center group overflow-hidden shadow-xs">
                                        
                                        <img id="placeholder-3" src="https://images.unsplash.com/photo-1528825871115-3581a5387919?w=300&auto=format&fit=crop&q=80" alt="Placeholder" 
                                             class="absolute inset-0 w-full h-full object-cover opacity-30 group-hover:opacity-40 transition-opacity pointer-events-none">
                                        <img id="preview-3" src="" alt="Preview 3" class="absolute inset-0 w-full h-full object-cover rounded-xl hidden z-10">

                                        <div id="ui-content-3" class="relative z-20 flex flex-col items-center gap-1">
                                            <div class="w-8 h-8 rounded-full bg-purple-600 text-white flex items-center justify-center text-xs shadow-sm group-hover:scale-110 transition-transform">
                                                <i class="fa-solid fa-list-check"></i>
                                            </div>
                                            <span class="text-[11px] font-extrabold text-purple-900">Góc chi tiết</span>
                                            <span class="text-[9px] text-purple-700 font-bold">Thêm ảnh phụ</span>
                                        </div>
                                        <input type="text" id="input-url-3" name="detailImage3" placeholder="Nhập URL..." onclick="event.stopPropagation()" onchange="previewFromInput(3)"
                                               class="absolute bottom-1 left-1 right-1 px-2 py-1 bg-white/95 backdrop-blur-xs border border-purple-300 rounded-lg text-[10px] font-semibold focus:outline-none focus:border-purple-600 text-center shadow-xs z-30">
                                    </div>
                                </div>

                                <div class="space-y-1.5">
                                    <label class="block text-[11px] font-black text-rose-700 uppercase tracking-wider">Góc toàn cảnh</label>
                                    <div id="drop-zone-4" onclick="triggerInput(4)" ondragover="handleDragOver(event, 4)" ondragleave="handleDragLeave(4)" ondrop="handleDrop(event, 4)"
                                         class="relative h-36 rounded-2xl border-2 border-dashed border-rose-400 bg-rose-100/60 hover:bg-rose-200/60 transition-all cursor-pointer flex flex-col items-center justify-center p-2 text-center group overflow-hidden shadow-xs">
                                        
                                        <img id="placeholder-4" src="https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=300&auto=format&fit=crop&q=80" alt="Placeholder" 
                                             class="absolute inset-0 w-full h-full object-cover opacity-30 group-hover:opacity-40 transition-opacity pointer-events-none">
                                        <img id="preview-4" src="" alt="Preview 4" class="absolute inset-0 w-full h-full object-cover rounded-xl hidden z-10">

                                        <div id="ui-content-4" class="relative z-20 flex flex-col items-center gap-1">
                                            <div class="w-8 h-8 rounded-full bg-rose-600 text-white flex items-center justify-center text-xs shadow-sm group-hover:scale-110 transition-transform">
                                                <i class="fa-solid fa-mountain-sun"></i>
                                            </div>
                                            <span class="text-[11px] font-extrabold text-rose-900">Góc toàn cảnh</span>
                                            <span class="text-[9px] text-rose-700 font-bold">Thêm ảnh phụ</span>
                                        </div>
                                        <input type="text" id="input-url-4" name="detailImage4" placeholder="Nhập URL..." onclick="event.stopPropagation()" onchange="previewFromInput(4)"
                                               class="absolute bottom-1 left-1 right-1 px-2 py-1 bg-white/95 backdrop-blur-xs border border-rose-300 rounded-lg text-[10px] font-semibold focus:outline-none focus:border-rose-600 text-center shadow-xs z-30">
                                    </div>
                                </div>

                            </div>

                            <div class="flex items-center gap-2.5 pt-2">
                                <input type="checkbox" name="isActive" id="isActive" value="true" ${product.active ? 'checked' : ''} class="w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 cursor-pointer">
                                <label for="isActive" class="text-xs font-bold text-slate-700 cursor-pointer">Sửa thông tin nông sản ngay lập tức trên sàn</label>
                            </div>
                        </div>

                        <script>
                            function triggerInput(index) {
                                document.getElementById('input-url-' + index).focus();
                            }
                            function previewFromInput(index) {
                                const urlInput = document.getElementById('input-url-' + index);
                                const previewImg = document.getElementById('preview-' + index);
                                const uiContent = document.getElementById('ui-content-' + index);
                                const placeholderImg = document.getElementById('placeholder-' + index);

                                if (urlInput.value && urlInput.value.trim() !== '') {
                                    previewImg.src = urlInput.value.trim();
                                    previewImg.classList.remove('hidden');
                                    uiContent.classList.add('opacity-0');
                                    if (placeholderImg) placeholderImg.classList.add('hidden');
                                } else {
                                    previewImg.src = '';
                                    previewImg.classList.add('hidden');
                                    uiContent.classList.remove('opacity-0');
                                    if (placeholderImg) placeholderImg.classList.remove('hidden');
                                }
                            }
                        </script>

                        <div class="pt-6 border-t border-slate-200 flex items-center justify-end gap-3">
                            <a href="${pageContext.request.contextPath}/shop/products" class="px-6 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition-all">
                                Hủy bỏ
                            </a>
                            <button type="submit" class="px-6 py-2.5 bg-emerald-700 hover:bg-emerald-800 text-white rounded-xl text-xs font-bold shadow-sm transition-all flex items-center gap-2">
                                <i class="fa-solid fa-cloud-arrow-up text-sm"></i>
                                <span>Lưu Thay Đổi</span>
                            </button>
                        </div>
                    </form>

                </div>
            </main>
        </div>

    </body>
</html>