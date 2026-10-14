package model;

import java.util.ArrayList;
import java.util.List;

public class Category {
    private int categoryId;
    private Integer parentId;
    private String categoryName;
    private String slug;
    private String description;
    private String imageUrl;
    private String iconClass;
    private int displayOrder;
    private boolean isActive;
    private int productCount;
    private List<Category> subCategories = new ArrayList<>();

    public Category() {}

    public Category(int categoryId, String categoryName, String slug, int productCount) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.slug = slug;
        this.productCount = productCount;
    }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public Integer getParentId() { return parentId; }
    public void setParentId(Integer parentId) { this.parentId = parentId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getIconClass() { return iconClass; }
    public void setIconClass(String iconClass) { this.iconClass = iconClass; }

    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public int getProductCount() { return productCount; }
    public void setProductCount(int productCount) { this.productCount = productCount; }

    public List<Category> getSubCategories() { return subCategories; }
    public void setSubCategories(List<Category> subCategories) { this.subCategories = subCategories; }
    public void addSubCategory(Category sub) {
        if (this.subCategories == null) {
            this.subCategories = new ArrayList<>();
        }
        this.subCategories.add(sub);
    }
}

