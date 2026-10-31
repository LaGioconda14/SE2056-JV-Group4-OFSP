function updateNameCounter(input) {
    const el = document.getElementById('nameCounter');
    if (el && input) {
        el.innerText = input.value.length + '/120 ký tự';
    }
}

function selectStorageTag(btn, val) {
    document.querySelectorAll('.storage-tag-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    const input = document.getElementById('inputStorageTemp');
    if (input) input.value = val;
}

function toggleCert(label) {
    const cb = label.querySelector('input[type="checkbox"]');
    setTimeout(() => {
        if (cb && cb.checked) {
            label.classList.add('selected');
        } else {
            label.classList.remove('selected');
        }
    }, 50);
}

function selectUnit(card, unitName) {
    document.querySelectorAll('.unit-radio-card').forEach(c => {
        c.classList.remove('active');
        const icon = c.querySelector('i');
        if (icon) icon.className = 'fa-regular fa-circle text-slate-400 text-sm';
    });
    card.classList.add('active');
    const icon = card.querySelector('i');
    if (icon) icon.className = 'fa-solid fa-circle-dot text-emerald-700 text-sm';

    const input = document.getElementById('inputUnit');
    if (input) input.value = unitName;
    
    let shortUnit = "Đơn vị";
    if (unitName.includes("Hộp")) shortUnit = "Hộp";
    else if (unitName.includes("Kg")) shortUnit = "Kg";
    else if (unitName.includes("Quả")) shortUnit = "Quả";
    else if (unitName.includes("Giỏ")) shortUnit = "Giỏ";

    const s1 = document.getElementById('unitStockSuffix');
    if (s1) s1.innerText = shortUnit;
    const s2 = document.getElementById('unitThresholdSuffix');
    if (s2) s2.innerText = shortUnit;
}

function setStatus(statusVal, label) {
    const statusInput = document.getElementById('inputStatus');
    if (statusInput) statusInput.value = statusVal;

    const labels = label.parentElement.querySelectorAll('label');
    labels.forEach(l => {
        l.className = 'border border-slate-200 bg-white rounded-xl p-4 flex items-start gap-3 cursor-pointer transition';
    });
    if (statusVal === 'active') {
        label.className = 'border border-emerald-600 bg-emerald-50/40 rounded-xl p-4 flex items-start gap-3 cursor-pointer transition';
    } else {
        label.className = 'border border-amber-500 bg-amber-50/40 rounded-xl p-4 flex items-start gap-3 cursor-pointer transition';
    }
}

function autoFillDescSEO() {
    const nameInput = document.getElementById('productNameInput');
    const name = nameInput ? nameInput.value : '';
    const desc = name + " chuẩn VietGAP thu hái từ sáng sớm tại vườn Đà Lạt. Vị thơm ngọt tự nhiên, thịt quả mọng nước, giàu Vitamin C & chất chống oxy hóa. Đóng gói đạt chuẩn chuỗi lạnh FreshCold 2H chuyển nhanh tới tận tay người tiêu dùng.";
    const descInput = document.getElementById('productDescTextarea');
    if (descInput) descInput.value = desc;
}

function promptImage(index) {
    const input = document.getElementById('inputImgDetail' + index);
    if (!input) return;
    const currentUrl = input.value;
    const newUrl = prompt("Nhập URL ảnh chi tiết góc chụp " + index + ":", currentUrl);
    if (newUrl && newUrl.trim() !== "") {
        input.value = newUrl.trim();
        const thumb = document.getElementById('thumb' + index);
        if (thumb) thumb.src = newUrl.trim();
    }
}

function submitEditForm() {
    const form = document.getElementById('editProductForm');
    const nameInput = document.getElementById('productNameInput');
    const name = nameInput ? nameInput.value : '';

    if (!name || name.trim() === "") {
        alert("Vui lòng nhập tên sản phẩm nông sản!");
        if (nameInput) nameInput.focus();
        return;
    }

    if (form) form.submit();
}

function submitForm(action) {
    const form = document.getElementById('addProductForm');
    const nameInput = document.getElementById('productNameInput');
    const name = nameInput ? nameInput.value : '';

    if (!name || name.trim() === "") {
        alert("Vui lòng nhập tên sản phẩm nông sản!");
        if (nameInput) nameInput.focus();
        return;
    }

    if (form) form.submit();
}

document.addEventListener('DOMContentLoaded', () => {
    const nameInput = document.getElementById('productNameInput');
    if (nameInput) updateNameCounter(nameInput);
});

