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

function submitAvatarForm() {
    const fileInput = document.getElementById('avatarFileInput');
    if (fileInput && fileInput.files && fileInput.files[0]) {
        const file = fileInput.files[0];
        const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
        if (!validTypes.includes(file.type)) {
            alert('Định dạng file không hỗ trợ! Vui lòng chọn ảnh JPG, PNG hoặc WEBP.');
            fileInput.value = '';
            return;
        }
        if (file.size > 2 * 1024 * 1024) {
            alert('Kích thước file vượt quá 2MB! Vui lòng chọn ảnh nhẹ hơn.');
            fileInput.value = '';
            return;
        }
        document.getElementById('avatarUploadForm').submit();
    }
}

function confirmDeleteAvatar() {
    if (confirm('Bạn có chắc chắn muốn xóa ảnh đại diện hiện tại không?')) {
        document.getElementById('avatarDeleteForm').submit();
    }
}

document.addEventListener('DOMContentLoaded', function() {
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

function updateOrderCounts() {
    const cards = document.querySelectorAll('#ordersContainer .shopee-order-card, #ordersContainer .order-card');
    if (!cards || cards.length === 0) return;

    let pendingCount = 0;
    let processingCount = 0;
    let shippingCount = 0;
    let deliveredCount = 0;
    let returnedCount = 0;
    let cancelledCount = 0;

    cards.forEach(card => {
        const s = (card.getAttribute('data-order-status') || '').toUpperCase();
        if (s === 'PENDING') pendingCount++;
        if (s === 'PROCESSING' || s === 'CONFIRMED') processingCount++;
        if (s === 'SHIPPING') shippingCount++;
        if (s === 'COMPLETED' || s === 'DELIVERED') deliveredCount++;
        if (s === 'RETURNED' || s === 'REFUNDED' || s === 'DISPUTED') returnedCount++;
        if (s === 'CANCELLED') cancelledCount++;
    });

    const setBadge = (id, count) => {
        const el = document.getElementById(id);
        if (el) el.textContent = count;
    };

    setBadge('count-all', cards.length);
    setBadge('count-pending', pendingCount);
    setBadge('count-processing', processingCount);
    setBadge('count-shipping', shippingCount);
    setBadge('count-delivered', deliveredCount);
    setBadge('count-returned', returnedCount);
    setBadge('count-cancelled', cancelledCount);
}

function filterOrders(filter, btn) {
    document.querySelectorAll('.order-filter-btn').forEach(b => b.classList.remove('active'));
    if (btn) btn.classList.add('active');

    const cards = document.querySelectorAll('#ordersContainer .shopee-order-card, #ordersContainer .order-card');
    let visibleCount = 0;

    cards.forEach(card => {
        const s = (card.getAttribute('data-order-status') || '').toUpperCase();
        let match = false;

        if (filter === 'all') {
            match = true;
        } else if (filter === 'pending') {
            match = (s === 'PENDING');
        } else if (filter === 'processing') {
            match = (s === 'PROCESSING' || s === 'CONFIRMED');
        } else if (filter === 'shipping') {
            match = (s === 'SHIPPING');
        } else if (filter === 'delivered') {
            match = (s === 'COMPLETED' || s === 'DELIVERED');
        } else if (filter === 'returned') {
            match = (s === 'RETURNED' || s === 'REFUNDED' || s === 'DISPUTED');
        } else if (filter === 'cancelled') {
            match = (s === 'CANCELLED');
        }

        if (match) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });

    const emptyBox = document.getElementById('ordersEmptyFilter');
    if (emptyBox) {
        if (visibleCount === 0) {
            emptyBox.classList.remove('d-none');
        } else {
            emptyBox.classList.add('d-none');
        }
    }
}

function searchOrders(keyword) {
    const kw = (keyword || '').trim().toLowerCase();
    const cards = document.querySelectorAll('#ordersContainer .shopee-order-card, #ordersContainer .order-card');
    let visibleCount = 0;

    cards.forEach(card => {
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

    const emptyBox = document.getElementById('ordersEmptyFilter');
    if (emptyBox) {
        if (visibleCount === 0) {
            emptyBox.classList.remove('d-none');
        } else {
            emptyBox.classList.add('d-none');
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
    if (amount === undefined || amount === null || isNaN(amount)) return '0₫';
    return new Intl.NumberFormat('vi-VN').format(Number(amount)) + '₫';
}

function showOrderTracking(orderId) {
    if (!orderId) return;

    const card = document.querySelector('.shopee-order-card[data-order-id="' + orderId + '"]');
    if (!card) {
        console.warn('Order card not found for ID: ' + orderId);
        return;
    }

    const status = (card.getAttribute('data-order-status') || 'PENDING').toUpperCase();
    const shopName = card.getAttribute('data-shop-name') || 'Gốc Vườn Official Store';
    const recipientName = card.getAttribute('data-recipient-name') || 'Người nhận';
    const recipientPhone = card.getAttribute('data-recipient-phone') || '0903 *** ***';
    const recipientAddress = card.getAttribute('data-recipient-address') || 'Địa chỉ giao hàng';
    const goodsAmount = card.getAttribute('data-goods-amount') || 0;
    const shippingFee = card.getAttribute('data-shipping-fee') || 25000;
    const discount = card.getAttribute('data-discount') || 0;
    const finalAmount = card.getAttribute('data-final-amount') || goodsAmount;
    const paymentMethod = card.getAttribute('data-payment-method') || 'COD';

    // 1. Header Order Code
    const orderCodeEl = document.getElementById('trackOrderCode');
    if (orderCodeEl) orderCodeEl.textContent = '#' + orderId;

    // 2. Recipient info
    const recNameEl = document.getElementById('trackRecipientName');
    if (recNameEl) recNameEl.textContent = recipientName;

    const recPhoneEl = document.getElementById('trackRecipientPhone');
    if (recPhoneEl) recPhoneEl.textContent = recipientPhone;

    const recAddrEl = document.getElementById('trackRecipientAddress');
    if (recAddrEl) recAddrEl.textContent = recipientAddress;

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

    // 5. Adapt Stepper and GPS Map depending on Status
    const estTimeEl = document.getElementById('trackEstimatedTime');
    const gpsCard = document.getElementById('trackGpsCard');
    const driverCard = document.getElementById('trackDriverCard');

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

    // Reset all steps
    [step1, step2, step3, step4, step5, step6].forEach(s => {
        if (s) {
            s.className = 'stepper-step';
            const c = s.querySelector('.stepper-circle');
            if (c) c.classList.remove('pulse');
        }
    });
    [line1, line2, line3, line4, line5].forEach(l => {
        if (l) l.className = 'stepper-line';
    });

    if (status === 'CANCELLED') {
        if (estTimeEl) {
            estTimeEl.textContent = 'Đơn hàng đã được hủy';
            estTimeEl.className = 'small fw-semibold text-danger bg-danger-subtle px-3 py-1 rounded-pill border border-danger-subtle';
        }
        if (step1) step1.classList.add('completed');
        if (line1) line1.classList.add('completed');
        if (step2) {
            step2.className = 'stepper-step cancelled';
            const c = step2.querySelector('.stepper-circle');
            if (c) c.innerHTML = '<i class="bi bi-x-lg"></i>';
            const t = step2.querySelector('.stepper-title');
            if (t) t.textContent = 'Đã hủy đơn';
        }
        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'none';
    } else if (status === 'COMPLETED' || status === 'DELIVERED') {
        if (estTimeEl) {
            estTimeEl.textContent = 'Giao hàng thành công';
            estTimeEl.className = 'small fw-semibold text-success bg-success-subtle px-3 py-1 rounded-pill border border-success-subtle';
        }
        [step1, step2, step3, step4, step5, step6].forEach(s => s && s.classList.add('completed'));
        [line1, line2, line3, line4, line5].forEach(l => l && l.classList.add('completed'));
        const step6Title = document.getElementById('trackTitle6');
        if (step6Title) step6Title.textContent = 'Đã nhận quả tươi';
        const step6Time = document.getElementById('trackTime6');
        if (step6Time) step6Time.textContent = 'Hoàn tất';
        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'block';
    } else if (status === 'SHIPPING') {
        if (estTimeEl) {
            estTimeEl.textContent = 'Dự kiến giao: 11:30 hôm nay';
            estTimeEl.className = 'small fw-semibold text-success bg-success-subtle px-3 py-1 rounded-pill border border-success-subtle';
        }
        [step1, step2, step3, step4].forEach(s => s && s.classList.add('completed'));
        [line1, line2, line3, line4].forEach(l => l && l.classList.add('completed'));
        if (step5) {
            step5.className = 'stepper-step active';
            const c = step5.querySelector('.stepper-circle');
            if (c) c.classList.add('pulse');
        }
        if (line5) line5.className = 'stepper-line active';
        if (gpsCard) gpsCard.style.display = 'block';
        if (driverCard) driverCard.style.display = 'block';
    } else if (status === 'PROCESSING' || status === 'CONFIRMED') {
        if (estTimeEl) {
            estTimeEl.textContent = 'Nhà vườn đang đóng gói';
            estTimeEl.className = 'small fw-semibold text-primary bg-primary-subtle px-3 py-1 rounded-pill border border-primary-subtle';
        }
        [step1, step2].forEach(s => s && s.classList.add('completed'));
        if (line1) line1.classList.add('completed');
        if (line2) line2.classList.add('completed');
        if (step3) {
            step3.className = 'stepper-step active';
            const c = step3.querySelector('.stepper-circle');
            if (c) c.classList.add('pulse');
        }
        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'none';
    } else {
        if (estTimeEl) {
            estTimeEl.textContent = 'Chờ shop xác nhận';
            estTimeEl.className = 'small fw-semibold text-warning bg-warning-subtle px-3 py-1 rounded-pill border border-warning-subtle';
        }
        if (step1) {
            step1.className = 'stepper-step active';
            const c = step1.querySelector('.stepper-circle');
            if (c) c.classList.add('pulse');
        }
        if (gpsCard) gpsCard.style.display = 'none';
        if (driverCard) driverCard.style.display = 'none';
    }

    // 6. Launch Bootstrap Modal
    const modalEl = document.getElementById('orderTrackingModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const m = bootstrap.Modal.getOrCreateInstance(modalEl);
        m.show();
    }
}

function cancelOrder(orderId) {
    if (confirm('Bạn có chắc chắn muốn hủy đơn hàng #' + orderId + '?')) {
        alert('Đã gửi yêu cầu hủy đơn hàng #' + orderId + ' đến người bán.');
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




