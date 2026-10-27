/**
 * Shop Shippers Management JavaScript
 * Path: /assets/js/shop-shippers.js
 */

function openCreateModal() {
    var backdrop = document.getElementById('createModalBackdrop');
    var modal = document.getElementById('createShipperModal');
    if (backdrop && modal) {
        backdrop.classList.remove('hidden');
        modal.classList.remove('hidden');
    }
}

function closeCreateModal() {
    var backdrop = document.getElementById('createModalBackdrop');
    var modal = document.getElementById('createShipperModal');
    if (backdrop && modal) {
        backdrop.classList.add('hidden');
        modal.classList.add('hidden');
    }
}

function openEditModal(driverId, fullName, phone, vehicleType, vehiclePlate, coldStorageType, status) {
    var editDriverId = document.getElementById('editDriverId');
    var editFullName = document.getElementById('editFullName');
    var editPhone = document.getElementById('editPhone');
    var editVehicleType = document.getElementById('editVehicleType');
    var editVehiclePlate = document.getElementById('editVehiclePlate');
    var editColdStorageType = document.getElementById('editColdStorageType');
    var editAvailabilityStatus = document.getElementById('editAvailabilityStatus');

    if (editDriverId) editDriverId.value = driverId || '';
    if (editFullName) editFullName.value = fullName || '';
    if (editPhone) editPhone.value = phone || '';
    if (editVehicleType) editVehicleType.value = vehicleType || '';
    if (editVehiclePlate) editVehiclePlate.value = vehiclePlate || '';
    if (editColdStorageType) editColdStorageType.value = coldStorageType || '';
    if (editAvailabilityStatus) editAvailabilityStatus.value = status || 'AVAILABLE';

    var backdrop = document.getElementById('editModalBackdrop');
    var modal = document.getElementById('editShipperModal');
    if (backdrop && modal) {
        backdrop.classList.remove('hidden');
        modal.classList.remove('hidden');
    }
}

function closeEditModal() {
    var backdrop = document.getElementById('editModalBackdrop');
    var modal = document.getElementById('editShipperModal');
    if (backdrop && modal) {
        backdrop.classList.add('hidden');
        modal.classList.add('hidden');
    }
}
