<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng ký thành công</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light text-center py-5">
    <div class="container mt-5">
        <div class="card shadow p-5 mx-auto" style="max-width: 600px;">
            <div class="card-body">
                <h2 class="text-success fw-bold mb-3">🎉 Gửi Yêu Cầu Thành Công!</h2>
                <p class="text-muted">Yêu cầu đăng ký gian hàng của bạn đã được gửi tới hệ thống. Vui lòng chờ Admin xét duyệt.</p>
                <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-success mt-3 px-4">Quay về Trang Chủ</a>
            </div>
        </div>
    </div>
</body>
</html>