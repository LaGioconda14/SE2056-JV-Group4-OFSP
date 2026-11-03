/**
 * Shop Shippers Management JavaScript
 * Path: /assets/js/shop-shippers.js
 */

function openCreateModal() {
    var modal = document.getElementById('createShipperModal');
    if (modal) {
        modal.classList.remove('hidden');
    }
}

function closeCreateModal() {
    var modal = document.getElementById('createShipperModal');
    if (modal) {
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

    var modal = document.getElementById('editShipperModal');
    if (modal) {
        modal.classList.remove('hidden');
    }
}

function closeEditModal() {
    var modal = document.getElementById('editShipperModal');
    if (modal) {
        modal.classList.add('hidden');
    }
}
