<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade show active" id="nav-profile" role="tabpanel">
    <form action="${pageContext.request.contextPath}/profile" method="POST" id="profileMainForm" enctype="multipart/form-data" class="profile-view-mode">
        <input type="hidden" name="action" value="updateProfile">
        <input type="hidden" name="deleteAvatar" id="deleteAvatarFlag" value="false">
        <input type="file" id="avatarFileInput" name="avatarFile" accept="image/png, image/jpeg, image/jpg, image/webp" class="d-none" onchange="handleAvatarFileSelect(this)">
        
        <div class="profile-section-card">
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                    <span class="section-tag">THÔNG TIN ĐỊNH DANH</span>
                    <h3 class="section-heading mb-0">Thông tin Cá Nhân Cơ Bản</h3>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span id="editStatusBadge" class="badge bg-warning-subtle text-warning-emphasis border border-warning px-3 py-2 rounded-pill fw-semibold d-none">
                        <i class="bi bi-pencil-fill me-1"></i> Đang chỉnh sửa
                    </span>
                    <button type="button" class="btn btn-fresh-green btn-sm px-3 shadow-sm" id="btnEditProfileTop" onclick="enableProfileEdit()">
                        <i class="bi bi-pencil-square me-1"></i> Sửa thông tin
                    </button>
                    <button type="button" class="btn btn-outline-secondary btn-sm px-3 d-none" id="btnCancelEditTop" onclick="cancelProfileEdit()">
                        <i class="bi bi-x-circle me-1"></i> Hủy
                    </button>
                    <button type="button" class="btn btn-fresh-green btn-sm px-3 shadow-sm d-none" id="btnSaveProfileTop" onclick="submitProfileForm()">
                        <i class="bi bi-check2 me-1"></i> Lưu thay đổi
                    </button>
                </div>
            </div>

            <!-- Khung ảnh đại diện -->
            <div class="avatar-upload-box">
                <div id="avatarContainer" role="button" onclick="triggerAvatarSelect()" title="Nhấp để tải ảnh mới" style="cursor: pointer; flex-shrink: 0;">
                    <c:choose>
                        <c:when test="${not empty user.avatarUrl}">
                            <c:set var="formUserAvatar" value="${user.avatarUrl.startsWith('http://') or user.avatarUrl.startsWith('https://') ? user.avatarUrl : (user.avatarUrl.startsWith('/') ? pageContext.request.contextPath.concat(user.avatarUrl) : pageContext.request.contextPath.concat('/').concat(user.avatarUrl))}" />
                            <img id="avatarImagePreview" src="${formUserAvatar}" class="avatar-form shadow-sm" alt="Avatar" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${user.fullName}&background=046A38&color=fff';">
                            <div id="avatarPlaceholderPreview" class="avatar-placeholder avatar-form d-none">
                                ${not empty user.fullName ? user.fullName.substring(0, 1).toUpperCase() : 'U'}
                            </div>
                        </c:when>
                        <c:otherwise>
                            <img id="avatarImagePreview" src="" class="avatar-form shadow-sm d-none" alt="Avatar">
                            <div id="avatarPlaceholderPreview" class="avatar-placeholder avatar-form">
                                ${not empty user.fullName ? user.fullName.substring(0, 1).toUpperCase() : 'U'}
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="flex-grow-1">
                    <!-- Trạng thái mặc định: Tải ảnh mới & Xóa ảnh -->
                    <div id="avatarDefaultActions" class="avatar-actions">
                        <button type="button" class="btn btn-fresh-green btn-sm px-3 shadow-sm" id="btnUploadAvatar" onclick="triggerAvatarSelect()">
                            <i class="bi bi-camera-fill me-1.5"></i> Tải ảnh mới
                        </button>
                        <button type="button" class="btn btn-outline-danger btn-sm px-3 ${empty user.avatarUrl ? 'd-none' : ''}" id="btnDeleteAvatar" onclick="confirmDeleteAvatar()">
                            <i class="bi bi-trash3 me-1"></i> Xóa ảnh
                        </button>
                    </div>

                    <!-- Trạng thái khi vừa chọn ảnh mới: Lưu ảnh & Hủy -->
                    <div id="avatarPendingActions" class="avatar-actions d-none">
                        <span class="badge bg-success-subtle text-success border border-success-subtle px-2.5 py-2 rounded-pill fw-semibold me-1">
                            <i class="bi bi-check2-circle me-1"></i> Đã chọn ảnh mới
                        </span>
                        <button type="button" class="btn btn-fresh-green btn-sm px-3 fw-semibold shadow-sm" id="btnSaveAvatarDirect" onclick="submitDirectAvatarUpload()">
                            <i class="bi bi-cloud-arrow-up-fill me-1"></i> Lưu ảnh đại diện
                        </button>
                        <button type="button" class="btn btn-outline-secondary btn-sm px-2.5" onclick="cancelAvatarPreview()">
                            <i class="bi bi-x-lg me-1"></i> Hủy
                        </button>
                    </div>

                    <div class="avatar-hint-text mt-1.5">
                        <i class="bi bi-info-circle me-1 text-muted"></i> Nhấp vào ảnh hoặc nút để chọn ảnh mới. Định dạng JPG, PNG, WEBP tối đa 2MB.
                    </div>
                </div>
            </div>

            <div class="row g-3">
                <div class="col-md-6 field-box">
                    <label class="field-label" for="fullName">Họ và tên *</label>
                    <div class="input-icon-group">
                        <i class="bi bi-person lead-icon"></i>
                        <input type="text" id="fullName" name="fullName" value="${user.fullName}" required placeholder="Nhập họ và tên của bạn" disabled>
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label" for="displayName">Tên hiển thị & Xưng hô giao dịch</label>
                    <div class="input-icon-group">
                        <i class="bi bi-card-heading lead-icon"></i>
                        <input type="text" id="displayName" name="displayName" value="${user.fullName}" placeholder="Tên gọi khi shipper liên hệ" disabled>
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
                    <label class="field-label" for="phone">Số điện thoại *</label>
                    <div class="input-icon-group">
                        <i class="bi bi-telephone lead-icon"></i>
                        <input type="tel" id="phone" name="phone" value="${not empty user.phone ? user.phone : ''}" placeholder="Ví dụ: 0912345678" maxlength="11" autocomplete="tel" disabled>
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label" for="birthDate">Ngày sinh (để nhận quà quả tươi sinh nhật)</label>
                    <div class="input-icon-group">
                        <i class="bi bi-calendar3 lead-icon"></i>
                        <input type="date" id="birthDate" name="birthDate" value="${user.birthDate}" disabled>
                    </div>
                </div>

                <div class="col-md-6 field-box">
                    <label class="field-label">Giới tính</label>
                    <div class="btn-group w-100" role="group">
                        <input type="radio" class="btn-check" name="gender" id="genderFemale" value="FEMALE" autocomplete="off" ${user.gender == 'FEMALE' ? 'checked' : ''} disabled>
                        <label class="gender-choice" for="genderFemale"><i class="bi bi-gender-female me-1"></i>Nữ</label>

                        <input type="radio" class="btn-check" name="gender" id="genderMale" value="MALE" autocomplete="off" ${user.gender == 'MALE' ? 'checked' : ''} disabled>
                        <label class="gender-choice" for="genderMale"><i class="bi bi-gender-male me-1"></i>Nam</label>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- Form ẩn thực hiện lưu / xóa avatar trực tiếp -->
    <form id="avatarDirectForm" action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" class="d-none">
        <input type="hidden" name="action" id="avatarDirectAction" value="uploadAvatar">
    </form>

    <script>
    (function() {
        let initialProfileData = {};

        function captureInitialProfileData() {
            const form = document.getElementById('profileMainForm');
            if (!form) return;
            const fullNameInput = document.getElementById('fullName');
            const displayNameInput = document.getElementById('displayName');
            const phoneInput = document.getElementById('phone');
            const birthDateInput = document.getElementById('birthDate');
            const checkedGender = form.querySelector('input[name="gender"]:checked');
            const previewImg = document.getElementById('avatarImagePreview');
            const deleteBtn = document.getElementById('btnDeleteAvatar');

            initialProfileData = {
                fullName: fullNameInput ? fullNameInput.value : '',
                displayName: displayNameInput ? displayNameInput.value : '',
                phone: phoneInput ? phoneInput.value : '',
                birthDate: birthDateInput ? birthDateInput.value : '',
                gender: checkedGender ? checkedGender.value : '',
                avatarSrc: previewImg ? previewImg.getAttribute('src') : '',
                hasAvatar: previewImg && !previewImg.classList.contains('d-none') && !!previewImg.getAttribute('src'),
                deleteBtnVisible: deleteBtn && !deleteBtn.classList.contains('d-none')
            };
        }

        window.triggerAvatarSelect = function() {
            const fileInput = document.getElementById('avatarFileInput');
            if (fileInput) fileInput.click();
        };

        window.enableProfileEdit = function() {
            const form = document.getElementById('profileMainForm');
            if (!form) return;

            form.classList.remove('profile-view-mode');
            form.classList.add('profile-edit-mode');

            const inputs = ['fullName', 'displayName', 'phone', 'birthDate'];
            inputs.forEach(id => {
                const el = document.getElementById(id);
                if (el) {
                    el.removeAttribute('disabled');
                    el.disabled = false;
                }
            });

            form.querySelectorAll('input[name="gender"]').forEach(r => {
                r.removeAttribute('disabled');
                r.disabled = false;
            });

            const btnEditTop = document.getElementById('btnEditProfileTop');
            const btnCancelTop = document.getElementById('btnCancelEditTop');
            const btnSaveTop = document.getElementById('btnSaveProfileTop');
            const badge = document.getElementById('editStatusBadge');

            if (btnEditTop) btnEditTop.classList.add('d-none');
            if (btnCancelTop) btnCancelTop.classList.remove('d-none');
            if (btnSaveTop) btnSaveTop.classList.remove('d-none');
            if (badge) badge.classList.remove('d-none');

            const fullNameEl = document.getElementById('fullName');
            if (fullNameEl) {
                fullNameEl.focus();
            }
        };

        window.cancelProfileEdit = function() {
            const form = document.getElementById('profileMainForm');
            if (!form) return;

            if (typeof window.cancelAvatarPreview === 'function') {
                window.cancelAvatarPreview();
            }

            if (initialProfileData) {
                const setVal = (id, val) => {
                    const el = document.getElementById(id);
                    if (el) el.value = val;
                };
                setVal('fullName', initialProfileData.fullName || '');
                setVal('displayName', initialProfileData.displayName || '');
                setVal('phone', initialProfileData.phone || '');
                setVal('birthDate', initialProfileData.birthDate || '');

                if (initialProfileData.gender) {
                    const r = form.querySelector('input[name="gender"][value="' + initialProfileData.gender + '"]');
                    if (r) r.checked = true;
                }

                const fileInput = document.getElementById('avatarFileInput');
                if (fileInput) fileInput.value = '';
                const deleteFlag = document.getElementById('deleteAvatarFlag');
                if (deleteFlag) deleteFlag.value = 'false';

                const deleteBtn = document.getElementById('btnDeleteAvatar');
                if (deleteBtn) {
                    if (initialProfileData.deleteBtnVisible) {
                        deleteBtn.classList.remove('d-none');
                    } else {
                        deleteBtn.classList.add('d-none');
                    }
                }
            }

            const inputs = ['fullName', 'displayName', 'phone', 'birthDate'];
            inputs.forEach(id => {
                const el = document.getElementById(id);
                if (el) {
                    el.setAttribute('disabled', 'disabled');
                    el.disabled = true;
                }
            });

            form.querySelectorAll('input[name="gender"]').forEach(r => {
                r.setAttribute('disabled', 'disabled');
                r.disabled = true;
            });

            form.classList.remove('profile-edit-mode');
            form.classList.add('profile-view-mode');

            const btnEditTop = document.getElementById('btnEditProfileTop');
            const btnCancelTop = document.getElementById('btnCancelEditTop');
            const btnSaveTop = document.getElementById('btnSaveProfileTop');
            const badge = document.getElementById('editStatusBadge');

            if (btnEditTop) btnEditTop.classList.remove('d-none');
            if (btnCancelTop) btnCancelTop.classList.add('d-none');
            if (btnSaveTop) btnSaveTop.classList.add('d-none');
            if (badge) badge.classList.add('d-none');
        };

        window.submitProfileForm = function() {
            const form = document.getElementById('profileMainForm');
            if (!form) return;

            form.querySelectorAll('input, select').forEach(el => {
                el.removeAttribute('disabled');
                el.disabled = false;
            });

            if (typeof form.requestSubmit === 'function') {
                form.requestSubmit();
            } else {
                form.submit();
            }
        };

        window.handleAvatarFileSelect = function(input) {
            if (input && input.files && input.files[0]) {
                const file = input.files[0];
                const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
                if (!validTypes.includes(file.type.toLowerCase())) {
                    alert('Định dạng file không hỗ trợ! Vui lòng chọn ảnh JPG, PNG hoặc WEBP.');
                    input.value = '';
                    return;
                }
                if (file.size > 2 * 1024 * 1024) {
                    alert('Kích thước file vượt quá 2MB! Vui lòng chọn ảnh nhẹ hơn.');
                    input.value = '';
                    return;
                }

                const reader = new FileReader();
                reader.onload = function(e) {
                    const previewImg = document.getElementById('avatarImagePreview');
                    const placeholder = document.getElementById('avatarPlaceholderPreview');
                    const defaultBox = document.getElementById('avatarDefaultActions');
                    const pendingBox = document.getElementById('avatarPendingActions');

                    if (previewImg) {
                        previewImg.src = e.target.result;
                        previewImg.classList.remove('d-none');
                    }
                    if (placeholder) {
                        placeholder.classList.add('d-none');
                    }
                    if (defaultBox) {
                        defaultBox.classList.add('d-none');
                    }
                    if (pendingBox) {
                        pendingBox.classList.remove('d-none');
                    }

                    const deleteFlag = document.getElementById('deleteAvatarFlag');
                    if (deleteFlag) deleteFlag.value = 'false';
                };
                reader.readAsDataURL(file);
            }
        };

        window.cancelAvatarPreview = function() {
            const fileInput = document.getElementById('avatarFileInput');
            if (fileInput) fileInput.value = '';

            const defaultBox = document.getElementById('avatarDefaultActions');
            const pendingBox = document.getElementById('avatarPendingActions');

            if (pendingBox) pendingBox.classList.add('d-none');
            if (defaultBox) defaultBox.classList.remove('d-none');

            const previewImg = document.getElementById('avatarImagePreview');
            const placeholder = document.getElementById('avatarPlaceholderPreview');

            if (previewImg && placeholder) {
                if (initialProfileData && initialProfileData.hasAvatar) {
                    previewImg.src = initialProfileData.avatarSrc;
                    previewImg.classList.remove('d-none');
                    placeholder.classList.add('d-none');
                } else {
                    previewImg.src = '';
                    previewImg.classList.add('d-none');
                    placeholder.classList.remove('d-none');
                }
            }
        };

        window.submitDirectAvatarUpload = function() {
            const fileInput = document.getElementById('avatarFileInput');
            if (!fileInput || !fileInput.files || !fileInput.files[0]) {
                alert('Vui lòng chọn ảnh đại diện trước khi lưu!');
                return;
            }

            const saveBtn = document.getElementById('btnSaveAvatarDirect');
            if (saveBtn) {
                saveBtn.disabled = true;
                saveBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Đang lưu...';
            }

            const directForm = document.getElementById('avatarDirectForm');
            if (!directForm) return;

            document.getElementById('avatarDirectAction').value = 'uploadAvatar';
            directForm.appendChild(fileInput);
            directForm.submit();
        };

        window.confirmDeleteAvatar = function() {
            const pendingBox = document.getElementById('avatarPendingActions');
            if (pendingBox && !pendingBox.classList.contains('d-none')) {
                window.cancelAvatarPreview();
                return;
            }

            if (!confirm('Bạn có chắc chắn muốn xóa ảnh đại diện hiện tại?')) {
                return;
            }

            const directForm = document.getElementById('avatarDirectForm');
            if (!directForm) return;

            document.getElementById('avatarDirectAction').value = 'deleteAvatar';
            directForm.submit();
        };

        window.handleStageDeleteAvatar = function() {
            window.confirmDeleteAvatar();
        };

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', captureInitialProfileData);
        } else {
            captureInitialProfileData();
        }

        const formEl = document.getElementById('profileMainForm');
        if (formEl) {
            formEl.addEventListener('submit', function() {
                this.querySelectorAll('input, select').forEach(el => {
                    el.removeAttribute('disabled');
                    el.disabled = false;
                });
            });
        }

        const btnEdit = document.getElementById('btnEditProfileTop');
        if (btnEdit) {
            btnEdit.addEventListener('click', function(e) {
                e.preventDefault();
                window.enableProfileEdit();
            });
        }
        const btnCancel = document.getElementById('btnCancelEditTop');
        if (btnCancel) {
            btnCancel.addEventListener('click', function(e) {
                e.preventDefault();
                window.cancelProfileEdit();
            });
        }
        const btnSave = document.getElementById('btnSaveProfileTop');
        if (btnSave) {
            btnSave.addEventListener('click', function(e) {
                e.preventDefault();
                window.submitProfileForm();
            });
        }
    })();
    </script>
</div>
