/**
 * Gốc Vườn Admin - Category Management JavaScript
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

function openEditCategoryModal(btn) {
    if (!btn) return;
    const d = btn.dataset;
    document.getElementById('categoryForm').reset();
    document.getElementById('categoryFormAction').value = 'updateCategory';
    document.getElementById('categoryFormId').value = d.categoryId || '';
    document.getElementById('categoryModalTitle').textContent = 'Chỉnh Sửa Danh Mục: ' + (d.categoryName || '');
    document.getElementById('categoryModalIcon').className = 'bi bi-pencil-square fs-5';
    document.getElementById('btnSaveCategory').innerHTML = '<i class="bi bi-save me-1"></i> Cập Nhật Danh Mục';

    document.getElementById('modalCategoryName').value = d.categoryName || '';
    document.getElementById('modalCategorySlug').value = d.slug || '';
    document.getElementById('modalCategoryDesc').value = d.description || '';
    document.getElementById('modalCategoryParent').value = d.parentId || '0';
    document.getElementById('modalCategoryOrder').value = d.displayOrder || 0;
    document.getElementById('modalCategoryIcon').value = d.iconClass || 'bi-tag';
    document.getElementById('modalCategoryImageUrl').value = d.imageUrl || '';
    document.getElementById('modalCategoryIsActive').checked = (d.isActive === '1' || d.isActive === 'true');
    updateIconPreview(d.iconClass || 'bi-tag');

    const modal = new bootstrap.Modal(document.getElementById('categoryModal'));
    modal.show();
}

function openDeleteCategoryModal(categoryId, categoryName, activeSkus) {
    document.getElementById('deleteCategoryId').value = categoryId;
    document.getElementById('deleteCategoryName').textContent = categoryName + ' (ID: #' + categoryId + ')';
    const modal = new bootstrap.Modal(document.getElementById('deleteCategoryModal'));
    modal.show();
}
