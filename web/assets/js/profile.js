function activateTab(tabTargetId, btnId) {
    if (!tabTargetId) return;

    document.querySelectorAll('#profileSidebarTab .sidebar-nav-item').forEach(b => {
        b.classList.remove('active');
        b.setAttribute('aria-selected', 'false');
    });

    let btn = btnId ? document.getElementById(btnId) : null;
    if (!btn && tabTargetId) {
        btn = document.querySelector('#profileSidebarTab button[data-bs-target="' + tabTargetId + '"]');
    }
    if (btn) {
        btn.classList.add('active');
        btn.setAttribute('aria-selected', 'true');
    }

    document.querySelectorAll('#profileTabContent .tab-pane').forEach(pane => {
        pane.classList.remove('show', 'active');
    });

    const targetPane = document.querySelector(tabTargetId);
    if (targetPane) {
        targetPane.classList.add('show', 'active');
    }

    if (btn && window.bootstrap && bootstrap.Tab) {
        try {
            const tabInstance = bootstrap.Tab.getOrCreateInstance(btn);
            tabInstance.show();
        } catch (e) {}
    }

    if (tabTargetId === '#nav-profile') {
        history.replaceState(null, null, window.location.pathname);
    } else {
        const hashName = tabTargetId.replace('#nav-', '#');
        history.replaceState(null, null, hashName);
    }

    if (tabTargetId === '#nav-orders') {
        if (typeof updateOrderCounts === 'function') {
            updateOrderCounts();
        }
    }

    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function switchTab(tabButtonId) {
    const btn = document.getElementById(tabButtonId);
    if (btn) {
        const targetId = btn.getAttribute('data-bs-target');
        activateTab(targetId, tabButtonId);
    }
}

function openAddAddressModal() {
    const modalEl = document.getElementById('addAddressModal');
    if (modalEl) {
        if (window.bootstrap && bootstrap.Modal) {
            const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.show();
        } else {
            modalEl.classList.add('show');
            modalEl.style.display = 'block';
            document.body.classList.add('modal-open');
        }
    }
}

let initialProfileData = {};

function captureInitialProfileData() {
    const form = document.getElementById('profileMainForm');
    if (!form) return;
    const fullNameInput = document.getElementById('fullName');
    const displayNameInput = document.getElementById('displayName');
    const phoneInput = document.getElementById('phone');
    const birthDateInput = document.getElementById('birthDate');
    const checkedGender = form.querySelector('input[name="gender"]:checked');
    const languageSelect = document.getElementById('language');
    const previewImg = document.getElementById('avatarImagePreview');
    const placeholder = document.getElementById('avatarPlaceholderPreview');
    const deleteBtn = document.getElementById('btnDeleteAvatar');

    initialProfileData = {
        fullName: fullNameInput ? fullNameInput.value : '',
        displayName: displayNameInput ? displayNameInput.value : '',
        phone: phoneInput ? phoneInput.value : '',
        birthDate: birthDateInput ? birthDateInput.value : '',
        gender: checkedGender ? checkedGender.value : '',
        language: languageSelect ? languageSelect.value : '',
        avatarSrc: previewImg ? previewImg.getAttribute('src') : '',
        hasAvatar: previewImg && !previewImg.classList.contains('d-none') && !!previewImg.getAttribute('src'),
        deleteBtnVisible: deleteBtn && !deleteBtn.classList.contains('d-none')
    };
}

function enableProfileEdit() {
    const form = document.getElementById('profileMainForm');
    if (!form) return;

    form.classList.remove('profile-view-mode');
    form.classList.add('profile-edit-mode');

    // Mở khóa các input cho phép sửa
    const editableInputs = form.querySelectorAll('#fullName, #displayName, #phone, #birthDate, input[name="gender"], #language');
    editableInputs.forEach(input => {
        input.removeAttribute('disabled');
        input.disabled = false;
    });

    // Mở khóa các nút avatar
    const btnUploadAvatar = document.getElementById('btnUploadAvatar');
    const btnDeleteAvatar = document.getElementById('btnDeleteAvatar');
    if (btnUploadAvatar) {
        btnUploadAvatar.removeAttribute('disabled');
        btnUploadAvatar.disabled = false;
    }
    if (btnDeleteAvatar) {
        btnDeleteAvatar.removeAttribute('disabled');
        btnDeleteAvatar.disabled = false;
    }

    // Cập nhật các nút ở header card
    const btnEditTop = document.getElementById('btnEditProfileTop');
    const btnCancelTop = document.getElementById('btnCancelEditTop');
    const btnSaveTop = document.getElementById('btnSaveProfileTop');
    const badge = document.getElementById('editStatusBadge');
    if (btnEditTop) btnEditTop.classList.add('d-none');
    if (btnCancelTop) btnCancelTop.classList.remove('d-none');
    if (btnSaveTop) btnSaveTop.classList.remove('d-none');
    if (badge) badge.classList.remove('d-none');

    // Cập nhật các nút ở bottom action bar
    const btnEditBottom = document.getElementById('btnEditProfileBottom');
    const btnCancelBottom = document.getElementById('btnCancelEditBottom');
    const btnSaveBottom = document.getElementById('btnSaveProfileBottom');
    const hint = document.getElementById('actionBarHint');
    if (btnEditBottom) btnEditBottom.style.display = 'none';
    if (btnCancelBottom) btnCancelBottom.style.display = 'inline-block';
    if (btnSaveBottom) btnSaveBottom.style.display = 'inline-block';
    if (hint) {
        hint.innerHTML = '<i class="bi bi-info-circle text-success me-1"></i> Đang chỉnh sửa thông tin cá nhân. Nhấn <strong>"Lưu thay đổi"</strong> để lưu vào hệ thống.';
    }

    // Tự động focus vào ô Họ và tên
    const fullNameInput = document.getElementById('fullName');
    if (fullNameInput) {
        fullNameInput.focus();
    }
}

function cancelProfileEdit() {
    const form = document.getElementById('profileMainForm');
    if (!form) return;

    // Khôi phục lại các giá trị ban đầu
    if (initialProfileData) {
        const fullNameInput = document.getElementById('fullName');
        if (fullNameInput) fullNameInput.value = initialProfileData.fullName || '';

        const displayNameInput = document.getElementById('displayName');
        if (displayNameInput) displayNameInput.value = initialProfileData.displayName || '';

        const phoneInput = document.getElementById('phone');
        if (phoneInput) phoneInput.value = initialProfileData.phone || '';

        const birthDateInput = document.getElementById('birthDate');
        if (birthDateInput) birthDateInput.value = initialProfileData.birthDate || '';

        if (initialProfileData.gender) {
            const r = form.querySelector('input[name="gender"][value="' + initialProfileData.gender + '"]');
            if (r) r.checked = true;
        } else {
            form.querySelectorAll('input[name="gender"]').forEach(r => r.checked = false);
        }

        const languageSelect = document.getElementById('language');
        if (languageSelect && initialProfileData.language) {
            languageSelect.value = initialProfileData.language;
        }

        // Khôi phục avatar
        const fileInput = document.getElementById('avatarFileInput');
        if (fileInput) fileInput.value = '';
        const deleteFlag = document.getElementById('deleteAvatarFlag');
        if (deleteFlag) deleteFlag.value = 'false';

        const previewImg = document.getElementById('avatarImagePreview');
        const placeholder = document.getElementById('avatarPlaceholderPreview');
        const deleteBtn = document.getElementById('btnDeleteAvatar');

        if (previewImg && placeholder) {
            if (initialProfileData.hasAvatar) {
                previewImg.src = initialProfileData.avatarSrc;
                previewImg.classList.remove('d-none');
                placeholder.classList.add('d-none');
            } else {
                previewImg.src = '';
                previewImg.classList.add('d-none');
                placeholder.classList.remove('d-none');
            }
        }
        if (deleteBtn) {
            if (initialProfileData.deleteBtnVisible) {
                deleteBtn.classList.remove('d-none');
            } else {
                deleteBtn.classList.add('d-none');
            }
        }
    }

    // Khóa lại các input
    const editableInputs = form.querySelectorAll('#fullName, #displayName, #phone, #birthDate, input[name="gender"], #language');
    editableInputs.forEach(input => {
        input.setAttribute('disabled', 'disabled');
        input.disabled = true;
    });

    // Khóa lại các nút avatar
    const btnUploadAvatar = document.getElementById('btnUploadAvatar');
    const btnDeleteAvatar = document.getElementById('btnDeleteAvatar');
    if (btnUploadAvatar) {
        btnUploadAvatar.setAttribute('disabled', 'disabled');
        btnUploadAvatar.disabled = true;
    }
    if (btnDeleteAvatar) {
        btnDeleteAvatar.setAttribute('disabled', 'disabled');
        btnDeleteAvatar.disabled = true;
    }

    form.classList.remove('profile-edit-mode');
    form.classList.add('profile-view-mode');

    // Khôi phục các nút header
    const btnEditTop = document.getElementById('btnEditProfileTop');
    const btnCancelTop = document.getElementById('btnCancelEditTop');
    const btnSaveTop = document.getElementById('btnSaveProfileTop');
    const badge = document.getElementById('editStatusBadge');
    if (btnEditTop) btnEditTop.classList.remove('d-none');
    if (btnCancelTop) btnCancelTop.classList.add('d-none');
    if (btnSaveTop) btnSaveTop.classList.add('d-none');
    if (badge) badge.classList.add('d-none');

    // Khôi phục các nút bottom action bar
    const btnEditBottom = document.getElementById('btnEditProfileBottom');
    const btnCancelBottom = document.getElementById('btnCancelEditBottom');
    const btnSaveBottom = document.getElementById('btnSaveProfileBottom');
    const hint = document.getElementById('actionBarHint');
    if (btnEditBottom) btnEditBottom.style.display = 'inline-block';
    if (btnCancelBottom) btnCancelBottom.style.display = 'none';
    if (btnSaveBottom) btnSaveBottom.style.display = 'none';
    if (hint) {
        hint.innerHTML = '<i class="bi bi-info-circle text-success me-1"></i> Nhấn <strong>"Sửa thông tin"</strong> để thay đổi thông tin cá nhân của bạn.';
    }
}

function submitProfileForm() {
    const form = document.getElementById('profileMainForm');
    if (!form) return;

    // Đảm bảo mở disabled để trình duyệt serialize gửi đầy đủ các trường
    const editableInputs = form.querySelectorAll('#fullName, #displayName, #phone, #birthDate, input[name="gender"], #language');
    editableInputs.forEach(input => {
        input.removeAttribute('disabled');
        input.disabled = false;
    });

    if (typeof form.requestSubmit === 'function') {
        form.requestSubmit();
    } else {
        form.submit();
    }
}

function handleAvatarFileSelect(input) {
    if (input && input.files && input.files[0]) {
        const file = input.files[0];
        const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
        if (!validTypes.includes(file.type)) {
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
            const deleteBtn = document.getElementById('btnDeleteAvatar');

            if (previewImg) {
                previewImg.src = e.target.result;
                previewImg.classList.remove('d-none');
            }
            if (placeholder) {
                placeholder.classList.add('d-none');
            }
            if (deleteBtn) {
                deleteBtn.classList.remove('d-none');
                deleteBtn.removeAttribute('disabled');
                deleteBtn.disabled = false;
            }

            const deleteFlag = document.getElementById('deleteAvatarFlag');
            if (deleteFlag) deleteFlag.value = 'false';
        };
        reader.readAsDataURL(file);
    }
}

function handleStageDeleteAvatar() {
    const deleteFlag = document.getElementById('deleteAvatarFlag');
    if (deleteFlag) deleteFlag.value = 'true';

    const fileInput = document.getElementById('avatarFileInput');
    if (fileInput) fileInput.value = '';

    const previewImg = document.getElementById('avatarImagePreview');
    const placeholder = document.getElementById('avatarPlaceholderPreview');
    const deleteBtn = document.getElementById('btnDeleteAvatar');

    if (previewImg) previewImg.classList.add('d-none');
    if (placeholder) placeholder.classList.remove('d-none');
    if (deleteBtn) deleteBtn.classList.add('d-none');
}

function submitAvatarForm() {
    // Tương thích ngược nếu còn lời gọi cũ
    const fileInput = document.getElementById('avatarFileInput');
    if (fileInput) handleAvatarFileSelect(fileInput);
}

function confirmDeleteAvatar() {
    // Tương thích ngược nếu còn lời gọi cũ
    handleStageDeleteAvatar();
}

document.addEventListener('DOMContentLoaded', function() {
    captureInitialProfileData();

    const profileMainForm = document.getElementById('profileMainForm');
    if (profileMainForm) {
        profileMainForm.addEventListener('submit', function() {
            const editableInputs = this.querySelectorAll('#fullName, #displayName, #phone, #birthDate, input[name="gender"], #language');
            editableInputs.forEach(input => {
                input.removeAttribute('disabled');
                input.disabled = false;
            });
        });
    }
    const hash = window.location.hash;
    if (hash === '#security') {
        activateTab('#nav-security', 'nav-security-tab');
    } else if (hash === '#orders') {
        activateTab('#nav-orders', 'nav-orders-tab');
    } else if (hash === '#vouchers') {
        activateTab('#nav-vouchers', 'nav-vouchers-tab');
    } else if (hash === '#notifications') {
        activateTab('#nav-notifications', 'nav-notifications-tab');
    } else if (hash === '#address') {
        activateTab('#nav-address', 'nav-address-tab');
    } else {
        activateTab('#nav-profile', 'nav-profile-tab');
    }

    document.querySelectorAll('#profileSidebarTab button[data-bs-target]').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('data-bs-target');
            activateTab(targetId, this.id);
        });
    });

    const citySelect = document.getElementById('citySelect');
    const districtSelect = document.getElementById('districtSelect');
    const wardSelect = document.getElementById('wardSelect');
    const addAddressModalEl = document.getElementById('addAddressModal');

    const fallbackProvinces = [
        {"name":"Thành phố Hà Nội","code":1},
        {"name":"Thành phố Hồ Chí Minh","code":79},
        {"name":"Thành phố Đà Nẵng","code":48},
        {"name":"Thành phố Hải Phòng","code":31},
        {"name":"Thành phố Cần Thơ","code":92},
        {"name":"Tỉnh An Giang","code":89},
        {"name":"Tỉnh Bà Rịa - Vũng Tàu","code":77},
        {"name":"Tỉnh Bắc Giang","code":24},
        {"name":"Tỉnh Bắc Kạn","code":6},
        {"name":"Tỉnh Bạc Liêu","code":95},
        {"name":"Tỉnh Bắc Ninh","code":27},
        {"name":"Tỉnh Bến Tre","code":83},
        {"name":"Tỉnh Bình Định","code":52},
        {"name":"Tỉnh Bình Dương","code":74},
        {"name":"Tỉnh Bình Phước","code":70},
        {"name":"Tỉnh Bình Thuận","code":60},
        {"name":"Tỉnh Cà Mau","code":96},
        {"name":"Tỉnh Cao Bằng","code":4},
        {"name":"Tỉnh Đắk Lắk","code":66},
        {"name":"Tỉnh Đắk Nông","code":67},
        {"name":"Tỉnh Điện Biên","code":11},
        {"name":"Tỉnh Đồng Nai","code":75},
        {"name":"Tỉnh Đồng Tháp","code":87},
        {"name":"Tỉnh Gia Lai","code":64},
        {"name":"Tỉnh Hà Giang","code":2},
        {"name":"Tỉnh Hà Nam","code":35},
        {"name":"Tỉnh Hà Tĩnh","code":42},
        {"name":"Tỉnh Hải Dương","code":30},
        {"name":"Tỉnh Hậu Giang","code":93},
        {"name":"Tỉnh Hòa Bình","code":17},
        {"name":"Tỉnh Hưng Yên","code":33},
        {"name":"Tỉnh Khánh Hòa","code":56},
        {"name":"Tỉnh Kiên Giang","code":91},
        {"name":"Tỉnh Kon Tum","code":62},
        {"name":"Tỉnh Lai Châu","code":12},
        {"name":"Tỉnh Lâm Đồng","code":68},
        {"name":"Tỉnh Lạng Sơn","code":20},
        {"name":"Tỉnh Lào Cai","code":10},
        {"name":"Tỉnh Long An","code":80},
        {"name":"Tỉnh Nam Định","code":36},
        {"name":"Tỉnh Nghệ An","code":40},
        {"name":"Tỉnh Ninh Bình","code":37},
        {"name":"Tỉnh Ninh Thuận","code":58},
        {"name":"Tỉnh Phú Thọ","code":25},
        {"name":"Tỉnh Phú Yên","code":54},
        {"name":"Tỉnh Quảng Bình","code":44},
        {"name":"Tỉnh Quảng Nam","code":49},
        {"name":"Tỉnh Quảng Ngãi","code":51},
        {"name":"Tỉnh Quảng Ninh","code":22},
        {"name":"Tỉnh Quảng Trị","code":45},
        {"name":"Tỉnh Sóc Trăng","code":94},
        {"name":"Tỉnh Sơn La","code":14},
        {"name":"Tỉnh Tây Ninh","code":72},
        {"name":"Tỉnh Thái Bình","code":34},
        {"name":"Tỉnh Thái Nguyên","code":19},
        {"name":"Tỉnh Thanh Hóa","code":38},
        {"name":"Thành phố Huế","code":46},
        {"name":"Tỉnh Tiền Giang","code":82},
        {"name":"Tỉnh Trà Vinh","code":84},
        {"name":"Tỉnh Tuyên Quang","code":8},
        {"name":"Tỉnh Vĩnh Long","code":86},
        {"name":"Tỉnh Vĩnh Phúc","code":26},
        {"name":"Tỉnh Yên Bái","code":15}
    ];

    async function initProvinces() {
        if (!citySelect) return;
        let list = [];
        try {
            const ctx = window.contextPath || '';
            const res = await fetch(ctx + '/api/address/provinces');
            if (!res.ok) throw new Error();
            list = await res.json();
        } catch (e) {
            list = fallbackProvinces;
        }
        citySelect.innerHTML = '<option value="" selected disabled>Chọn Tỉnh / Thành phố</option>';
        list.forEach(p => {
            const opt = document.createElement('option');
            opt.value = p.name;
            opt.textContent = p.name;
            opt.dataset.code = p.code;
            citySelect.appendChild(opt);
        });
    }

    if (citySelect) {
        citySelect.addEventListener('change', async function() {
            const selectedOpt = citySelect.options[citySelect.selectedIndex];
            const pCode = selectedOpt.dataset.code;
            districtSelect.disabled = true;
            districtSelect.innerHTML = '<option value="" selected disabled>Đang tải danh sách...</option>';
            wardSelect.disabled = true;
            wardSelect.innerHTML = '<option value="" selected disabled>Chọn Phường / Xã</option>';

            if (!pCode) return;
            try {
                const ctx = window.contextPath || '';
                const res = await fetch(ctx + '/api/address/districts?provinceCode=' + encodeURIComponent(pCode));
                if (!res.ok) throw new Error();
                const data = await res.json();
                districtSelect.innerHTML = '<option value="" selected disabled>Chọn Quận / Huyện</option>';
                data.districts.forEach(d => {
                    const opt = document.createElement('option');
                    opt.value = d.name;
                    opt.textContent = d.name;
                    opt.dataset.code = d.code;
                    districtSelect.appendChild(opt);
                });
                districtSelect.disabled = false;
            } catch (e) {
                districtSelect.innerHTML = '<option value="" selected disabled>Chọn Quận / Huyện</option>';
                districtSelect.disabled = false;
            }
        });
    }

    if (districtSelect) {
        districtSelect.addEventListener('change', async function() {
            const selectedOpt = districtSelect.options[districtSelect.selectedIndex];
            const dCode = selectedOpt.dataset.code;
            wardSelect.disabled = true;
            wardSelect.innerHTML = '<option value="" selected disabled>Đang tải danh sách...</option>';

            if (!dCode) return;
            try {
                const ctx = window.contextPath || '';
                const res = await fetch(ctx + '/api/address/wards?districtCode=' + encodeURIComponent(dCode));
                if (!res.ok) throw new Error();
                const data = await res.json();
                wardSelect.innerHTML = '<option value="" selected disabled>Chọn Phường / Xã</option>';
                data.wards.forEach(w => {
                    const opt = document.createElement('option');
                    opt.value = w.name;
                    opt.textContent = w.name;
                    wardSelect.appendChild(opt);
                });
                wardSelect.disabled = false;
            } catch (e) {
                wardSelect.innerHTML = '<option value="" selected disabled>Chọn Phường / Xã</option>';
                wardSelect.disabled = false;
            }
        });
    }

    if (addAddressModalEl) {
        addAddressModalEl.addEventListener('show.bs.modal', function() {
            if (citySelect && citySelect.options.length <= 1) {
                initProvinces();
            }
        });
    }

    updateOrderCounts();
});

function isOrderToPay(s, payStatus, payMethod) {
    if (s === 'CANCELLED' || s === 'CANCELED' || s === 'COMPLETED' || s === 'DELIVERED') return false;
    return s === 'PENDING' || s === 'UNPAID' || (payStatus === 'PENDING' && payMethod !== 'COD');
}

function isOrderToShip(s, payStatus, payMethod) {
    if (s === 'CANCELLED' || s === 'CANCELED' || s === 'COMPLETED' || s === 'DELIVERED') return false;
    if (isOrderToPay(s, payStatus, payMethod)) return false;
    return s === 'CONFIRMED' || s === 'PROCESSING' || s === 'PREPARING' || s === 'NEW' || s === 'PACKED' || s === 'READY_TO_SHIP';
}

function isOrderShipping(s) {
    return s === 'SHIPPING' || s === 'DELIVERING' || s === 'IN_TRANSIT';
}

function isOrderCompleted(s) {
    return s === 'COMPLETED' || s === 'DELIVERED' || s === 'SUCCESS';
}

function isOrderCancelled(s) {
    return s === 'CANCELLED' || s === 'CANCELED';
}

function isOrderReturned(s) {
    return s === 'RETURNED' || s === 'REFUNDED' || s === 'DISPUTED';
}

function updateOrderCounts() {
    const cards = document.querySelectorAll('#ordersContainer .shopee-order-card');
    
    let toPayCount = 0;
    let toShipCount = 0;
    let shippingCount = 0;
    let completedCount = 0;
    let cancelledCount = 0;
    let returnedCount = 0;

    cards.forEach(card => {
        const s = (card.getAttribute('data-order-status') || '').toUpperCase();
        const payStatus = (card.getAttribute('data-payment-status') || '').toUpperCase();
        const payMethod = (card.getAttribute('data-payment-method') || '').toUpperCase();

        if (isOrderToPay(s, payStatus, payMethod)) {
            toPayCount++;
        } else if (isOrderToShip(s, payStatus, payMethod)) {
            toShipCount++;
        } else if (isOrderShipping(s)) {
            shippingCount++;
        } else if (isOrderCompleted(s)) {
            completedCount++;
        } else if (isOrderCancelled(s)) {
            cancelledCount++;
        } else if (isOrderReturned(s)) {
            returnedCount++;
        }
    });

    const setTabCount = (id, count) => {
        const el = document.getElementById(id);
        if (el) {
            el.textContent = count > 0 ? ` (${count})` : '';
        }
    };

    setTabCount('count-topay', toPayCount);
    setTabCount('count-toship', toShipCount);
    setTabCount('count-shipping', shippingCount);
    setTabCount('count-completed', completedCount);
    setTabCount('count-cancelled', cancelledCount);
    setTabCount('count-returned', returnedCount);

    const headerCount = document.getElementById('headerTotalOrdersCount');
    if (headerCount) {
        headerCount.textContent = cards.length;
    }
}

function filterOrders(filter, btn) {
    document.querySelectorAll('.order-filter-btn').forEach(b => b.classList.remove('active'));
    if (btn) btn.classList.add('active');

    const searchInput = document.getElementById('orderSearchInput');
    const kw = searchInput ? (searchInput.value || '').trim().toLowerCase() : '';

    const cards = document.querySelectorAll('#ordersContainer .shopee-order-card');
    let visibleCount = 0;

    cards.forEach(card => {
        const s = (card.getAttribute('data-order-status') || '').toUpperCase();
        const payStatus = (card.getAttribute('data-payment-status') || '').toUpperCase();
        const payMethod = (card.getAttribute('data-payment-method') || '').toUpperCase();

        let tabMatch = false;
        if (filter === 'all') {
            tabMatch = true;
        } else if (filter === 'to-pay' || filter === 'pending') {
            tabMatch = isOrderToPay(s, payStatus, payMethod);
        } else if (filter === 'to-ship' || filter === 'processing') {
            tabMatch = isOrderToShip(s, payStatus, payMethod);
        } else if (filter === 'shipping') {
            tabMatch = isOrderShipping(s);
        } else if (filter === 'completed' || filter === 'delivered') {
            tabMatch = isOrderCompleted(s);
        } else if (filter === 'cancelled') {
            tabMatch = isOrderCancelled(s);
        } else if (filter === 'returned') {
            tabMatch = isOrderReturned(s);
        }

        if (tabMatch) {
            const orderId = (card.getAttribute('data-order-id') || '').toLowerCase();
            const shopName = (card.getAttribute('data-shop-name') || '').toLowerCase();
            const cardText = card.innerText.toLowerCase();

            if (!kw || orderId.includes(kw) || shopName.includes(kw) || cardText.includes(kw)) {
                card.style.display = 'block';
                visibleCount++;
            } else {
                card.style.display = 'none';
            }
        } else {
            card.style.display = 'none';
        }
    });

    const emptyFilterBox = document.getElementById('ordersEmptyFilter');
    if (emptyFilterBox) {
        if (visibleCount === 0) {
            emptyFilterBox.classList.remove('d-none');
        } else {
            emptyFilterBox.classList.add('d-none');
        }
    }
}

function searchOrders(keyword) {
    const kw = (keyword || '').trim().toLowerCase();
    const activeBtn = document.querySelector('.order-filter-btn.active');
    const currentFilter = activeBtn ? (activeBtn.getAttribute('data-filter') || 'all') : 'all';

    const cards = document.querySelectorAll('#ordersContainer .shopee-order-card');
    let visibleCount = 0;

    cards.forEach(card => {
        const s = (card.getAttribute('data-order-status') || '').toUpperCase();
        const payStatus = (card.getAttribute('data-payment-status') || '').toUpperCase();
        const payMethod = (card.getAttribute('data-payment-method') || '').toUpperCase();

        let tabMatch = false;
        if (currentFilter === 'all') {
            tabMatch = true;
        } else if (currentFilter === 'to-pay' || currentFilter === 'pending') {
            tabMatch = isOrderToPay(s, payStatus, payMethod);
        } else if (currentFilter === 'to-ship' || currentFilter === 'processing') {
            tabMatch = isOrderToShip(s, payStatus, payMethod);
        } else if (currentFilter === 'shipping') {
            tabMatch = isOrderShipping(s);
        } else if (currentFilter === 'completed' || currentFilter === 'delivered') {
            tabMatch = isOrderCompleted(s);
        } else if (currentFilter === 'cancelled') {
            tabMatch = isOrderCancelled(s);
        } else if (currentFilter === 'returned') {
            tabMatch = isOrderReturned(s);
        }

        if (!tabMatch) {
            card.style.display = 'none';
            return;
        }

        const orderId = (card.getAttribute('data-order-id') || '').toLowerCase();
        const shopName = (card.getAttribute('data-shop-name') || '').toLowerCase();
        const cardText = card.innerText.toLowerCase();

        if (!kw || orderId.includes(kw) || shopName.includes(kw) || cardText.includes(kw)) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });

    const emptyFilterBox = document.getElementById('ordersEmptyFilter');
    if (emptyFilterBox) {
        if (visibleCount === 0) {
            emptyFilterBox.classList.remove('d-none');
        } else {
            emptyFilterBox.classList.add('d-none');
        }
    }
}

function openChatShop(shopName) {
    alert('Đang mở khung chat trực tiếp với gian hàng: ' + (shopName || 'Gốc Vườn Shop') + '. Nhân viên tư vấn đang kết nối...');
}

function openReturnModal(orderId) {
    const reason = prompt('Nhập lý do yêu cầu Trả hàng / Hoàn tiền cho đơn hàng #' + orderId + ':', 'Trái cây dập hỏng do vận chuyển');
    if (reason && reason.trim() !== '') {
        alert('Yêu cầu Trả hàng/Hoàn tiền cho đơn #' + orderId + ' đã được gửi thành công. Shop sẽ phản hồi trong 24 giờ.');
    }
}

function confirmReceivedOrder(orderId) {
    if (confirm('Bạn xác nhận đã nhận được đầy đủ hoa quả của đơn hàng #' + orderId + ' và không có vấn đề gì?')) {
        alert('Cảm ơn bạn! Đơn hàng #' + orderId + ' đã được cập nhật sang trạng thái Hoàn thành. Hãy để lại đánh giá nhé!');
        location.reload();
    }
}

function trackDelivery(orderId) {
    showOrderTracking(orderId);
}

function formatVND(amount) {
    if (amount === undefined || amount === null || amount === '') return '0₫';
    if (typeof amount === 'string') {
        const cleaned = amount.replace(/[^\d.-]/g, '');
        const parsed = parseFloat(cleaned);
        if (!isNaN(parsed)) {
            return new Intl.NumberFormat('vi-VN').format(Math.round(parsed)) + '₫';
        }
    }
    const num = Number(amount) || 0;
    return new Intl.NumberFormat('vi-VN').format(Math.round(num)) + '₫';
}

function showOrderTracking(orderId) {
    if (!orderId) return;

    const card = document.querySelector('.shopee-order-card[data-order-id="' + orderId + '"]');
    if (!card) {
        console.warn('Order card not found for ID: ' + orderId);
        return;
    }

    const status = (card.getAttribute('data-order-status') || 'PENDING').toUpperCase();
    const shopName = card.getAttribute('data-shop-name') || 'Gian hàng nông sản FreshFruit';
    const createdAt = card.getAttribute('data-created-at') || '';
    const cancelReason = card.getAttribute('data-cancel-reason') || 'Người mua hủy đơn trực tiếp';
    const deliverySlot = card.getAttribute('data-delivery-slot') || '';
    const recipientName = card.getAttribute('data-recipient-name') || 'Người nhận';
    const recipientPhone = card.getAttribute('data-recipient-phone') || '0903 *** ***';
    const recipientAddress = card.getAttribute('data-recipient-address') || 'Địa chỉ giao hàng';
    const goodsAmount = card.getAttribute('data-goods-amount') || 0;
    const shippingFee = card.getAttribute('data-shipping-fee') || 0;
    const discount = card.getAttribute('data-discount') || 0;
    const finalAmount = card.getAttribute('data-final-amount') || goodsAmount;
    const paymentMethod = (card.getAttribute('data-payment-method') || 'COD').toUpperCase();

    // 1. Header Order Code & Date
    const orderCodeEl = document.getElementById('trackOrderCode') || document.getElementById('trackModalOrderCode');
    if (orderCodeEl) orderCodeEl.textContent = '#' + orderId;

    const orderDateEl = document.getElementById('trackModalOrderDate');
    if (orderDateEl) orderDateEl.textContent = createdAt ? createdAt : 'Vừa xong';

    // Status Badge in Header
    const statusBadge = document.getElementById('trackStatusBadge');
    if (statusBadge) {
        if (status === 'CANCELLED' || status === 'CANCELED') {
            statusBadge.textContent = 'ĐÃ HỦY';
            statusBadge.className = 'badge bg-danger-subtle text-danger px-3 py-1 rounded-pill fw-bold border border-danger-subtle';
        } else if (status === 'COMPLETED' || status === 'DELIVERED' || status === 'SUCCESS') {
            statusBadge.textContent = 'GIAO THÀNH CÔNG';
            statusBadge.className = 'badge bg-success-subtle text-success px-3 py-1 rounded-pill fw-bold border border-success-subtle';
        } else if (status === 'SHIPPING' || status === 'DELIVERING' || status === 'IN_TRANSIT') {
            statusBadge.textContent = 'ĐANG GIAO HÀNG';
            statusBadge.className = 'badge bg-primary-subtle text-primary px-3 py-1 rounded-pill fw-bold border border-primary-subtle';
        } else if (status === 'CONFIRMED' || status === 'PROCESSING' || status === 'PREPARING' || status === 'NEW' || status === 'PACKED' || status === 'READY_TO_SHIP') {
            statusBadge.textContent = 'ĐANG CHUẨN BỊ HÀNG';
            statusBadge.className = 'badge bg-info-subtle text-info px-3 py-1 rounded-pill fw-bold border border-info-subtle';
        } else {
            statusBadge.textContent = 'CHỜ THANH TOÁN';
            statusBadge.className = 'badge bg-warning-subtle text-warning px-3 py-1 rounded-pill fw-bold border border-warning-subtle';
        }
    }

    // 2. Recipient info
    const recNameEl = document.getElementById('trackRecipientName');
    if (recNameEl) recNameEl.textContent = recipientName;

    const recPhoneEl = document.getElementById('trackRecipientPhone');
    if (recPhoneEl) recPhoneEl.textContent = recipientPhone;

    const recAddrEl = document.getElementById('trackRecipientAddress');
    if (recAddrEl) recAddrEl.textContent = recipientAddress;

    const noteEl = document.getElementById('trackNoteText');
    if (noteEl) {
        noteEl.textContent = deliverySlot ? ('Khung giờ giao đã chọn: ' + deliverySlot) : 'Đóng thùng cách nhiệt chuỗi lạnh FreshCold tiêu chuẩn.';
    }

    const destNameEl = document.getElementById('trackMapDestName');
    if (destNameEl) {
        const parts = recipientAddress.split(',');
        destNameEl.textContent = parts[0] ? parts[0].trim() : 'Điểm giao hàng';
    }

    const mapShopNameEl = document.getElementById('trackMapShopName');
    if (mapShopNameEl) mapShopNameEl.textContent = shopName;

    // 3. Payment amounts
    const goodsSubtotalEl = document.getElementById('trackGoodsSubtotal');
    if (goodsSubtotalEl) goodsSubtotalEl.textContent = formatVND(goodsAmount);

    const shipFeeEl = document.getElementById('trackShippingFee');
    if (shipFeeEl) shipFeeEl.textContent = formatVND(shippingFee);

    const discountEl = document.getElementById('trackVoucherDiscount');
    if (discountEl) discountEl.textContent = '-' + formatVND(discount);

    const finalTotalEl = document.getElementById('trackFinalTotal');
    if (finalTotalEl) finalTotalEl.textContent = formatVND(finalAmount);

    const payMethodBadge = document.getElementById('trackPaymentMethodBadge');
    if (payMethodBadge) {
        if (paymentMethod === 'VNPAY') {
            payMethodBadge.textContent = 'VNPAY QR';
            payMethodBadge.className = 'badge bg-primary-subtle text-primary border fw-semibold';
        } else if (paymentMethod === 'WALLET') {
            payMethodBadge.textContent = 'Ví Gốc Vườn Pay';
            payMethodBadge.className = 'badge bg-success-subtle text-success border fw-semibold';
        } else {
            payMethodBadge.textContent = 'Thu hộ tiền mặt (COD)';
            payMethodBadge.className = 'badge bg-light text-dark border fw-semibold';
        }
    }

    // 4. Populate Items
    const itemsContainer = document.getElementById('trackItemsContainer');
    const itemCountEl = document.getElementById('trackItemCount');
    if (itemsContainer) {
        itemsContainer.innerHTML = '';
        const itemRows = card.querySelectorAll('.shopee-item-row');
        if (itemCountEl) itemCountEl.textContent = itemRows.length;

        itemRows.forEach(row => {
            const img = row.querySelector('.shopee-item-thumb');
            const imgSrc = img ? img.getAttribute('src') : 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop';
            const title = row.querySelector('.shopee-item-title') ? row.querySelector('.shopee-item-title').textContent.trim() : 'Sản phẩm';
            const variant = row.querySelector('.shopee-item-variant') ? row.querySelector('.shopee-item-variant').textContent.trim() : '';
            const qty = row.querySelector('.shopee-item-qty') ? row.querySelector('.shopee-item-qty').textContent.trim() : 'x1';
            const price = row.querySelector('.shopee-price-current') ? row.querySelector('.shopee-price-current').textContent.trim() : '0₫';

            const itemDiv = document.createElement('div');
            itemDiv.className = 'tracking-item-card';
            itemDiv.innerHTML = `
                <img src="${imgSrc}" alt="${title}" onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop';">
                <div class="tracking-item-info">
                    <div class="tracking-item-name">${title}</div>
                    <div class="tracking-item-variant">${variant} &bull; <strong class="text-dark">${qty}</strong></div>
                </div>
                <div class="tracking-item-price">${price}</div>
            `;
            itemsContainer.appendChild(itemDiv);
        });
    }

    // 5. Adapt Stepper, Times and Cards depending on Status
    const estTimeEl = document.getElementById('trackEstimatedTime');
    const gpsCard = document.getElementById('trackGpsCard');
    const driverCard = document.getElementById('trackDriverCard');
    const prepCard = document.getElementById('trackPreparingCard');
    const cancelCard = document.getElementById('trackCancelledCard');
    const cancelReasonEl = document.getElementById('trackCancelReason');

    const step1 = document.getElementById('trackStep1');
    const step2 = document.getElementById('trackStep2');
    const step3 = document.getElementById('trackStep3');
    const step4 = document.getElementById('trackStep4');
    const step5 = document.getElementById('trackStep5');
    const step6 = document.getElementById('trackStep6');

    const line1 = document.getElementById('trackLine1');
    const line2 = document.getElementById('trackLine2');
    const line3 = document.getElementById('trackLine3');
    const line4 = document.getElementById('trackLine4');
    const line5 = document.getElementById('trackLine5');

    const time1 = document.getElementById('trackTime1');
    const time2 = document.getElementById('trackTime2');
    const time3 = document.getElementById('trackTime3');
    const time4 = document.getElementById('trackTime4');
    const time5 = document.getElementById('trackTime5');
    const time6 = document.getElementById('trackTime6');

    let orderHour = 'Vừa xong';
    if (createdAt) {
        const parts = createdAt.trim().split(' ');
        orderHour = parts.length > 1 ? parts[1] : parts[0];
    }
    if (time1) time1.textContent = orderHour;

    // Reset all steps to initial pristine state
    const defaultSteps = [
        { el: step1, icon: 'bi-check-lg', title: '\u0110\u1eb7t h\u00e0ng', time: orderHour },
        { el: step2, icon: 'bi-shop', title: 'Shop x\u00e1c nh\u1eadn', time: 'Ch\u1edd x\u1eed l\u00fd' },
        { el: step3, icon: 'bi-box-seam', title: '\u0110\u00f3ng g\u00f3i qu\u1ea3 t\u01b0\u01a1i', time: 'Ch\u1edd x\u1eed l\u00fd' },
        { el: step4, icon: 'bi-person-badge', title: 'T\u00e0i x\u1ebf nh\u1eadn h\u00e0ng', time: 'Ch\u01b0a b\u00e0n giao' },
        { el: step5, icon: 'bi-truck', title: '\u0110ang giao h\u00e0ng', time: 'Ch\u1edd v\u1eadn chuy\u1ec3n' },
        { el: step6, icon: 'bi-house-check', title: '\u0110\u00e3 giao h\u00e0ng', time: 'Ch\u1edd ho\u00e0n t\u1ea5t' }
    ];

    defaultSteps.forEach(def => {
        if (def.el) {
            def.el.className = 'stepper-step';
            const c = def.el.querySelector('.stepper-circle');
            if (c) {
                c.className = 'stepper-circle';
                c.innerHTML = '<i class="bi ' + def.icon + '"></i>';
            }
            const t = def.el.querySelector('.stepper-title');
            if (t) t.textContent = def.title;
            const timeEl = def.el.querySelector('.stepper-time');
            if (timeEl) timeEl.textContent = def.time;
        }
    });
    [line1, line2, line3, line4, line5].forEach(l => {
        if (l) l.className = 'stepper-line';
    });

    if (status === 'CANCELLED' || status === 'CANCELED') {
        if (estTimeEl) {
            estTimeEl.textContent = '\u0110\u01a1n h\u00e0ng \u0111\u00e3 \u0111\u01b0\u1ee3c h\u1ee7y';
            estTimeEl.className = 'small fw-semibold text-danger bg-danger-subtle px-3 py-1 rounded-pill border border-danger-subtle';
        }
        if (step1) step1.classList.add('completed');
        if (line1) line1.classList.add('completed');
        if (step2) {
            step2.className = 'stepper-step cancelled';
            const c = step2.querySelector('.stepper-circle');
            if (c) c.innerHTML = '<i class="bi bi-x-lg"></i>';
            const t = step2.querySelector('.stepper-title');
            if (t) t.textContent = '\u0110\u00e3 h\u1ee7y \u0111\u01a1n';
            if (time2) time2.textContent = '\u0110\u00e3 h\u1ee7y';
        }
        if (time3) time3.textContent = '--:--';
        if (time4) time4.textContent = '--:--';
        if (time5) time5.textContent = '--:--';
        if (time6) time6.textContent = '--:--';

        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'none';
        if (prepCard) prepCard.classList.add('d-none');
        if (cancelCard) {
            cancelCard.classList.remove('d-none');
            if (cancelReasonEl) cancelReasonEl.textContent = 'L\u00fd do h\u1ee7y: ' + (cancelReason || 'Ng\u01b0\u1eddi mua h\u1ee7y \u0111\u01a1n tr\u1ef1c ti\u1ebfp');
        }
    } else if (status === 'FAILED' || status === 'RETURNED' || status === 'DELIVERY_FAILED') {
        if (estTimeEl) {
            estTimeEl.textContent = 'Giao h\u00e0ng kh\u00f4ng th\u00e0nh c\u00f4ng / Ho\u00e0n h\u00e0ng';
            estTimeEl.className = 'small fw-semibold text-danger bg-danger-subtle px-3 py-1 rounded-pill border border-danger-subtle';
        }
        [step1, step2, step3, step4, step5].forEach(s => s && s.classList.add('completed'));
        [line1, line2, line3, line4, line5].forEach(l => l && l.classList.add('completed'));
        if (time2) time2.textContent = '\u0110\u00e3 x\u00e1c nh\u1eadn';
        if (time3) time3.textContent = '\u0110\u00e3 \u0111\u00f3ng g\u00f3i';
        if (time4) time4.textContent = '\u0110\u00e3 b\u00e0n giao';
        if (time5) time5.textContent = '\u0110\u00e3 chuy\u1ec3n h\u00e0ng';
        if (time6) time6.textContent = 'Giao th\u1ea5t b\u1ea1i';

        if (step6) {
            step6.className = 'stepper-step cancelled';
            const c = step6.querySelector('.stepper-circle');
            if (c) c.innerHTML = '<i class="bi bi-x-lg"></i>';
            const t = step6.querySelector('.stepper-title');
            if (t) t.textContent = 'Giao th\u1ea5t b\u1ea1i';
        }

        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'block';
        if (prepCard) prepCard.classList.add('d-none');
        if (cancelCard) {
            cancelCard.classList.remove('d-none');
            if (cancelReasonEl) cancelReasonEl.textContent = 'L\u00fd do giao th\u1ea5t b\u1ea1i: ' + (cancelReason || 'Kh\u00e1ch t\u1eeb ch\u1ed1i nh\u1eadn hoa qu\u1ea3 t\u01b0\u01a1i ho\u1eb7c giao kh\u00f4ng th\u00e0nh c\u00f4ng');
        }
    } else if (status === 'COMPLETED' || status === 'DELIVERED' || status === 'SUCCESS') {
        if (estTimeEl) {
            estTimeEl.textContent = 'Giao h\u00e0ng th\u00e0nh c\u00f4ng';
            estTimeEl.className = 'small fw-semibold text-success bg-success-subtle px-3 py-1 rounded-pill border border-success-subtle';
        }
        [step1, step2, step3, step4, step5, step6].forEach(s => s && s.classList.add('completed'));
        [line1, line2, line3, line4, line5].forEach(l => l && l.classList.add('completed'));
        if (time2) time2.textContent = '\u0110\u00e3 x\u00e1c nh\u1eadn';
        if (time3) time3.textContent = '\u0110\u00e3 \u0111\u00f3ng g\u00f3i';
        if (time4) time4.textContent = '\u0110\u00e3 b\u00e0n giao';
        if (time5) time5.textContent = '\u0110\u00e3 chuy\u1ec3n h\u00e0ng';
        if (time6) time6.textContent = '\u0110\u00e3 nh\u1eadn qu\u1ea3 t\u01b0\u01a1i';

        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'block';
        if (prepCard) prepCard.classList.add('d-none');
        if (cancelCard) cancelCard.classList.add('d-none');
    } else if (status === 'SHIPPING' || status === 'DELIVERING' || status === 'IN_TRANSIT') {
        if (estTimeEl) {
            estTimeEl.textContent = '\u0110ang giao chu\u1ed7i l\u1ea1nh FreshCold';
            estTimeEl.className = 'small fw-semibold text-success bg-success-subtle px-3 py-1 rounded-pill border border-success-subtle';
        }
        [step1, step2, step3, step4].forEach(s => s && s.classList.add('completed'));
        [line1, line2, line3, line4].forEach(l => l && l.classList.add('completed'));
        if (time2) time2.textContent = '\u0110\u00e3 x\u00e1c nh\u1eadn';
        if (time3) time3.textContent = '\u0110\u00e3 \u0111\u00f3ng g\u00f3i';
        if (time4) time4.textContent = '\u0110\u00e3 l\u1ea5y h\u00e0ng';
        if (time5) time5.textContent = '\u0110ang giao...';
        if (time6) time6.textContent = 'Ch\u1edd nh\u1eadn h\u00e0ng';

        if (step5) {
            step5.className = 'stepper-step active';
            const c = step5.querySelector('.stepper-circle');
            if (c) c.classList.add('pulse');
        }
        if (line5) line5.className = 'stepper-line active';

        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'block';
        if (prepCard) prepCard.classList.add('d-none');
        if (cancelCard) cancelCard.classList.add('d-none');
    } else if (status === 'NEW') {
        if (estTimeEl) {
            estTimeEl.textContent = '\u0110ang ch\u1edd shop x\u00e1c nh\u1eadn \u0111\u01a1n';
            estTimeEl.className = 'small fw-semibold text-warning bg-warning-subtle px-3 py-1 rounded-pill border border-warning-subtle';
        }
        if (step1) step1.classList.add('completed');
        if (line1) line1.className = 'stepper-line active';

        if (step2) {
            step2.className = 'stepper-step active';
            const c = step2.querySelector('.stepper-circle');
            if (c) {
                c.className = 'stepper-circle pulse';
                c.innerHTML = '<i class="bi bi-shop"></i>';
            }
            const t = step2.querySelector('.stepper-title');
            if (t) t.textContent = 'Shop x\u00e1c nh\u1eadn';
        }

        if (step6) {
            const c6 = step6.querySelector('.stepper-circle');
            if (c6) c6.innerHTML = '<i class="bi bi-house-check"></i>';
            const t6 = step6.querySelector('.stepper-title');
            if (t6) t6.textContent = '\u0110\u00e3 giao h\u00e0ng';
        }

        if (time2) time2.textContent = 'Ch\u1edd shop duy\u1ec7t';
        if (time3) time3.textContent = 'Ch\u1edd \u0111\u00f3ng g\u00f3i';
        if (time4) time4.textContent = 'Ch\u01b0a b\u00e0n giao';
        if (time5) time5.textContent = 'Ch\u01b0a giao';
        if (time6) time6.textContent = 'Ch\u1edd ho\u00e0n t\u1ea5t';

        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'none';
        if (prepCard) prepCard.classList.add('d-none');
        if (cancelCard) cancelCard.classList.add('d-none');
    } else if (status === 'PACKING' || status === 'CONFIRMED' || status === 'PROCESSING' || status === 'PREPARING' || status === 'PACKED' || status === 'READY_TO_SHIP') {
        if (estTimeEl) {
            estTimeEl.textContent = 'Nh\u00e0 v\u01b0\u1eddn \u0111ang \u0111\u00f3ng g\u00f3i qu\u1ea3 t\u01b0\u01a1i';
            estTimeEl.className = 'small fw-semibold text-primary bg-primary-subtle px-3 py-1 rounded-pill border border-primary-subtle';
        }
        [step1, step2].forEach(s => s && s.classList.add('completed'));
        if (line1) line1.classList.add('completed');
        if (line2) line2.className = 'stepper-line active';

        if (step2) {
            const c = step2.querySelector('.stepper-circle');
            if (c) c.innerHTML = '<i class="bi bi-shop"></i>';
            const t = step2.querySelector('.stepper-title');
            if (t) t.textContent = 'Shop x\u00e1c nh\u1eadn';
        }

        if (time2) time2.textContent = '\u0110\u00e3 duy\u1ec7t';
        if (time3) time3.textContent = '\u0110ang \u0111\u00f3ng g\u00f3i';
        if (time4) time4.textContent = 'Ch\u1edd b\u00e0n giao';
        if (time5) time5.textContent = 'Ch\u01b0a giao';
        if (time6) time6.textContent = 'Ch\u1edd nh\u1eadn h\u00e0ng';

        if (step3) {
            step3.className = 'stepper-step active';
            const c = step3.querySelector('.stepper-circle');
            if (c) c.classList.add('pulse');
        }

        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'none';
        if (prepCard) prepCard.classList.remove('d-none');
        if (cancelCard) cancelCard.classList.add('d-none');
    } else {
        if (estTimeEl) {
            estTimeEl.textContent = 'Ch\u1edd x\u00e1c nh\u1eadn';
            estTimeEl.className = 'small fw-semibold text-warning bg-warning-subtle px-3 py-1 rounded-pill border border-warning-subtle';
        }
        if (step1) {
            step1.className = 'stepper-step active';
            const c = step1.querySelector('.stepper-circle');
            if (c) c.classList.add('pulse');
        }
        if (step2) {
            const c = step2.querySelector('.stepper-circle');
            if (c) c.innerHTML = '<i class="bi bi-shop"></i>';
            const t = step2.querySelector('.stepper-title');
            if (t) t.textContent = 'Shop x\u00e1c nh\u1eadn';
        }
        if (time2) time2.textContent = 'Ch\u1edd shop duy\u1ec7t';
        if (time3) time3.textContent = '--:--';
        if (time4) time4.textContent = '--:--';
        if (time5) time5.textContent = '--:--';
        if (time6) time6.textContent = '--:--';

        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'none';
        if (prepCard) prepCard.classList.remove('d-none');
        if (cancelCard) cancelCard.classList.add('d-none');
    }
    // 6. Launch Bootstrap Modal
    const modalEl = document.getElementById('orderTrackingModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const m = bootstrap.Modal.getOrCreateInstance(modalEl);
        m.show();
    }
}

function cancelOrder(orderId) {
    openCancelModal(orderId);
}

function openCancelModal(orderId) {
    const inputId = document.getElementById('cancelTargetOrderId');
    const codeEl = document.getElementById('cancelModalOrderCode');
    const select = document.getElementById('cancelReasonSelect');
    const custom = document.getElementById('cancelReasonCustom');

    if (inputId) inputId.value = orderId;
    if (codeEl) codeEl.textContent = '#' + orderId;
    if (select) select.value = 'Đổi ý, không muốn mua nữa';
    if (custom) {
        custom.value = '';
        custom.classList.add('d-none');
    }

    const modalEl = document.getElementById('cancelOrderModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const m = bootstrap.Modal.getOrCreateInstance(modalEl);
        m.show();
    } else {
        cancelOrderFallback(orderId);
    }
}

function toggleCustomCancelReason(val) {
    const custom = document.getElementById('cancelReasonCustom');
    if (!custom) return;
    if (val === 'OTHER') {
        custom.classList.remove('d-none');
        custom.focus();
    } else {
        custom.classList.add('d-none');
    }
}

async function submitCancelOrder() {
    const inputId = document.getElementById('cancelTargetOrderId');
    const orderId = inputId ? inputId.value : '';
    if (!orderId) {
        alert('Không tìm thấy mã đơn hàng!');
        return;
    }

    const select = document.getElementById('cancelReasonSelect');
    const custom = document.getElementById('cancelReasonCustom');
    let reason = select ? select.value : 'Đổi ý, không muốn mua nữa';
    if (reason === 'OTHER') {
        reason = custom && custom.value.trim() ? custom.value.trim() : 'Lý do khác';
    }

    const btn = document.getElementById('btnConfirmCancelOrder');
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang hủy...';
    }

    try {
        const ctx = window.contextPath || '';
        const params = new URLSearchParams();
        params.append('action', 'cancelOrder');
        params.append('orderId', orderId);
        params.append('reason', reason);
        params.append('ajax', 'true');

        const res = await fetch(ctx + '/profile', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
            },
            body: params.toString()
        });

        const data = await res.json();
        if (data && data.success) {
            const modalEl = document.getElementById('cancelOrderModal');
            if (modalEl && window.bootstrap && bootstrap.Modal) {
                const m = bootstrap.Modal.getInstance(modalEl);
                if (m) m.hide();
            }
            alert(data.message || 'Hủy đơn hàng thành công!');
            // Chuyển sang tab Đã hủy và tải lại trang
            window.location.href = ctx + '/profile#orders';
            window.location.reload();
        } else {
            alert(data.message || 'Không thể hủy đơn hàng!');
        }
    } catch (e) {
        alert('Có lỗi xảy ra khi hủy đơn hàng: ' + (e.message || e));
    } finally {
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-x-circle me-1"></i> Xác Nhận Hủy Đơn';
        }
    }
}

function cancelOrderFallback(orderId) {
    if (confirm('Bạn có chắc chắn muốn hủy đơn hàng #' + orderId + ' ngay lập tức?')) {
        const reason = prompt('Lý do hủy đơn hàng:', 'Đổi ý, không muốn mua nữa') || 'Người mua hủy đơn trực tiếp';
        const ctx = window.contextPath || '';
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = ctx + '/profile';

        const actInput = document.createElement('input');
        actInput.type = 'hidden';
        actInput.name = 'action';
        actInput.value = 'cancelOrder';
        form.appendChild(actInput);

        const idInput = document.createElement('input');
        idInput.type = 'hidden';
        idInput.name = 'orderId';
        idInput.value = orderId;
        form.appendChild(idInput);

        const rInput = document.createElement('input');
        rInput.type = 'hidden';
        rInput.name = 'reason';
        rInput.value = reason;
        form.appendChild(rInput);

        document.body.appendChild(form);
        form.submit();
    }
}

/* FE10_PROFILE_REVIEW_INTEGRATION: Uses current FE-10 API; no database changes. */
let fe10ProfileOrderCode = '';
let fe10ProfileShopId = '';
let fe10ProfileCsrf = '';
let fe10ProfileLoading = false;

function setOrderReviewRating(value) {
    const rating = Math.max(1, Math.min(5, parseInt(value, 10) || 5));
    const input = document.getElementById('reviewRating');
    if (input) input.value = String(rating);
    document.querySelectorAll('#reviewModal .fe10-review-star').forEach(function (star) {
        const selected = Number(star.dataset.rating) <= rating;
        star.classList.toggle('selected', selected);
        star.setAttribute('aria-checked', Number(star.dataset.rating) === rating ? 'true' : 'false');
    });
    const text = document.getElementById('reviewRatingCaption');
    if (text) text.textContent = ['', 'Rất tệ', 'Chưa hài lòng', 'Bình thường', 'Hài lòng', 'Tuyệt vời'][rating];
}

function fe10ProfileMessage(message, error) {
    const target = document.getElementById('reviewFormMessage');
    if (!target) return;
    target.textContent = message || '';
    target.className = error ? 'fe10-review-message is-error' : 'fe10-review-message';
}

function fe10ReviewProductChanged() {
    const select = document.getElementById('reviewPurchaseSelect');
    const preview = document.getElementById('reviewSelectedProduct');
    const submit = document.getElementById('reviewSubmitButton');
    if (!select || !preview) return;
    const option = select.options[select.selectedIndex];
    const enabled = Boolean(select.value) && !fe10ProfileLoading;
    preview.textContent = enabled ? option.textContent : 'Chọn một sản phẩm đã giao để đánh giá.';
    if (submit) submit.disabled = !enabled;
}

async function fe10ProfileJson(response) {
    let data;
    try { data = await response.json(); }
    catch (e) { throw new Error('Server không trả JSON. Kiểm tra Output Tomcat.'); }
    if (!response.ok) throw new Error(data.error || 'Yêu cầu thất bại: HTTP ' + response.status);
    return data;
}

async function openReviewModal(orderCode, shopId) {
    fe10ProfileOrderCode = String(orderCode || '').trim();
    fe10ProfileShopId = String(shopId || '').trim();
    const code = document.getElementById('reviewModalOrderCode');
    const modalElement = document.getElementById('reviewModal');
    const select = document.getElementById('reviewPurchaseSelect');
    const comment = document.getElementById('reviewComment');
    if (!modalElement || !select || !window.bootstrap || !bootstrap.Modal) {
        alert('Không tìm thấy popup đánh giá hoặc Bootstrap.');
        return;
    }
    if (code) code.textContent = '#' + fe10ProfileOrderCode;
    if (comment) comment.value = '';
    setOrderReviewRating(5);
    fe10ProfileMessage('Đang tìm sản phẩm đã giao trong đơn hàng...', false);
    select.replaceChildren(new Option('Đang tải sản phẩm...', ''));
    select.disabled = true;
    fe10ProfileLoading = true;
    fe10ReviewProductChanged();
    bootstrap.Modal.getOrCreateInstance(modalElement).show();
    try {
        const ctx = window.contextPath || '';
        const response = await fetch(ctx + '/reviews/purchases?type=PRODUCT', {
            credentials: 'same-origin', cache: 'no-store'
        });
        const data = await fe10ProfileJson(response);
        const purchases = (data.purchases || []).filter(function (item) {
            return String(item.orderCode || '').trim() === fe10ProfileOrderCode &&
                   String(item.shopId || '') === fe10ProfileShopId;
        });
        select.replaceChildren(new Option('Chọn sản phẩm cần đánh giá', ''));
        for (const item of purchases) {
            const option = new Option(
                (item.productName || 'Sản phẩm') + (item.canReview ? '' : ' — Đã đánh giá'),
                String(item.purchaseRef)
            );
            option.disabled = !item.canReview;
            select.add(option);
        }
        select.disabled = false;
        fe10ProfileMessage(
            purchases.length === 0
                ? 'Không tìm thấy sản phẩm đã giao của đơn này. Kiểm tra trạng thái DELIVERED và mã đơn hàng.'
                : purchases.every(item => !item.canReview)
                    ? 'Tất cả sản phẩm trong đơn này đã được đánh giá.'
                    : 'Chọn một sản phẩm trong đơn, chấm sao và gửi nhận xét.',
            purchases.length === 0
        );
    } catch (error) {
        select.replaceChildren(new Option('Không thể tải sản phẩm', ''));
        fe10ProfileMessage(error.message, true);
    } finally {
        fe10ProfileLoading = false;
        fe10ReviewProductChanged();
    }
}

async function submitReview() {
    if (fe10ProfileLoading) return;
    const select = document.getElementById('reviewPurchaseSelect');
    const commentBox = document.getElementById('reviewComment');
    const submitButton = document.getElementById('reviewSubmitButton');
    const purchaseRef = select ? select.value : '';
    const rating = document.getElementById('reviewRating')?.value || '5';
    const comment = commentBox ? commentBox.value.trim() : '';
    if (!purchaseRef) {
        fe10ProfileMessage('Bạn cần chọn một sản phẩm chưa đánh giá.', true);
        return;
    }
    if (comment.length > 2000) {
        fe10ProfileMessage('Nội dung không được quá 2000 ký tự.', true);
        return;
    }
    fe10ProfileLoading = true;
    if (submitButton) submitButton.disabled = true;
    fe10ProfileMessage('Đang lưu đánh giá vào hệ thống...', false);
    try {
        const ctx = window.contextPath || '';
        if (!fe10ProfileCsrf) {
            const csrfResponse = await fetch(ctx + '/reviews/csrf', {
                credentials: 'same-origin', cache: 'no-store'
            });
            fe10ProfileCsrf = (await fe10ProfileJson(csrfResponse)).csrfToken;
            if (!fe10ProfileCsrf) throw new Error('Không lấy được mã bảo vệ CSRF.');
        }
        const fields = new URLSearchParams({
            action: 'create', type: 'PRODUCT', purchaseRef: purchaseRef,
            rating: rating, comment: comment
        });
        const response = await fetch(ctx + '/reviews', {
            method: 'POST', credentials: 'same-origin', cache: 'no-store',
            headers: { 'X-CSRF-Token': fe10ProfileCsrf, 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: fields.toString()
        });
        const result = await fe10ProfileJson(response);
        if (!result.reviewId) throw new Error('Máy chủ chưa xác nhận đã lưu đánh giá.');
        bootstrap.Modal.getInstance(document.getElementById('reviewModal'))?.hide();
        alert('Đánh giá đã được lưu thành công! Mã đánh giá #' + result.reviewId);
        window.location.reload();
    } catch (error) {
        fe10ProfileMessage('Không lưu được: ' + error.message, true);
    } finally {
        fe10ProfileLoading = false;
        fe10ReviewProductChanged();
    }
}

// =========================================================================
// CUSTOMER RETURN & REFUND WORKFLOW (BF Implementation)
// =========================================================================

function openReturnModal(orderCode, shopName, totalAmount, dbOrderId) {
    const codeEl = document.getElementById('returnOrderCode');
    const shopEl = document.getElementById('returnShopName');
    const amountEl = document.getElementById('returnTotalAmount');
    const claimInput = document.getElementById('returnClaimAmountInput');
    const subOrderInput = document.getElementById('returnSubOrderId');

    if (codeEl) codeEl.textContent = '#' + (orderCode || 'N/A');
    if (shopEl) shopEl.textContent = shopName || 'Gốc Vườn Shop';
    if (amountEl) amountEl.textContent = (totalAmount ? totalAmount + '₫' : '0₫');
    if (claimInput) claimInput.value = totalAmount || '0';
    if (subOrderInput) subOrderInput.value = dbOrderId || orderCode || '';

    const modalEl = document.getElementById('returnOrderModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const m = bootstrap.Modal.getOrCreateInstance(modalEl);
        m.show();
    }
}

function selectReturnPhotoPreset(url) {
    const input = document.getElementById('returnEvidenceInput');
    const preview = document.getElementById('returnPreviewImg');
    if (input) input.value = url;
    if (preview) {
        preview.src = url;
        preview.style.display = 'block';
    }
}

function viewReturnDetail(subOrderIdOrCode) {
    if (!subOrderIdOrCode) return;

    const returnForm = document.querySelector('#returnOrderModal form');
    const basePath = returnForm ? returnForm.getAttribute('action') : 'customer/return';
    const url = basePath + '?subOrderId=' + encodeURIComponent(subOrderIdOrCode);

    fetch(url)
        .then(res => {
            if (!res.ok) throw new Error('Không thể tải thông tin khiếu nại');
            return res.json();
        })
        .then(data => {
            if (data && data.disputeId) {
                const codeEl = document.getElementById('dispCodeText');
                const badgeEl = document.getElementById('dispStatusBadge');
                const reasonEl = document.getElementById('dispReasonText');
                const compEl = document.getElementById('dispComplaintText');
                const imgEl = document.getElementById('dispEvidenceImg');
                const claimEl = document.getElementById('dispClaimAmount');
                const resTitle = document.getElementById('dispResolutionTitle');
                const resNote = document.getElementById('dispResolutionNote');

                if (codeEl) codeEl.textContent = data.disputeCode || ('DIS-' + data.disputeId);

                if (badgeEl) {
                    const status = (data.status || 'OPEN').toUpperCase();
                    if (status === 'REFUNDED_BUYER' || status === 'RESOLVED') {
                        badgeEl.className = 'badge bg-success fs-6';
                        badgeEl.textContent = 'Đã Hoàn Tiền';
                    } else if (status === 'REJECTED') {
                        badgeEl.className = 'badge bg-danger fs-6';
                        badgeEl.textContent = 'Từ Chối Hoàn Tiền';
                    } else if (status === 'MEDIATING') {
                        badgeEl.className = 'badge bg-warning text-dark fs-6';
                        badgeEl.textContent = 'Đang Thẩm Định Quả';
                    } else {
                        badgeEl.className = 'badge bg-primary fs-6';
                        badgeEl.textContent = 'Chờ Shop Phản Hồi';
                    }
                }

                if (reasonEl) reasonEl.textContent = data.reasonCategory || 'Khiếu nại tươi ngon';
                if (compEl) compEl.textContent = data.complaintText || 'Không có mô tả chi tiết';

                if (imgEl) {
                    if (data.evidenceImageUrl && data.evidenceImageUrl.trim() !== '') {
                        imgEl.src = data.evidenceImageUrl;
                        imgEl.style.display = 'inline-block';
                    } else {
                        imgEl.style.display = 'none';
                    }
                }

                if (claimEl) {
                    const formatted = Number(data.claimAmount || 0).toLocaleString('vi-VN');
                    claimEl.textContent = formatted + '₫';
                }

                if (resTitle && resNote) {
                    if (data.resolutionNote && data.resolutionNote.trim() !== '') {
                        resTitle.textContent = 'Phản hồi từ ' + (data.resolverName || 'Hệ thống Sàn') + ':';
                        resNote.textContent = data.resolutionNote;
                    } else {
                        resTitle.textContent = 'Tiến độ:';
                        resNote.textContent = 'Yêu cầu của bạn đang được Bộ phận Vận hành Sàn & Nhà Vườn cùng xem xét ảnh bằng chứng. Kết quả thẩm định sẽ được cập nhật trong 24h.';
                    }
                }

                const modalEl = document.getElementById('returnDetailModal');
                if (modalEl && window.bootstrap && bootstrap.Modal) {
                    const m = bootstrap.Modal.getOrCreateInstance(modalEl);
                    m.show();
                }
            } else {
                alert('Chưa có thông tin khiếu nại trả hàng cho đơn này hoặc đơn hàng đang xử lý.');
            }
        })
        .catch(err => {
            console.error('Lỗi tra cứu khiếu nại:', err);
            alert('Không thể kết nối đến máy chủ để lấy thông tin khiếu nại.');
        });
}




