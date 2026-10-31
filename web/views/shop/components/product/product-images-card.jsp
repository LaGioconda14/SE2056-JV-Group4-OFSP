<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="form-section-card">
    <div class="form-section-header">
        <div class="flex items-center gap-3">
            <div class="section-icon-box bg-purple-50 text-purple-700">
                <i class="fa-solid fa-camera"></i>
            </div>
            <div>
                <h2 class="text-sm font-bold text-slate-900 leading-tight">Hình ảnh sản phẩm</h2>
                <p class="text-xs text-slate-400 mt-0.5">Ảnh bìa và các góc chụp chi tiết thực tế</p>
            </div>
        </div>
        <span class="section-badge-pill required">5 ẢNH</span>
    </div>

    <div class="space-y-4">
        <div>
            <label class="form-label">
                <span>Ảnh bìa chính (Cover) <span class="req">*</span></span>
            </label>

            <div class="image-cover-box group">
                <img id="previewCoverImg" src="${not empty product.image ? product.image : 'https://images.unsplash.com/photo-1543528176-61b239494933?w=800'}" alt="Ảnh bìa">
                <div class="image-cover-overlay opacity-90 group-hover:opacity-100 transition">
                    <div class="w-10 h-10 rounded-full bg-white/30 backdrop-blur flex items-center justify-center text-white mb-2">
                        <i class="fa-solid fa-cloud-arrow-up text-lg"></i>
                    </div>
                    <p class="text-xs font-bold leading-tight">Kéo thả ảnh bìa hoặc dán liên kết CDN</p>
                    <p class="text-[10px] text-slate-200 mt-1">Khuyến dùng ảnh vuông 1000 x 1000px</p>
                </div>
            </div>

            <div class="mt-2.5">
                <label class="text-[11px] font-semibold text-slate-600 block mb-1">Liên kết CDN Ảnh bìa</label>
                <input type="text" name="coverImage" id="inputCoverUrl"
                       value="${not empty product.image ? product.image : 'https://images.unsplash.com/photo-1543528176-61b239494933?w=800'}"
                       onchange="document.getElementById('previewCoverImg').src = this.value"
                       placeholder="https://images.unsplash.com/..."
                       class="form-input text-xs font-mono text-slate-600">
            </div>
        </div>

        <div>
            <label class="form-label">
                <span>4 Ảnh chi tiết góc chụp bổ sung</span>
            </label>
            <div class="grid grid-cols-4 gap-2 mt-1.5">
                <c:set var="img1" value="${not empty product.galleryImages && product.galleryImages.size() > 0 ? product.galleryImages[0] : 'https://images.unsplash.com/photo-1588615419957-6627063d81b4?w=400'}"/>
                <div class="detail-thumb-slot group" onclick="promptImage(1)">
                    <img id="thumb1" src="${img1}" alt="Cuống">
                    <div class="detail-thumb-label">Cuống</div>
                    <input type="hidden" name="imgDetail1" id="inputImgDetail1" value="${img1}">
                </div>

                <c:set var="img2" value="${not empty product.galleryImages && product.galleryImages.size() > 1 ? product.galleryImages[1] : 'https://images.unsplash.com/photo-1518635017498-87f514b751ba?w=400'}"/>
                <div class="detail-thumb-slot group" onclick="promptImage(2)">
                    <img id="thumb2" src="${img2}" alt="Cắt lát">
                    <div class="detail-thumb-label">Cắt lát</div>
                    <input type="hidden" name="imgDetail2" id="inputImgDetail2" value="${img2}">
                </div>

                <c:set var="img3" value="${not empty product.galleryImages && product.galleryImages.size() > 2 ? product.galleryImages[2] : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400'}"/>
                <div class="detail-thumb-slot group" onclick="promptImage(3)">
                    <img id="thumb3" src="${img3}" alt="Tem QR">
                    <div class="detail-thumb-label">Tem QR</div>
                    <input type="hidden" name="imgDetail3" id="inputImgDetail3" value="${img3}">
                </div>

                <c:set var="img4" value="${not empty product.galleryImages && product.galleryImages.size() > 3 ? product.galleryImages[3] : 'https://images.unsplash.com/photo-1596704017254-9b121068fb31?w=400'}"/>
                <div class="detail-thumb-slot group" onclick="promptImage(4)">
                    <img id="thumb4" src="${img4}" alt="1 Hộp">
                    <div class="detail-thumb-label">1 Hộp</div>
                    <input type="hidden" name="imgDetail4" id="inputImgDetail4" value="${img4}">
                </div>
            </div>
            <p class="text-[10px] text-slate-400 mt-2 italic text-center">Bấm vào từng ảnh ô vuông để đổi liên kết ảnh chi tiết</p>
        </div>
    </div>
</div>

