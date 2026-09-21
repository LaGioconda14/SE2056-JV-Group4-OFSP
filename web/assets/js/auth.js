// Toggle Password Visibility
function togglePasswordVisibility(fieldId, triggerEl) {
    const input = document.getElementById(fieldId);
    const icon = triggerEl.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.remove('bi-eye');
        icon.classList.add('bi-eye-slash');
    } else {
        input.type = 'password';
        icon.classList.remove('bi-eye-slash');
        icon.classList.add('bi-eye');
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

// Trigger validation on load if pre-filled
document.addEventListener('DOMContentLoaded', function() {
    const emailInput = document.getElementById('email');
    if (emailInput && emailInput.value) {
        checkEmailValidity(emailInput);
    }
});

