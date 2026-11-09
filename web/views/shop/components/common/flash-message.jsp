<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Thông báo kết quả thao tác (lưu trong session hoặc request) --%>
<c:set var="flashSuccess" value="${not empty sessionScope.successMessage ? sessionScope.successMessage : (not empty requestScope.successMessage ? requestScope.successMessage : successMessage)}" />
<c:if test="${not empty flashSuccess}">
    <div data-autohide class="mb-4 bg-emerald-50 border border-emerald-300 text-emerald-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-xs">
        <div class="flex items-center gap-3">
            <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
            <span class="text-xs font-bold"><c:out value="${flashSuccess}"/></span>
        </div>
        <button type="button" onclick="this.closest('[data-autohide]').remove()" class="text-emerald-500 hover:text-emerald-900 cursor-pointer">
            <i class="fa-solid fa-xmark text-sm"></i>
        </button>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>

<c:set var="flashError" value="${not empty sessionScope.errorMessage ? sessionScope.errorMessage : (not empty requestScope.errorMessage ? requestScope.errorMessage : errorMessage)}" />
<c:if test="${not empty flashError}">
    <div data-autohide class="mb-4 bg-rose-50 border border-rose-300 text-rose-900 px-4 py-3 rounded-2xl flex items-center justify-between shadow-xs">
        <div class="flex items-center gap-3">
            <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
            <span class="text-xs font-bold"><c:out value="${flashError}"/></span>
        </div>
        <button type="button" onclick="this.closest('[data-autohide]').remove()" class="text-rose-500 hover:text-rose-900 cursor-pointer">
            <i class="fa-solid fa-xmark text-sm"></i>
        </button>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>
