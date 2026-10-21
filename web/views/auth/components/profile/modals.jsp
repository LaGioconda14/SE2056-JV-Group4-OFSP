<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

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

<style>
/* FE-10 popup styles scoped to profile, independent of review.css filenames */
#reviewModal .fe10-review-header {background:linear-gradient(125deg,#f0fdf4,#fff); border-bottom:1px solid #dcfce7;}
#reviewModal .fe10-review-icon {width:46px;height:46px;border-radius:16px;display:grid;place-items:center;background:#dcfce7;color:#00652c;font-size:24px;}
#reviewModal .fe10-review-star {border:0;background:none;font-size:35px;color:#cbd5e1;line-height:1.2;cursor:pointer;padding:0 4px;transition:transform .15s,color .15s;}
#reviewModal .fe10-review-star.selected {color:#f5ad22;}
#reviewModal .fe10-review-star:hover {transform:translateY(-2px) scale(1.05);}
#reviewModal .fe10-review-submit {border:0;border-radius:12px;padding:11px 22px;background:#00652c;color:white;font-weight:700;}
#reviewModal .fe10-review-submit:disabled {background:#a5b8a8;cursor:not-allowed;}
#reviewModal .fe10-review-message {font-size:13px;line-height:1.5;color:#64748b;min-height:20px;}
#reviewModal .fe10-review-message.is-error {color:#b91c1c;}
#reviewModal .fe10-review-product {border:1px dashed #b7ddc4;padding:11px 13px;border-radius:12px;background:#f4fbf6;font-size:13px;color:#166534;margin-top:10px;}
#reviewModal .fe10-review-input {border:1px solid #d6e2d9;border-radius:12px;padding:12px 14px;}
#reviewModal .fe10-review-input:focus {border-color:#15803d;box-shadow:0 0 0 3px #dcfce7;}
</style>
<div class="modal fade" id="reviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
            <div class="modal-header fe10-review-header px-4 py-4">
                <div class="d-flex align-items-center gap-3">
                    <div class="fe10-review-icon"><i class="bi bi-star-fill"></i></div>
                    <div>
                        <h5 class="modal-title fw-bold text-dark mb-1">Đánh giá sản phẩm đã mua</h5>
                        <div class="small text-secondary">Đơn hàng <strong id="reviewModalOrderCode">#</strong> · Gốc Vườn</div>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body p-4">
                <div class="mb-4">
                    <label for="reviewPurchaseSelect" class="form-label fw-bold text-dark">1. Chọn sản phẩm trong đơn</label>
                    <select id="reviewPurchaseSelect" class="form-select fe10-review-input" onchange="fe10ReviewProductChanged()" disabled>
                        <option value="">Đang tải sản phẩm...</option>
                    </select>
                    <div id="reviewSelectedProduct" class="fe10-review-product">Chọn một sản phẩm đã giao để đánh giá.</div>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-bold text-dark d-block mb-2">2. Chất lượng sản phẩm</label>
                    <input type="hidden" id="reviewRating" value="5" />
                    <div class="d-flex align-items-center flex-wrap gap-3">
                        <div role="radiogroup" aria-label="Số sao đánh giá">
                            <button type="button" class="fe10-review-star" data-rating="1" role="radio" onclick="setOrderReviewRating(1)" aria-label="1 sao">★</button>
                            <button type="button" class="fe10-review-star" data-rating="2" role="radio" onclick="setOrderReviewRating(2)" aria-label="2 sao">★</button>
                            <button type="button" class="fe10-review-star" data-rating="3" role="radio" onclick="setOrderReviewRating(3)" aria-label="3 sao">★</button>
                            <button type="button" class="fe10-review-star" data-rating="4" role="radio" onclick="setOrderReviewRating(4)" aria-label="4 sao">★</button>
                            <button type="button" class="fe10-review-star" data-rating="5" role="radio" onclick="setOrderReviewRating(5)" aria-label="5 sao">★</button>
                        </div>
                        <span id="reviewRatingCaption" class="small fw-bold text-success">Tuyệt vời</span>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-bold text-dark" for="reviewComment">3. Chia sẻ trải nghiệm</label>
                    <textarea class="form-control fe10-review-input" id="reviewComment" rows="4" maxlength="2000"
                        placeholder="Độ tươi ngon, đóng gói, chất lượng hoa quả... (không bắt buộc)"></textarea>
                </div>
                <p id="reviewFormMessage" class="fe10-review-message" role="status"></p>
            </div>
            <div class="modal-footer border-top px-4 py-3 justify-content-between bg-light">
                <span class="small text-secondary"><i class="bi bi-shield-check text-success me-1"></i>Chỉ sản phẩm đã giao mới có thể đánh giá</span>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-outline-secondary rounded-3 px-3" data-bs-dismiss="modal">Đóng</button>
                    <button type="button" class="fe10-review-submit" id="reviewSubmitButton" onclick="submitReview()" disabled>
                        <i class="bi bi-send me-1"></i>Gửi đánh giá
                    </button>
                </div>
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
                        <span>Ngày đặt: <span id="trackModalOrderDate">--/--/----</span></span>
                        <span>•</span>
                        <span class="text-success fw-semibold"><i class="bi bi-snow me-1"></i>Chuỗi lạnh FreshCold</span>
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
                            Chờ shop xác nhận
                        </div>
                    </div>
                    <div class="tracking-stepper" id="trackingStepper">
                        <div class="stepper-step completed" id="trackStep1">
                            <div class="stepper-circle"><i class="bi bi-check-lg"></i></div>
                            <div class="stepper-title">Đặt hàng</div>
                            <div class="stepper-time" id="trackTime1">--:--</div>
                        </div>
                        <div class="stepper-line completed" id="trackLine1"></div>

                        <div class="stepper-step" id="trackStep2">
                            <div class="stepper-circle"><i class="bi bi-shop"></i></div>
                            <div class="stepper-title">Shop xác nhận</div>
                            <div class="stepper-time" id="trackTime2">Chờ xử lý</div>
                        </div>
                        <div class="stepper-line" id="trackLine2"></div>

                        <div class="stepper-step" id="trackStep3">
                            <div class="stepper-circle"><i class="bi bi-box-seam"></i></div>
                            <div class="stepper-title">Đóng gói quả tươi</div>
                            <div class="stepper-time" id="trackTime3">Chờ xử lý</div>
                        </div>
                        <div class="stepper-line" id="trackLine3"></div>

                        <div class="stepper-step" id="trackStep4">
                            <div class="stepper-circle"><i class="bi bi-person-badge"></i></div>
                            <div class="stepper-title">Tài xế nhận hàng</div>
                            <div class="stepper-time" id="trackTime4">Chưa bàn giao</div>
                        </div>
                        <div class="stepper-line" id="trackLine4"></div>

                        <div class="stepper-step" id="trackStep5">
                            <div class="stepper-circle"><i class="bi bi-truck"></i></div>
                            <div class="stepper-title" id="trackTitle5">Đang giao hàng</div>
                            <div class="stepper-time" id="trackTime5">Chờ vận chuyển</div>
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
                        <div class="tracking-card mb-4 d-none" id="trackPreparingCard">
                            <div class="p-3 rounded-4 bg-primary-subtle border border-primary-subtle d-flex align-items-start gap-3">
                                <div class="stat-icon-circle bg-primary text-white fs-4 mt-1"><i class="bi bi-box-seam"></i></div>
                                <div>
                                    <h6 class="fw-bold text-primary mb-1">Nhà vườn đang xử lý đóng gói hoa quả</h6>
                                    <p class="small text-muted mb-0 lh-base">
                                        Đơn hàng của bạn đang được gian hàng kiểm tra chất lượng, đóng thùng cách nhiệt chuyên dụng. Thông tin tài xế và lộ trình giao hàng sẽ hiển thị ngay khi bưu tá tiếp nhận đơn.
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div class="tracking-card mb-4 d-none" id="trackCancelledCard">
                            <div class="p-3 rounded-4 bg-danger-subtle border border-danger-subtle d-flex align-items-start gap-3">
                                <div class="stat-icon-circle bg-danger text-white fs-4 mt-1"><i class="bi bi-x-circle-fill"></i></div>
                                <div>
                                    <h6 class="fw-bold text-danger mb-1">Đơn hàng đã được hủy</h6>
                                    <p class="small text-muted mb-0 lh-base" id="trackCancelReason">
                                        Lý do: Người mua hủy đơn trực tiếp.
                                    </p>
                                </div>
                            </div>
                        </div>

                                                <div class="tracking-card mb-4" id="trackDriverCard">
                            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                                <div class="d-flex align-items-center gap-3">
                                    <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop" class="driver-avatar rounded-circle border shadow-xs" alt="Tài xế">
                                    <div>
                                        <div class="d-flex align-items-center gap-2">
                                            <h6 class="fw-bold text-dark mb-0" id="trackDriverName">Tài xế chuỗi lạnh Gốc Vườn</h6>
                                            <span class="badge bg-success-subtle text-success small" id="trackDriverBadge">Tài xế chuyên dụng</span>
                                        </div>
                                        <div class="text-muted small" id="trackDriverSubtitle">Đội ngũ giao vận nội bộ Gốc Vườn Express</div>
                                        <div class="text-muted small mt-1" id="trackDriverInfoRow">
                                            Xe chuyên dụng bảo quản lạnh • <span class="text-warning">★ 5.0</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <a href="#" id="trackDriverCallBtn" class="btn btn-success fw-semibold px-3 py-2 rounded-3 shadow-xs" style="display: none;">
                                        <i class="bi bi-telephone-fill me-1"></i> <span id="trackDriverCallText">Gọi tài xế</span>
                                    </a>
                                    <button type="button" class="btn btn-outline-secondary px-3 py-2 rounded-3" onclick="alert('Đang kết nối khung chat trực tiếp với tài xế giao hàng...')">
                                        <i class="bi bi-chat-dots-fill"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                                                <div class="tracking-card">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                                    <div class="fw-bold text-dark d-flex align-items-center">
                                        <i class="bi bi-box-seam text-success me-2"></i> Sản phẩm trong kiện hàng (<span id="trackItemCount" class="mx-1">1</span> món)
                                    </div>
                                    <span class="badge bg-light text-muted border">Bảo quản chuỗi lạnh FreshCold</span>
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
                                    <strong class="text-dark fs-6" id="trackRecipientName">Người nhận</strong>
                                    <span class="text-muted small ms-2" id="trackRecipientPhone">0903 *** ***</span>
                                </div>
                                <p class="text-secondary small mb-3 lh-base" id="trackRecipientAddress">
                                    Địa chỉ nhận hàng
                                </p>
                                <div class="p-2 rounded-3 bg-light border small text-muted" id="trackNoteBox">
                                    <i class="bi bi-chat-left-text me-1 text-primary"></i> <strong>Khung giờ / Ghi chú:</strong> <span id="trackNoteText">Giao hàng chuỗi lạnh FreshCold tiêu chuẩn</span>
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
                            <a href="${pageContext.request.contextPath}/home" class="small text-success text-decoration-none fw-semibold d-inline-flex align-items-center">
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

<!-- Modal Xác Nhận Hủy Đơn Hàng (Người mua hủy trực tiếp không cần ai duyệt) -->
<div class="modal fade" id="cancelOrderModal" tabindex="-1" aria-labelledby="cancelOrderModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
            <div class="modal-header bg-danger text-white px-4 py-3">
                <h5 class="modal-title fw-bold d-flex align-items-center gap-2" id="cancelOrderModalLabel">
                    <i class="bi bi-x-circle-fill"></i> Xác Nhận Hủy Đơn Hàng
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <input type="hidden" id="cancelTargetOrderId" value="">
                
                <div class="d-flex align-items-center gap-3 p-3 bg-danger-subtle rounded-3 mb-3 border border-danger-subtle">
                    <i class="bi bi-exclamation-triangle-fill text-danger fs-3"></i>
                    <div>
                        <div class="fw-bold text-danger">Hủy đơn hàng <span id="cancelModalOrderCode">#ORD</span></div>
                        <div class="small text-muted">Đơn hàng sẽ được hủy ngay lập tức mà không cần chờ người bán phê duyệt.</div>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold text-dark small">Vui lòng chọn lý do hủy đơn: <span class="text-danger">*</span></label>
                    <select id="cancelReasonSelect" class="form-select form-select-sm mb-2" onchange="toggleCustomCancelReason(this.value)">
                        <option value="Đổi ý, không muốn mua nữa">Đổi ý, không muốn mua nữa</option>
                        <option value="Muốn thay đổi địa chỉ hoặc số điện thoại nhận hàng">Muốn thay đổi địa chỉ hoặc số điện thoại nhận hàng</option>
                        <option value="Muốn thay đổi sản phẩm trong giỏ (thêm/bớt mặt hàng)">Muốn thay đổi sản phẩm trong giỏ (thêm/bớt mặt hàng)</option>
                        <option value="Tìm thấy giá rẻ hơn ở nơi khác">Tìm thấy giá rẻ hơn ở nơi khác</option>
                        <option value="Thời gian giao hàng dự kiến không phù hợp">Thời gian giao hàng dự kiến không phù hợp</option>
                        <option value="OTHER">Lý do khác...</option>
                    </select>
                    <textarea id="cancelReasonCustom" class="form-control form-control-sm d-none mt-2" rows="2" placeholder="Nhập lý do cụ thể..."></textarea>
                </div>
            </div>
            <div class="modal-footer bg-light px-4 py-3">
                <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-danger rounded-pill px-4 fw-semibold" id="btnConfirmCancelOrder" onclick="submitCancelOrder()">
                    <i class="bi bi-x-circle me-1"></i> Xác Nhận Hủy Đơn
                </button>
            </div>
        </div>
    </div>
</div>



