<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade" id="nav-orders" role="tabpanel">
    <div class="profile-section-card">
        <div class="profile-section-header">
            <div>
                <span class="section-tag">QUẢN LÝ ĐƠN MUA</span>
                <h3 class="section-heading">Đơn Hàng & Lịch Sử Mua Hàng</h3>
            </div>
            <span class="badge-soft-success">
                <span id="headerTotalOrdersCount">${not empty orders ? orders.size() : 0}</span> đơn hàng
            </span>
        </div>

        <div class="order-filter-nav">
            <button type="button" class="order-filter-btn active" data-filter="all" onclick="filterOrders('all', this)">
                Tất cả
            </button>
            <button type="button" class="order-filter-btn" data-filter="to-pay" onclick="filterOrders('to-pay', this)">
                Chờ thanh toán<span class="order-tab-count" id="count-topay"></span>
            </button>
            <button type="button" class="order-filter-btn" data-filter="to-ship" onclick="filterOrders('to-ship', this)">
                Vận chuyển<span class="order-tab-count" id="count-toship"></span>
            </button>
            <button type="button" class="order-filter-btn" data-filter="shipping" onclick="filterOrders('shipping', this)">
                Chờ giao hàng<span class="order-tab-count" id="count-shipping"></span>
            </button>
            <button type="button" class="order-filter-btn" data-filter="completed" onclick="filterOrders('completed', this)">
                Hoàn thành<span class="order-tab-count" id="count-completed"></span>
            </button>
            <button type="button" class="order-filter-btn" data-filter="cancelled" onclick="filterOrders('cancelled', this)">
                Đã hủy<span class="order-tab-count" id="count-cancelled"></span>
            </button>
        </div>

        <c:choose>
            <c:when test="${not empty orders}">
                <div id="ordersContainer">
                    <c:forEach items="${orders}" var="order">
                        <c:set var="statusUpper" value="${order.status.toUpperCase()}" />
                        <div class="shopee-order-card"
                             data-order-status="${statusUpper}"
                             data-payment-status="${order.paymentStatus != null ? order.paymentStatus.toUpperCase() : ''}"
                             data-payment-method="${order.paymentMethod != null ? order.paymentMethod.toUpperCase() : ''}"
                             data-order-id="${order.id}"
                             data-shop-name="${order.shopName}"
                             data-created-at="${order.createdAt}"
                             data-cancel-reason="${order.cancelReason != null ? order.cancelReason : ''}"
                             data-failure-reason="${order.failureReason != null ? order.failureReason : ''}"
                             data-delivery-slot="${order.deliverySlot != null ? order.deliverySlot : ''}"
                             data-recipient-name="${order.shippingAddress != null ? order.shippingAddress.recipientName : user.fullName}"
                             data-recipient-phone="${order.shippingAddress != null ? order.shippingAddress.recipientPhone : user.phone}"
                             data-recipient-address="${order.shippingAddress != null ? order.shippingAddress.fullAddress : 'Địa chỉ nhận hàng'}"
                             data-goods-amount="${order.shopSubtotal != null ? order.shopSubtotal : order.totalGoodsAmount}"
                             data-shipping-fee="${order.shopShippingFee != null ? order.shopShippingFee : order.totalShippingFee}"
                             data-discount="${order.shopDiscount != null ? order.shopDiscount : order.platformDiscount}"
                             data-final-amount="${order.shopTotal != null ? order.shopTotal : order.totalAmount}"
                             data-driver-name="${order.driverName != null ? order.driverName : ''}"
                             data-driver-phone="${order.driverPhone != null ? order.driverPhone : ''}">
                            <div class="shopee-card-header">
                                <div class="shopee-shop-info">
                                    <span class="shopee-shop-name">${order.shopName}</span>
                                    <button type="button" class="shopee-btn-chat" onclick="openChatShop('${order.shopName}')">
                                        <i class="bi bi-chat-dots-fill"></i> Chat
                                    </button>
                                    <a href="${pageContext.request.contextPath}/store?id=${order.shopId}" class="shopee-btn-shop">
                                        <i class="bi bi-shop"></i> Xem Shop
                                    </a>
                                </div>
                                <div class="shopee-status-right">
                                    <c:choose>
                                        <c:when test="${statusUpper == 'COMPLETED' or statusUpper == 'DELIVERED'}">
                                            <span class="text-muted small me-1"><i class="bi bi-truck text-success"></i> Giao hàng thành công</span>
                                            <span class="text-muted">|</span>
                                            <span class="shopee-status-shipping ms-1">HOÀN THÀNH</span>
                                        </c:when>
                                        <c:when test="${statusUpper == 'SHIPPING' or statusUpper == 'DELIVERING' or statusUpper == 'IN_TRANSIT'}">
                                            <span class="text-muted small me-1"><i class="bi bi-snow text-primary"></i> Đang giao chuỗi lạnh</span>
                                            <span class="text-muted">|</span>
                                            <span class="shopee-status-shipping ms-1">CHỜ GIAO HÀNG</span>
                                        </c:when>
                                        <c:when test="${statusUpper == 'CANCELLED' or statusUpper == 'CANCELED'}">
                                            <span class="shopee-status-cancelled ms-1">ĐÃ HỦY</span>
                                        </c:when>
                                        <c:when test="${statusUpper == 'PENDING' or statusUpper == 'UNPAID'}">
                                            <span class="text-muted small me-1"><i class="bi bi-hourglass-split text-warning"></i> Chờ thanh toán</span>
                                            <span class="text-muted">|</span>
                                            <span class="shopee-status-shipping ms-1 text-danger">CHỜ THANH TOÁN</span>
                                        </c:when>
                                        <c:when test="${statusUpper == 'NEW'}">
                                            <span class="text-muted small me-1"><i class="bi bi-clock-history text-warning"></i> Chờ shop xác nhận</span>
                                            <span class="text-muted">|</span>
                                            <span class="shopee-status-shipping ms-1 text-warning">CHỜ XÁC NHẬN</span>
                                        </c:when>
                                        <c:when test="${statusUpper == 'PACKING'}">
                                            <span class="text-muted small me-1"><i class="bi bi-box-seam text-primary"></i> Đang đóng gói quả tươi</span>
                                            <span class="text-muted">|</span>
                                            <span class="shopee-status-shipping ms-1">ĐANG ĐÓNG GÓI</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small me-1"><i class="bi bi-box-seam text-primary"></i> Đang chuẩn bị hàng</span>
                                            <span class="text-muted">|</span>
                                            <span class="shopee-status-shipping ms-1">VẬN CHUYỂN</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="shopee-items-list" onclick="showOrderTracking('${order.id}')" title="Bấm vào sản phẩm để xem lộ trình giao hàng">
                                <c:choose>
                                    <c:when test="${order.hasItems()}">
                                        <c:forEach items="${order.items}" var="item">
                                            <div class="shopee-item-row">
                                                <img src="${item.imageUrl}" class="shopee-item-thumb" alt="${item.productName}" onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop';">
                                                <div class="shopee-item-details">
                                                    <div class="shopee-item-title">${item.productName}</div>
                                                    <div class="shopee-item-variant">Phân loại hàng: ${not empty item.variantName ? item.variantName : 'Tiêu chuẩn'}</div>
                                                    <div class="shopee-item-qty">x${item.quantity}</div>
                                                </div>
                                                <div class="shopee-item-price">
                                                    <span class="shopee-price-current">${item.formattedUnitPrice}</span>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="shopee-item-row">
                                            <img src="https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop" class="shopee-item-thumb" alt="Trái cây tươi">
                                            <div class="shopee-item-details">
                                                    <div class="shopee-item-title">${order.note}</div>
                                                    <div class="shopee-item-variant">Phân loại hàng: Tiêu chuẩn Gốc Vườn</div>
                                                    <div class="shopee-item-qty">x1</div>
                                            </div>
                                            <div class="shopee-item-price">
                                                <span class="shopee-price-current">${order.totalAmount}₫</span>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="shopee-summary-row">
                                <span class="shopee-summary-label">Thành tiền:</span>
                                <span class="shopee-summary-amount">${order.totalAmount}₫</span>
                            </div>

                            <div class="shopee-card-footer">
                                <div class="shopee-footer-note">
                                    <c:choose>
                                        <c:when test="${statusUpper == 'COMPLETED' or statusUpper == 'DELIVERED'}">
                                            Đang chờ Người bán đánh giá
                                        </c:when>
                                        <c:when test="${statusUpper == 'SHIPPING'}">
                                            Vui lòng chỉ nhấn "Đã Nhận Hàng" khi đơn hàng đã được giao đến bạn và sản phẩm nhận được không có vấn đề nào.
                                        </c:when>
                                        <c:when test="${statusUpper == 'CANCELLED'}">
                                            Đơn hàng đã được hủy bởi bạn hoặc người bán.
                                        </c:when>
                                        <c:when test="${statusUpper == 'FAILED'}">
                                            Giao hàng không thành công.
                                        </c:when>
                                        <c:otherwise>
                                            Người bán đang chuẩn bị đóng gói hoa quả tươi chuyển giao cho đơn vị vận chuyển.
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="shopee-actions">
                                    <c:choose>
                                        <c:when test="${statusUpper == 'COMPLETED' or statusUpper == 'DELIVERED'}">
                                            <a href="${pageContext.request.contextPath}/home" class="btn-shopee-primary">
                                                Mua Lại
                                            </a>
                                            <button type="button" class="btn-shopee-outline" onclick="openChatShop('${order.shopName}')">
                                                Liên Hệ Người Bán
                                            </button>
                                            <button type="button" class="btn-shopee-review" onclick="openReviewModal('${order.id}')">
                                                Đánh Giá
                                            </button>
                                        </c:when>
                                        <c:when test="${statusUpper == 'SHIPPING' or statusUpper == 'DELIVERING' or statusUpper == 'IN_TRANSIT'}">
                                            <button type="button" class="btn-shopee-primary" onclick="confirmReceivedOrder('${order.id}')">
                                                Đã Nhận Hàng
                                            </button>
                                            <button type="button" class="btn-shopee-outline" onclick="showOrderTracking('${order.id}')">
                                                <i class="bi bi-truck me-1"></i> Tra Cứu Vận Chuyển
                                            </button>
                                            <button type="button" class="btn-shopee-outline" onclick="openChatShop('${order.shopName}')">
                                                Liên Hệ Người Bán
                                            </button>
                                        </c:when>
                                        <c:when test="${statusUpper == 'CANCELLED' or statusUpper == 'CANCELED'}">
                                            <a href="${pageContext.request.contextPath}/home" class="btn-shopee-primary">
                                                Mua Lại
                                            </a>
                                            <button type="button" class="btn-shopee-outline" onclick="showOrderTracking('${order.id}')">
                                                <i class="bi bi-info-circle me-1"></i> Xem Chi Tiết Hủy
                                            </button>
                                            <button type="button" class="btn-shopee-outline" onclick="openChatShop('${order.shopName}')">
                                                Liên Hệ Người Bán
                                            </button>
                                        </c:when>
                                        <c:when test="${statusUpper == 'FAILED'}">
                                            <button type="button" class="btn-shopee-outline text-warning border-warning-subtle" onclick="showOrderTracking('${order.id}')">
                                                <i class="bi bi-exclamation-triangle me-1"></i> Xem Chi Tiết Sự Cố
                                            </button>
                                            <button type="button" class="btn-shopee-outline" onclick="openChatShop('${order.shopName}')">
                                                Liên Hệ Người Bán
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="btn-shopee-outline text-danger border-danger-subtle" onclick="cancelOrder('${order.id}')">
                                                <i class="bi bi-x-circle me-1"></i> Hủy Đơn Hàng
                                            </button>
                                            <button type="button" class="btn-shopee-outline" onclick="openChatShop('${order.shopName}')">
                                                Liên Hệ Người Bán
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div id="ordersEmptyFilter" class="empty-state d-none py-4">
                    <div class="empty-state-icon">
                        <i class="bi bi-inbox"></i>
                    </div>
                    <h6 class="fw-bold text-dark">Chưa có đơn hàng nào trong mục này</h6>
                    <p class="text-muted small mb-0">Các đơn hàng tương ứng sẽ xuất hiện tại đây khi phát sinh giao dịch.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i class="bi bi-bag-x"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Chưa có đơn hàng nào</h5>
                    <p class="text-muted small mb-4">Bạn chưa thực hiện đơn đặt hàng trái cây nào trên hệ thống.</p>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-fresh-green px-4 py-2">
                        <i class="bi bi-basket2 me-1"></i> Khám phá nông sản ngay
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

