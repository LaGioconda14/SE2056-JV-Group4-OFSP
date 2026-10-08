<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Thêm Vào Giỏ Hàng - Online Fruit Shop</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 30px;
            background-color: #fafafa;
            color: #333;
        }
        .container {
            max-width: 850px;
            margin: 0 auto;
            background: #fff;
            padding: 24px;
            border: 1px solid #ddd;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        h2, h3 {
            margin-top: 0;
            color: #2e7d32;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 24px;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f0f0f0;
        }
        .form-group {
            margin-bottom: 16px;
        }
        label {
            display: block;
            font-weight: bold;
            margin-bottom: 6px;
        }
        select, input[type="number"], input[type="text"] {
            width: 100%;
            max-width: 400px;
            padding: 8px;
            font-size: 14px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        button {
            background-color: #2e7d32;
            color: #fff;
            border: none;
            padding: 10px 20px;
            font-size: 15px;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #1b5e20;
        }
        .btn-select {
            background-color: #1976d2;
            padding: 5px 10px;
            font-size: 12px;
            font-weight: normal;
        }
        .btn-select:hover {
            background-color: #1565c0;
        }
        .alert {
            padding: 12px;
            margin-bottom: 16px;
            border-radius: 4px;
        }
        .alert-danger {
            background-color: #ffebee;
            color: #c62828;
            border: 1px solid #ffcdd2;
        }
        .alert-success {
            background-color: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }
        .links {
            margin-top: 20px;
            padding-top: 16px;
            border-top: 1px solid #eee;
        }
        .links a {
            color: #1976d2;
            text-decoration: none;
            margin-right: 16px;
            font-weight: bold;
        }
        .links a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>🍎 Test Thêm Sản Phẩm Vào Giỏ Hàng</h2>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
    </c:if>
    <c:if test="${not empty cartError}">
        <div class="alert alert-danger"><c:out value="${cartError}"/></div>
    </c:if>
    <c:if test="${not empty cartSuccess}">
        <div class="alert alert-success"><c:out value="${cartSuccess}"/></div>
    </c:if>

    <h3>1. Danh sách sản phẩm có trong hệ thống</h3>
    <table>
        <thead>
            <tr>
                <th>Variant ID</th>
                <th>Tên sản phẩm</th>
                <th>Phân loại / Quy cách</th>
                <th>Đơn giá</th>
                <th>Tồn kho</th>
                <th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${not empty variantList}">
                    <c:forEach var="v" items="${variantList}">
                        <tr>
                            <td><strong>${v.variantId}</strong></td>
                            <td><c:out value="${v.product.name}"/></td>
                            <td><c:out value="${v.variantName}"/> (<c:out value="${v.unit}"/>)</td>
                            <td><fmt:formatNumber value="${v.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/></td>
                            <td>${v.stockQuantity}</td>
                            <td>
                                <button type="button" class="btn-select" onclick="selectVariant('${v.variantId}')">
                                    Chọn mã này
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td><strong>1</strong></td>
                        <td>Dâu Tây Giống Nhật Đà Lạt</td>
                        <td>Hộp 500g (Loại 1) (hộp)</td>
                        <td>120.000 ₫</td>
                        <td>100</td>
                        <td><button type="button" class="btn-select" onclick="selectVariant(1)">Chọn mã này</button></td>
                    </tr>
                    <tr>
                        <td><strong>2</strong></td>
                        <td>Dâu Tây Giống Nhật Đà Lạt</td>
                        <td>Hộp 1kg (Loại 1) (hộp)</td>
                        <td>230.000 ₫</td>
                        <td>50</td>
                        <td><button type="button" class="btn-select" onclick="selectVariant(2)">Chọn mã này</button></td>
                    </tr>
                    <tr>
                        <td><strong>3</strong></td>
                        <td>Bơ Sáp 034 Đặc Sản Lâm Đồng</td>
                        <td>Túi 1kg (3-4 quả/kg) (kg)</td>
                        <td>65.000 ₫</td>
                        <td>200</td>
                        <td><button type="button" class="btn-select" onclick="selectVariant(3)">Chọn mã này</button></td>
                    </tr>
                    <tr>
                        <td><strong>4</strong></td>
                        <td>Táo Envy New Zealand Size 70</td>
                        <td>Túi 1kg (khoảng 3-4 quả) (kg)</td>
                        <td>189.000 ₫</td>
                        <td>150</td>
                        <td><button type="button" class="btn-select" onclick="selectVariant(4)">Chọn mã này</button></td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>

    <h3>2. Form gửi thêm vào giỏ (POST /cart/add)</h3>
    <form method="post" action="${pageContext.request.contextPath}/cart/add">
        <c:if test="${not empty sessionScope.cartCsrfToken}">
            <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}">
        </c:if>
        <div class="form-group">
            <label for="variantId">Mã biến thể (Variant ID):</label>
            <input type="number" id="variantId" name="variantId" value="1" min="1" required>
        </div>

        <div class="form-group">
            <label for="quantity">Số lượng mua:</label>
            <input type="number" id="quantity" name="quantity" value="1" min="1" max="1000" required>
        </div>

        <div class="form-group">
            <button type="submit">🛒 Thêm vào giỏ hàng</button>
        </div>
    </form>

    <div class="links">
        <a href="${pageContext.request.contextPath}/cart">👉 Xem giỏ hàng hiện tại (/cart)</a>
        <a href="${pageContext.request.contextPath}/home.jsp">🏠 Trang chủ</a>
    </div>
</div>

<script>
    function selectVariant(id) {
        document.getElementById("variantId").value = id;
        document.getElementById("quantity").focus();
    }
</script>

</body>
</html>
