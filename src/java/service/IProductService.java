package service;

import java.util.List;
import model.ProductVariant;

public interface IProductService {
    List<ProductVariant> getVariantsByShopId(long shopId);
}