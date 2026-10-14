package service.impl;

import dao.ProductDAO;
import java.util.List;
import model.Category;
import model.Product;
import service.IProductService;

public class ProductServiceImpl implements IProductService {

    private final ProductDAO productDAO;

    public ProductServiceImpl() {
        this.productDAO = new ProductDAO();
    }

    public ProductServiceImpl(ProductDAO productDAO) {
        this.productDAO = productDAO;
    }

    @Override
    public List<Product> getHomeProducts() {
        return productDAO.getHomeProducts();
    }

    @Override
    public List<Category> getAllCategories() {
        return productDAO.getAllCategories();
    }

    @Override
    public List<Category> getHomeFeaturedTabs() {
        return productDAO.getHomeFeaturedTabs();
    }

    @Override
    public List<Category> getHierarchyCategories() {
        return productDAO.getHierarchyCategories();
    }

    @Override
    public int countCatalogProducts(String keyword, String[] categories, Double minPrice, Double maxPrice, 
                                    Integer rating, String availability, String origin, String tag) {
        return productDAO.countCatalogProducts(keyword, categories, minPrice, maxPrice, rating, availability, origin, tag);
    }

    @Override
    public List<Product> getCatalogProducts(String keyword, String[] categories, Double minPrice, Double maxPrice, 
                                            Integer rating, String availability, String origin, String tag, 
                                            String sortBy, int page, int pageSize) {
        return productDAO.getCatalogProducts(keyword, categories, minPrice, maxPrice, rating, availability, origin, tag, sortBy, page, pageSize);
    }

    @Override
    public Product getProductById(long productId) {
        return productDAO.getProductById(productId);
    }
}

