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

function openChatShop(shopName) {
    alert('Đang mở khung chat trực tiếp với gian hàng: ' + (shopName || 'Gốc Vườn Shop') + '. Nhân viên tư vấn đang kết nối...');
}

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
    setText('trackNoteText', deliverySlot ? ('Khung giờ giao đã chọn: ' + deliverySlot) : 'Đóng thùng cách nhiệt chuỗi lạnh FreshCold tiêu chuẩn.');

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

function openReviewModal(orderCode) {
    const codeEl = document.getElementById('reviewModalOrderCode');
    if (codeEl) {
        codeEl.textContent = '#' + orderCode;
    }
    const modalEl = document.getElementById('reviewModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const m = bootstrap.Modal.getOrCreateInstance(modalEl);
        m.show();
    }
}

function submitReview() {
    const comment = document.getElementById('reviewComment');
    const modalEl = document.getElementById('reviewModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const m = bootstrap.Modal.getInstance(modalEl);
        if (m) m.hide();
    }
    if (comment) comment.value = '';
    alert('Cảm ơn bạn! Đánh giá chất lượng trái cây của bạn đã được gửi thành công.');
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




