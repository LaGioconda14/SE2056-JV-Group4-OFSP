package model;

import java.io.Serializable;

public class ReviewSummary implements Serializable {
    private static final long serialVersionUID = 1L;

    private double averageRating = 5.0;
    private int totalReviews = 0;
    private int star5 = 0;
    private int star4 = 0;
    private int star3 = 0;
    private int star2 = 0;
    private int star1 = 0;

    public ReviewSummary() {
    }

    public ReviewSummary(double averageRating, int totalReviews, int star5, int star4, int star3, int star2, int star1) {
        this.averageRating = averageRating;
        this.totalReviews = totalReviews;
        this.star5 = star5;
        this.star4 = star4;
        this.star3 = star3;
        this.star2 = star2;
        this.star1 = star1;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }

    public int getTotalReviews() {
        return totalReviews;
    }

    public void setTotalReviews(int totalReviews) {
        this.totalReviews = totalReviews;
    }

    public int getStar5() {
        return star5;
    }

    public void setStar5(int star5) {
        this.star5 = star5;
    }

    public int getStar4() {
        return star4;
    }

    public void setStar4(int star4) {
        this.star4 = star4;
    }

    public int getStar3() {
        return star3;
    }

    public void setStar3(int star3) {
        this.star3 = star3;
    }

    public int getStar2() {
        return star2;
    }

    public void setStar2(int star2) {
        this.star2 = star2;
    }

    public int getStar1() {
        return star1;
    }

    public void setStar1(int star1) {
        this.star1 = star1;
    }

    public int getStarPercent(int star) {
        if (totalReviews == 0) return 0;
        int count = switch (star) {
            case 5 -> star5;
            case 4 -> star4;
            case 3 -> star3;
            case 2 -> star2;
            case 1 -> star1;
            default -> 0;
        };
        return (int) Math.round((count * 100.0) / totalReviews);
    }
}
