package controller.product;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Product;
import model.ProductVariant;
import util.DBContext;

@WebServlet(name = "ProductListServlet", urlPatterns = {"/products", "/product-detail"})
public class ProductListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ProductVariant> variants = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.price, pv.stock_quantity, p.name AS product_name "
                + "FROM product_variants pv "
                + "INNER JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.is_active = 1 AND p.is_active = 1 "
                + "ORDER BY pv.variant_id ASC";

        try {
            Connection conn = new DBContext().getConnection();
            if (conn != null) {
                try (conn;
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Product p = new Product();
                        p.setName(rs.getString("product_name"));

                        ProductVariant v = new ProductVariant();
                        v.setVariantId(rs.getLong("variant_id"));
                        v.setSku(rs.getString("sku"));
                        v.setVariantName(rs.getString("variant_name"));
                        v.setUnit(rs.getString("unit"));
                        v.setPrice(rs.getBigDecimal("price"));
                        v.setStockQuantity(rs.getInt("stock_quantity"));
                        v.setProduct(p);

                        variants.add(v);
                    }
                }
            }
        } catch (Exception ex) {
            // Bỏ qua lỗi kết nối để JSP hiển thị dữ liệu tĩnh dự phòng
        }

        request.setAttribute("variantList", variants);
        request.getRequestDispatcher("/views/product/product-detail.jsp").forward(request, response);
    }
}
