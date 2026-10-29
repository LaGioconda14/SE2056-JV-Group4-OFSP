/* ========================================================
   ĐĂNG KÝ SHOP - bước form, xem trước ảnh, tóm tắt, modal điều khoản
   ======================================================== */
(function () {
  'use strict';

  var TOTAL_STEPS = 5;
  var currentStep = 1;

  function $(id) { return document.getElementById(id); }

  /* ---------- Stepper ---------- */
  function updateProgressBar() {
    var bar = $('stepperProgress');
    if (!bar) return;
    // Thanh chạy trong khoảng 80% chiều rộng (từ 10% đến 90%)
    var pct = ((currentStep - 1) / (TOTAL_STEPS - 1)) * 80;
    bar.style.width = pct + '%';
  }

  function showStep(step, scroll) {
    document.querySelectorAll('.rs-step-panel').forEach(function (p) { p.classList.remove('active'); });
    $('step-' + step).classList.add('active');

    for (var i = 1; i <= TOTAL_STEPS; i++) {
      var ind = $('step-indicator-' + i);
      var counter = ind.querySelector('.rs-step-counter');
      ind.classList.remove('active', 'completed');
      if (i < step) {
        ind.classList.add('completed');
        counter.innerHTML = '<i class="fa-solid fa-check"></i>';
      } else {
        counter.textContent = i;
        if (i === step) ind.classList.add('active');
      }
    }
    currentStep = step;
    updateProgressBar();
    if (step === TOTAL_STEPS) fillSummary();
    if (scroll !== false) {
      var top = $('rsTop');
      if (top) top.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  window.nextStep = function (step) {
    if (validateStep(step)) showStep(step + 1);
  };
  window.prevStep = function (step) {
    showStep(step - 1);
  };

  /* ---------- Validate ---------- */
  function validateStep(step) {
    var container = $('step-' + step);
    var ok = true;
    var firstBad = null;

    container.querySelectorAll('input, select, textarea').forEach(function (el) {
      if (!el.hasAttribute('required')) return;
      var bad = false;
      if (el.type === 'file') {
        var err = $('err-' + el.id);
        bad = !el.files || el.files.length === 0;
        if (err) err.classList.toggle('show', bad);
      } else if (el.type === 'checkbox') {
        bad = !el.checked;
        el.classList.toggle('is-invalid', bad);
      } else {
        bad = !el.checkValidity();
        el.classList.toggle('is-invalid', bad);
      }
      if (bad) {
        ok = false;
        if (!firstBad) firstBad = el;
      }
    });

    if (!ok && firstBad && firstBad.type !== 'file' && firstBad.focus) firstBad.focus({ preventScroll: false });
    return ok;
  }

  // Xóa trạng thái lỗi khi người dùng sửa
  document.addEventListener('input', function (e) {
    if (e.target.classList && e.target.classList.contains('is-invalid') && e.target.checkValidity()) {
      e.target.classList.remove('is-invalid');
    }
  });
  document.addEventListener('change', function (e) {
    if (e.target.type === 'checkbox' && e.target.checked) e.target.classList.remove('is-invalid');
  });

  /* ---------- Ảnh ---------- */
  window.previewImage = function (input, previewId, boxId, wrapperId) {
    var errEl = $('err-' + input.id);
    if (input.files && input.files[0]) {
      var file = input.files[0];
      if (file.size > 10 * 1024 * 1024) {
        alert('Ảnh quá lớn. Vui lòng chọn ảnh tối đa 10MB.');
        input.value = '';
        return;
      }
      var reader = new FileReader();
      reader.onload = function (e) {
        $(previewId).src = e.target.result;
        $(boxId).classList.add('hidden');
        $(wrapperId).classList.remove('hidden');
        if (errEl) errEl.classList.remove('show');
      };
      reader.readAsDataURL(file);
    }
  };
  window.removeImage = function (inputId, previewId, boxId, wrapperId) {
    $(inputId).value = '';
    $(previewId).src = '';
    $(wrapperId).classList.add('hidden');
    $(boxId).classList.remove('hidden');
  };

  /* ---------- Tóm tắt ở bước 5 ---------- */
  function val(name) {
    var el = document.querySelector('#multiStepForm [name="' + name + '"]');
    return el ? (el.value || '').trim() : '';
  }
  function selText(name) {
    var el = document.querySelector('#multiStepForm [name="' + name + '"]');
    return el && el.selectedIndex >= 0 ? el.options[el.selectedIndex].text : '';
  }
  function set(id, text) {
    var el = $(id);
    if (el) el.textContent = text && text.length ? text : '—';
  }
  function fillSummary() {
    set('sum-owner', [val('fullName'), val('phone'), val('email')].filter(Boolean).join(' · '));
    set('sum-shop', [val('shopName'), selText('businessType')].filter(function (x) { return x && x.indexOf('--') !== 0; }).join(' · '));
    set('sum-address', [val('streetAddress'), val('ward'), val('district'), val('province')].filter(Boolean).join(', '));
    set('sum-bank', [selText('bankName'), val('bankAccountNumber'), val('bankAccountHolder')].filter(function (x) { return x && x.indexOf('--') !== 0; }).join(' · '));
  }

  /* ---------- Modal điều khoản ---------- */
  var openModalEl = null;
  var lastFocus = null;

  function openModal(id) {
    var modal = $('modal-' + id);
    if (!modal) return;
    lastFocus = document.activeElement;
    modal.hidden = false;
    document.body.style.overflow = 'hidden';
    openModalEl = modal;
    var body = modal.querySelector('.tm-body');
    body.scrollTop = 0;
    updateReadProgress(modal);
    var closeBtn = modal.querySelector('.tm-close');
    if (closeBtn) closeBtn.focus();
  }
  function closeModal() {
    if (!openModalEl) return;
    openModalEl.hidden = true;
    openModalEl = null;
    document.body.style.overflow = '';
    if (lastFocus && lastFocus.focus) lastFocus.focus();
  }
  function updateReadProgress(modal) {
    var body = modal.querySelector('.tm-body');
    var label = modal.querySelector('.tm-progress');
    if (!body || !label) return;
    var max = body.scrollHeight - body.clientHeight;
    var pct = max <= 0 ? 100 : Math.min(100, Math.round((body.scrollTop / max) * 100));
    if (pct >= 98) {
      label.textContent = 'Đã đọc hết nội dung';
      label.classList.add('done');
    } else {
      label.textContent = 'Đã đọc ' + pct + '%';
      label.classList.remove('done');
    }
  }

  document.addEventListener('click', function (e) {
    var opener = e.target.closest('[data-open-terms]');
    if (opener) {
      e.preventDefault();
      openModal(opener.getAttribute('data-open-terms'));
      return;
    }
    if (e.target.closest('[data-close-modal]')) { closeModal(); return; }
    if (openModalEl && e.target === openModalEl) { closeModal(); return; } // bấm nền mờ

    var accept = e.target.closest('[data-accept]');
    if (accept) {
      var cb = $(accept.getAttribute('data-accept'));
      if (cb) { cb.checked = true; cb.classList.remove('is-invalid'); }
      closeModal();
      return;
    }
    var goto = e.target.closest('[data-goto]');
    if (goto) {
      var target = $(goto.getAttribute('data-goto'));
      if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeModal();
  });
  document.querySelectorAll('.tm-body').forEach(function (b) {
    b.addEventListener('scroll', function () { updateReadProgress(b.closest('.tm-overlay')); });
  });

  /* ---------- Submit ---------- */
  document.addEventListener('DOMContentLoaded', function () {
    var form = $('multiStepForm');
    if (!form) return;
    form.addEventListener('submit', function (event) {
      if (!validateStep(5)) {
        event.preventDefault();
        alert('Vui lòng tích chọn đồng ý với Điều khoản dịch vụ và Chính sách bán hàng trước khi gửi đăng ký.');
        return;
      }
      var btn = $('submitBtn');
      if (btn) {
        btn.disabled = true;
        btn.style.opacity = '.7';
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang gửi hồ sơ...';
      }
    });
    showStep(1, false);
  });
})();
