package model;

import java.util.ArrayList;
import java.util.List;

/** Kết quả một lần bấm "Tạo kỳ quyết toán". */
public class PayoutGenerationResult {

    private int created;
    private final List<String> skipped = new ArrayList<>();

    public int getCreated() { return created; }
    public void incrementCreated() { created++; }
    public List<String> getSkipped() { return skipped; }
}
