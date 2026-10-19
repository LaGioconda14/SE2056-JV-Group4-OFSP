function togglePasswordVisibility(fieldId, triggerEl) {
    const input = document.getElementById(fieldId);
    if (!input) return;
    const icon = triggerEl.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        if (icon) {
            icon.classList.remove('bi-eye');
            icon.classList.add('bi-eye-slash');
        }
        triggerEl.setAttribute('title', 'Hide password');
    } else {
        input.type = 'password';
        if (icon) {
            icon.classList.remove('bi-eye-slash');
            icon.classList.add('bi-eye');
        }
        triggerEl.setAttribute('title', 'Show password');
    }
}

function checkEmailValidity(input) {
    const icon = document.getElementById('emailStatusIcon');
    if (!icon) return;
    const val = input.value.trim();
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const phonePattern = /^(0|\+84)[0-9]{9,10}$/;
    if (emailPattern.test(val) || phonePattern.test(val)) {
        icon.innerHTML = '<i class="bi bi-check-circle-fill valid-mark"></i>';
    } else {
        icon.innerHTML = '';
    }
}

function initPasswordMatchCheck() {
    const pass = document.getElementById('password');
    const confirm = document.getElementById('confirmPassword');
    const hint = document.getElementById('passwordMatchHint');
    if (!pass || !confirm) return;

    function checkMatch() {
        if (!confirm.value) {
            if (hint) hint.textContent = '';
            confirm.setCustomValidity('');
            return;
        }
        if (pass.value !== confirm.value) {
            if (hint) {
                hint.textContent = 'Passwords do not match';
                hint.className = 'form-hint text-danger';
            }
            confirm.setCustomValidity('Passwords do not match');
        } else {
            if (hint) {
                hint.textContent = 'Passwords match';
                hint.className = 'form-hint text-success';
            }
            confirm.setCustomValidity('');
        }
    }

    pass.addEventListener('input', checkMatch);
    confirm.addEventListener('input', checkMatch);
}

function initSocialLogin() {
}

document.addEventListener('DOMContentLoaded', function() {
    const emailInput = document.getElementById('email');
    if (emailInput && emailInput.value) {
        checkEmailValidity(emailInput);
    }

    initPasswordMatchCheck();
    initSocialLogin();
});
