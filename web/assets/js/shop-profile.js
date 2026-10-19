/* =========================================================
   SHOP PROFILE - tab, trạng thái shop, banner/logo,
   dropdown địa chỉ VN (có tìm kiếm), danh sách ngân hàng
   ========================================================= */

/* ---------- TAB ---------- */
const TAB_ACTIVE = ['bg-emerald-600', 'text-white', 'shadow-sm'];
const TAB_IDLE = ['text-slate-600', 'hover:bg-slate-50'];

function switchTab(tabId) {
  document.querySelectorAll('.tab-content').forEach(c => {
    c.classList.add('hidden');
    c.classList.remove('flex', 'active');
  });
  document.querySelectorAll('.tab-button').forEach(btn => {
    btn.classList.remove(...TAB_ACTIVE);
    btn.classList.add(...TAB_IDLE);
  });

  const content = document.getElementById('tab-' + tabId);
  if (content) {
    content.classList.remove('hidden');
    content.classList.add('flex', 'active');
  }
  const btn = document.getElementById('tab-btn-' + tabId);
  if (btn) {
    btn.classList.remove(...TAB_IDLE);
    btn.classList.add(...TAB_ACTIVE);
  }
}

function saveAllSettings() {
  const form = document.getElementById('profileForm');
  if (form) form.submit();
}

/* ---------- TRẠNG THÁI SHOP ---------- */
const STATUS_INFO = {
  open:   { text: 'Đang hoạt động (Open For Orders)', cls: 'text-emerald-600' },
  paused: { text: 'Tạm ngưng nhận đơn (Paused)',      cls: 'text-amber-600' },
  closed: { text: 'Đã đóng cửa (Closed)',             cls: 'text-red-600' }
};

function setShopStatus(status) {
  const info = STATUS_INFO[status];
  if (!info) return;
  document.getElementById('shopStatusInput').value = status;
  const label = document.getElementById('statusText');
  label.textContent = info.text;
  label.className = 'font-bold text-sm ' + info.cls;
  document.querySelectorAll('.status-btn').forEach(b => {
    b.classList.toggle('is-active', b.dataset.status === status);
  });
}

/* ---------- BANNER & LOGO ---------- */
function initMedia() {
  const bannerFile = document.getElementById('bannerFile');
  const bannerBox = document.getElementById('bannerBox');
  bannerFile.addEventListener('change', () => {
    const f = bannerFile.files[0];
    if (f) bannerBox.style.backgroundImage = "url('" + URL.createObjectURL(f) + "')";
  });

  const logoFile = document.getElementById('logoFile');
  const logoImg = document.getElementById('logoImg');
  const logoMenu = document.getElementById('logoMenu');
  const logoBtn = document.getElementById('logoBtn');

  logoBtn.addEventListener('click', e => {
    e.stopPropagation();
    logoMenu.classList.toggle('hidden');
  });
  document.addEventListener('click', e => {
    if (!logoMenu.contains(e.target)) logoMenu.classList.add('hidden');
  });

  document.getElementById('logoChangeBtn').addEventListener('click', () => {
    logoMenu.classList.add('hidden');
    logoFile.click();
  });
  logoFile.addEventListener('change', () => {
    const f = logoFile.files[0];
    if (f) logoImg.src = URL.createObjectURL(f);
  });

  const box = document.getElementById('logoLightbox');
  const boxImg = document.getElementById('logoLightboxImg');
  const closeBox = () => box.classList.remove('show');
  document.getElementById('logoViewBtn').addEventListener('click', () => {
    logoMenu.classList.add('hidden');
    boxImg.src = logoImg.src;
    box.classList.add('show');
  });
  document.getElementById('logoLightboxClose').addEventListener('click', closeBox);
  box.addEventListener('click', e => { if (e.target === box) closeBox(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape') closeBox(); });
}

/* ---------- COMBOBOX CÓ TÌM KIẾM ---------- */
function removeAccent(s) {
  return (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd').replace(/Đ/g, 'D').toLowerCase().trim();
}
// Bỏ tiền tố hành chính để so khớp "Hà Nội" với "Thành phố Hà Nội"
function normalizeAdmin(s) {
  return removeAccent(s)
    .replace(/^(thanh pho|tinh|quan|huyen|thi xa|thi tran|phuong|xa|tp\.?)\s+/, '')
    .trim();
}

class Combo {
  /**
   * @param {string} rootId  id của div.combo
   * @param {function(item):void} onSelect  gọi khi người dùng chọn 1 mục
   */
  constructor(rootId, onSelect) {
    this.root = document.getElementById(rootId);
    this.input = this.root.querySelector('.combo-input');
    this.list = this.root.querySelector('.combo-list');
    this.items = [];           // [{name, code}]
    this.selected = null;      // item đang chọn
    this.validText = this.input.value; // giá trị hợp lệ gần nhất
    this.onSelect = onSelect || function () {};

    this.input.addEventListener('focus', () => this.open(false));
    this.input.addEventListener('click', () => this.open(false));
    this.input.addEventListener('input', () => this.open(true));
    this.input.addEventListener('keydown', e => this.onKey(e));
    document.addEventListener('mousedown', e => {
      if (!this.root.contains(e.target)) this.close();
    });
  }

  setItems(items) {
    this.items = items || [];
    this.render('');
  }

  // Khớp giá trị đang có (từ DB) với danh sách để lấy code
  matchCurrent() {
    const cur = normalizeAdmin(this.input.value);
    if (!cur) { this.selected = null; return null; }
    const found = this.items.find(i => normalizeAdmin(i.name) === cur);
    this.selected = found || null;
    return this.selected;
  }

  setDisabled(disabled) { this.input.disabled = disabled; }

  clear() {
    this.input.value = '';
    this.validText = '';
    this.selected = null;
  }

  open(filter) {
    if (this.input.disabled) return;
    this.render(filter ? this.input.value : '');
    this.list.classList.remove('hidden');
  }

  close() {
    this.list.classList.add('hidden');
    // Nếu gõ dở mà không chọn -> quay về giá trị hợp lệ gần nhất
    if (this.input.value !== this.validText) {
      const hit = this.items.find(i => removeAccent(i.name) === removeAccent(this.input.value));
      if (hit) this.choose(hit); else this.input.value = this.validText;
    }
  }

  render(keyword) {
    const k = removeAccent(keyword);
    const shown = k ? this.items.filter(i => removeAccent(i.name).includes(k)) : this.items;
    this.list.innerHTML = '';
    if (!shown.length) {
      const empty = document.createElement('div');
      empty.className = 'combo-empty';
      empty.textContent = this.items.length ? 'Không tìm thấy kết quả' : 'Đang tải danh sách...';
      this.list.appendChild(empty);
      return;
    }
    shown.forEach(item => {
      const el = document.createElement('div');
      el.className = 'combo-item' + (this.selected && this.selected.name === item.name ? ' is-selected' : '');
      el.textContent = item.name;
      el.addEventListener('mousedown', e => { e.preventDefault(); this.choose(item); });
      this.list.appendChild(el);
    });
  }

  choose(item) {
    const changed = !this.selected || this.selected.name !== item.name;
    this.selected = item;
    this.input.value = item.name;
    this.validText = item.name;
    this.list.classList.add('hidden');
    if (changed) this.onSelect(item);
  }

  onKey(e) {
    const els = Array.from(this.list.querySelectorAll('.combo-item'));
    let idx = els.findIndex(el => el.classList.contains('is-hover'));
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      this.list.classList.remove('hidden');
      if (!els.length) return;
      if (idx >= 0) els[idx].classList.remove('is-hover');
      idx = e.key === 'ArrowDown' ? (idx + 1) % els.length : (idx - 1 + els.length) % els.length;
      els[idx].classList.add('is-hover');
      els[idx].scrollIntoView({ block: 'nearest' });
    } else if (e.key === 'Enter') {
      if (!this.list.classList.contains('hidden')) {
        e.preventDefault();
        const target = idx >= 0 ? els[idx] : els[0];
        if (target) target.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }));
      }
    } else if (e.key === 'Escape') {
      this.close();
    }
  }
}

/* ---------- ĐỊA CHỈ VIỆT NAM (provinces.open-api.vn) ---------- */
const VN_API = 'https://provinces.open-api.vn/api';

async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error('HTTP ' + res.status);
  return res.json();
}

function initAddress() {
  const ward = new Combo('comboWard');
  const district = new Combo('comboDistrict', async item => {
    ward.clear();
    await loadWards(item.code);
  });
  const province = new Combo('comboProvince', async item => {
    district.clear();
    ward.clear();
    ward.setItems([]);
    await loadDistricts(item.code);
  });

  async function loadDistricts(provinceCode) {
    try {
      const data = await fetchJson(VN_API + '/p/' + provinceCode + '?depth=2');
      district.setItems((data.districts || []).map(d => ({ name: d.name, code: d.code })));
    } catch (e) { district.setItems([]); }
  }
  async function loadWards(districtCode) {
    try {
      const data = await fetchJson(VN_API + '/d/' + districtCode + '?depth=2');
      ward.setItems((data.wards || []).map(w => ({ name: w.name, code: w.code })));
    } catch (e) { ward.setItems([]); }
  }

  // Tải tỉnh/thành, rồi khôi phục huyện/xã theo dữ liệu đã lưu
  (async () => {
    try {
      const provinces = await fetchJson(VN_API + '/p/');
      province.setItems(provinces.map(p => ({ name: p.name, code: p.code })));
      const p = province.matchCurrent();
      if (p) {
        await loadDistricts(p.code);
        const d = district.matchCurrent();
        if (d) {
          await loadWards(d.code);
          ward.matchCurrent();
        }
      }
    } catch (e) {
      console.warn('Không tải được danh sách địa chỉ VN', e);
      province.list.innerHTML = '<div class="combo-empty">Không tải được danh sách. Kiểm tra mạng rồi tải lại trang.</div>';
    }
  })();
}

/* ---------- NGÂN HÀNG ---------- */
const VN_BANKS = [
  'Vietcombank - Ngoại thương Việt Nam (VCB)', 'VietinBank - Công thương Việt Nam (CTG)',
  'BIDV - Đầu tư và Phát triển Việt Nam', 'Agribank - Nông nghiệp và Phát triển Nông thôn',
  'Techcombank - Kỹ thương Việt Nam (TCB)', 'MB Bank - Quân đội (MBB)',
  'ACB - Á Châu', 'VPBank - Việt Nam Thịnh Vượng', 'TPBank - Tiên Phong',
  'Sacombank - Sài Gòn Thương Tín (STB)', 'HDBank - Phát triển TP.HCM',
  'VIB - Quốc tế Việt Nam', 'SHB - Sài Gòn - Hà Nội', 'SeABank - Đông Nam Á',
  'OCB - Phương Đông', 'MSB - Hàng Hải Việt Nam (Maritime Bank)', 'Eximbank - Xuất nhập khẩu Việt Nam',
  'LPBank - Lộc Phát Việt Nam (LienVietPostBank)', 'SCB - Sài Gòn', 'Nam A Bank - Nam Á',
  'ABBANK - An Bình', 'Bac A Bank - Bắc Á', 'BaoViet Bank - Bảo Việt', 'VietBank - Việt Nam Thương Tín',
  'PVcomBank - Đại chúng Việt Nam', 'NCB - Quốc Dân', 'Kienlongbank - Kiên Long',
  'Saigonbank - Sài Gòn Công Thương', 'PG Bank - Xăng dầu Petrolimex', 'VietABank - Việt Á',
  'BVBank - Bản Việt (Viet Capital Bank)', 'GPBank - Dầu Khí Toàn Cầu', 'CBBank - Xây dựng Việt Nam',
  'OceanBank - Đại Dương', 'Dong A Bank - Đông Á', 'Co-opBank - Hợp tác xã Việt Nam',
  'Shinhan Bank Việt Nam', 'Woori Bank Việt Nam', 'HSBC Việt Nam', 'Standard Chartered Việt Nam',
  'UOB Việt Nam', 'Public Bank Việt Nam', 'CIMB Bank Việt Nam', 'Hong Leong Bank Việt Nam',
  'ANZ Việt Nam', 'Indovina Bank (IVB)', 'Vietnam - Russia Bank (VRB)',
  'Timo (Digital Bank)', 'Cake by VPBank', 'Ubank by VPBank', 'MoMo (Ví điện tử)', 'ZaloPay (Ví điện tử)', 'ViettelMoney (Ví điện tử)'
].map(name => ({ name, code: name }));

function initBank() {
  const bank = new Combo('comboBank');
  bank.setItems(VN_BANKS);
  // Nếu giá trị đã lưu khác định dạng danh sách, giữ nguyên giá trị đó
  const cur = bank.input.value;
  if (cur) {
    const hit = VN_BANKS.find(b => removeAccent(b.name).includes(removeAccent(cur)));
    if (hit) { bank.selected = hit; }
  }
}

/* ---------- HỦY THAY ĐỔI ---------- */
function initDiscard() {
  document.getElementById('discardBtn').addEventListener('click', () => {
    if (confirm('Hủy toàn bộ thay đổi chưa lưu và quay về dữ liệu ban đầu?')) {
      // Tải lại trang bằng GET để lấy lại dữ liệu đã lưu trong DB
      window.location.href = window.location.pathname;
    }
  });
}

/* ---------- KHỞI TẠO ---------- */
document.addEventListener('DOMContentLoaded', () => {
  const current = document.getElementById('shopStatusInput').value || 'open';
  setShopStatus(current);
  document.querySelectorAll('.status-btn').forEach(b => {
    b.addEventListener('click', () => setShopStatus(b.dataset.status));
  });
  initMedia();
  initAddress();
  initBank();
  initDiscard();
});
