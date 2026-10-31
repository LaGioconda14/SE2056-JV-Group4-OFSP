<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="rs-step-panel" id="step-4">
    <div class="rs-section-title"><span class="rs-section-num">4</span><span>Bank Information (Thông Tin Ngân Hàng Doanh Thu)</span></div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
            <label class="rs-label">Bank Name – Tên ngân hàng <span class="text-red-500">*</span></label>
            <select name="bankName" class="rs-input" required>
                <option value="" selected disabled>-- Chọn ngân hàng --</option>
                <option value="Vietcombank">Vietcombank (VCB)</option>
                <option value="MBBank">MBBank (MB)</option>
                <option value="Techcombank">Techcombank (TCB)</option>
                <option value="VietinBank">VietinBank</option>
                <option value="BIDV">BIDV</option>
                <option value="VPBank">VPBank</option>
                <option value="ACB">ACB</option>
            </select>
            <p class="rs-feedback">Vui lòng chọn ngân hàng.</p>
        </div>
        <div>
            <label class="rs-label">Bank Account Number – Số tài khoản <span class="text-red-500">*</span></label>
            <input type="text" name="bankAccountNumber" class="rs-input" placeholder="Nhập số tài khoản ngân hàng" inputmode="numeric" required>
            <p class="rs-feedback">Vui lòng nhập số tài khoản.</p>
        </div>
        <div>
            <label class="rs-label">Account Holder Name – Tên chủ tài khoản <span class="text-red-500">*</span></label>
            <input type="text" name="bankAccountHolder" class="rs-input uppercase" placeholder="Viết hoa không dấu (VD: NGUYEN VAN A)" required>
            <p class="rs-feedback">Vui lòng nhập tên chủ tài khoản.</p>
        </div>
    </div>
    <p class="text-xs text-gray-500 mt-4"><i class="fa-solid fa-circle-info text-emerald-600"></i> Tài khoản ngân hàng nên đứng tên chính chủ Shop Owner để việc đối soát và chi trả doanh thu không bị gián đoạn.</p>
    <div class="flex justify-between mt-8">
        <button type="button" class="rs-btn-back" onclick="prevStep(4)"><i class="fa-solid fa-arrow-left text-xs"></i> Quay lại</button>
        <button type="button" class="rs-btn-next" onclick="nextStep(4)">Tiếp theo <i class="fa-solid fa-arrow-right text-xs"></i></button>
    </div>
</div>

