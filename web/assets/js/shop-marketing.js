/* Promotion & Voucher của shop - tiện ích dùng chung */
(function () {
  'use strict';

  function $(sel, root) { return (root || document).querySelector(sel); }
  function $all(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }

  /* ---- Copy mã voucher ---- */
  window.copyVoucherCode = function (btn, code) {
    var done = function () {
      var old = btn.innerHTML;
      btn.innerHTML = '<i class="fa-solid fa-check"></i>';
      setTimeout(function () { btn.innerHTML = old; }, 1200);
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(code).then(done);
    } else {
      var t = document.createElement('textarea');
      t.value = code; document.body.appendChild(t); t.select();
      try { document.execCommand('copy'); done(); } catch (e) { /* bỏ qua */ }
      document.body.removeChild(t);
    }
  };

  /* ---- Xác nhận trước khi gửi form thao tác ---- */
  document.addEventListener('submit', function (e) {
    var msg = e.target.getAttribute('data-confirm');
    if (msg && !window.confirm(msg)) e.preventDefault();
  });

  /* ---- Tự ẩn thông báo ---- */
  $all('[data-autohide]').forEach(function (el) {
    setTimeout(function () { el.style.transition = 'opacity .4s'; el.style.opacity = '0'; setTimeout(function () { el.remove(); }, 450); }, 5000);
  });

  /* ---- Form: loại giảm giá (phần trăm / cố định) ---- */
  function bindType() {
    var radios = $all('input[name="discountType"], input[name="promotionType"]');
    if (!radios.length) return;
    function refresh() {
      var checked = radios.filter(function (r) { return r.checked; })[0];
      var pct = !checked || checked.value === 'PERCENTAGE';
      $all('[data-show-pct]').forEach(function (el) { el.style.display = pct ? '' : 'none'; });
      var unit = $('#valueUnit');
      if (unit) unit.textContent = pct ? '%' : '₫';
      var val = $('#discountValue');
      if (val) val.placeholder = pct ? 'VD: 10' : 'VD: 20000';
      updatePreview();
    }
    radios.forEach(function (r) { r.addEventListener('change', refresh); });
    refresh();
  }

  /* ---- Form: phạm vi áp dụng voucher ---- */
  function bindScope() {
    var radios = $all('input[name="appliesTo"]');
    var box = $('#scopeProducts');
    if (!radios.length || !box) return;
    function refresh() {
      var c = radios.filter(function (r) { return r.checked; })[0];
      box.style.display = c && c.value === 'PRODUCTS' ? '' : 'none';
    }
    radios.forEach(function (r) { r.addEventListener('change', refresh); });
    refresh();
  }

  /* ---- Chọn sản phẩm ---- */
  function bindPicker() {
    var picker = $('#productPicker');
    if (!picker) return;
    var items = $all('.mk-picker-item', picker);
    var search = $('#pickerSearch');
    var counter = $('#pickerCount');

    function count() {
      var n = items.filter(function (i) { return $('input', i).checked; }).length;
      if (counter) counter.textContent = n;
    }
    function norm(s) {
      return (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').toLowerCase();
    }
    if (search) {
      search.addEventListener('input', function () {
        var k = norm(search.value);
        items.forEach(function (i) {
          i.classList.toggle('hidden-item', k && norm(i.getAttribute('data-name')).indexOf(k) === -1);
        });
      });
    }
    var all = $('#pickerAll'), none = $('#pickerNone');
    if (all) all.addEventListener('click', function () {
      items.forEach(function (i) { if (!i.classList.contains('hidden-item')) $('input', i).checked = true; });
      count();
    });
    if (none) none.addEventListener('click', function () {
      items.forEach(function (i) { $('input', i).checked = false; });
      count();
    });
    items.forEach(function (i) { $('input', i).addEventListener('change', count); });
    count();
  }

  /* ---- Xem trước voucher (form voucher) ---- */
  function fmtMoney(n) { return new Intl.NumberFormat('vi-VN').format(n); }
  function updatePreview() {
    var box = $('#ticketPreview');
    if (!box) return;
    var type = ($('input[name="discountType"]:checked') || {}).value || 'PERCENTAGE';
    var val = parseFloat(($('#discountValue') || {}).value) || 0;
    var min = parseInt((($('#minOrderValue') || {}).value || '0').replace(/[.,\s]/g, ''), 10) || 0;
    var max = parseInt((($('#maxDiscountAmount') || {}).value || '0').replace(/[.,\s]/g, ''), 10) || 0;
    var code = ($('#codeInput') || {}).value || 'MA-VOUCHER';
    var title = ($('#titleInput') || {}).value || 'Tên chương trình voucher';

    $('#pvVal').textContent = type === 'PERCENTAGE' ? (val || 0) + '%' : (val >= 1000 ? Math.round(val / 1000) + 'K' : fmtMoney(val));
    var meta = [];
    meta.push(min > 0 ? 'Đơn tối thiểu ' + fmtMoney(min) + '₫' : 'Không yêu cầu đơn tối thiểu');
    if (type === 'PERCENTAGE' && max > 0) meta.push('Giảm tối đa ' + fmtMoney(max) + '₫');
    $('#pvTitle').textContent = title;
    $('#pvMeta').textContent = meta.join(' · ');
    $('#pvCode').textContent = (code || '').toUpperCase() || 'MA-VOUCHER';
  }
  function bindPreview() {
    ['#discountValue', '#minOrderValue', '#maxDiscountAmount', '#codeInput', '#titleInput'].forEach(function (s) {
      var el = $(s);
      if (el) el.addEventListener('input', updatePreview);
    });
    updatePreview();
  }

  document.addEventListener('DOMContentLoaded', function () {
    bindType();
    bindScope();
    bindPicker();
    bindPreview();
  });
})();
