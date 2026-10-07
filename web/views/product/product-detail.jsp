<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Th&#234;m V&#224;o Gi&#7887; H&#224;ng - Online Fruit Shop</title>
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
    <h2>🍎 Test Th&#234;m S&#7843;n Ph&#7849;m V&#224;o Gi&#7887; H&#224;ng</h2>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
    </c:if>
    <c:if test="${not empty cartError}">
        <div class="alert alert-danger"><c:out value="${cartError}"/></div>
    </c:if>
    <c:if test="${not empty cartSuccess}">
        <div class="alert alert-success"><c:out value="${cartSuccess}"/></div>
    </c:if>

    <h3>1. Danh s&#225;ch s&#7843;n ph&#7849;m c&#243; trong h&#7879; th&#7889;ng</h3>
    <table>
        <thead>
            <tr>
                <th>Variant ID</th>
                <th>T&#234;n s&#7843;n ph&#7849;m</th>
                <th>Ph&#226;n lo&#7841;i / Quy c&#225;ch</th>
                <th>&#272;&#417;n gi&#225;</th>
                <th>T&#7891;n kho</th>
                <th>Thao t&#225;c</th>
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
                                    Ch&#7885;n m&#227; n&#224;y
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td><strong>1</strong></td>
                        <td>D&#226;u T&#226;y Gi&#7889;ng Nh&#7853;t &#272;&#224; L&#7841;t</td>
                        <td>H&#7897;p 500g (Lo&#7841;i 1) (h&#7897;p)</td>
                        <td>120.000 &#8363;</td>
                        <td>100</td>
                        <td><button type="button" class="btn-select" onclick="selectVariant(1)">Ch&#7885;n m&#227; n&#224;y</button></td>
                    </tr>
                    <tr>
                        <td><strong>2</strong></td>
                        <td>D&#226;u T&#226;y Gi&#7889;ng Nh&#7853;t &#272;&#224; L&#7841;t</td>
                        <td>H&#7897;p 1kg (Lo&#7841;i 1) (h&#7897;p)</td>
                        <td>230.000 &#8363;</td>
                        <td>50</td>
                        <td><button type="button" class="btn-select" onclick="selectVariant(2)">Ch&#7885;n m&#227; n&#224;y</button></td>
                    </tr>
                    <tr>
                        <td><strong>3</strong></td>
                        <td>B&#417; S&#225;p 034 &#272;&#7863;c S&#7843;n L&#226;m &#272;&#7891;ng</td>
                        <td>T&#250;i 1kg (3-4 qu&#7843;/kg) (kg)</td>
                        <td>65.000 &#8363;</td>
                        <td>200</td>
                        <td><button type="button" class="btn-select" onclick="selectVariant(3)">Ch&#7885;n m&#227; n&#224;y</button></td>
                    </tr>
                    <tr>
                        <td><strong>4</strong></td>
                        <td>T&#225;o Envy New Zealand Size 70</td>
                        <td>T&#250;i 1kg (kho&#7843;ng 3-4 qu&#7843;) (kg)</td>
                        <td>189.000 &#8363;</td>
                        <td>150</td>
                        <td><button type="button" class="btn-select" onclick="selectVariant(4)">Ch&#7885;n m&#227; n&#224;y</button></td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>

    <h3>2. Form g&#7917;i th&#234;m v&#224;o gi&#7887; (POST /cart/add)</h3>
    <form method="post" action="${pageContext.request.contextPath}/cart/add">
        <c:if test="${not empty sessionScope.cartCsrfToken}">
            <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}">
        </c:if>
        <div class="form-group">
            <label for="variantId">M&#227; bi&#7871;n th&#7875; (Variant ID):</label>
            <input type="number" id="variantId" name="variantId" value="1" min="1" required>
        </div>

        <div class="form-group">
            <label for="quantity">S&#7889; l&#432;&#7907;ng mua:</label>
            <input type="number" id="quantity" name="quantity" value="1" min="1" max="1000" required>
        </div>

        <div class="form-group">
            <button type="submit">🛒 Th&#234;m v&#224;o gi&#7887; h&#224;ng</button>
        </div>
    </form>

    <div class="links">
        <a href="${pageContext.request.contextPath}/cart">👉 Xem gi&#7887; h&#224;ng hi&#7879;n t&#7841;i (/cart)</a>
        <a href="${pageContext.request.contextPath}/home.jsp">🏠 Trang ch&#7911;</a>
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
