package service.impl;

import dao.ProductDAO;
import java.util.List;
import model.ProductVariant;
import service.IProductService;

public class ProductServiceImpl implements IProductService {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    public List<ProductVariant> getVariantsByShopId(long shopId) {
        return productDAO.getVariantsByShopId(shopId);
    }
}