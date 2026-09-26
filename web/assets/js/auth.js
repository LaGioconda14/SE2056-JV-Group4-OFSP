/**
 * Authentication Module Scripts
 * Handles password visibility toggle, live email validation,
 * password matching, and social login interactions.
 */

// Toggle Password Visibility
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

// Live Email Validation Indicator
function checkEmailValidity(input) {
    const icon = document.getElementById('emailStatusIcon');
    if (!icon) return;
    const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (pattern.test(input.value.trim())) {
        icon.innerHTML = '<i class="bi bi-check-circle-fill valid-mark"></i>';
    } else {
        icon.innerHTML = '';
    }
}

// Live Password Match Checker for Registration
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

// Social Login Button Handler
function initSocialLogin() {
    // Google button now directs naturally to /login-google endpoint
}

// Initialize on DOM Ready
document.addEventListener('DOMContentLoaded', function() {
    // Check pre-filled email
    const emailInput = document.getElementById('email');
    if (emailInput && emailInput.value) {
        checkEmailValidity(emailInput);
    }

    // Init password matcher if present
    initPasswordMatchCheck();

    // Init social login handlers
    initSocialLogin();
});
