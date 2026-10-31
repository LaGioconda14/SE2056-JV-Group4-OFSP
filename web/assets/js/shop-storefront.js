let isFollowing = false;
function toggleFollowShop() {
    isFollowing = !isFollowing;
    const btn = document.getElementById('btnFollowShop');
    const icon = document.getElementById('followIcon');
    const text = document.getElementById('followText');
    if (!btn || !icon || !text) return;

    if (isFollowing) {
        btn.classList.add('bg-emerald-100', 'border-emerald-600', 'text-emerald-800');
        btn.classList.remove('bg-white', 'text-gray-800');
        icon.className = 'fa-solid fa-check text-sm text-emerald-700';
        text.textContent = 'Đang Theo Dõi';
    } else {
        btn.classList.remove('bg-emerald-100', 'border-emerald-600', 'text-emerald-800');
        btn.classList.add('bg-white', 'text-gray-800');
        icon.className = 'fa-regular fa-bookmark text-sm';
        text.textContent = 'Theo Dõi Shop';
    }
}

