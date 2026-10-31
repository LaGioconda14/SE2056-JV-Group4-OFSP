<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty sessionScope.successMessage}">
    <div data-autohide class="mb-4 bg-emerald-50 border border-emerald-300 text-emerald-800 px-4 py-3 rounded-xl flex items-center gap-3 shadow-sm">
        <i class="fa-solid fa-circle-check text-emerald-600 text-lg"></i>
        <span class="text-sm font-semibold"><c:out value="${sessionScope.successMessage}"/></span>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.errorMessage}">
    <div data-autohide class="mb-4 bg-red-50 border border-red-300 text-red-800 px-4 py-3 rounded-xl flex items-center gap-3 shadow-sm">
        <i class="fa-solid fa-circle-exclamation text-red-600 text-lg"></i>
        <span class="text-sm font-semibold"><c:out value="${sessionScope.errorMessage}"/></span>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>
