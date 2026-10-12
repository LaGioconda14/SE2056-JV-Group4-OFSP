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
            padding: 12px 30px;
            font-size: 1.05rem;
            border-radius: 50rem;
            transition: all 0.3s ease;
        }
        .btn-fruit:hover {
            background: linear-gradient(135deg, #1b5e20, #2e7d32);
            color: #ffffff;
            box-shadow: 0 6px 20px rgba(46, 125, 50, 0.3);
            transform: translateY(-2px);
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
        .preview-img {
            max-height: 120px;
            border-radius: 0.5rem;
            object-fit: cover;
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
                <p class="text-muted">Vui lòng điền đầy đủ các thông tin dưới đây để đăng ký gian hàng bán hoa quả tươi trên hệ thống.</p>
            </div>

            <!-- Form Đăng Ký -->
            <form action="${pageContext.request.contextPath}/register-shop" method="POST" enctype="multipart/form-data" class="needs-validation" novalidate>
                <div class="form-card p-4 p-md-5">

                    <!-- 1. SELLER INFORMATION -->
                    <div class="mb-5">
                        <div class="section-header">
                            <span class="section-number">1</span>
                            <span>Seller Information (Thông Tin Người Bán)</span>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name – Họ và tên <span class="text-danger">*</span></label>
                                <input type="text" name="fullName" class="form-control" value="${sessionScope.user.fullName}" placeholder="Nhập họ và tên" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date of Birth – Ngày sinh <span class="text-danger">*</span></label>
                                <input type="date" name="dob" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone Number – Số điện thoại <span class="text-danger">*</span></label>
                                <input type="tel" name="phone" class="form-control" value="${sessionScope.user.phone}" placeholder="Nhập số điện thoại" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email – Email <span class="text-danger">*</span></label>
                                <input type="email" name="email" class="form-control" value="${sessionScope.user.email}" placeholder="example@domain.com" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ID/CCCD Number – Số CCCD <span class="text-danger">*</span></label>
                                <input type="text" name="idCardNumber" class="form-control" placeholder="Nhập số CCCD (12 chữ số)" pattern="[0-9]{12}" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Tax Identification Number (TIN) – Mã số thuế</label>
                                <input type="text" name="taxId" class="form-control" placeholder="Mã số thuế cá nhân / hộ kinh doanh">
                            </div>
                            <!-- ID Front Image -->
                            <div class="col-md-6">
                                <label class="form-label">ID/CCCD Front Image – Ảnh CCCD mặt trước <span class="text-danger">*</span></label>
                                <div class="upload-box" onclick="document.getElementById('idFrontInput').click()">
                                    <i class="bi bi-card-heading text-success fs-2"></i>
                                    <p class="small text-muted mb-0 mt-2">Nhấp để tải lên ảnh CCCD mặt trước</p>
                                    <input type="file" id="idFrontInput" name="idFrontImage" accept="image/*" class="d-none" onchange="previewImage(this, 'idFrontPreview')" required>
                                    <img id="idFrontPreview" class="preview-img d-none mt-2 img-fluid" alt="Front Preview">
                                </div>
                            </div>
                            <!-- ID Back Image -->
                            <div class="col-md-6">
                                <label class="form-label">ID/CCCD Back Image – Ảnh CCCD mặt sau <span class="text-danger">*</span></label>
                                <div class="upload-box" onclick="document.getElementById('idBackInput').click()">
                                    <i class="bi bi-credit-card-2-back text-success fs-2"></i>
                                    <p class="small text-muted mb-0 mt-2">Nhấp để tải lên ảnh CCCD mặt sau</p>
                                    <input type="file" id="idBackInput" name="idBackImage" accept="image/*" class="d-none" onchange="previewImage(this, 'idBackPreview')" required>
                                    <img id="idBackPreview" class="preview-img d-none mt-2 img-fluid" alt="Back Preview">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 2. SHOP INFORMATION -->
                    <div class="mb-5">
                        <div class="section-header">
                            <span class="section-number">2</span>
                            <span>Shop Information (Thông Tin Cửa Hàng)</span>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Shop Name – Tên cửa hàng <span class="text-danger">*</span></label>
                                <input type="text" name="shopName" class="form-control" placeholder="Ví dụ: Nông Sản Tươi Xanh" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Shop Category – Danh mục kinh doanh <span class="text-danger">*</span></label>
                                <select name="shopCategory" class="form-select" required>
                                    <option value="" selected disabled>-- Chọn danh mục chính --</option>
                                    <option value="TRAI_CAY_NOI_DIA">Trái Cây Nội Địa</option>
                                    <option value="TRAI_CAY_NHAP_KHAU">Trái Cây Nhập Khẩu</option>
                                    <option value="TRAI_CAY_HUU_CO">Trái Cây Hữu Cơ (Organic)</option>
                                    <option value="HOA_QUA_SAY">Hoa Quả Sấy & Chế Biến</option>
                                    <option value="COMBO_GIOT_HOA_QUA">Giỏ Quà Trái Cây</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Shop Description – Mô tả cửa hàng</label>
                                <textarea name="shopDescription" class="form-control" rows="3" placeholder="Giới thiệu ngắn gọn về gian hàng, nguồn gốc xuất xứ sản phẩm..."></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Shop Logo – Logo cửa hàng <span class="text-danger">*</span></label>
                                <div class="upload-box" onclick="document.getElementById('shopLogoInput').click()">
                                    <i class="bi bi-image text-success fs-2"></i>
                                    <p class="small text-muted mb-0 mt-2">Tải lên logo cửa hàng (Định dạng JPG, PNG)</p>
                                    <input type="file" id="shopLogoInput" name="shopLogo" accept="image/*" class="d-none" onchange="previewImage(this, 'shopLogoPreview')" required>
                                    <img id="shopLogoPreview" class="preview-img d-none mt-2 img-fluid" alt="Logo Preview">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 3. ADDRESS INFORMATION -->
                    <div class="mb-5">
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
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">District – Quận / Huyện <span class="text-danger">*</span></label>
                                <input type="text" name="district" class="form-control" placeholder="Nhập Quận / Huyện" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Ward – Phường / Xã <span class="text-danger">*</span></label>
                                <input type="text" name="ward" class="form-control" placeholder="Nhập Phường / Xã" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Street Address – Số nhà, tên đường <span class="text-danger">*</span></label>
                                <input type="text" name="streetAddress" class="form-control" placeholder="Ví dụ: 123 Đường Nguyễn Trãi" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Pickup Address – Địa chỉ lấy hàng <span class="text-danger">*</span></label>
                                <input type="text" name="pickupAddress" class="form-control" placeholder="Địa chỉ để đơn vị vận chuyển tới lấy hàng" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Return Address – Địa chỉ trả hàng <span class="text-danger">*</span></label>
                                <input type="text" name="returnAddress" class="form-control" placeholder="Địa chỉ nhận hàng hoàn trả (nếu có)" required>
                            </div>
                        </div>
                    </div>

                    <!-- 4. BANK INFORMATION -->
                    <div class="mb-5">
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
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Bank Account Number – Số tài khoản <span class="text-danger">*</span></label>
                                <input type="text" name="bankAccountNumber" class="form-control" placeholder="Nhập số tài khoản ngân hàng" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Account Holder Name – Tên chủ tài khoản <span class="text-danger">*</span></label>
                                <input type="text" name="accountHolderName" class="form-control" placeholder="Viết hoa không dấu (VD: NGUYEN VAN A)" required>
                            </div>
                        </div>
                    </div>

                    <!-- 5. VERIFICATION & AGREEMENT -->
                    <div class="mb-4">
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
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" value="true" id="policyCheck" name="agreePolicies" required>
                                <label class="form-check-label text-dark" for="policyCheck">
                                    Tôi cam kết tuân thủ các <a href="#" class="text-success fw-bold text-decoration-none">Chính sách bán hàng & An toàn thực phẩm</a> của nền tảng. <span class="text-danger">*</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <div class="text-center pt-3">
                        <button type="submit" class="btn btn-fruit shadow">
                            <i class="bi bi-check-circle-fill me-2"></i> Submit Registration (Gửi Đăng Ký)
                        </button>
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

<!-- Script xem trước ảnh upload & validate form -->
<script>
    // Hàm xem trước ảnh khi chọn file
    function previewImage(input, previewId) {
        const preview = document.getElementById(previewId);
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                preview.classList.remove('d-none');
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Bootstrap Form Validation Client-side
    (function () {
        'use strict'
        const forms = document.querySelectorAll('.needs-validation')
        Array.prototype.slice.call(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        })
    })()
</script>

</body>
</html>