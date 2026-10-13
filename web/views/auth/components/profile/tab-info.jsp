<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade show active" id="nav-profile" role="tabpanel">
    <form id="avatarUploadForm" action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" class="d-none-form">
        <input type="hidden" name="action" value="uploadAvatar">
        <input type="file" id="avatarFileInput" name="avatarFile" accept="image/png, image/jpeg, image/jpg, image/webp" onchange="submitAvatarForm()">
    </form>

    <form id="avatarDeleteForm" action="${pageContext.request.contextPath}/profile" method="POST" class="d-none-form">
        <input type="hidden" name="action" value="deleteAvatar">
    </form>

    <form action="${pageContext.request.contextPath}/profile" method="POST" id="profileMainForm">
        <input type="hidden" name="action" value="updateProfile">
        
        <div class="profile-section-card">
            <span class="section-tag">THÔNG TIN ĐỊNH DANH</span>
            <h3 class="section-heading mb-4">Thông tin Cá Nhân Cơ Bản</h3>

            <div class="avatar-upload-box">
                <c:choose>
                    <c:when test="${not empty user.avatarUrl}">
                        <c:set var="formUserAvatar" value="${user.avatarUrl.startsWith('http://') or user.avatarUrl.startsWith('https://') ? user.avatarUrl : pageContext.request.contextPath.concat('/').concat(user.avatarUrl)}" />
                        <img src="${formUserAvatar}" class="avatar-form" alt="Avatar" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${user.fullName}&background=046A38&color=fff';">
                    </c:when>
                    <c:otherwise>
                        <div class="avatar-placeholder avatar-form">
                            ${not empty user.fullName ? user.fullName.substring(0, 1).toUpperCase() : 'U'}
                        </div>
                    </c:otherwise>
                </c:choose>
                <div>
                    <div class="avatar-actions">
                        <button type="button" class="btn btn-fresh-green btn-sm" onclick="document.getElementById('avatarFileInput').click();">
                            <i class="bi bi-upload me-1"></i> Tải ảnh mới
                        </button>
                        <c:if test="${not empty user.avatarUrl}">
                            <button type="button" class="btn-pill-danger" onclick="confirmDeleteAvatar()">Xóa ảnh</button>
                        </c:if>
                    </div>
                    <div class="avatar-hint-text">
                        Ảnh đại diện hiển thị trên đơn hàng và hồ sơ khách hàng. Định dạng JPG, PNG, WEBP tối đa 2MB.
                    </div>
                </div>
            </div>

            <div class="row g-3">
                <div class="col-md-6 field-box">
                    <label class="field-label" for="fullName">Họ và tên *</label>
                    <div class="input-icon-group">
                        <i class="bi bi-person lead-icon"></i>
                        <input type="text" id="fullName" name="fullName" value="${user.fullName}" required placeholder="Nhập họ và tên của bạn">
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label" for="displayName">Tên hiển thị & Xưng hô giao dịch</label>
                    <div class="input-icon-group">
                        <i class="bi bi-card-heading lead-icon"></i>
                        <input type="text" id="displayName" name="displayName" value="${user.fullName}" placeholder="Tên gọi khi shipper liên hệ">
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label" for="email">Địa chỉ Email đăng nhập *</label>
                    <div class="input-icon-group">
                        <i class="bi bi-envelope lead-icon"></i>
                        <input type="text" id="email" value="${user.email}" readonly class="input-readonly-fixed" title="Email tài khoản được cố định để bảo vệ an toàn">
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label" for="phone">Số điện thoại giao hàng *</label>
                    <div class="input-icon-group">
                        <i class="bi bi-telephone lead-icon"></i>
                        <input type="tel" id="phone" name="phone" value="${not empty user.phone ? user.phone : ''}" placeholder="Ví dụ: 0912345678" maxlength="11" autocomplete="tel">
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label" for="birthDate">Ngày sinh (để nhận quà quả tươi sinh nhật)</label>
                    <div class="input-icon-group">
                        <i class="bi bi-calendar3 lead-icon"></i>
                        <input type="date" id="birthDate" name="birthDate" value="${user.birthDate}">
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label">Giới tính</label>
                    <div class="btn-group w-100" role="group">
                        <input type="radio" class="btn-check" name="gender" id="genderFemale" value="FEMALE" autocomplete="off" ${user.gender == 'FEMALE' ? 'checked' : ''}>
                        <label class="gender-choice" for="genderFemale"><i class="bi bi-gender-female me-1"></i>Nữ</label>

                        <input type="radio" class="btn-check" name="gender" id="genderMale" value="MALE" autocomplete="off" ${user.gender == 'MALE' ? 'checked' : ''}>
                        <label class="gender-choice" for="genderMale"><i class="bi bi-gender-male me-1"></i>Nam</label>

                        <input type="radio" class="btn-check" name="gender" id="genderOther" value="OTHER" autocomplete="off" ${user.gender == 'OTHER' ? 'checked' : ''}>
                        <label class="gender-choice" for="genderOther"><i class="bi bi-gender-ambiguous me-1"></i>Khác</label>
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label" for="language">Ngôn ngữ giao diện</label>
                    <div class="input-icon-group">
                        <i class="bi bi-translate lead-icon"></i>
                        <select id="language" name="language">
                            <option selected>Tiếng Việt (Mặc định)</option>
                            <option>English (US)</option>
                        </select>
                    </div>
                </div>

                <div class="col-12 field-box">
                    <div class="default-address-header">
                        <label class="field-label mb-0">Địa chỉ nhận hàng mặc định</label>
                        <button type="button" class="btn btn-link btn-sm text-success text-decoration-none p-0 fw-semibold" onclick="switchTab('nav-address-tab')">
                            <i class="bi bi-geo-alt me-1"></i> Quản lý địa chỉ (${not empty addresses ? addresses.size() : 0})
                        </button>
                    </div>
                    <div class="default-address-box">
                        <c:choose>
                            <c:when test="${not empty addresses}">
                                <c:set var="defaultFound" value="false" />
                                <c:forEach items="${addresses}" var="a">
                                    <c:if test="${(a.isDefault or a['default']) and not defaultFound}">
                                        <div class="d-flex align-items-start gap-2">
                                            <i class="bi bi-geo-alt-fill text-success fs-5 mt-1"></i>
                                            <div>
                                                <strong class="text-dark">${a.recipientName}</strong> &bull; <span class="text-muted">${a.recipientPhone}</span>
                                                <div class="text-secondary small mt-1">${a.fullAddress}</div>
                                            </div>
                                        </div>
                                        <c:set var="defaultFound" value="true" />
                                    </c:if>
                                </c:forEach>
                                <c:if test="${not defaultFound}">
                                    <div class="text-muted small">
                                        ${addresses[0].recipientName} &bull; ${addresses[0].recipientPhone} - ${addresses[0].fullAddress}
                                    </div>
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-muted small">Chưa có địa chỉ nhận hàng nào được lưu.</span>
                                    <button type="button" class="btn-pill-success" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                                        <i class="bi bi-plus-lg me-1"></i> Thêm địa chỉ
                                    </button>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <div class="sticky-action-bar">
            <div class="text-muted small">
                <i class="bi bi-info-circle text-success me-1"></i> Tất cả các tùy chỉnh sẽ có hiệu lực ngay tức thì trên hệ thống FreshFruit.
            </div>
            <div class="d-flex gap-2">
                <button type="reset" class="btn-pill-sec">Hủy bỏ</button>
                <button type="submit" class="btn btn-fresh-green btn-sm px-4">
                    <i class="bi bi-check2 me-1"></i> Lưu thay đổi
                </button>
            </div>
        </div>
    </form>
</div>

