<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn vai trò - Gốc Vườn</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            min-height: 100vh;
            background: linear-gradient(160deg, #ecfdf5 0%, #f8fafc 55%, #fefce8 100%);
            color: #0f172a;
        }
        .cr-brand { display: inline-flex; align-items: center; gap: .6rem; font-weight: 800; font-size: 1.25rem; color: #166534; text-decoration: none; }
        .cr-brand .logo { width: 2.5rem; height: 2.5rem; border-radius: .8rem; background: #dcfce7; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; }
        .cr-title { font-weight: 800; letter-spacing: -.02em; }
        .cr-card {
            position: relative; height: 100%; background: #fff; border: 2px solid #e2e8f0; border-radius: 1.5rem;
            padding: 2rem 1.75rem; display: flex; flex-direction: column;
            box-shadow: 0 10px 30px rgba(15, 23, 42, .06); transition: transform .2s ease, border-color .2s ease, box-shadow .2s ease;
        }
        .cr-card:hover { transform: translateY(-4px); border-color: #34d399; box-shadow: 0 18px 40px rgba(5, 150, 105, .15); }
        .cr-icon { width: 4rem; height: 4rem; border-radius: 1.2rem; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin-bottom: 1.1rem; }
        .cr-icon.buyer { background: #dcfce7; color: #15803d; }
        .cr-icon.seller { background: #fef3c7; color: #b45309; }
        .cr-card h2 { font-size: 1.3rem; font-weight: 800; }
        .cr-card ul { list-style: none; padding: 0; margin: 1rem 0 1.5rem; display: grid; gap: .55rem; font-size: .9rem; color: #475569; }
        .cr-card li { display: flex; gap: .55rem; align-items: flex-start; }
        .cr-card li i { color: #10b981; margin-top: .1rem; }
        .cr-btn { margin-top: auto; display: inline-flex; align-items: center; justify-content: center; gap: .5rem; padding: .85rem 1.2rem; border-radius: 999px; font-weight: 700; font-size: .95rem; text-decoration: none; transition: all .2s; }
        .cr-btn.buyer { background: linear-gradient(135deg, #059669, #10b981); color: #fff; box-shadow: 0 6px 16px rgba(5, 150, 105, .25); }
        .cr-btn.buyer:hover { color: #fff; filter: brightness(.95); }
        .cr-btn.seller { background: #fff; color: #b45309; border: 2px solid #f59e0b; }
        .cr-btn.seller:hover { background: #fffbeb; color: #92400e; }
        .cr-badge { position: absolute; top: 1rem; right: 1rem; background: #fef3c7; color: #92400e; font-size: .7rem; font-weight: 800; padding: .25rem .7rem; border-radius: 999px; }
        .cr-note { font-size: .82rem; color: #64748b; }
    </style>
</head>
<body>
<div class="container py-4 py-md-5">
    <div class="d-flex justify-content-between align-items-center mb-4 mb-md-5">
        <a href="${ctx}/home" class="cr-brand"><span class="logo">🍎</span> Gốc Vườn</a>
        <a href="${ctx}/logout" class="cr-note text-decoration-none"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a>
    </div>

    <div class="text-center mb-4 mb-md-5">
        <div class="d-inline-flex align-items-center gap-2 px-3 py-1 rounded-pill bg-success-subtle text-success fw-bold small mb-3">
            <i class="bi bi-check-circle-fill"></i> Tạo tài khoản thành công
        </div>
        <h1 class="cr-title display-6">
            Chào <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'bạn'}" />, bạn muốn dùng Gốc Vườn với vai trò nào?
        </h1>
        <p class="text-secondary mb-0">Chọn một vai trò để bắt đầu. Bạn vẫn có thể đổi ý sau này.</p>
    </div>

    <div class="row g-4 justify-content-center">
        <!-- Khách hàng -->
        <div class="col-12 col-md-6 col-lg-5">
            <div class="cr-card">
                <div class="cr-icon buyer"><i class="bi bi-basket2-fill"></i></div>
                <h2>Tôi là khách hàng</h2>
                <p class="text-secondary mb-0">Mua nông sản, trái cây tươi trực tiếp từ nhà vườn.</p>
                <ul>
                    <li><i class="bi bi-check-circle-fill"></i> Duyệt và đặt mua sản phẩm ngay</li>
                    <li><i class="bi bi-check-circle-fill"></i> Lưu sản phẩm yêu thích, dùng mã giảm giá</li>
                    <li><i class="bi bi-check-circle-fill"></i> Theo dõi đơn hàng và giao hàng</li>
                </ul>
                <a href="${ctx}/home" class="cr-btn buyer">Tiếp tục mua sắm <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>

        <!-- Người bán -->
        <div class="col-12 col-md-6 col-lg-5">
            <div class="cr-card">
                <span class="cr-badge">Cần Admin duyệt</span>
                <div class="cr-icon seller"><i class="bi bi-shop"></i></div>
                <h2>Tôi muốn trở thành người bán</h2>
                <p class="text-secondary mb-0">Mở gian hàng và bán nông sản của bạn trên sàn.</p>
                <ul>
                    <li><i class="bi bi-check-circle-fill"></i> Điền thông tin cửa hàng, địa chỉ, ngân hàng</li>
                    <li><i class="bi bi-check-circle-fill"></i> Ban quản trị xét duyệt hồ sơ trong 1–3 ngày</li>
                    <li><i class="bi bi-check-circle-fill"></i> Trong lúc chờ, bạn vẫn mua sắm như khách hàng</li>
                </ul>
                <a href="${ctx}/register-shop" class="cr-btn seller">Đăng ký bán hàng <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>

    <p class="text-center cr-note mt-4 mb-0">
        Chưa chắc chắn? Hãy chọn khách hàng — bạn có thể đăng ký bán hàng bất kỳ lúc nào trong menu tài khoản.
    </p>
</div>
</body>
</html>
