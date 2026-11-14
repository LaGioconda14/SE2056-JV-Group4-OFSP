<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>

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
                        <c:set var="statusUpper" value="${not empty order.status ? order.status.toUpperCase() : ''}" />
                        <c:set var="displayOrderId" value="${not empty order.subOrderCode ? order.subOrderCode : order.subOrderId}" />
                        <c:set var="fallbackNote" value="${not empty order.deliverySlot ? 'Khung giờ giao: '.concat(order.deliverySlot) : 'Đơn hàng nông sản chuỗi lạnh Gốc Vườn'}" />
                        <c:set var="mainProductName" value="${not empty order.items ? order.items[0].productNameSnapshot : fallbackNote}" />
                        <c:if test="${not empty order.items and order.items.size() > 1}">
                            <c:set var="mainProductName" value="${mainProductName.concat(' (+').concat(order.items.size() - 1).concat(' sản phẩm khác)')}" />
                        </c:if>
                        <div class="shopee-order-card"
                             data-order-status="${statusUpper}"
                             data-payment-status="${order.paymentStatus != null ? order.paymentStatus.toUpperCase() : ''}"
                             data-payment-method="${order.paymentMethod != null ? order.paymentMethod.toUpperCase() : ''}"
                             data-order-id="${displayOrderId}"
                             data-sub-order-id="${order.subOrderId}"
                             data-shop-id="${order.shopId}"
                             data-product-name="<c:out value='${mainProductName}'/>"
                             data-timestamp="${order.createdAt != null ? order.createdAt.time : 0}"
                             data-shop-name="${order.shopName}"
                             data-created-at="${order.createdAt}"
                             data-cancel-reason="${order.cancelReason != null ? order.cancelReason : ''}"
                             data-failure-reason="${order.delivery != null and order.delivery.failureReason != null ? order.delivery.failureReason : ''}"
                             data-delivery-slot="${order.deliverySlot != null ? order.deliverySlot : ''}"
                             data-note="${order.note != null ? order.note : ''}"
                             data-recipient-name="${order.shippingAddress != null ? order.shippingAddress.recipientName : user.fullName}"
                             data-recipient-phone="${order.shippingAddress != null ? order.shippingAddress.recipientPhone : user.phone}"
                             data-recipient-address="${order.shippingAddress != null ? order.shippingAddress.fullAddress : 'Địa chỉ nhận hàng'}"
                             data-goods-amount="${order.shopSubtotal}"
                             data-shipping-fee="${order.shopShippingFee}"
                             data-discount="${order.shopDiscount}"
                             data-final-amount="${order.shopTotal}"
                             data-driver-name="${order.delivery != null and order.delivery.driverName != null ? order.delivery.driverName : ''}"
                             data-driver-phone="${order.delivery != null and order.delivery.driverPhone != null ? order.delivery.driverPhone : ''}">
                            <div class="shopee-card-header">
                                <div class="shopee-shop-info flex-wrap">
                                    <span class="shopee-shop-name">${order.shopName}</span>
                                    <button type="button" class="shopee-btn-chat" onclick="openChatFromCard(this)">
                                        <i class="bi bi-chat-dots-fill"></i> Chat
                                    </button>
                                    <a href="${pageContext.request.contextPath}/store?id=${order.shopId}" class="shopee-btn-shop">
                                        <i class="bi bi-shop"></i> Xem Shop
                                    </a>

                                    <span class="text-muted small ms-2 d-none d-sm-inline">•</span>
                                    <span class="text-muted small ms-1"><i class="bi bi-clock me-1 text-secondary"></i><c:choose><c:when test="${not empty order.createdAt}"><fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></c:when><c:otherwise>Mới đặt</c:otherwise></c:choose></span>
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

                            <div class="shopee-items-list" onclick="showOrderTracking('${displayOrderId}')" title="Bấm vào sản phẩm để xem lộ trình giao hàng">
                                <c:choose>
                                    <c:when test="${not empty order.items}">
                                        <c:forEach items="${order.items}" var="item">
                                            <c:set var="resolvedItemImg" value="${not empty item.imageUrl ? item.imageUrl : 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop'}" />
                                            <div class="shopee-item-row">
                                                <c:choose>
                                                    <c:when test="${not empty item.productId and item.productId > 0}">
                                                        <a href="${pageContext.request.contextPath}/detail?id=${item.productId}<c:if test='${not empty item.variantId and item.variantId > 0}'>&variantId=${item.variantId}</c:if>" onclick="event.stopPropagation();" title="Xem chi tiết sản phẩm">
                                                            <img src="${resolvedItemImg}" class="shopee-item-thumb" alt="${item.productNameSnapshot}" onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop';">
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${resolvedItemImg}" class="shopee-item-thumb" alt="${item.productNameSnapshot}" onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop';">
                                                    </c:otherwise>
                                                </c:choose>
                                                <div class="shopee-item-details">
                                                    <c:choose>
                                                        <c:when test="${not empty item.productId and item.productId > 0}">
                                                            <a href="${pageContext.request.contextPath}/detail?id=${item.productId}<c:if test='${not empty item.variantId and item.variantId > 0}'>&variantId=${item.variantId}</c:if>" onclick="event.stopPropagation();" class="shopee-item-title text-decoration-none" style="color: inherit;" title="Xem chi tiết sản phẩm">
                                                                ${item.productNameSnapshot}
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="shopee-item-title">${item.productNameSnapshot}</div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div class="shopee-item-variant">Phân loại hàng: ${not empty item.variantNameSnapshot ? item.variantNameSnapshot : 'Tiêu chuẩn'}</div>
                                                    <div class="shopee-item-qty">x${item.quantity}</div>
                                                </div>
                                                <div class="shopee-item-price">
                                                    <span class="shopee-price-current"><fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/>₫</span>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="shopee-item-row">
                                            <img src="https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop" class="shopee-item-thumb" alt="Trái cây tươi">
                                            <div class="shopee-item-details">
                                                <div class="shopee-item-title">${fallbackNote}</div>
                                                <div class="shopee-item-variant">Phân loại hàng: Tiêu chuẩn Gốc Vườn</div>
                                                <div class="shopee-item-qty">x1</div>
                                            </div>
                                            <div class="shopee-item-price">
                                                <span class="shopee-price-current"><fmt:formatNumber value="${order.shopTotal}" pattern="#,##0"/>₫</span>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="shopee-summary-row">
                                <span class="shopee-summary-label">Thành tiền:</span>
                                <span class="shopee-summary-amount"><fmt:formatNumber value="${order.shopTotal}" pattern="#,##0"/>₫</span>
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
                                            <c:set var="targetPId" value="${null}" />
                                            <c:set var="targetVId" value="${null}" />
                                            <c:forEach items="${order.items}" var="it">
                                                <c:if test="${empty targetPId and not empty it.productId and it.productId > 0}">
                                                    <c:set var="targetPId" value="${it.productId}" />
                                                    <c:set var="targetVId" value="${it.variantId}" />
                                                </c:if>
                                            </c:forEach>
                                            <c:if test="${empty targetVId and not empty order.items}">
                                                <c:set var="targetVId" value="${order.items[0].variantId}" />
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${not empty targetPId and targetPId > 0}">
                                                    <a href="${pageContext.request.contextPath}/detail?id=${targetPId}<c:if test='${not empty targetVId and targetVId > 0}'>&variantId=${targetVId}</c:if>" class="btn-shopee-primary text-decoration-none">
                                                        Mua Lại
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/products" class="btn-shopee-primary text-decoration-none">
                                                        Mua Lại
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                            <button type="button" class="btn-shopee-review" onclick="openReviewModal('${not empty order.subOrderCode ? order.subOrderCode : order.orderCode}', '${not empty order.items ? order.items[0].orderItemId : ''}')">
                                                Đánh Giá
                                            </button>
                                        </c:when>
                                        <c:when test="${statusUpper == 'SHIPPING' or statusUpper == 'DELIVERING' or statusUpper == 'IN_TRANSIT'}">
                                            <button type="button" class="btn-shopee-primary" onclick="confirmReceivedOrder('${displayOrderId}')">
                                                Đã Nhận Hàng
                                            </button>
                                            <button type="button" class="btn-shopee-outline" onclick="showOrderTracking('${displayOrderId}')">
                                                <i class="bi bi-truck me-1"></i> Tra Cứu Vận Chuyển
                                            </button>
                                        </c:when>
                                        <c:when test="${statusUpper == 'CANCELLED' or statusUpper == 'CANCELED'}">
                                            <c:set var="targetPId" value="${null}" />
                                            <c:set var="targetVId" value="${null}" />
                                            <c:forEach items="${order.items}" var="it">
                                                <c:if test="${empty targetPId and not empty it.productId and it.productId > 0}">
                                                    <c:set var="targetPId" value="${it.productId}" />
                                                    <c:set var="targetVId" value="${it.variantId}" />
                                                </c:if>
                                            </c:forEach>
                                            <c:if test="${empty targetVId and not empty order.items}">
                                                <c:set var="targetVId" value="${order.items[0].variantId}" />
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${not empty targetPId and targetPId > 0}">
                                                    <a href="${pageContext.request.contextPath}/detail?id=${targetPId}<c:if test='${not empty targetVId and targetVId > 0}'>&variantId=${targetVId}</c:if>" class="btn-shopee-primary text-decoration-none">
                                                        Mua Lại
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/products" class="btn-shopee-primary text-decoration-none">
                                                        Mua Lại
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                            <button type="button" class="btn-shopee-outline" onclick="showOrderTracking('${displayOrderId}')">
                                                <i class="bi bi-info-circle me-1"></i> Xem Chi Tiết Hủy
                                            </button>
                                        </c:when>
                                        <c:when test="${statusUpper == 'FAILED'}">
                                            <button type="button" class="btn-shopee-outline text-warning border-warning-subtle" onclick="showOrderTracking('${displayOrderId}')">
                                                <i class="bi bi-exclamation-triangle me-1"></i> Xem Chi Tiết Sự Cố
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <c:if test="${order.paymentMethod == 'VNPAY' and (order.paymentStatus == 'PENDING' or order.paymentStatus == 'FAILED')}">
                                                <a href="${pageContext.request.contextPath}/payment/vnpay/create?orderId=${order.orderId}" class="btn-shopee-primary text-decoration-none">
                                                    <i class="bi bi-credit-card me-1"></i> ${order.paymentStatus == 'FAILED' ? 'Thanh toán lại VNPAY' : 'Thanh toán VNPAY'}
                                                </a>
                                            </c:if>
                                            <button type="button" class="btn-shopee-outline text-danger border-danger-subtle" onclick="cancelOrder('${displayOrderId}')">
                                                <i class="bi bi-x-circle me-1"></i> Hủy Đơn Hàng
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
