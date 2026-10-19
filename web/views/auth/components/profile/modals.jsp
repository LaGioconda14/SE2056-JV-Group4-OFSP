<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

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

<div class="modal fade" id="orderTrackingModal" tabindex="-1" aria-labelledby="orderTrackingModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl modal-dialog-scrollable">
        <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden tracking-modal-content">
                        <div class="modal-header bg-white border-bottom px-4 py-3 align-items-center">
                <div class="flex-grow-1">
                    <div class="d-flex align-items-center gap-2 flex-wrap mb-1">
                        <h4 class="modal-title fw-bolder text-dark mb-0">Theo Dõi Hành Trình Đơn Hàng</h4>
                        <span id="trackStatusBadge" class="badge bg-success-subtle text-success px-3 py-1 rounded-pill fw-bold border border-success-subtle">
                            ĐANG VẬN CHUYỂN
                        </span>
                    </div>
                    <div class="text-muted small d-flex align-items-center gap-2 flex-wrap">
                        <span>Mã đơn hàng: <strong id="trackModalOrderCode" class="text-dark">#ORD-98241</strong></span>
                        <span>•</span>
                        <span>Ngày đặt: <span id="trackModalOrderDate">24/10/2024 (10:15)</span></span>
                        <span>•</span>
                        <span class="text-success fw-semibold"><i class="bi bi-geo-alt-fill me-1"></i>Giao hỏa tốc chuỗi lạnh FreshCold 2h</span>
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill px-3" onclick="alert('Đang kết nối xuất hóa đơn VAT điện tử...')">
                        <i class="bi bi-file-earmark-text me-1"></i> Hóa đơn VAT
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill px-3" onclick="alert('Tổng đài hỗ trợ sự cố Gốc Vườn: 1900 6868 (Nhánh 1). Đang kết nối chuyên viên CSKH...')">
                        <i class="bi bi-headset me-1"></i> Hỗ trợ sự cố
                    </button>
                    <button type="button" class="btn-close ms-2" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
            </div>

                        <div class="modal-body p-4 bg-slate-50">
                                <div class="tracking-card mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div class="fw-bold text-dark fs-6 d-flex align-items-center">
                            <i class="bi bi-clock-history text-success me-2 fs-5"></i> Tiến độ giao hàng
                        </div>
                        <div class="small fw-semibold text-success bg-success-subtle px-3 py-1 rounded-pill border border-success-subtle" id="trackEstimatedTime">
                            Dự kiến giao: 11:30 hôm nay
                        </div>
                    </div>
                    <div class="tracking-stepper" id="trackingStepper">
                        <div class="stepper-step completed" id="trackStep1">
                            <div class="stepper-circle"><i class="bi bi-check-lg"></i></div>
                            <div class="stepper-title">Đặt hàng</div>
                            <div class="stepper-time" id="trackTime1">10:15</div>
                        </div>
                        <div class="stepper-line completed" id="trackLine1"></div>

                        <div class="stepper-step completed" id="trackStep2">
                            <div class="stepper-circle"><i class="bi bi-shop"></i></div>
                            <div class="stepper-title">Shop xác nhận</div>
                            <div class="stepper-time" id="trackTime2">10:25</div>
                        </div>
                        <div class="stepper-line completed" id="trackLine2"></div>

                        <div class="stepper-step completed" id="trackStep3">
                            <div class="stepper-circle"><i class="bi bi-box-seam"></i></div>
                            <div class="stepper-title">Đóng gói quả tươi</div>
                            <div class="stepper-time" id="trackTime3">10:35</div>
                        </div>
                        <div class="stepper-line completed" id="trackLine3"></div>

                        <div class="stepper-step completed" id="trackStep4">
                            <div class="stepper-circle"><i class="bi bi-person-badge"></i></div>
                            <div class="stepper-title">Tài xế nhận hàng</div>
                            <div class="stepper-time" id="trackTime4">10:50</div>
                        </div>
                        <div class="stepper-line active" id="trackLine4"></div>

                        <div class="stepper-step active" id="trackStep5">
                            <div class="stepper-circle pulse"><i class="bi bi-truck"></i></div>
                            <div class="stepper-title text-success fw-bold" id="trackTitle5">ĐANG GIAO HÀNG</div>
                            <div class="stepper-time text-success fw-semibold" id="trackTime5">11:20 (Dự kiến)</div>
                        </div>
                        <div class="stepper-line" id="trackLine5"></div>

                        <div class="stepper-step" id="trackStep6">
                            <div class="stepper-circle"><i class="bi bi-house-check"></i></div>
                            <div class="stepper-title" id="trackTitle6">Đã giao hàng</div>
                            <div class="stepper-time" id="trackTime6">Chờ hoàn tất</div>
                        </div>
                    </div>
                </div>

                <div class="row g-4">
                                        <div class="col-lg-7">
                                                <div class="tracking-card mb-4" id="trackGpsCard">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="fw-bold text-dark d-flex align-items-center">
                                    <i class="bi bi-broadcast text-success me-2"></i> Lộ trình hỏa tốc thời gian thực (GPS Live)
                                </div>
                                <span class="badge bg-light text-muted border rounded-pill">
                                    <i class="bi bi-arrow-clockwise me-1"></i> Cập nhật 1m trước
                                </span>
                            </div>

                                                        <div class="gps-map-container mb-3 position-relative rounded-4 overflow-hidden border">
                                <svg class="w-100 h-100 position-absolute inset-0" xmlns="http://www.w3.org/2000/svg" style="background: #edf7f1;">
                                    <defs>
                                        <pattern id="gridPattern" width="28" height="28" patternUnits="userSpaceOnUse">
                                            <path d="M 28 0 L 0 0 0 28" fill="none" stroke="#d5e8dc" stroke-width="1"/>
                                        </pattern>
                                        <linearGradient id="routeGradient" x1="0%" y1="100%" x2="100%" y2="0%">
                                            <stop offset="0%" stop-color="#10b981" />
                                            <stop offset="100%" stop-color="#047857" />
                                        </linearGradient>
                                    </defs>
                                    <rect width="100%" height="100%" fill="url(#gridPattern)" />
                                                                        <path d="M -30 200 Q 140 160 260 210 T 650 140" fill="none" stroke="#c7dffc" stroke-width="26" stroke-linecap="round"/>
                                                                        <path d="M 40 280 L 580 40" fill="none" stroke="#ffffff" stroke-width="14"/>
                                    <path d="M 120 20 L 420 300" fill="none" stroke="#ffffff" stroke-width="12"/>
                                    <path d="M 0 100 L 600 120" fill="none" stroke="#ffffff" stroke-width="10"/>
                                                                        <path d="M 50 230 Q 180 180 290 150 T 540 65" fill="none" stroke="url(#routeGradient)" stroke-width="8" stroke-dasharray="12 6" stroke-linecap="round"/>
                                </svg>

                                                                <div class="map-node map-node-origin" style="left: 7%; top: 72%;">
                                    <div class="map-pin-circle bg-success text-white shadow"><i class="bi bi-shop"></i></div>
                                    <span class="map-pin-tag" id="trackMapShopName">Nông Trại Hữu Cơ Mộc Châu</span>
                                </div>

                                                                <div class="map-waypoint" style="left: 48%; top: 52%;">
                                    <span class="badge bg-white text-secondary border shadow-xs">Đường Nguyễn Hữu Cảnh</span>
                                </div>

                                                                <div class="map-node map-node-driver pulse-driver" style="left: 48%; top: 35%;">
                                    <div class="driver-bubble bg-amber-600 text-white shadow fw-bold">
                                        <i class="bi bi-truck me-1"></i> <span id="trackMapDriverTag">Tài xế Trần Văn Nam (Cách 1.5 km)</span>
                                    </div>
                                    <div class="map-pin-driver bg-amber-500 text-white shadow"><i class="bi bi-cursor-fill"></i></div>
                                </div>

                                                                <div class="map-node map-node-dest" style="left: 82%; top: 16%;">
                                    <div class="map-pin-circle bg-emerald-700 text-white shadow"><i class="bi bi-geo-alt-fill"></i></div>
                                    <span class="map-pin-tag text-emerald-800 fw-bold" id="trackMapDestName">Vinhomes Central Park</span>
                                </div>
                            </div>

                                                        <div class="row g-2">
                                <div class="col-sm-6">
                                    <div class="p-3 rounded-3 bg-white border d-flex align-items-center gap-3 h-100">
                                        <div class="stat-icon-circle bg-primary-subtle text-primary">
                                            <i class="bi bi-cursor-fill fs-5"></i>
                                        </div>
                                        <div>
                                            <div class="text-muted small">Khoảng cách & Thời gian</div>
                                            <div class="fw-bold text-dark small" id="trackDistanceText">Còn cách 1.5 km (Khoảng 8 phút nữa sẽ đến)</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class="p-3 rounded-3 bg-white border d-flex align-items-center gap-3 h-100">
                                        <div class="stat-icon-circle bg-info-subtle text-info">
                                            <i class="bi bi-thermometer-snow fs-5"></i>
                                        </div>
                                        <div>
                                            <div class="text-muted small">Nhiệt độ thùng bảo quản</div>
                                            <div class="fw-bold text-dark small">9.2°C — Đạt chuẩn tươi ngon chuẩn tại vườn</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                                                <div class="tracking-card mb-4" id="trackDriverCard">
                            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                                <div class="d-flex align-items-center gap-3">
                                    <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop" class="driver-avatar rounded-circle border shadow-xs" alt="Tài xế">
                                    <div>
                                        <div class="d-flex align-items-center gap-2">
                                            <h6 class="fw-bold text-dark mb-0" id="trackDriverName">Trần Văn Nam</h6>
                                            <span class="badge bg-success-subtle text-success small">Tài xế chuyên dụng</span>
                                        </div>
                                        <div class="text-muted small">Đội ngũ giao vận nội bộ Gốc Vườn Express</div>
                                        <div class="text-muted small mt-1">
                                            Biển số: <strong class="text-dark">59-P1 084.21</strong> • <span class="text-warning">★ 4.9</span> (340 cuốc giao xuất sắc)
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <a href="tel:0903778899" class="btn btn-success fw-semibold px-3 py-2 rounded-3 shadow-xs">
                                        <i class="bi bi-telephone-fill me-1"></i> Gọi tài xế (0903 *** 112)
                                    </a>
                                    <button type="button" class="btn btn-outline-secondary px-3 py-2 rounded-3" onclick="alert('Đang kết nối khung chat trực tiếp với tài xế giao hàng...')">
                                        <i class="bi bi-chat-dots-fill"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                                                <div class="tracking-card">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="fw-bold text-dark d-flex align-items-center">
                                    <i class="bi bi-box-seam text-success me-2"></i> Kiện hàng đóng gói riêng biệt (<span id="trackItemCount">1</span> kiện)
                                </div>
                                <span class="text-muted small">Bảo quản độc lập theo tiêu chuẩn nông trại</span>
                            </div>
                            <div id="trackItemsContainer" class="d-flex flex-column gap-3">
                                                            </div>
                        </div>
                    </div>

                                        <div class="col-lg-5">
                                                <div class="tracking-card mb-4">
                            <div class="fw-bold text-dark mb-3 d-flex align-items-center">
                                <i class="bi bi-geo-alt-fill text-success me-2"></i> Địa chỉ nhận hàng
                            </div>
                            <div class="mb-2">
                                <strong class="text-dark fs-6" id="trackRecipientName">Nguyễn Thu Trang</strong>
                                <span class="text-muted small ms-2" id="trackRecipientPhone">0912 *** 882</span>
                            </div>
                            <p class="text-secondary small mb-3 lh-base" id="trackRecipientAddress">
                                Căn hộ 14.02, Tháp B2, Tòa Vinhomes Central Park, Phường 22, Quận Bình Thạnh, TP. Hồ Chí Minh
                            </p>
                            <div class="p-2 rounded-3 bg-light border small text-muted">
                                <i class="bi bi-chat-left-text me-1 text-primary"></i> <strong>Ghi chú:</strong> Gọi trước khi lên sảnh 5 phút để xuống nhận hàng.
                            </div>
                        </div>

                                                <div class="tracking-card mb-4">
                            <div class="fw-bold text-dark mb-3 d-flex align-items-center">
                                <i class="bi bi-credit-card text-success me-2"></i> Chi tiết thanh toán
                            </div>
                            <div class="d-flex justify-content-between text-muted small mb-2">
                                <span>Tạm tính hoa quả:</span>
                                <span class="text-dark fw-semibold" id="trackGoodsSubtotal">0₫</span>
                            </div>
                            <div class="d-flex justify-content-between text-muted small mb-2">
                                <span>Phí giao chuỗi lạnh FreshCold:</span>
                                <span class="text-dark fw-semibold" id="trackShippingFee">25.000₫</span>
                            </div>
                            <div class="d-flex justify-content-between text-muted small mb-2">
                                <span>Voucher sàn tài trợ (FREESHIP30K):</span>
                                <span class="text-danger fw-semibold" id="trackVoucherDiscount">-0₫</span>
                            </div>
                            <hr class="my-2 border-dashed">
                            <div class="d-flex justify-content-between align-items-baseline mb-2">
                                <span class="fw-bold text-dark">Tổng cần thanh toán:</span>
                                <span class="fw-bolder text-success fs-4" id="trackFinalTotal">0₫</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="text-muted small">Hình thức:</span>
                                <span class="badge bg-light text-dark border fw-semibold" id="trackPaymentMethodBadge">Thu hộ tiền mặt (COD)</span>
                            </div>
                            <div class="alert alert-success py-2 px-3 small rounded-3 mb-0 d-flex align-items-center gap-2 border-0 bg-success-subtle text-success">
                                <i class="bi bi-shield-check fs-5"></i>
                                <span>Bạn chỉ thanh toán khi đã hài lòng với chất lượng quả.</span>
                            </div>
                        </div>

                                                <div class="tracking-card">
                            <div class="fw-bold text-dark mb-2 d-flex align-items-center">
                                <i class="bi bi-patch-check-fill text-success me-2"></i> Cam kết Gốc Vườn
                            </div>
                            <p class="small text-muted mb-3">
                                <strong>Bảo đảm quả tươi 100%</strong> — Quý khách hàng hoàn toàn có quyền đồng kiểm tra ngoại quan (độ tươi, cuống lá, độ chín) cùng tài xế trước khi nhận hàng và thanh toán.
                            </p>
                            <div class="d-flex flex-column gap-2 small text-muted mb-3">
                                <div class="d-flex align-items-start gap-2">
                                    <i class="bi bi-arrow-repeat text-success mt-1"></i>
                                    <span>Đổi trả 1-đổi-1 ngay lập tức nếu quả dập nát hoặc úng</span>
                                </div>
                                <div class="d-flex align-items-start gap-2">
                                    <i class="bi bi-snow text-info mt-1"></i>
                                    <span>Thùng cách nhiệt đảm bảo nhiệt độ chuẩn suốt chặng</span>
                                </div>
                                <div class="d-flex align-items-start gap-2">
                                    <i class="bi bi-patch-check text-success mt-1"></i>
                                    <span>Nguồn gốc xuất xứ minh bạch từ từng nhà vườn uy tín</span>
                                </div>
                            </div>
                            <a href="${pageContext.request.contextPath}/home.jsp" class="small text-success text-decoration-none fw-semibold d-inline-flex align-items-center">
                                Tìm hiểu chi tiết chính sách hoàn tiền 100% <i class="bi bi-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="returnOrderModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title fw-bold d-flex align-items-center gap-2">
                    <i class="bi bi-arrow-return-left"></i> Yêu Cầu Trả Hàng / Hoàn Tiền
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/customer/return">
                <input type="hidden" name="subOrderId" id="returnSubOrderId">
                <input type="hidden" name="shopId" id="returnShopId" value="1">
                <div class="modal-body p-4">
                    <div class="p-3 rounded-3 bg-light border mb-3">
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted small">Đơn hàng:</span>
                            <strong class="text-dark" id="returnOrderCode">#</strong>
                        </div>
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted small">Gian hàng:</span>
                            <span class="text-dark fw-semibold" id="returnShopName">Gốc Vườn Shop</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted small">Giá trị đơn:</span>
                            <span class="text-success fw-bold fs-6" id="returnTotalAmount">0₫</span>
                        </div>
                    </div>

                                        <div class="mb-3">
                        <label class="form-label fw-bold small text-dark">
                            <i class="bi bi-exclamation-circle text-danger me-1"></i> Lý do trả hàng / hoàn tiền:
                        </label>
                        <select class="form-select" name="reasonCategory" id="returnReasonSelect" required>
                            <option value="Quả dập nát / úng hỏng do vận chuyển">Quả dập nát / úng hỏng do vận chuyển</option>
                            <option value="Đứt gãy chuỗi bảo quản lạnh (quả héo, thâm, biến chất)">Đứt gãy chuỗi bảo quản lạnh (quả héo, thâm, biến chất)</option>
                            <option value="Giao sai loại quả hoặc thiếu số lượng">Giao sai loại quả hoặc thiếu số lượng</option>
                            <option value="Chất lượng quả không đúng cam kết tại vườn">Chất lượng quả không đúng cam kết tại vườn</option>
                        </select>
                    </div>

                                        <div class="mb-3">
                        <label class="form-label fw-bold small text-dark">Mô tả cụ thể sự cố quả tươi:</label>
                        <textarea class="form-control" name="complaintText" id="returnComplaintText" rows="3"
                                  placeholder="Mô tả cụ thể tình trạng quả bạn nhận được (vị trí dập, độ chín, số lượng bị lỗi...)" required></textarea>
                    </div>

                                        <div class="mb-3">
                        <label class="form-label fw-bold small text-dark">
                            <i class="bi bi-camera text-success me-1"></i> Link ảnh bằng chứng thực tế:
                        </label>
                        <input type="text" class="form-control mb-2" name="evidenceImageUrl" id="returnEvidenceInput"
                               value="https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&fit=crop"
                               placeholder="Nhập đường dẫn ảnh hoặc chọn mẫu bên dưới">
                        <div class="text-muted fs-xs mb-2">Ảnh mẫu chụp thực tế quả dập để thẩm định nhanh:</div>
                        <div class="d-flex gap-2">
                            <img src="https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=120&h=80&fit=crop"
                                 class="rounded border cursor-pointer" style="width: 60px; height: 45px; object-fit: cover;"
                                 alt="Ảnh lỗi 1" onclick="selectReturnPhotoPreset('https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&fit=crop')">
                            <img src="https://images.unsplash.com/photo-1579613832125-5d34a13ffe0a?w=120&h=80&fit=crop"
                                 class="rounded border cursor-pointer" style="width: 60px; height: 45px; object-fit: cover;"
                                 alt="Ảnh lỗi 2" onclick="selectReturnPhotoPreset('https://images.unsplash.com/photo-1579613832125-5d34a13ffe0a?w=500&fit=crop')">
                            <img src="https://images.unsplash.com/photo-1528825871115-3581a5387919?w=120&h=80&fit=crop"
                                 class="rounded border cursor-pointer" style="width: 60px; height: 45px; object-fit: cover;"
                                 alt="Ảnh lỗi 3" onclick="selectReturnPhotoPreset('https://images.unsplash.com/photo-1528825871115-3581a5387919?w=500&fit=crop')">
                        </div>
                        <div class="mt-2 text-center">
                            <img id="returnPreviewImg" src="https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&fit=crop"
                                 class="rounded border shadow-xs" style="max-height: 100px; object-fit: cover;">
                        </div>
                    </div>

                                        <div class="row g-2 mb-3">
                        <div class="col-sm-6">
                            <label class="form-label fw-bold small text-dark">Số tiền yêu cầu hoàn:</label>
                            <input type="text" class="form-control fw-bold text-success" name="claimAmount" id="returnClaimAmountInput" required>
                        </div>
                        <div class="col-sm-6">
                            <label class="form-label fw-bold small text-dark">Hình thức hoàn tiền:</label>
                            <select class="form-select" name="refundMethod">
                                <option value="WALLET">Ví Gốc Vườn Pay (Hoàn tức thì)</option>
                                <option value="BANK">Tài khoản ngân hàng</option>
                            </select>
                        </div>
                    </div>

                    <div class="alert alert-success py-2 px-3 small rounded-3 mb-0">
                        <i class="bi bi-shield-check me-1"></i> Cam kết Gốc Vườn: Shop & Sàn sẽ phản hồi thẩm định trong vòng <strong>24 giờ</strong>.
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger fw-bold rounded-pill px-4">
                        <i class="bi bi-send-fill me-1"></i> Gửi Yêu Cầu Hoàn Tiền
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="returnDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title fw-bold d-flex align-items-center gap-2">
                    <i class="bi bi-info-circle-fill"></i> Tiến Độ Xử Lý Trả Hàng & Hoàn Tiền
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom">
                    <div>
                        <span class="text-muted small d-block">Mã khiếu nại:</span>
                        <strong class="text-dark fs-6" id="dispCodeText">DIS-892</strong>
                    </div>
                    <span class="badge bg-success fs-6" id="dispStatusBadge">Đã Hoàn Tiền</span>
                </div>

                <div class="mb-3">
                    <span class="text-muted small d-block">Nhóm lý do:</span>
                    <strong class="text-dark" id="dispReasonText">Quả dập nát / úng hỏng do vận chuyển</strong>
                </div>

                <div class="mb-3">
                    <span class="text-muted small d-block">Mô tả sự cố của bạn:</span>
                    <p class="text-secondary small bg-light p-2 rounded-3 border mb-0" id="dispComplaintText">
                        Dâu tây bị dập nát cuống do chèn ép trong thùng đá.
                    </p>
                </div>

                <div class="mb-3">
                    <span class="text-muted small d-block">Ảnh bằng chứng đã gửi:</span>
                    <img id="dispEvidenceImg" src="" class="rounded border mt-1 shadow-xs" style="max-height: 140px; object-fit: cover;">
                </div>

                <div class="d-flex justify-content-between align-items-center p-3 bg-success-subtle rounded-3 border border-success-subtle mb-3">
                    <span class="text-dark fw-semibold">Số tiền hoàn:</span>
                    <span class="text-success fw-bolder fs-5" id="dispClaimAmount">0₫</span>
                </div>

                <div class="alert alert-info py-2 px-3 small rounded-3 mb-0" id="dispResolutionBox">
                    <i class="bi bi-chat-quote-fill me-1"></i> <strong id="dispResolutionTitle">Phản hồi từ sàn:</strong>
                    <span id="dispResolutionNote">Hệ thống đã chấp thuận khiếu nại và hoàn tiền về ví của bạn.</span>
                </div>
            </div>
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>



