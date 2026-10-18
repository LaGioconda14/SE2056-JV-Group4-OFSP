<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade" id="nav-address" role="tabpanel">
    <div class="profile-section-card">
        <div class="profile-section-header">
            <div>
                <span class="section-tag">ĐỊA ĐIỂM GIAO NHẬN</span>
                <h3 class="section-heading">Địa Chỉ Nhận Trái Cây Chuỗi Lạnh</h3>
            </div>
            <c:if test="${not empty addresses}">
                <button class="btn btn-fresh-green btn-sm px-3" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                    <i class="bi bi-plus-lg me-1"></i> Thêm địa chỉ mới
                </button>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${not empty addresses}">
                <c:forEach items="${addresses}" var="addr">
                    <div class="address-item ${(addr.isDefault or addr['default']) ? 'address-item-default' : ''}">
                        <div>
                            <div class="d-flex align-items-center gap-2 mb-1 flex-wrap">
                                <strong class="text-dark fs-6">${addr.recipientName}</strong>
                                <c:if test="${addr.isDefault or addr['default']}">
                                    <span class="badge bg-success rounded-pill small"><i class="bi bi-check-circle-fill me-1"></i>Mặc định</span>
                                </c:if>
                            </div>
                            <div class="text-muted small mb-1">
                                <i class="bi bi-telephone text-success me-1"></i><strong>${addr.recipientPhone}</strong>
                            </div>
                            <div class="text-dark small">
                                <i class="bi bi-geo-alt-fill text-danger me-1"></i>${addr.fullAddress}
                            </div>
                        </div>
                        <div class="address-item-actions">
                            <c:if test="${not (addr.isDefault or addr['default'])}">
                                <form action="${pageContext.request.contextPath}/profile" method="POST" class="d-inline m-0">
                                    <input type="hidden" name="action" value="setDefaultAddress">
                                    <input type="hidden" name="addressId" value="${addr.addressId}">
                                    <button type="submit" class="btn-pill-sec py-1" title="Đặt làm địa chỉ nhận hàng ưu tiên">
                                        Thiết lập mặc định
                                    </button>
                                </form>
                            </c:if>
                            <form action="${pageContext.request.contextPath}/profile" method="POST" class="d-inline m-0" onsubmit="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?');">
                                <input type="hidden" name="action" value="deleteAddress">
                                <input type="hidden" name="addressId" value="${addr.addressId}">
                                <button type="submit" class="btn-pill-danger" title="Xóa địa chỉ">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i class="bi bi-geo-alt"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Chưa lưu địa chỉ nhận hàng</h5>
                    <p class="text-muted small mb-3">Thêm địa chỉ giao nhận để đặt hàng và nhận trái cây tươi nhanh chóng hơn.</p>
                    <button class="btn-pill-success py-2" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                        <i class="bi bi-plus-lg me-1"></i> Thêm địa chỉ nhận hàng
                    </button>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

