<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký Shop - FreshFruit</title>
    <!-- Giống Trang chủ: Tailwind + Font Awesome + Inter + home.css -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/home.css">
    <link rel="stylesheet" href="${ctx}/assets/css/register-shop.css">
    <script src="${ctx}/assets/js/home.js" defer></script>
    <script src="${ctx}/assets/js/register-shop.js" defer></script>
</head>
<body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

    <%-- Header + menu giống hệt Trang chủ --%>
    <jsp:include page="/views/common/site-header.jsp" />

    <main class="max-w-5xl mx-auto px-4 py-6 sm:py-8" id="rsTop">

        <!-- Breadcrumb: Trang chủ > Đăng ký shop -->
        <nav class="rs-breadcrumb mb-6" aria-label="Breadcrumb">
            <a href="${ctx}/home"><i class="fa-solid fa-house text-xs"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right sep"></i>
            <span class="current">Đăng ký shop</span>
        </nav>

        <!-- Tiêu đề -->
        <div class="text-center mb-8">
            <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-100 text-xs font-bold mb-3">
                <i class="fa-solid fa-store"></i> Kênh Người Bán FreshFruit
            </div>
            <h1 class="text-2xl sm:text-3xl font-extrabold text-gray-900 tracking-tight">
                Đăng Ký Trở Thành <span class="text-emerald-600">Shop Owner</span>
            </h1>
            <p class="text-sm text-gray-500 mt-2 max-w-xl mx-auto">
                Hoàn thành 5 bước đơn giản để mở gian hàng bán hoa quả tươi sạch trên hệ thống.
            </p>
        </div>

        <!-- Stepper -->
        <div class="rs-stepper">
            <div class="rs-stepper-progress" id="stepperProgress"></div>
            <div class="rs-step active" id="step-indicator-1"><div class="rs-step-counter">1</div><div class="rs-step-name">Người bán</div></div>
            <div class="rs-step" id="step-indicator-2"><div class="rs-step-counter">2</div><div class="rs-step-name">Cửa hàng</div></div>
            <div class="rs-step" id="step-indicator-3"><div class="rs-step-counter">3</div><div class="rs-step-name">Địa chỉ</div></div>
            <div class="rs-step" id="step-indicator-4"><div class="rs-step-counter">4</div><div class="rs-step-name">Ngân hàng</div></div>
            <div class="rs-step" id="step-indicator-5"><div class="rs-step-counter">5</div><div class="rs-step-name">Xác nhận</div></div>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="rs-alert-error mb-4">
                <i class="fa-solid fa-circle-exclamation"></i> <span><c:out value="${errorMessage}"/></span>
            </div>
        </c:if>

        <!-- FORM -->
        <form action="${ctx}/register-shop" method="POST" enctype="multipart/form-data" id="multiStepForm" novalidate>
            <div class="rs-card p-6 md:p-10">

                <!-- BƯỚC 1: THÔNG TIN NGƯỜI BÁN -->
                <div class="rs-step-panel active" id="step-1">
                    <div class="rs-section-title"><span class="rs-section-num">1</span><span>Seller Information (Thông Tin Người Bán)</span></div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="rs-label">Full Name – Họ và tên <span class="text-red-500">*</span></label>
                            <input type="text" name="fullName" class="rs-input" value="<c:out value='${sessionScope.user.fullName}'/>" placeholder="Nhập họ và tên" required>
                            <p class="rs-feedback">Vui lòng nhập họ và tên.</p>
                        </div>
                        <div>
                            <label class="rs-label">Date of Birth – Ngày sinh <span class="text-red-500">*</span></label>
                            <input type="date" name="dob" class="rs-input" value="${sessionScope.user.birthDate}" required>
                            <p class="rs-feedback">Vui lòng chọn ngày sinh.</p>
                        </div>
                        <div>
                            <label class="rs-label">Phone Number – Số điện thoại <span class="text-red-500">*</span></label>
                            <input type="tel" name="phone" class="rs-input" value="<c:out value='${sessionScope.user.phone}'/>" placeholder="Nhập số điện thoại" required>
                            <p class="rs-feedback">Vui lòng nhập số điện thoại.</p>
                        </div>
                        <div>
                            <label class="rs-label">Email – Email <span class="text-red-500">*</span></label>
                            <input type="email" name="email" class="rs-input" value="<c:out value='${sessionScope.user.email}'/>" placeholder="example@domain.com" required>
                            <p class="rs-feedback">Vui lòng nhập email hợp lệ.</p>
                        </div>
                        <div>
                            <label class="rs-label">ID/CCCD Number – Số CCCD <span class="text-red-500">*</span></label>
                            <input type="text" name="idCardNumber" class="rs-input" placeholder="Nhập số CCCD (12 chữ số)" pattern="[0-9]{12}" inputmode="numeric" required>
                            <p class="rs-feedback">Số CCCD phải gồm đúng 12 chữ số.</p>
                        </div>
                        <div>
                            <label class="rs-label">Tax Identification Number (TIN) – Mã số thuế</label>
                            <input type="text" name="taxCode" class="rs-input" placeholder="Mã số thuế cá nhân / hộ kinh doanh">
                        </div>

                        <div>
                            <label class="rs-label">ID/CCCD Front Image – Ảnh CCCD mặt trước <span class="text-red-500">*</span></label>
                            <div class="rs-upload" id="box-idFrontInput" onclick="document.getElementById('idFrontInput').click()">
                                <i class="fa-regular fa-id-card"></i>
                                <p>Nhấp để tải lên ảnh CCCD mặt trước</p>
                            </div>
                            <input type="file" id="idFrontInput" name="idCardFront" accept="image/*" class="hidden" onchange="previewImage(this, 'idFrontPreview', 'box-idFrontInput', 'wrap-idFront')" required>
                            <div id="wrap-idFront" class="rs-preview hidden">
                                <img id="idFrontPreview" alt="Ảnh CCCD mặt trước">
                                <button type="button" class="rs-preview-remove" onclick="removeImage('idFrontInput', 'idFrontPreview', 'box-idFrontInput', 'wrap-idFront')" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>
                            </div>
                            <p class="rs-feedback" id="err-idFrontInput">Vui lòng tải lên ảnh CCCD mặt trước.</p>
                        </div>
                        <div>
                            <label class="rs-label">ID/CCCD Back Image – Ảnh CCCD mặt sau <span class="text-red-500">*</span></label>
                            <div class="rs-upload" id="box-idBackInput" onclick="document.getElementById('idBackInput').click()">
                                <i class="fa-regular fa-credit-card"></i>
                                <p>Nhấp để tải lên ảnh CCCD mặt sau</p>
                            </div>
                            <input type="file" id="idBackInput" name="idCardBack" accept="image/*" class="hidden" onchange="previewImage(this, 'idBackPreview', 'box-idBackInput', 'wrap-idBack')" required>
                            <div id="wrap-idBack" class="rs-preview hidden">
                                <img id="idBackPreview" alt="Ảnh CCCD mặt sau">
                                <button type="button" class="rs-preview-remove" onclick="removeImage('idBackInput', 'idBackPreview', 'box-idBackInput', 'wrap-idBack')" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>
                            </div>
                            <p class="rs-feedback" id="err-idBackInput">Vui lòng tải lên ảnh CCCD mặt sau.</p>
                        </div>
                    </div>
                    <div class="flex justify-end mt-8">
                        <button type="button" class="rs-btn-next" onclick="nextStep(1)">Tiếp theo <i class="fa-solid fa-arrow-right text-xs"></i></button>
                    </div>
                </div>

                <!-- BƯỚC 2: THÔNG TIN CỬA HÀNG -->
                <div class="rs-step-panel" id="step-2">
                    <div class="rs-section-title"><span class="rs-section-num">2</span><span>Shop Information (Thông Tin Cửa Hàng)</span></div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="rs-label">Shop Name – Tên cửa hàng <span class="text-red-500">*</span></label>
                            <input type="text" name="shopName" class="rs-input" placeholder="Ví dụ: Nông Sản Tươi Xanh" required>
                            <p class="rs-feedback">Vui lòng nhập tên cửa hàng.</p>
                        </div>
                        <div>
                            <label class="rs-label">Business Type – Mô hình kinh doanh <span class="text-red-500">*</span></label>
                            <select name="businessType" class="rs-input" required>
                                <option value="" selected disabled>-- Chọn danh mục chính --</option>
                                <option value="TRAI_CAY_NOI_DIA">Trái Cây Nội Địa</option>
                                <option value="TRAI_CAY_NHAP_KHAU">Trái Cây Nhập Khẩu</option>
                                <option value="TRAI_CAY_HUU_CO">Trái Cây Hữu Cơ (Organic)</option>
                                <option value="HOA_QUA_SAY">Hoa Quả Sấy &amp; Chế Biến</option>
                                <option value="COMBO_GIOT_HOA_QUA">Giỏ Quà Trái Cây</option>
                            </select>
                            <p class="rs-feedback">Vui lòng chọn danh mục kinh doanh.</p>
                        </div>
                        <div class="md:col-span-2">
                            <label class="rs-label">Shop Description – Mô tả cửa hàng</label>
                            <textarea name="shopDescription" class="rs-input" rows="3" placeholder="Giới thiệu ngắn gọn về gian hàng, nguồn gốc xuất xứ sản phẩm..."></textarea>
                        </div>
                        <div>
                            <label class="rs-label">Shop Logo – Logo cửa hàng <span class="text-red-500">*</span></label>
                            <div class="rs-upload" id="box-shopLogoInput" onclick="document.getElementById('shopLogoInput').click()">
                                <i class="fa-regular fa-image"></i>
                                <p>Tải lên logo cửa hàng (JPG, PNG)</p>
                            </div>
                            <input type="file" id="shopLogoInput" name="shopLogo" accept="image/*" class="hidden" onchange="previewImage(this, 'shopLogoPreview', 'box-shopLogoInput', 'wrap-shopLogo')" required>
                            <div id="wrap-shopLogo" class="rs-preview hidden">
                                <img id="shopLogoPreview" alt="Logo cửa hàng">
                                <button type="button" class="rs-preview-remove" onclick="removeImage('shopLogoInput', 'shopLogoPreview', 'box-shopLogoInput', 'wrap-shopLogo')" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>
                            </div>
                            <p class="rs-feedback" id="err-shopLogoInput">Vui lòng tải lên logo cửa hàng.</p>
                        </div>
                        <div>
                            <label class="rs-label">Shop Banner – Ảnh bìa cửa hàng <span class="text-red-500">*</span></label>
                            <div class="rs-upload" id="box-shopBannerInput" onclick="document.getElementById('shopBannerInput').click()">
                                <i class="fa-regular fa-file-image"></i>
                                <p>Tải lên ảnh bìa / banner (khuyên dùng 1200x400px)</p>
                            </div>
                            <input type="file" id="shopBannerInput" name="shopBanner" accept="image/*" class="hidden" onchange="previewImage(this, 'shopBannerPreview', 'box-shopBannerInput', 'wrap-shopBanner')" required>
                            <div id="wrap-shopBanner" class="rs-preview hidden">
                                <img id="shopBannerPreview" alt="Banner cửa hàng">
                                <button type="button" class="rs-preview-remove" onclick="removeImage('shopBannerInput', 'shopBannerPreview', 'box-shopBannerInput', 'wrap-shopBanner')" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>
                            </div>
                            <p class="rs-feedback" id="err-shopBannerInput">Vui lòng tải lên banner cửa hàng.</p>
                        </div>
                    </div>
                    <div class="flex justify-between mt-8">
                        <button type="button" class="rs-btn-back" onclick="prevStep(2)"><i class="fa-solid fa-arrow-left text-xs"></i> Quay lại</button>
                        <button type="button" class="rs-btn-next" onclick="nextStep(2)">Tiếp theo <i class="fa-solid fa-arrow-right text-xs"></i></button>
                    </div>
                </div>

                <!-- BƯỚC 3: ĐỊA CHỈ -->
                <div class="rs-step-panel" id="step-3">
                    <div class="rs-section-title"><span class="rs-section-num">3</span><span>Address Information (Thông Tin Địa Chỉ)</span></div>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div>
                            <label class="rs-label">Province/City – Tỉnh / Thành phố <span class="text-red-500">*</span></label>
                            <select name="province" class="rs-input" required>
                                <option value="" selected disabled>-- Chọn Tỉnh / Thành phố --</option>
                                <option value="Hà Nội">Hà Nội</option>
                                <option value="TP. Hồ Chí Minh">TP. Hồ Chí Minh</option>
                                <option value="Đà Nẵng">Đà Nẵng</option>
                                <option value="Cần Thơ">Cần Thơ</option>
                                <option value="Đồng Nai">Đồng Nai</option>
                                <option value="Lâm Đồng">Lâm Đồng</option>
                            </select>
                            <p class="rs-feedback">Vui lòng chọn Tỉnh / Thành phố.</p>
                        </div>
                        <div>
                            <label class="rs-label">District – Quận / Huyện <span class="text-red-500">*</span></label>
                            <input type="text" name="district" class="rs-input" placeholder="Nhập Quận / Huyện" required>
                            <p class="rs-feedback">Vui lòng nhập Quận / Huyện.</p>
                        </div>
                        <div>
                            <label class="rs-label">Ward – Phường / Xã <span class="text-red-500">*</span></label>
                            <input type="text" name="ward" class="rs-input" placeholder="Nhập Phường / Xã" required>
                            <p class="rs-feedback">Vui lòng nhập Phường / Xã.</p>
                        </div>
                        <div class="md:col-span-3">
                            <label class="rs-label">Street Address – Số nhà, tên đường <span class="text-red-500">*</span></label>
                            <input type="text" name="streetAddress" class="rs-input" placeholder="Ví dụ: 123 Đường Nguyễn Trãi" required>
                            <p class="rs-feedback">Vui lòng nhập số nhà, tên đường.</p>
                        </div>
                        <div class="md:col-span-3 grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="rs-label">Pickup Address – Địa chỉ lấy hàng <span class="text-red-500">*</span></label>
                                <input type="text" name="pickupAddress" class="rs-input" placeholder="Địa chỉ để đơn vị vận chuyển tới lấy hàng" required>
                                <p class="rs-feedback">Vui lòng nhập địa chỉ lấy hàng.</p>
                            </div>
                            <div>
                                <label class="rs-label">Return Address – Địa chỉ trả hàng <span class="text-red-500">*</span></label>
                                <input type="text" name="returnAddress" class="rs-input" placeholder="Địa chỉ nhận hàng hoàn trả (nếu có)" required>
                                <p class="rs-feedback">Vui lòng nhập địa chỉ trả hàng.</p>
                            </div>
                        </div>
                    </div>
                    <div class="flex justify-between mt-8">
                        <button type="button" class="rs-btn-back" onclick="prevStep(3)"><i class="fa-solid fa-arrow-left text-xs"></i> Quay lại</button>
                        <button type="button" class="rs-btn-next" onclick="nextStep(3)">Tiếp theo <i class="fa-solid fa-arrow-right text-xs"></i></button>
                    </div>
                </div>

                <!-- BƯỚC 4: NGÂN HÀNG -->
                <div class="rs-step-panel" id="step-4">
                    <div class="rs-section-title"><span class="rs-section-num">4</span><span>Bank Information (Thông Tin Ngân Hàng Doanh Thu)</span></div>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div>
                            <label class="rs-label">Bank Name – Tên ngân hàng <span class="text-red-500">*</span></label>
                            <select name="bankName" class="rs-input" required>
                                <option value="" selected disabled>-- Chọn ngân hàng --</option>
                                <option value="Vietcombank">Vietcombank (VCB)</option>
                                <option value="MBBank">MBBank (MB)</option>
                                <option value="Techcombank">Techcombank (TCB)</option>
                                <option value="VietinBank">VietinBank</option>
                                <option value="BIDV">BIDV</option>
                                <option value="VPBank">VPBank</option>
                                <option value="ACB">ACB</option>
                            </select>
                            <p class="rs-feedback">Vui lòng chọn ngân hàng.</p>
                        </div>
                        <div>
                            <label class="rs-label">Bank Account Number – Số tài khoản <span class="text-red-500">*</span></label>
                            <input type="text" name="bankAccountNumber" class="rs-input" placeholder="Nhập số tài khoản ngân hàng" inputmode="numeric" required>
                            <p class="rs-feedback">Vui lòng nhập số tài khoản.</p>
                        </div>
                        <div>
                            <label class="rs-label">Account Holder Name – Tên chủ tài khoản <span class="text-red-500">*</span></label>
                            <input type="text" name="bankAccountHolder" class="rs-input uppercase" placeholder="Viết hoa không dấu (VD: NGUYEN VAN A)" required>
                            <p class="rs-feedback">Vui lòng nhập tên chủ tài khoản.</p>
                        </div>
                    </div>
                    <p class="text-xs text-gray-500 mt-4"><i class="fa-solid fa-circle-info text-emerald-600"></i> Tài khoản ngân hàng nên đứng tên chính chủ Shop Owner để việc đối soát và chi trả doanh thu không bị gián đoạn.</p>
                    <div class="flex justify-between mt-8">
                        <button type="button" class="rs-btn-back" onclick="prevStep(4)"><i class="fa-solid fa-arrow-left text-xs"></i> Quay lại</button>
                        <button type="button" class="rs-btn-next" onclick="nextStep(4)">Tiếp theo <i class="fa-solid fa-arrow-right text-xs"></i></button>
                    </div>
                </div>

                <!-- BƯỚC 5: XÁC NHẬN & ĐIỀU KHOẢN -->
                <div class="rs-step-panel" id="step-5">
                    <div class="rs-section-title"><span class="rs-section-num">5</span><span>Verification &amp; Agreement (Điều Khoản &amp; Cam Kết)</span></div>

                    <div class="rs-summary">
                        <div class="rs-summary-box"><h4><i class="fa-solid fa-user"></i> Người bán</h4><p id="sum-owner">—</p></div>
                        <div class="rs-summary-box"><h4><i class="fa-solid fa-store"></i> Cửa hàng</h4><p id="sum-shop">—</p></div>
                        <div class="rs-summary-box"><h4><i class="fa-solid fa-location-dot"></i> Địa chỉ</h4><p id="sum-address">—</p></div>
                        <div class="rs-summary-box"><h4><i class="fa-solid fa-building-columns"></i> Ngân hàng</h4><p id="sum-bank">—</p></div>
                    </div>

                    <div class="rs-agree-box">
                        <label class="rs-check">
                            <input type="checkbox" value="true" id="termsCheck" name="agreeTerms" required>
                            <span>
                                Tôi đã đọc và đồng ý với
                                <button type="button" class="rs-terms-link" data-open-terms="tos">Điều khoản &amp; Điều kiện dịch vụ</button>
                                dành cho Shop Owner. <span class="text-red-500">*</span>
                            </span>
                        </label>
                        <label class="rs-check">
                            <input type="checkbox" value="true" id="policyCheck" name="agreePolicies" required>
                            <span>
                                Tôi cam kết tuân thủ
                                <button type="button" class="rs-terms-link" data-open-terms="policy">Chính sách bán hàng &amp; An toàn thực phẩm</button>
                                của nền tảng. <span class="text-red-500">*</span>
                            </span>
                        </label>
                    </div>
                    <p class="text-xs text-gray-500 mt-3"><i class="fa-solid fa-lock text-emerald-600"></i> Thông tin của bạn được bảo mật và chỉ dùng cho việc thẩm định hồ sơ, vận hành gian hàng theo quy định pháp luật về bảo vệ dữ liệu cá nhân.</p>

                    <div class="flex justify-between mt-8">
                        <button type="button" class="rs-btn-back" onclick="prevStep(5)"><i class="fa-solid fa-arrow-left text-xs"></i> Quay lại</button>
                        <button type="submit" class="rs-btn-submit" id="submitBtn"><i class="fa-solid fa-circle-check"></i> Gửi Đăng Ký</button>
                    </div>
                </div>

            </div>
        </form>
    </main>

    <%-- Footer giống Trang chủ --%>
    <jsp:include page="/views/common/site-footer.jsp" />

    <%-- 2 modal điều khoản (cuộn được) --%>
    <jsp:include page="/views/shop/terms-modals.jsp" />

</body>
</html>
