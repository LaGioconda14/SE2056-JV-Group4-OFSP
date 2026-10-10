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
            const res = await fetch('https://provinces.open-api.vn/api/p/');
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
                const res = await fetch('https://provinces.open-api.vn/api/p/' + pCode + '?depth=2');
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
                const res = await fetch('https://provinces.open-api.vn/api/d/' + dCode + '?depth=2');
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
});

