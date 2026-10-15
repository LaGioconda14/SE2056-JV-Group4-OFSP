/**
 * FreshFruit Admin - Category Management JavaScript
 * Module: /admin/categories
 */

// Client-side Vietnamese slug generator
function slugify(text) {
    if (!text) return '';
    let str = text.trim();
    str = str.replace(/[đĐ]/g, 'd');
    str = str.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    str = str.toLowerCase();
    str = str.replace(/[^a-z0-9]+/g, '-');
    str = str.replace(/^-+|-+$/g, '');
    return str;
}

function handleCategoryNameInput(val) {
    const action = document.getElementById('categoryFormAction').value;
    if (action === 'addCategory') {
        document.getElementById('modalCategorySlug').value = slugify(val);
    }
}

function updateIconPreview(val) {
    const iconEl = document.getElementById('iconPreview');
    if (iconEl) {
        iconEl.className = 'bi ' + (val ? val.trim() : 'bi-tag');
    }
}

function openAddCategoryModal(defaultParentId) {
    document.getElementById('categoryForm').reset();
    document.getElementById('categoryFormAction').value = 'addCategory';
    document.getElementById('categoryFormId').value = '';
    document.getElementById('categoryModalTitle').textContent = 'Thêm Danh Mục Ngành Hàng Mới';
    document.getElementById('categoryModalIcon').className = 'bi bi-folder-plus fs-5';
    document.getElementById('btnSaveCategory').innerHTML = '<i class="bi bi-check-circle me-1"></i> Lưu Danh Mục';
    document.getElementById('modalCategoryIsActive').checked = true;
    document.getElementById('modalCategoryOrder').value = 0;
    document.getElementById('modalCategoryIcon').value = 'bi-tag';
    updateIconPreview('bi-tag');

    if (defaultParentId !== undefined && defaultParentId !== null) {
        document.getElementById('modalCategoryParent').value = defaultParentId;
    } else {
        document.getElementById('modalCategoryParent').value = '0';
    }

    const modal = new bootstrap.Modal(document.getElementById('categoryModal'));
    modal.show();
}

function openEditCategoryModal(categoryId) {
    const ctx = typeof getAdminContextPath === 'function' ? getAdminContextPath() : '';
    fetch(ctx + '/admin/categories?action=categoryDetail&categoryId=' + encodeURIComponent(categoryId))
        .then(res => {
            if (!res.ok) throw new Error('Không thể tải chi tiết danh mục');
            return res.json();
        })
        .then(data => {
            document.getElementById('categoryForm').reset();
            document.getElementById('categoryFormAction').value = 'updateCategory';
            document.getElementById('categoryFormId').value = data.categoryId;
            document.getElementById('categoryModalTitle').textContent = 'Chỉnh Sửa Danh Mục: ' + data.categoryName;
            document.getElementById('categoryModalIcon').className = 'bi bi-pencil-square fs-5';
            document.getElementById('btnSaveCategory').innerHTML = '<i class="bi bi-save me-1"></i> Cập Nhật Danh Mục';

            document.getElementById('modalCategoryName').value = data.categoryName || '';
            document.getElementById('modalCategorySlug').value = data.slug || '';
            document.getElementById('modalCategoryDesc').value = data.description || '';
            document.getElementById('modalCategoryParent').value = (data.parentId !== null && data.parentId !== undefined) ? data.parentId : '0';
            document.getElementById('modalCategoryOrder').value = data.displayOrder || 0;
            document.getElementById('modalCategoryIcon').value = data.iconClass || 'bi-tag';
            document.getElementById('modalCategoryImageUrl').value = data.imageUrl || '';
            document.getElementById('modalCategoryIsActive').checked = (data.isActive === true || data.isActive === 'true');
            updateIconPreview(data.iconClass || 'bi-tag');

            const modal = new bootstrap.Modal(document.getElementById('categoryModal'));
            modal.show();
        })
        .catch(err => {
            alert('Lỗi: ' + err.message);
        });
}

function openDeleteCategoryModal(categoryId, categoryName, activeSkus) {
    document.getElementById('deleteCategoryId').value = categoryId;
    document.getElementById('deleteCategoryName').textContent = categoryName + ' (ID: #' + categoryId + ')';
    const modal = new bootstrap.Modal(document.getElementById('deleteCategoryModal'));
    modal.show();
}

function toggleCategoryActive(categoryId, isChecked) {
    const ctx = typeof getAdminContextPath === 'function' ? getAdminContextPath() : '';
    const formData = new URLSearchParams();
    formData.append('action', 'toggleCategoryStatus');
    formData.append('categoryId', categoryId);
    formData.append('isActive', isChecked ? '1' : '0');
    formData.append('ajax', '1');

    fetch(ctx + '/admin/categories', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData.toString()
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            if (typeof showAdminToast === 'function') {
                showAdminToast('Đã ' + (isChecked ? 'bật hiển thị' : 'tắt hiển thị') + ' danh mục #' + categoryId + ' ngoài sàn!');
            }
        } else {
            alert('Không thể thay đổi trạng thái danh mục #' + categoryId);
        }
    })
    .catch(err => {
        console.error('Lỗi toggle:', err);
        alert('Lỗi kết nối khi cập nhật trạng thái danh mục.');
    });
}

