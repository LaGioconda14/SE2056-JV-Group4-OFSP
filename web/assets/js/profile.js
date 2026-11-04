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

    if (typeof cancelAvatarPreview === 'function') {
        cancelAvatarPreview();
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

function triggerAvatarSelect() {
    const fileInput = document.getElementById('avatarFileInput');
    if (fileInput) fileInput.click();
}

function handleAvatarFileSelect(input) {
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
}

function cancelAvatarPreview() {
    const fileInput = document.getElementById('avatarFileInput');
    if (fileInput) fileInput.value = '';

    const defaultBox = document.getElementById('avatarDefaultActions');
    const pendingBox = document.getElementById('avatarPendingActions');

    if (pendingBox) pendingBox.classList.add('d-none');
    if (defaultBox) defaultBox.classList.remove('d-none');

    const previewImg = document.getElementById('avatarImagePreview');
    const placeholder = document.getElementById('avatarPlaceholderPreview');

    if (previewImg && placeholder) {
        if (typeof initialProfileData !== 'undefined' && initialProfileData && initialProfileData.hasAvatar) {
            previewImg.src = initialProfileData.avatarSrc;
            previewImg.classList.remove('d-none');
            placeholder.classList.add('d-none');
        } else {
            previewImg.src = '';
            previewImg.classList.add('d-none');
            placeholder.classList.remove('d-none');
        }
    }
}

function submitDirectAvatarUpload() {
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
}

function confirmDeleteAvatar() {
    const pendingBox = document.getElementById('avatarPendingActions');
    if (pendingBox && !pendingBox.classList.contains('d-none')) {
        cancelAvatarPreview();
        return;
    }

    if (!confirm('Bạn có chắc chắn muốn xóa ảnh đại diện hiện tại?')) {
        return;
    }

    const directForm = document.getElementById('avatarDirectForm');
    if (!directForm) return;

    document.getElementById('avatarDirectAction').value = 'deleteAvatar';
    directForm.submit();
}

function handleStageDeleteAvatar() {
    confirmDeleteAvatar();
}

function submitAvatarForm() {
    submitDirectAvatarUpload();
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
    const cancelOrderForm = document.getElementById('cancelOrderForm');
    if (cancelOrderForm) {
        cancelOrderForm.addEventListener('submit', function() {
            const select = document.getElementById('cancelReasonSelect');
            const custom = document.getElementById('cancelReasonCustom');
            const finalReason = document.getElementById('finalCancelReason');
            if (select && select.value === 'OTHER') {
                const text = custom ? custom.value.trim() : '';
                if (finalReason) finalReason.value = text ? text : 'Lý do khác';
            } else if (select && finalReason) {
                finalReason.value = select.value;
            }
        });
    }

    sortOrdersNewestFirst();
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

function sortOrdersNewestFirst() {
    const container = document.getElementById('ordersContainer');
    if (!container) return;
    const cards = Array.from(container.querySelectorAll('.shopee-order-card'));
    if (cards.length <= 1) return;
    cards.sort((a, b) => {
        const timeA = parseInt(a.getAttribute('data-timestamp') || '0', 10);
        const timeB = parseInt(b.getAttribute('data-timestamp') || '0', 10);
        if (timeB !== timeA) return timeB - timeA;
        const idA = parseInt(a.getAttribute('data-sub-order-id') || '0', 10);
        const idB = parseInt(b.getAttribute('data-sub-order-id') || '0', 10);
        return idB - idA;
    });
    cards.forEach(card => container.appendChild(card));
}

function filterOrders(filter, btn) {
    document.querySelectorAll('.order-filter-btn').forEach(b => b.classList.remove('active'));
    if (btn) btn.classList.add('active');

    if (filter === 'all') {
        sortOrdersNewestFirst();
    }

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

let currentContactShop = {
    shopName: '',
    shopId: '',
    orderId: '',
    productName: ''
};

function escapeContactHtml(text) {
    if (!text) return '';
    return text.replace(/[&<>"']/g, function(m) {
        return {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        }[m];
    });
}

function openChatFromCard(btn) {
    if (!btn) return;
    const card = btn.closest('.shopee-order-card');
    if (!card) return;
    const shopName = card.dataset.shopName || '';
    const shopId = card.dataset.shopId || '';
    const orderId = card.dataset.orderId || card.dataset.subOrderId || '';
    const productName = card.dataset.productName || 'Hoa quả tươi';
    openChatShop(shopName, shopId, orderId, productName);
}

function openChatShop(shopName, shopId, orderId, productName) {
    currentContactShop.shopName = shopName || 'Gian Hàng Nông Trại';
    currentContactShop.shopId = shopId || '';
    currentContactShop.orderId = orderId || '';
    currentContactShop.productName = productName || 'Hoa quả tươi';

    const nameEl = document.getElementById('contactSellerShopName');
    if (nameEl) nameEl.textContent = currentContactShop.shopName;

    const prodEl = document.getElementById('contactSellerProductName');
    if (prodEl) prodEl.textContent = currentContactShop.productName;

    const storeLink = document.getElementById('contactSellerStoreLink');
    if (storeLink) {
        if (currentContactShop.shopId) {
            storeLink.href = (window.contextPath || '') + '/store?id=' + currentContactShop.shopId;
            storeLink.classList.remove('d-none');
        } else {
            storeLink.classList.add('d-none');
        }
    }

    const chatContainer = document.getElementById('contactSellerChatMessages');
    if (chatContainer) {
        chatContainer.innerHTML = `
            <div class="d-flex align-items-start gap-2.5">
                <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center fw-bold shadow-xs flex-shrink-0" style="width: 34px; height: 34px; font-size: 14px;">
                    <i class="bi bi-shop"></i>
                </div>
                <div class="p-3 rounded-4 bg-white border shadow-xs text-dark" style="max-width: 85%; font-size: 13px; line-height: 1.5;">
                    <div class="fw-bold text-success small mb-1">${escapeContactHtml(currentContactShop.shopName)}</div>
                    Xin kính chào quý khách! Cảm ơn bạn đã tin tưởng đặt hoa quả tại nông trại của chúng tôi. Bạn cần hỗ trợ vấn đề gì về sản phẩm <strong>${escapeContactHtml(currentContactShop.productName)}</strong> này ạ?
                </div>
            </div>
        `;
    }

    const input = document.getElementById('contactSellerChatInput');
    if (input) input.value = '';

    const modalEl = document.getElementById('contactSellerModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        bootstrap.Modal.getOrCreateInstance(modalEl).show();
        setTimeout(() => {
            if (input) input.focus();
        }, 400);
    }
}

function sendQuickQuestion(questionText) {
    const input = document.getElementById('contactSellerChatInput');
    if (input) input.value = questionText;
    sendContactChatMessage();
}

function handleContactChatKeyPress(e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        sendContactChatMessage();
    }
}

function sendContactChatMessage() {
    const input = document.getElementById('contactSellerChatInput');
    if (!input) return;
    const msg = input.value.trim();
    if (!msg) return;

    const chatContainer = document.getElementById('contactSellerChatMessages');
    if (!chatContainer) return;

    // Render tin nhắn của người mua (bên phải)
    const userMsgEl = document.createElement('div');
    userMsgEl.className = 'd-flex justify-content-end';
    userMsgEl.innerHTML = `
        <div class="p-3 rounded-4 text-white shadow-xs" style="background: var(--primary-green, #046A38); max-width: 80%; font-size: 13px; line-height: 1.5;">
            ${escapeContactHtml(msg)}
        </div>
    `;
    chatContainer.appendChild(userMsgEl);
    input.value = '';
    chatContainer.scrollTop = chatContainer.scrollHeight;

    // Phản hồi thông minh tự động từ nhà vườn nhắc đến tên sản phẩm thay vì mã đơn
    setTimeout(() => {
        let reply = 'Dạ nhà vườn chúng tôi đã nhận được thông tin yêu cầu của bạn về sản phẩm ' + currentContactShop.productName + '. Nhân viên tư vấn đang xử lý và sẽ phản hồi hoặc liên hệ hỗ trợ bạn ngay ạ!';
        const lowerMsg = msg.toLowerCase();

        if (lowerMsg.includes('khi nào') || lowerMsg.includes('bao giờ') || lowerMsg.includes('thời gian') || lowerMsg.includes('giao')) {
            reply = 'Dạ kiện hàng sản phẩm ' + currentContactShop.productName + ' của bạn đang được nông trại đóng thùng chuỗi lạnh và chuyển giao bưu tá. Bạn có thể theo dõi hành trình chi tiết bằng nút "Tra cứu vận chuyển" trên đơn hàng nhé!';
        } else if (lowerMsg.includes('lạnh') || lowerMsg.includes('bảo quản') || lowerMsg.includes('đóng gói')) {
            reply = 'Dạ toàn bộ ' + currentContactShop.productName + ' được thu hái tươi trong ngày, bọc xốp chống dập và đóng thùng giữ nhiệt FreshCold đạt chuẩn 2–8°C để bảo đảm độ giòn tươi ngon nhất khi đến tay bạn ạ!';
        } else if (lowerMsg.includes('đổi giờ') || lowerMsg.includes('ghi chú') || lowerMsg.includes('hẹn')) {
            reply = 'Dạ nông trại đã ghi nhận thay đổi của bạn cho kiện hàng ' + currentContactShop.productName + '. Bưu tá khi nhận đơn sẽ liên hệ trước khi phát hàng, bạn cũng có thể trao đổi trực tiếp giờ nhận thuận tiện nhất với tài xế ạ!';
        } else if (lowerMsg.includes('đổi trả') || lowerMsg.includes('dập') || lowerMsg.includes('hỏng') || lowerMsg.includes('chất lượng')) {
            reply = 'Dạ nông trại cam kết bảo hành 1 đổi 1 hoặc hoàn tiền nếu sản phẩm ' + currentContactShop.productName + ' có hiện tượng dập nát, hư hỏng. Quý khách vui lòng đồng kiểm cùng shipper hoặc chụp lại ảnh kiện hàng gửi shop để được hỗ trợ tức thì ạ!';
        }

        const shopMsgEl = document.createElement('div');
        shopMsgEl.className = 'd-flex align-items-start gap-2.5';
        shopMsgEl.innerHTML = `
            <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center fw-bold shadow-xs flex-shrink-0" style="width: 34px; height: 34px; font-size: 14px;">
                <i class="bi bi-shop"></i>
            </div>
            <div class="p-3 rounded-4 bg-white border shadow-xs text-dark" style="max-width: 80%; font-size: 13px; line-height: 1.5;">
                <div class="fw-bold text-success small mb-1">${escapeContactHtml(currentContactShop.shopName)}</div>
                ${reply}
            </div>
        `;
        chatContainer.appendChild(shopMsgEl);
        chatContainer.scrollTop = chatContainer.scrollHeight;
    }, 700);
}

window.openChatFromCard = openChatFromCard;
window.openChatShop = openChatShop;
window.sendQuickQuestion = sendQuickQuestion;
window.handleContactChatKeyPress = handleContactChatKeyPress;
window.sendContactChatMessage = sendContactChatMessage;

function confirmReceivedOrder(orderId) {
    if (confirm('Bạn xác nhận đã nhận được đầy đủ hoa quả của đơn hàng #' + orderId + ' và không có vấn đề gì?')) {
        alert('Cảm ơn bạn! Đơn hàng #' + orderId + ' đã được cập nhật sang trạng thái Hoàn thành. Hãy để lại đánh giá nhé!');
        location.reload();
    }
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
    if (!card) return;

    const getAttr = (name, def = '') => card.getAttribute(name) || def;
    const setText = (id, val) => {
        const el = document.getElementById(id);
        if (el) el.textContent = val;
    };

    const status = getAttr('data-order-status', 'PENDING').toUpperCase();
    const createdAt = getAttr('data-created-at');
    const recipientAddress = getAttr('data-recipient-address', 'Địa chỉ giao hàng');
    const deliverySlot = getAttr('data-delivery-slot');
    const paymentMethod = getAttr('data-payment-method', 'COD').toUpperCase();

    setText('trackModalOrderCode', '#' + orderId);
    setText('trackModalOrderDate', createdAt || 'Vừa xong');
    setText('trackRecipientName', getAttr('data-recipient-name', 'Người nhận'));
    setText('trackRecipientPhone', getAttr('data-recipient-phone', '0903 *** ***'));
    setText('trackRecipientAddress', recipientAddress);
    function formatDeliverySlotNote(raw) {
        if (!raw || !raw.trim()) return 'Giao hàng chuỗi lạnh FreshCold tiêu chuẩn.';
        const s = raw.trim();
        const upper = s.toUpperCase();
        if (upper === 'MORNING') return 'Giao buổi sáng (08:00 - 12:00)';
        if (upper === 'AFTERNOON') return 'Giao buổi chiều (13:00 - 17:00)';
        if (upper === 'EVENING') return 'Giao buổi tối (18:00 - 21:00)';
        return s;
    }
    setText('trackNoteText', formatDeliverySlotNote(deliverySlot));

    const finalAmount = getAttr('data-final-amount', getAttr('data-goods-amount', 0));
    setText('trackFinalTotal', formatVND(finalAmount));

    const payBadge = document.getElementById('trackPaymentMethodBadge');
    if (payBadge) {
        const payMap = {
            'VNPAY': { text: 'VNPAY QR', cls: 'bg-primary-subtle text-primary' },
            'WALLET': { text: 'Ví Gốc Vườn Pay', cls: 'bg-success-subtle text-success' }
        };
        const p = payMap[paymentMethod] || { text: 'Thu hộ tiền mặt (COD)', cls: 'bg-light text-dark' };
        payBadge.textContent = p.text;
        payBadge.className = 'badge ' + p.cls + ' border fw-semibold';
    }

    const itemsContainer = document.getElementById('trackItemsContainer');
    if (itemsContainer) {
        itemsContainer.innerHTML = '';
        const itemRows = card.querySelectorAll('.shopee-item-row');
        setText('trackItemCount', itemRows.length);

        itemRows.forEach(row => {
            const img = row.querySelector('.shopee-item-thumb');
            const imgSrc = img ? img.getAttribute('src') : 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop';
            const titleEl = row.querySelector('.shopee-item-title');
            const title = titleEl ? titleEl.textContent.trim() : 'Sản phẩm';
            const variantEl = row.querySelector('.shopee-item-variant');
            const variant = variantEl ? variantEl.textContent.trim() : '';
            const qtyEl = row.querySelector('.shopee-item-qty');
            const qty = qtyEl ? qtyEl.textContent.trim() : 'x1';
            const priceEl = row.querySelector('.shopee-price-current');
            const price = priceEl ? priceEl.textContent.trim() : '0₫';

            const itemDiv = document.createElement('div');
            itemDiv.className = 'tracking-item-card';
            itemDiv.innerHTML = '<img src="' + imgSrc + '" alt="' + title + '" onerror="this.src=\'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop\';">' +
                '<div class="tracking-item-info">' +
                    '<div class="tracking-item-name">' + title + '</div>' +
                    '<div class="tracking-item-variant">' + variant + ' &bull; <strong class="text-dark">' + qty + '</strong></div>' +
                '</div>' +
                '<div class="tracking-item-price">' + price + '</div>';
            itemsContainer.appendChild(itemDiv);
        });
    }

    const orderHour = createdAt ? (createdAt.trim().split(' ')[1] || createdAt) : 'Vừa xong';
    const isCancel = status === 'CANCELLED' || status === 'CANCELED';
    const isReturned = status === 'RETURNED' || status === 'REFUNDED' || status === 'DISPUTED' || status === 'FAILED';
    const isCompleted = status === 'COMPLETED' || status === 'DELIVERED' || status === 'SUCCESS';
    const isShipping = status === 'SHIPPING' || status === 'DELIVERING' || status === 'IN_TRANSIT';
    const isPacking = ['PACKING', 'CONFIRMED', 'PROCESSING', 'PREPARING', 'PACKED', 'READY_TO_SHIP'].includes(status);
    const isNew = status === 'NEW';

    let badgeText = 'CHỜ THANH TOÁN', badgeCls = 'bg-warning-subtle text-warning border-warning-subtle';
    let estText = 'Chờ xác nhận', estCls = 'text-warning bg-warning-subtle border-warning-subtle';
    let completedSteps = 0, activeStep = 1;
    let times = [orderHour, 'Chờ shop duyệt', '--:--', '--:--', '--:--', '--:--'];

    if (isCancel) {
        badgeText = 'ĐÃ HỦY';
        badgeCls = 'bg-danger-subtle text-danger border-danger-subtle';
        estText = 'Đơn hàng đã được hủy';
        estCls = 'text-danger bg-danger-subtle border-danger-subtle';
        completedSteps = 1;
        activeStep = 0;
        times = [orderHour, 'Đã hủy', '--:--', '--:--', '--:--', '--:--'];
    } else if (isReturned) {
        badgeText = 'ĐÃ TRẢ HÀNG';
        badgeCls = 'bg-warning-subtle text-warning border-warning-subtle';
        estText = 'Đơn hàng đã được trả về nhà vườn';
        estCls = 'text-warning bg-warning-subtle border-warning-subtle';
        completedSteps = 6;
        activeStep = 0;
        times = [orderHour, 'Đã xác nhận', 'Đã đóng gói', 'Đã bàn giao', 'Đã chuyển hàng', 'Đã trả hàng'];
    } else if (isCompleted) {
        badgeText = 'GIAO THÀNH CÔNG';
        badgeCls = 'bg-success-subtle text-success border-success-subtle';
        estText = 'Giao hàng thành công';
        estCls = 'text-success bg-success-subtle border-success-subtle';
        completedSteps = 6;
        activeStep = 0;
        times = [orderHour, 'Đã xác nhận', 'Đã đóng gói', 'Đã bàn giao', 'Đã chuyển hàng', 'Đã nhận quả tươi'];
    } else if (isShipping) {
        badgeText = 'ĐANG GIAO HÀNG';
        badgeCls = 'bg-primary-subtle text-primary border-primary-subtle';
        estText = 'Đang giao chuỗi lạnh FreshCold';
        estCls = 'text-success bg-success-subtle border-success-subtle';
        completedSteps = 4;
        activeStep = 5;
        times = [orderHour, 'Đã xác nhận', 'Đã đóng gói', 'Đã lấy hàng', 'Đang giao...', 'Chờ nhận hàng'];
    } else if (isPacking) {
        badgeText = 'ĐANG CHUẨN BỊ HÀNG';
        badgeCls = 'bg-info-subtle text-info border-info-subtle';
        estText = 'Nhà vườn đang đóng gói quả tươi';
        estCls = 'text-primary bg-primary-subtle border-primary-subtle';
        completedSteps = 2;
        activeStep = 3;
        times = [orderHour, 'Đã duyệt', 'Đang đóng gói', 'Chờ bàn giao', 'Chưa giao', 'Chờ nhận hàng'];
    } else if (isNew) {
        badgeText = 'ĐANG CHUẨN BỊ HÀNG';
        badgeCls = 'bg-info-subtle text-info border-info-subtle';
        estText = 'Đang chờ shop xác nhận đơn';
        estCls = 'text-warning bg-warning-subtle border-warning-subtle';
        completedSteps = 1;
        activeStep = 2;
        times = [orderHour, 'Chờ shop duyệt', 'Chờ đóng gói', 'Chưa bàn giao', 'Chưa giao', 'Chờ hoàn tất'];
    }

    const statusBadge = document.getElementById('trackStatusBadge');
    if (statusBadge) {
        statusBadge.textContent = badgeText;
        statusBadge.className = 'badge ' + badgeCls + ' px-3 py-1 rounded-pill fw-bold border';
    }

    const estTimeEl = document.getElementById('trackEstimatedTime');
    if (estTimeEl) {
        estTimeEl.textContent = estText;
        estTimeEl.className = 'small fw-semibold px-3 py-1 rounded-pill border ' + estCls;
    }

    const prepCard = document.getElementById('trackPreparingCard');
    if (prepCard) prepCard.classList.toggle('d-none', !(isPacking || isNew));

    const cancelCard = document.getElementById('trackCancelledCard');
    if (cancelCard) {
        cancelCard.classList.toggle('d-none', !isCancel);
        if (isCancel) {
            setText('trackCancelReason', 'Lý do: ' + getAttr('data-cancel-reason', 'Người mua hủy đơn trực tiếp'));
        }
    }

    const returnCard = document.getElementById('trackReturnedCard');
    if (returnCard) {
        returnCard.classList.toggle('d-none', !isReturned);
        if (isReturned) {
            const failureReason = getAttr('data-failure-reason');
            const cancelReason = getAttr('data-cancel-reason');
            const reason = failureReason || cancelReason || 'Khách từ chối nhận khi đồng kiểm với Shipper (Giao sai loại quả hoặc thiếu số lượng/dập nát).';
            setText('trackReturnedReason', reason);
        }
    }

    for (let i = 1; i <= 6; i++) {
        const stepEl = document.getElementById('trackStep' + i);
        const lineEl = document.getElementById('trackLine' + i);
        setText('trackTime' + i, times[i - 1]);

        if (stepEl) {
            stepEl.className = 'stepper-step';
            const circle = stepEl.querySelector('.stepper-circle');
            if (circle) circle.classList.remove('pulse');

            if (i === 2) {
                const titleEl = stepEl.querySelector('.stepper-title');
                if (titleEl) titleEl.textContent = isCancel ? 'Đã hủy đơn' : 'Shop xác nhận';
                if (circle) circle.innerHTML = isCancel ? '<i class="bi bi-x-lg"></i>' : '<i class="bi bi-shop"></i>';
            }

            if (i === 6) {
                const titleEl = stepEl.querySelector('.stepper-title');
                if (titleEl) titleEl.textContent = isReturned ? 'Đã trả hàng' : 'Đã giao hàng';
                if (circle) circle.innerHTML = isReturned ? '<i class="bi bi-arrow-return-left"></i>' : '<i class="bi bi-house-check"></i>';
            }

            if (isCancel && i === 2) {
                stepEl.classList.add('cancelled');
            } else if (isReturned && i === 6) {
                stepEl.classList.add('completed', 'returned');
            } else if (i <= completedSteps) {
                stepEl.classList.add('completed');
            } else if (i === activeStep) {
                stepEl.classList.add('active');
                if (circle) circle.classList.add('pulse');
            }
        }

        if (lineEl) {
            lineEl.className = 'stepper-line';
            if (i <= completedSteps && !(isCancel && i >= 2)) {
                lineEl.classList.add('completed');
            } else if (i === completedSteps && activeStep > completedSteps) {
                lineEl.classList.add('active');
            }
        }
    }

    const modalEl = document.getElementById('orderTrackingModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        bootstrap.Modal.getOrCreateInstance(modalEl).show();
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
    const finalReason = document.getElementById('finalCancelReason');

    if (inputId) inputId.value = orderId || '';
    if (codeEl) codeEl.textContent = '#' + (orderId || '');
    if (select) select.selectedIndex = 0;
    if (custom) {
        custom.value = '';
        custom.classList.add('d-none');
    }
    if (finalReason) finalReason.value = select ? select.value : 'Đổi ý, không muốn mua nữa';

    const modalEl = document.getElementById('cancelOrderModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const m = bootstrap.Modal.getOrCreateInstance(modalEl);
        m.show();
    }
}

function toggleCustomCancelReason(val) {
    const custom = document.getElementById('cancelReasonCustom');
    const finalReason = document.getElementById('finalCancelReason');
    if (!custom) return;
    if (val === 'OTHER') {
        custom.classList.remove('d-none');
        custom.focus();
        if (finalReason) finalReason.value = custom.value.trim() || 'Lý do khác';
    } else {
        custom.classList.add('d-none');
        if (finalReason) finalReason.value = val;
    }
}

function openReviewModal(orderCode, orderItemId) {
    const codeEl = document.getElementById('reviewModalOrderCode');
    const itemInput = document.getElementById('reviewModalOrderItemId');
    if (codeEl) codeEl.textContent = '#' + (orderCode || '');
    if (itemInput) itemInput.value = orderItemId || '';
    setReviewRating(5);
    const modalEl = document.getElementById('reviewModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const m = bootstrap.Modal.getOrCreateInstance(modalEl);
        m.show();
    }
}

function setReviewRating(stars) {
    const ratingInput = document.getElementById('reviewModalRating');
    const label = document.getElementById('reviewRatingLabel');
    if (ratingInput) ratingInput.value = stars;
    const starIcons = document.querySelectorAll('#reviewStarContainer .review-star');
    starIcons.forEach(icon => {
        const r = parseInt(icon.dataset.rating);
        if (r <= stars) {
            icon.className = 'bi bi-star-fill review-star text-warning';
        } else {
            icon.className = 'bi bi-star review-star text-muted';
        }
    });
    const labels = {
        1: 'Rất tệ (1/5 sao)',
        2: 'Không hài lòng (2/5 sao)',
        3: 'Bình thường (3/5 sao)',
        4: 'Hài lòng (4/5 sao)',
        5: 'Tuyệt vời (5/5 sao)'
    };
    if (label) label.textContent = labels[stars] || (stars + '/5 sao');
}

async function submitReview() {
    const commentEl = document.getElementById('reviewComment');
    const orderItemIdEl = document.getElementById('reviewModalOrderItemId');
    const ratingEl = document.getElementById('reviewModalRating');
    const modalEl = document.getElementById('reviewModal');

    const orderItemId = orderItemIdEl ? orderItemIdEl.value : null;
    const rating = ratingEl ? ratingEl.value : '5';
    const comment = commentEl ? commentEl.value.trim() : '';

    if (!orderItemId) {
        alert('Không tìm thấy thông tin sản phẩm cần đánh giá!');
        return;
    }

    try {
        const formData = new URLSearchParams();
        formData.append('orderItemId', orderItemId);
        formData.append('rating', rating);
        formData.append('comment', comment);

        const response = await fetch((window.contextPath || '') + '/review/create', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
            },
            body: formData.toString()
        });

        const data = await response.json();
        if (response.ok && data.success) {
            if (modalEl && window.bootstrap && bootstrap.Modal) {
                const m = bootstrap.Modal.getInstance(modalEl);
                if (m) m.hide();
            }
            alert('Cảm ơn bạn! Đánh giá chất lượng trái cây của bạn đã được gửi thành công.');
            location.reload();
        } else {
            alert(data.message || 'Không thể gửi đánh giá!');
        }
    } catch (e) {
        alert('Lỗi gửi đánh giá: ' + e.message);
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
    showOrderTracking(subOrderIdOrCode);
}




