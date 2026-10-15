<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- Modal Thêm Địa Chỉ Nhận Hàng Mới -->
<div class="modal fade" id="addAddressModal" tabindex="-1" aria-labelledby="addAddressModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
            <div class="modal-header bg-fresh-header text-white px-4 py-3">
                <h5 class="modal-title fw-bold" id="addAddressModalLabel">
                    <i class="bi bi-geo-alt-fill me-2"></i> Thêm Địa Chỉ Nhận Hàng Mới
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/profile" method="POST" id="addAddressForm">
                <input type="hidden" name="action" value="addAddress">
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label-bold" for="recipientName">
                                Họ và tên người nhận <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-person text-muted"></i></span>
                                <input type="text" class="form-control border-start-0" id="recipientName" name="recipientName" required value="${user.fullName}" maxlength="100">
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label-bold" for="recipientPhone">
                                Số điện thoại nhận hàng <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-telephone text-muted"></i></span>
                                <input type="tel" class="form-control border-start-0" id="recipientPhone" name="recipientPhone" required pattern="0[0-9]{9,10}" maxlength="11" value="${user.phone}">
                            </div>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label-bold" for="citySelect">
                                Tỉnh / Thành phố <span class="text-danger">*</span>
                            </label>
                            <select class="form-select" id="citySelect" name="city" required>
                                <option value="" selected disabled>Chọn Tỉnh / Thành phố</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label-bold" for="districtSelect">
                                Quận / Huyện <span class="text-danger">*</span>
                            </label>
                            <select class="form-select" id="districtSelect" name="district" required disabled>
                                <option value="" selected disabled>Chọn Quận / Huyện</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label-bold" for="wardSelect">
                                Phường / Xã
                            </label>
                            <select class="form-select" id="wardSelect" name="ward" disabled>
                                <option value="" selected disabled>Chọn Phường / Xã</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label-bold" for="streetAddress">
                                Địa chỉ cụ thể (Số nhà, tên ngõ, tòa nhà...) <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="streetAddress" name="streetAddress" required maxlength="255">
                        </div>

                        <div class="col-12">
                            <div class="form-check p-3 rounded-3 bg-light border">
                                <input class="form-check-input ms-0 me-2" type="checkbox" name="isDefault" value="true" id="isDefaultCheck">
                                <label class="form-check-label small fw-semibold text-dark" for="isDefaultCheck">
                                    Đặt làm địa chỉ nhận hàng mặc định cho các đơn hàng tiếp theo
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3">
                    <button type="button" class="btn-pill-sec" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-fresh-green px-4 fw-semibold">
                        <i class="bi bi-check-lg me-1"></i> Lưu địa chỉ
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Đánh Giá Đơn Hàng -->
<div class="modal fade" id="reviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold text-dark"><i class="bi bi-star-fill text-warning me-2"></i>Đánh giá đơn hàng</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body pt-3">
                <p class="text-muted small mb-3">Mã đơn: <strong id="reviewModalOrderCode" class="text-dark">#</strong></p>
                <div class="mb-3 text-center">
                    <div class="fs-2 text-warning mb-1">
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                        <i class="bi bi-star-fill"></i>
                    </div>
                    <span class="small text-muted fw-semibold">Tuyệt vời (5/5 sao)</span>
                </div>
                <div class="mb-3">
                    <label class="form-label-bold" for="reviewComment">Cảm nhận của bạn về chất lượng trái cây</label>
                    <textarea class="form-control rounded-3" id="reviewComment" rows="3" placeholder="Chia sẻ cảm nhận về độ tươi ngon, chất lượng bảo quản hoa quả..."></textarea>
                </div>
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn-pill-sec" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-fresh-green px-4" onclick="submitReview()">
                    <i class="bi bi-send me-1"></i> Gửi đánh giá
                </button>
            </div>
        </div>
    </div>
</div>

