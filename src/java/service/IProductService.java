package service;

import java.util.List;
import model.ProductVariant;

public interface IProductService {
    //lấy list sản phẩm
    List<ProductVariant> getVariantsByShopId(long shopId);
    int countProductsByShopId(long shopId);
    int countVariantsByShopId(long shopId);
    int countVariantsByStatusTab(long shopId, String statusTab);
}