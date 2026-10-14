package service;

import java.util.List;
import model.Category;
import model.Product;

public interface IProductService {

    /**
     * Lấy danh sách sản phẩm nổi bật hiển thị trên trang chủ.
     */
    List<Product> getHomeProducts();

    /**
     * Lấy toàn bộ danh mục sản phẩm kèm số lượng sản phẩm.
     */
    List<Category> getAllCategories();

    /**
     * Lấy danh sách các tab danh mục hiển thị trên trang chủ.
     */
    List<Category> getHomeFeaturedTabs();

    /**
     * Lấy danh sách danh mục theo cấu trúc phân cấp đa tầng (cha - con).
     */
    List<Category> getHierarchyCategories();

    /**
     * Đếm tổng số lượng sản phẩm theo các tiêu chí tìm kiếm và bộ lọc.
     */
    int countCatalogProducts(String keyword, String[] categories, Double minPrice, Double maxPrice, 
                             Integer rating, String availability, String origin, String tag);

    /**
     * Lấy danh sách sản phẩm theo bộ lọc tìm kiếm, phân trang và sắp xếp.
     */
    List<Product> getCatalogProducts(String keyword, String[] categories, Double minPrice, Double maxPrice, 
                                     Integer rating, String availability, String origin, String tag, 
                                     String sortBy, int page, int pageSize);

    /**
     * Lấy chi tiết sản phẩm theo ID.
     */
    Product getProductById(long productId);
}

