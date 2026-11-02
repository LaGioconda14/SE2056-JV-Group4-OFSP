package model;

public class ReviewSummary {
    public long total;
    public double average;
    // Index 1..5, with index 0 unused.
    public long[] distribution = new long[6];
}
