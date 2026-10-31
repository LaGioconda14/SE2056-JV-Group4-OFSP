<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="form-section-card">
    <div class="form-section-header">
        <div class="flex items-center gap-3">
            <div class="section-icon-box">
                <i class="fa-solid fa-seedling"></i>
            </div>
            <div>
                <h2 class="text-sm font-bold text-slate-900 leading-tight">Thông tin chung & Nguồn gốc xuất xứ</h2>
                <p class="text-xs text-slate-400 mt-0.5">Mã vùng trồng và định danh nông sản sạch chính hãng</p>
            </div>
        </div>
        <span class="section-badge-pill required">BẮT BUỘC</span>
    </div>

    <div class="space-y-4">
        <div>
            <div class="form-label">
                <span>Tên sản phẩm nông sản <span class="req">*</span></span>
                <span id="nameCounter" class="text-slate-400 font-normal text-xs">0/120 ký tự</span>
            </div>
            <input type="text" name="name" id="productNameInput" required maxlength="120"
                   value="${product.productName}"
                   oninput="updateNameCounter(this)"
                   class="form-input font-bold text-slate-900 text-sm">
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
                <div class="form-label">
                    <span>Mã định danh SKU <span class="req">*</span></span>
                </div>
                <input type="text" name="sku" required value="${product.sku}" class="form-input font-mono font-bold text-slate-700">
            </div>
            <div>
                <div class="form-label">
                    <span>Danh mục sản phẩm <span class="req">*</span></span>
                </div>
                <select name="categoryId" class="form-select font-medium text-slate-800">
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}" ${cat.categoryId == product.categoryId ? 'selected' : ''}>
                            ${cat.categoryName}
                        </option>
                    </c:forEach>
                    <c:if test="${empty categories}">
                        <option value="11" selected>Trái cây tươi ôn đới (Đà Lạt)</option>
                        <option value="1">Trái Cây</option>
                        <option value="4">Thực Phẩm Hữu Cơ</option>
                        <option value="6">Trái Cây Việt Nam</option>
                    </c:if>
                </select>
            </div>
        </div>

        <div>
            <div class="form-label">
                <span>Vùng trồng / Xuất xứ <span class="req">*</span></span>
            </div>
            <input type="text" name="origin" list="originList"
                   value="${not empty product.origin ? product.origin : 'Đà Lạt, Lâm Đồng'}"
                   class="form-input font-medium">
            <datalist id="originList">
                <option value="Đà Lạt, Lâm Đồng (Trại Mát Farm)">
                <option value="Mộc Châu, Sơn La">
                <option value="Tiền Giang, Đồng Bằng Sông Cửu Long">
                <option value="Bến Tre (Xứ dừa Chợ Lách)">
                <option value="Gia Lai, Tây Nguyên">
                <option value="Bắc Giang (Lục Ngạn)">
            </datalist>
        </div>

        <div>
            <label class="form-label">Điều kiện bảo quản khuyên dùng</label>
            <div class="flex flex-wrap gap-2.5 mt-1">
                <button type="button" onclick="selectStorageTag(this, 'Kho lạnh 2°C - 8°C')"
                        class="storage-tag-btn ${product.storageTemp == null || product.storageTemp.contains('2°C') ? 'active' : ''}">
                    <i class="fa-solid fa-snowflake text-xs"></i>
                    <span>Kho lạnh 2°C - 8°C</span>
                </button>
                <button type="button" onclick="selectStorageTag(this, 'Thoáng mát tự nhiên')"
                        class="storage-tag-btn ${product.storageTemp != null && product.storageTemp.contains('Thoáng mát') ? 'active' : ''}">
                    <i class="fa-solid fa-wind text-xs"></i>
                    <span>Thoáng mát tự nhiên</span>
                </button>
                <button type="button" onclick="selectStorageTag(this, 'Tránh ánh nắng trực tiếp')"
                        class="storage-tag-btn ${product.storageTemp != null && product.storageTemp.contains('Tránh ánh nắng') ? 'active' : ''}">
                    <i class="fa-solid fa-sun text-xs"></i>
                    <span>Tránh ánh nắng trực tiếp</span>
                </button>
                <button type="button" onclick="selectStorageTag(this, 'Độ ẩm tiêu chuẩn 85%')"
                        class="storage-tag-btn ${product.storageTemp != null && product.storageTemp.contains('85%') ? 'active' : ''}">
                    <i class="fa-solid fa-droplet text-xs"></i>
                    <span>Độ ẩm tiêu chuẩn 85%</span>
                </button>
            </div>
        </div>

        <div>
            <label class="form-label">Tiêu chuẩn chứng nhận chất lượng</label>
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3 mt-1.5">
                <label class="cert-checkbox-card ${product.certification != null && product.certification.contains('VietGAP') ? 'selected' : ''}" onclick="toggleCert(this)">
                    <input type="checkbox" name="certifications" value="VietGAP"
                           ${product.certification != null && product.certification.contains('VietGAP') ? 'checked' : ''}
                           class="mt-0.5 rounded text-blue-600 focus:ring-0">
                    <div>
                        <div class="text-xs font-bold text-slate-800">VietGAP</div>
                        <div class="text-[11px] text-slate-500">Chuẩn quốc gia</div>
                    </div>
                </label>
                <label class="cert-checkbox-card ${product.certification != null && product.certification.contains('GlobalGAP') ? 'selected' : ''}" onclick="toggleCert(this)">
                    <input type="checkbox" name="certifications" value="GlobalGAP"
                           ${product.certification != null && product.certification.contains('GlobalGAP') ? 'checked' : ''}
                           class="mt-0.5 rounded text-blue-600 focus:ring-0">
                    <div>
                        <div class="text-xs font-bold text-slate-800">GlobalGAP</div>
                        <div class="text-[11px] text-slate-500">Xuất khẩu</div>
                    </div>
                </label>
                <label class="cert-checkbox-card ${product.certification != null && product.certification.contains('OCOP') ? 'selected' : ''}" onclick="toggleCert(this)">
                    <input type="checkbox" name="certifications" value="OCOP 4 Sao"
                           ${product.certification != null && product.certification.contains('OCOP') ? 'checked' : ''}
                           class="mt-0.5 rounded text-blue-600 focus:ring-0">
                    <div>
                        <div class="text-xs font-bold text-slate-800">OCOP 4 Sao</div>
                        <div class="text-[11px] text-slate-500">Đặc sản địa phương</div>
                    </div>
                </label>
                <label class="cert-checkbox-card ${product.certification != null && product.certification.contains('Organic') ? 'selected' : ''}" onclick="toggleCert(this)">
                    <input type="checkbox" name="certifications" value="Organic"
                           ${product.certification != null && product.certification.contains('Organic') ? 'checked' : ''}
                           class="mt-0.5 rounded text-blue-600 focus:ring-0">
                    <div>
                        <div class="text-xs font-bold text-slate-800">Hữu cơ Organic</div>
                        <div class="text-[11px] text-slate-500">Không hóa chất</div>
                    </div>
                </label>
            </div>
        </div>

        <div>
            <div class="form-label">
                <span>Mô tả chi tiết nông sản</span>
                <a href="javascript:void(0)" onclick="autoFillDescSEO()" class="text-emerald-700 hover:text-emerald-800 font-semibold text-xs flex items-center gap-1">
                    <i class="fa-regular fa-lightbulb"></i>
                    <span>Gợi ý chuẩn SEO FreshFruit</span>
                </a>
            </div>

            <div class="border border-slate-300 rounded-lg overflow-hidden focus-within:border-emerald-600 focus-within:ring-2 focus-within:ring-emerald-500/20">
                <div class="bg-slate-50 px-3 py-2 border-b border-slate-200 flex items-center justify-between flex-wrap gap-2 text-xs text-slate-600">
                    <div class="flex items-center gap-1">
                        <button type="button" class="w-7 h-7 rounded hover:bg-slate-200 flex items-center justify-center font-bold" title="In đậm">B</button>
                        <button type="button" class="w-7 h-7 rounded hover:bg-slate-200 flex items-center justify-center italic font-serif" title="In nghiêng">I</button>
                        <button type="button" class="w-7 h-7 rounded hover:bg-slate-200 flex items-center justify-center" title="Danh sách"><i class="fa-solid fa-list-ul"></i></button>
                        <button type="button" class="w-7 h-7 rounded hover:bg-slate-200 flex items-center justify-center" title="Bảng biểu"><i class="fa-solid fa-table"></i></button>
                    </div>
                    <div class="text-[11px] text-slate-400">
                        Mô tả độ tươi giòn, lượng đường (brix), xuất xứ nông trại...
                    </div>
                </div>
                <textarea name="description" id="productDescTextarea" rows="4" class="form-textarea border-0 rounded-none focus:ring-0 p-3 text-xs leading-relaxed"
                          placeholder="Mô tả chi tiết nông sản...">${product.description}</textarea>
            </div>
        </div>
    </div>
</div>

