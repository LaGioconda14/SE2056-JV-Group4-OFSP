<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký Cửa Hàng - Online Fruit Shop</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8faf9;
            min-height: 100vh;
        }
        .navbar-fruit {
            background: linear-gradient(135deg, #2e7d32, #388e3c);
            box-shadow: 0 4px 15px rgba(46, 125, 50, 0.15);
        }
        
        /* Stepper Progress Bar Style */
        .stepper-wrapper {
            display: flex;
            justify-content: space-between;
            position: relative;
            margin-bottom: 2.5rem;
        }
        .stepper-wrapper::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 10%;
            right: 10%;
            height: 3px;
            background-color: #e0e0e0;
            z-index: 1;
        }
        .stepper-item {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            flex: 1;
            text-align: center;
        }
        .stepper-item .step-counter {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background-color: #ffffff;
            border: 2px solid #e0e0e0;
            color: #777;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.95rem;
            margin-bottom: 8px;
            transition: all 0.3s ease;
        }
        .stepper-item.active .step-counter {
            background-color: #2e7d32;
            border-color: #2e7d32;
            color: #ffffff;
            box-shadow: 0 0 0 4px rgba(46, 125, 50, 0.15);
        }
        .stepper-item.completed .step-counter {
            background-color: #1b5e20;
            border-color: #1b5e20;
            color: #ffffff;
        }
        .stepper-item .step-name {
            font-size: 0.85rem;
            font-weight: 600;
            color: #666;
        }
        .stepper-item.active .step-name {
            color: #2e7d32;
            font-weight: 700;
        }

        .form-card {
            background-color: #ffffff;
            border-radius: 1.25rem;
            border: 1px solid #e0e0e0;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        }
        .section-header {
            color: #2e7d32;
            font-weight: 700;
            font-size: 1.15rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #e8f5e9;
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .section-number {
            background-color: #2e7d32;
            color: #ffffff;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.875rem;
            font-weight: 700;
        }
        .form-label {
            font-weight: 600;
            color: #333;
            font-size: 0.9rem;
        }
        .form-control:focus, .form-select:focus {
            border-color: #43a047;
            box-shadow: 0 0 0 0.25rem rgba(67, 160, 71, 0.25);
        }
        .btn-fruit {
            background: linear-gradient(135deg, #2e7d32, #43a047);
            border: none;
            color: #ffffff;
            font-weight: 600;
            padding: 10px 25px;
            font-size: 1rem;
            border-radius: 50rem;
            transition: all 0.3s ease;
        }
        .btn-fruit:hover {
            background: linear-gradient(135deg, #1b5e20, #2e7d32);
            color: #ffffff;
            box-shadow: 0 6px 20px rgba(46, 125, 50, 0.3);
        }
        .upload-box {
            border: 2px dashed #a5d6a7;
            background-color: #f1f8e9;
            border-radius: 0.75rem;
            padding: 1.5rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .upload-box:hover {
            background-color: #e8f5e9;
            border-color: #2e7d32;
        }
        .preview-container {
            position: relative;
            display: inline-block;
            width: 100%;
        }
        .preview-img {
            max-height: 150px;
            width: 100%;
            border-radius: 0.5rem;
            object-fit: cover;
            border: 1px solid #dee2e6;
        }
        .btn-remove-img {
            position: absolute;
            top: 8px;
            right: 8px;
            background: rgba(220, 53, 69, 0.85);
            color: white;
            border: none;
            border-radius: 50%;
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-remove-img:hover {
            background: #dc3545;
        }
        
        /* Chuyển đổi giữa các bước */
        .form-step {
            display: none;
        }
        .form-step.active {
            display: block;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-fruit py-3">
    <div class="container">
        <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/home.jsp">
            <span>🍎 Online Fruit Shop</span>
        </a>
        <div class="d-flex align-items-center gap-3">
            <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-sm btn-outline-light d-flex align-items-center gap-1">
                <i class="bi bi-house"></i> Trang Chủ
            </a>
            <c:if test="${not empty sessionScope.user}">
                <span class="text-white small d-none d-md-inline">
                    Xin chào, <strong>${sessionScope.user.fullName}</strong>
                </span>
            </c:if>
        </div>
    </div>
</nav>

<!-- Container Chính -->
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            <!-- Header Banner -->
            <div class="text-center mb-4">
                <h2 class="fw-bold text-success">Đăng Ký Trở Thành Shop Owner 🏪</h2>
                <p class="text-muted">Vui lòng hoàn thành từng bước dưới đây để đăng ký gian hàng bán hoa quả tươi trên hệ thống.</p>
            </div>

            <!-- Stepper Progress Bar -->
            <div class="stepper-wrapper">
                <div class="stepper-item active" id="step-indicator-1">
                    <div class="step-counter">1</div>
                    <div class="step-name">Người bán</div>
                </div>
                <div class="stepper-item" id="step-indicator-2">
                    <div class="step-counter">2</div>
                    <div class="step-name">Cửa hàng</div>
                </div>
                <div class="stepper-item" id="step-indicator-3">
                    <div class="step-counter">3</div>
                    <div class="step-name">Địa chỉ</div>
                </div>
                <div class="stepper-item" id="step-indicator-4">
                    <div class="step-counter">4</div>
                    <div class="step-name">Ngân hàng</div>
                </div>
                <div class="stepper-item" id="step-indicator-5">
                    <div class="step-counter">5</div>
                    <div class="step-name">Xác nhận</div>
                </div>
            </div>

            <!-- Form Đăng Ký -->
            <form action="${pageContext.request.contextPath}/register-shop" method="POST" enctype="multipart/form-data" id="multiStepForm" novalidate>
                <div class="form-card p-4 p-md-5">

                    <!-- BƯỚC 1: SELLER INFORMATION -->
                    <div class="form-step active" id="step-1">
                        <div class="section-header">
                            <span class="section-number">1</span>
                            <span>Seller Information (Thông Tin Người Bán)</span>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name – Họ và tên <span class="text-danger">*</span></label>
                                <input type="text" name="fullName" class="form-control" value="${sessionScope.user.fullName}" placeholder="Nhập họ và tên" required>
                                <div class="invalid-feedback">Vui lòng nhập họ và tên.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date of Birth – Ngày sinh <span class="text-danger">*</span></label>
                                <input type="date" name="dob" class="form-control" value="${sessionScope.user.birthDate}" required>
                                <div class="invalid-feedback">Vui lòng chọn ngày sinh.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone Number – Số điện thoại <span class="text-danger">*</span></label>
                                <input type="tel" name="phone" class="form-control" value="${sessionScope.user.phone}" placeholder="Nhập số điện thoại" required>
                                <div class="invalid-feedback">Vui lòng nhập số điện thoại.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email – Email <span class="text-danger">*</span></label>
                                <input type="email" name="email" class="form-control" value="${sessionScope.user.email}" placeholder="example@domain.com" required>
                                <div class="invalid-feedback">Vui lòng nhập email hợp lệ.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ID/CCCD Number – Số CCCD <span class="text-danger">*</span></label>
                                <input type="text" name="idCardNumber" class="form-control" placeholder="Nhập số CCCD (12 chữ số)" pattern="[0-9]{12}" required>
                                <div class="invalid-feedback">Số CCCD phải gồm đúng 12 chữ số.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Tax Identification Number (TIN) – Mã số thuế</label>
                                <input type="text" name="taxCode" class="form-control" placeholder="Mã số thuế cá nhân / hộ kinh doanh">
                            </div>

                            <!-- ID Front Image -->
                            <div class="col-md-6">
                                <label class="form-label">ID/CCCD Front Image – Ảnh CCCD mặt trước <span class="text-danger">*</span></label>
                                <div class="upload-box" id="box-idFrontInput" onclick="document.getElementById('idFrontInput').click()">
                                    <i class="bi bi-card-heading text-success fs-2"></i>
                                    <p class="small text-muted mb-0 mt-2">Nhấp để tải lên ảnh CCCD mặt trước</p>
                                </div>
                                <input type="file" id="idFrontInput" name="idCardFront" accept="image/*" class="d-none" onchange="previewImage(this, 'idFrontPreview', 'box-idFrontInput', 'wrap-idFront')" required>
                                <div id="wrap-idFront" class="preview-container d-none mt-2">
                                    <img id="idFrontPreview" class="preview-img" alt="Front Preview">
                                    <button type="button" class="btn-remove-img" onclick="removeImage('idFrontInput', 'idFrontPreview', 'box-idFrontInput', 'wrap-idFront')" title="Xóa ảnh">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>
                                <div class="invalid-feedback d-block d-none" id="err-idFrontInput">Vui lòng tải lên ảnh CCCD mặt trước.</div>
                            </div>

                            <!-- ID Back Image -->
                            <div class="col-md-6">
                                <label class="form-label">ID/CCCD Back Image – Ảnh CCCD mặt sau <span class="text-danger">*</span></label>
                                <div class="upload-box" id="box-idBackInput" onclick="document.getElementById('idBackInput').click()">
                                    <i class="bi bi-credit-card-2-back text-success fs-2"></i>
                                    <p class="small text-muted mb-0 mt-2">Nhấp để tải lên ảnh CCCD mặt sau</p>
                                </div>
                                <input type="file" id="idBackInput" name="idCardBack" accept="image/*" class="d-none" onchange="previewImage(this, 'idBackPreview', 'box-idBackInput', 'wrap-idBack')" required>
                                <div id="wrap-idBack" class="preview-container d-none mt-2">
                                    <img id="idBackPreview" class="preview-img" alt="Back Preview">
                                    <button type="button" class="btn-remove-img" onclick="removeImage('idBackInput', 'idBackPreview', 'box-idBackInput', 'wrap-idBack')" title="Xóa ảnh">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>
                                <div class="invalid-feedback d-block d-none" id="err-idBackInput">Vui lòng tải lên ảnh CCCD mặt sau.</div>
                            </div>
                        </div>
                        <div class="d-flex justify-content-end mt-4">
                            <button type="button" class="btn btn-fruit" onclick="nextStep(1)">Tiếp theo <i class="bi bi-arrow-right ms-1"></i></button>
                        </div>
                    </div>

                    <!-- BƯỚC 2: SHOP INFORMATION -->
                    <div class="form-step" id="step-2">
                        <div class="section-header">
                            <span class="section-number">2</span>
                            <span>Shop Information (Thông Tin Cửa Hàng)</span>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Shop Name – Tên cửa hàng <span class="text-danger">*</span></label>
                                <input type="text" name="shopName" class="form-control" placeholder="Ví dụ: Nông Sản Tươi Xanh" required>
                                <div class="invalid-feedback">Vui lòng nhập tên cửa hàng.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Business Type – Mô hình kinh doanh <span class="text-danger">*</span></label>
                                <select name="businessType" class="form-select" required>
                                    <option value="" selected disabled>-- Chọn danh mục chính --</option>
                                    <option value="TRAI_CAY_NOI_DIA">Trái Cây Nội Địa</option>
                                    <option value="TRAI_CAY_NHAP_KHAU">Trái Cây Nhập Khẩu</option>
                                    <option value="TRAI_CAY_HUU_CO">Trái Cây Hữu Cơ (Organic)</option>
                                    <option value="HOA_QUA_SAY">Hoa Quả Sấy & Chế Biến</option>
                                    <option value="COMBO_GIOT_HOA_QUA">Giỏ Quà Trái Cây</option>
                                </select>
                                <div class="invalid-feedback">Vui lòng chọn danh mục kinh doanh.</div>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Shop Description – Mô tả cửa hàng</label>
                                <textarea name="shopDescription" class="form-control" rows="3" placeholder="Giới thiệu ngắn gọn về gian hàng, nguồn gốc xuất xứ sản phẩm..."></textarea>
                            </div>
                            
                            <!-- Shop Logo -->
                            <div class="col-md-6">
                                <label class="form-label">Shop Logo – Logo cửa hàng <span class="text-danger">*</span></label>
                                <div class="upload-box" id="box-shopLogoInput" onclick="document.getElementById('shopLogoInput').click()">
                                    <i class="bi bi-image text-success fs-2"></i>
                                    <p class="small text-muted mb-0 mt-2">Tải lên logo cửa hàng (Định dạng JPG, PNG)</p>
                                </div>
                                <input type="file" id="shopLogoInput" name="shopLogo" accept="image/*" class="d-none" onchange="previewImage(this, 'shopLogoPreview', 'box-shopLogoInput', 'wrap-shopLogo')" required>
                                <div id="wrap-shopLogo" class="preview-container d-none mt-2">
                                    <img id="shopLogoPreview" class="preview-img" alt="Logo Preview">
                                    <button type="button" class="btn-remove-img" onclick="removeImage('shopLogoInput', 'shopLogoPreview', 'box-shopLogoInput', 'wrap-shopLogo')" title="Xóa ảnh">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>
                                <div class="invalid-feedback d-block d-none" id="err-shopLogoInput">Vui lòng tải lên logo cửa hàng.</div>
                            </div>

                            <!-- Shop Banner -->
                            <div class="col-md-6">
                                <label class="form-label">Shop Banner – Ảnh bìa cửa hàng <span class="text-danger">*</span></label>
                                <div class="upload-box" id="box-shopBannerInput" onclick="document.getElementById('shopBannerInput').click()">
                                    <i class="bi bi-file-earmark-image text-success fs-2"></i>
                                    <p class="small text-muted mb-0 mt-2">Tải lên ảnh bìa / banner (Khuyên dùng 1200x400px)</p>
                                </div>
                                <input type="file" id="shopBannerInput" name="shopBanner" accept="image/*" class="d-none" onchange="previewImage(this, 'shopBannerPreview', 'box-shopBannerInput', 'wrap-shopBanner')" required>
                                <div id="wrap-shopBanner" class="preview-container d-none mt-2">
                                    <img id="shopBannerPreview" class="preview-img" alt="Banner Preview">
                                    <button type="button" class="btn-remove-img" onclick="removeImage('shopBannerInput', 'shopBannerPreview', 'box-shopBannerInput', 'wrap-shopBanner')" title="Xóa ảnh">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>
                                <div class="invalid-feedback d-block d-none" id="err-shopBannerInput">Vui lòng tải lên banner cửa hàng.</div>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between mt-4">
                            <button type="button" class="btn btn-outline-secondary rounded-pill px-4" onclick="prevStep(2)"><i class="bi bi-arrow-left me-1"></i> Quay lại</button>
                            <button type="button" class="btn btn-fruit" onclick="nextStep(2)">Tiếp theo <i class="bi bi-arrow-right ms-1"></i></button>
                        </div>
                    </div>

                    <!-- BƯỚC 3: ADDRESS INFORMATION -->
                    <div class="form-step" id="step-3">
                        <div class="section-header">
                            <span class="section-number">3</span>
                            <span>Address Information (Thông Tin Địa Chỉ)</span>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label">Province/City – Tỉnh / Thành phố <span class="text-danger">*</span></label>
                                <select name="province" class="form-select" required>
                                    <option value="" selected disabled>-- Chọn Tỉnh / Thành phố --</option>
                                    <option value="Hà Nội">Hà Nội</option>
                                    <option value="TP. Hồ Chí Minh">TP. Hồ Chí Minh</option>
                                    <option value="Đà Nẵng">Đà Nẵng</option>
                                    <option value="Cần Thơ">Cần Thơ</option>
                                    <option value="Đồng Nai">Đồng Nai</option>
                                    <option value="Lâm Đồng">Lâm Đồng</option>
                                </select>
                                <div class="invalid-feedback">Vui lòng chọn Tỉnh / Thành phố.</div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">District – Quận / Huyện <span class="text-danger">*</span></label>
                                <input type="text" name="district" class="form-control" placeholder="Nhập Quận / Huyện" required>
                                <div class="invalid-feedback">Vui lòng nhập Quận / Huyện.</div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Ward – Phường / Xã <span class="text-danger">*</span></label>
                                <input type="text" name="ward" class="form-control" placeholder="Nhập Phường / Xã" required>
                                <div class="invalid-feedback">Vui lòng nhập Phường / Xã.</div>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Street Address – Số nhà, tên đường <span class="text-danger">*</span></label>
                                <input type="text" name="streetAddress" class="form-control" placeholder="Ví dụ: 123 Đường Nguyễn Trãi" required>
                                <div class="invalid-feedback">Vui lòng nhập số nhà, tên đường.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Pickup Address – Địa chỉ lấy hàng <span class="text-danger">*</span></label>
                                <input type="text" name="pickupAddress" class="form-control" placeholder="Địa chỉ để đơn vị vận chuyển tới lấy hàng" required>
                                <div class="invalid-feedback">Vui lòng nhập địa chỉ lấy hàng.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Return Address – Địa chỉ trả hàng <span class="text-danger">*</span></label>
                                <input type="text" name="returnAddress" class="form-control" placeholder="Địa chỉ nhận hàng hoàn trả (nếu có)" required>
                                <div class="invalid-feedback">Vui lòng nhập địa chỉ trả hàng.</div>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between mt-4">
                            <button type="button" class="btn btn-outline-secondary rounded-pill px-4" onclick="prevStep(3)"><i class="bi bi-arrow-left me-1"></i> Quay lại</button>
                            <button type="button" class="btn btn-fruit" onclick="nextStep(3)">Tiếp theo <i class="bi bi-arrow-right ms-1"></i></button>
                        </div>
                    </div>

                    <!-- BƯỚC 4: BANK INFORMATION -->
                    <div class="form-step" id="step-4">
                        <div class="section-header">
                            <span class="section-number">4</span>
                            <span>Bank Information (Thông Tin Ngân Hàng Doanh Thu)</span>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label">Bank Name – Tên ngân hàng <span class="text-danger">*</span></label>
                                <select name="bankName" class="form-select" required>
                                    <option value="" selected disabled>-- Chọn ngân hàng --</option>
                                    <option value="Vietcombank">Vietcombank (VCB)</option>
                                    <option value="MBBank">MBBank (MB)</option>
                                    <option value="Techcombank">Techcombank (TCB)</option>
                                    <option value="VietinBank">VietinBank</option>
                                    <option value="BIDV">BIDV</option>
                                    <option value="VPBank">VPBank</option>
                                    <option value="ACB">ACB</option>
                                </select>
                                <div class="invalid-feedback">Vui lòng chọn ngân hàng.</div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Bank Account Number – Số tài khoản <span class="text-danger">*</span></label>
                                <input type="text" name="bankAccountNumber" class="form-control" placeholder="Nhập số tài khoản ngân hàng" required>
                                <div class="invalid-feedback">Vui lòng nhập số tài khoản.</div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Account Holder Name – Tên chủ tài khoản <span class="text-danger">*</span></label>
                                <input type="text" name="bankAccountHolder" class="form-control" placeholder="Viết hoa không dấu (VD: NGUYEN VAN A)" required>
                                <div class="invalid-feedback">Vui lòng nhập tên chủ tài khoản.</div>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between mt-4">
                            <button type="button" class="btn btn-outline-secondary rounded-pill px-4" onclick="prevStep(4)"><i class="bi bi-arrow-left me-1"></i> Quay lại</button>
                            <button type="button" class="btn btn-fruit" onclick="nextStep(4)">Tiếp theo <i class="bi bi-arrow-right ms-1"></i></button>
                        </div>
                    </div>

                    <!-- BƯỚC 5: VERIFICATION & AGREEMENT -->
                    <div class="form-step" id="step-5">
                        <div class="section-header">
                            <span class="section-number">5</span>
                            <span>Verification & Agreement (Điều Khoản & Cam Kết)</span>
                        </div>
                        <div class="card bg-light border-0 p-3 mb-3">
                            <div class="form-check mb-2">
                                <input class="form-check-input" type="checkbox" value="true" id="termsCheck" name="agreeTerms" required>
                                <label class="form-check-label text-dark" for="termsCheck">
                                    Tôi đồng ý với các <a href="#" class="text-success fw-bold text-decoration-none">Điều khoản & Điều kiện dịch vụ</a> dành cho Shop Owner. <span class="text-danger">*</span>
                                </label>
                                <div class="invalid-feedback">Bạn cần đồng ý với điều khoản dịch vụ.</div>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" value="true" id="policyCheck" name="agreePolicies" required>
                                <label class="form-check-label text-dark" for="policyCheck">
                                    Tôi cam kết tuân thủ các <a href="#" class="text-success fw-bold text-decoration-none">Chính sách bán hàng & An toàn thực phẩm</a> của nền tảng. <span class="text-danger">*</span>
                                </label>
                                <div class="invalid-feedback">Bạn cần đồng ý với chính sách bán hàng.</div>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between mt-4">
                            <button type="button" class="btn btn-outline-secondary rounded-pill px-4" onclick="prevStep(5)"><i class="bi bi-arrow-left me-1"></i> Quay lại</button>
                            <button type="submit" class="btn btn-fruit shadow">
                                <i class="bi bi-check-circle-fill me-2"></i> Submit Registration (Gửi Đăng Ký)
                            </button>
                        </div>
                    </div>

                </div>
            </form>
        </div>
    </div>
</div>

<!-- Footer -->
<footer class="bg-white border-top py-4 text-center text-muted small mt-5">
    <div class="container">
        &copy; 2026 Online Fruit Shop. All rights reserved.
    </div>
</footer>

<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    let currentStep = 1;

    // Chuyển sang bước tiếp theo
    function nextStep(step) {
        if (validateStep(step)) {
            document.getElementById('step-' + step).classList.remove('active');
            
            // Cập nhật Stepper Progress
            const currentIndicator = document.getElementById('step-indicator-' + step);
            currentIndicator.classList.remove('active');
            currentIndicator.classList.add('completed');
            currentIndicator.querySelector('.step-counter').innerHTML = '<i class="bi bi-check"></i>';

            currentStep = step + 1;
            document.getElementById('step-' + currentStep).classList.add('active');
            
            const nextIndicator = document.getElementById('step-indicator-' + currentStep);
            nextIndicator.classList.add('active');

            window.scrollTo({ top: 150, behavior: 'smooth' });
        }
    }

    // Quay lại bước trước đó
    function prevStep(step) {
        document.getElementById('step-' + step).classList.remove('active');
        
        const currentIndicator = document.getElementById('step-indicator-' + step);
        currentIndicator.classList.remove('active');

        currentStep = step - 1;
        document.getElementById('step-' + currentStep).classList.add('active');
        
        const prevIndicator = document.getElementById('step-indicator-' + currentStep);
        prevIndicator.classList.remove('completed');
        prevIndicator.classList.add('active');
        prevIndicator.querySelector('.step-counter').innerText = currentStep;

        window.scrollTo({ top: 150, behavior: 'smooth' });
    }

    // Kiểm tra tính hợp lệ của trường dữ liệu từng bước
    function validateStep(step) {
        const stepContainer = document.getElementById('step-' + step);
        const inputs = stepContainer.querySelectorAll('input, select, textarea');
        let isValid = true;

        inputs.forEach(input => {
            if (input.hasAttribute('required')) {
                if (input.type === 'file') {
                    const errEl = document.getElementById('err-' + input.id);
                    // Kiểm tra xem đã chọn file chưa (hoặc đã có file lưu trữ tạm)
                    if (!input.files || input.files.length === 0) {
                        isValid = false;
                        if(errEl) errEl.classList.remove('d-none');
                    } else {
                        if(errEl) errEl.classList.add('d-none');
                    }
                } else if (input.type === 'checkbox') {
                    if (!input.checked) {
                        isValid = false;
                        input.classList.add('is-invalid');
                    } else {
                        input.classList.remove('is-invalid');
                    }
                } else if (!input.checkValidity()) {
                    isValid = false;
                    input.classList.add('is-invalid');
                } else {
                    input.classList.remove('is-invalid');
                }
            }
        });

        return isValid;
    }

    // Hàm xem trước ảnh và ẩn hộp upload
    function previewImage(input, previewId, boxId, wrapperId) {
        const preview = document.getElementById(previewId);
        const uploadBox = document.getElementById(boxId);
        const wrapper = document.getElementById(wrapperId);
        const errEl = document.getElementById('err-' + input.id);

        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                uploadBox.classList.add('d-none');
                wrapper.classList.remove('d-none');
                if(errEl) errEl.classList.add('d-none');
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Hàm xóa ảnh đã chọn để tải lại
    function removeImage(inputId, previewId, boxId, wrapperId) {
        const input = document.getElementById(inputId);
        const preview = document.getElementById(previewId);
        const uploadBox = document.getElementById(boxId);
        const wrapper = document.getElementById(wrapperId);

        input.value = '';
        preview.src = '';
        wrapper.classList.add('d-none');
        uploadBox.classList.remove('d-none');
    }

    // Validate toàn bộ form trước khi Submit thực sự
    document.getElementById('multiStepForm').addEventListener('submit', function (event) {
        // Kiểm tra lại bước 5 (checkbox điều khoản)
        if (!validateStep(5)) {
            event.preventDefault();
            event.stopPropagation();
            alert('Vui lòng tích chọn đồng ý với các điều khoản và chính sách của sàn trước khi gửi đăng ký.');
        }
    });
</script>

</body>
</html>