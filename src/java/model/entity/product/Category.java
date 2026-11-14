package model.entity.product;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


public class Category implements Serializable {
    private static final long serialVersionUID = 1L;

    private int categoryId;
    private Integer parentId; // Có thể null trong DB
    private String categoryName;
    private String slug;
    private String description;
    private String iconClass;
    private boolean isActive;
    private List<Category> subCategories = new ArrayList<>();

    // Default Constructor
    public Category() {
    }

    // Parameterized Constructor
    public Category(int categoryId, Integer parentId, String categoryName, String slug, 
                    String description, String iconClass, boolean isActive) {
        this.categoryId = categoryId;
        this.parentId = parentId;
        this.categoryName = categoryName;
        this.slug = slug;
        this.description = description;
        this.iconClass = iconClass;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIconClass() {
        return iconClass;
    }

    public void setIconClass(String iconClass) {
        this.iconClass = iconClass;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    private int productCount;

    public int getProductCount() {
        return productCount;
    }

    public void setProductCount(int productCount) {
        this.productCount = productCount;
    }

    public List<Category> getSubCategories() { return subCategories; }
    public void setSubCategories(List<Category> subCategories) { this.subCategories = subCategories; }
    public void addSubCategory(Category sub) {
        if (this.subCategories == null) {
            this.subCategories = new ArrayList<>();
        }
        this.subCategories.add(sub);
    }
}