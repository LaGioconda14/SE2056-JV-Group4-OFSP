<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<section class="relative">
    <div class="w-full h-64 sm:h-72 md:h-80 bg-gray-900 relative overflow-hidden">
        <img src="${not empty shop.bannerUrl ? shop.bannerUrl : 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=1600&fit=crop'}" 
             alt="Farm Cover" 
             class="w-full h-full object-cover opacity-85">
        <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent"></div>
    </div>

    <div class="max-w-7xl mx-auto px-4 -mt-24 sm:-mt-20 relative z-20">
        <div class="bg-white rounded-3xl p-6 sm:p-8 shadow-xl border border-gray-100 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6">
            <div class="flex items-start sm:items-center gap-5 flex-1">
                <div class="relative flex-shrink-0">
                    <div class="w-20 h-20 sm:w-24 sm:h-24 rounded-2xl border-4 border-white bg-white shadow-md overflow-hidden flex items-center justify-center p-1">
                        <img src="${not empty shop.logoUrl ? shop.logoUrl : 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=150&h=150&fit=crop'}" 
                             alt="Shop Logo" 
                             class="w-full h-full object-cover rounded-xl">
                    </div>
                    <div class="absolute -bottom-1 -right-1 w-6 h-6 bg-emerald-600 text-white rounded-full flex items-center justify-center text-xs shadow-md border-2 border-white" title="Chứng nhận nông trại xác thực">
                        <i class="fa-solid fa-check text-[10px]"></i>
                    </div>
                </div>

                <div class="space-y-1.5">
                    <div class="flex flex-wrap items-center gap-2.5">
                        <h1 class="text-2xl sm:text-3xl font-black text-gray-950 tracking-tight">
                            ${not empty shop.shopName ? shop.shopName : 'Nông Trại Hữu Cơ Mộc Châu'}
                        </h1>
                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold">
                            <i class="fa-solid fa-shield-halved text-emerald-600 text-xs"></i> 
                            ${not empty shop.certificationName ? shop.certificationName : 'VietGAP Certified'}
                        </span>
                    </div>

                    <p class="text-xs sm:text-sm text-gray-600 max-w-2xl leading-relaxed">
                        ${not empty shop.description ? shop.description : 'Direct from highland volcanic soils. Grown at 1,050m altitude with pristine spring water and zero synthetic pesticides.'}
                    </p>

                    <div class="flex flex-wrap items-center gap-4 sm:gap-6 pt-1 text-xs text-gray-500 font-medium">
                        <div class="flex items-center gap-1 text-gray-900 font-bold">
                            <i class="fa-solid fa-star text-amber-400"></i>
                            <span>${shop.rating != null ? shop.rating : '4.9'}</span>
                            <span class="text-gray-400 font-normal">(${reviews != null ? reviews.size() : 1420} đánh giá)</span>
                        </div>
                        <span class="text-gray-300 hidden sm:inline">&bull;</span>
                        <div class="flex items-center gap-1.5">
                            <i class="fa-solid fa-users text-gray-400"></i>
                            <span class="font-bold text-gray-900">8.4k</span> người theo dõi
                        </div>
                        <span class="text-gray-300 hidden sm:inline">&bull;</span>
                        <div class="flex items-center gap-1.5 text-emerald-700 font-semibold">
                            <i class="fa-solid fa-bolt text-emerald-600"></i>
                            <span>100% tỷ lệ phản hồi (&lt; 1 giờ)</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex items-center gap-3 w-full sm:w-auto flex-wrap">
                <button type="button" id="btnFollowShop" onclick="toggleFollowShop()"
                        class="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-white hover:bg-gray-50 text-gray-800 border-2 border-gray-200 hover:border-gray-300 px-5 py-2.5 rounded-full text-xs font-extrabold transition shadow-xs">
                    <i id="followIcon" class="fa-regular fa-bookmark text-sm"></i>
                    <span id="followText">Theo Dõi Shop</span>
                </button>

                <a href="${pageContext.request.contextPath}/chat?shopId=${shop.shopId}"
                   class="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-emerald-700 hover:bg-emerald-800 text-white px-6 py-2.5 rounded-full text-xs font-extrabold transition shadow-sm">
                    <i class="fa-regular fa-comments text-sm"></i>
                    <span>Nhắn Tin Trực Tiếp</span>
                </a>
            </div>
        </div>
    </div>
</section>

<section id="shop-products" class="max-w-7xl mx-auto px-4 py-8">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-gray-200 pb-4">
        <div class="flex items-center gap-2 overflow-x-auto pb-1 text-xs hide-scrollbar">
            <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}&cat=all" 
               class="px-4 py-2 rounded-full font-bold whitespace-nowrap transition-all ${selectedCategory eq 'all' or empty selectedCategory ? 'bg-emerald-700 text-white shadow-xs' : 'bg-white text-gray-600 hover:bg-gray-100 border border-gray-200'}">
                Tất Cả Sản Phẩm (${products != null ? products.size() : 0})
            </a>
            <c:forEach var="cat" items="${shopCategories}">
                <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}&cat=${cat.id}" 
                   class="px-4 py-2 rounded-full font-bold whitespace-nowrap transition-all ${selectedCategory eq cat.id ? 'bg-emerald-700 text-white shadow-xs' : 'bg-white text-gray-600 hover:bg-gray-100 border border-gray-200'}">
                    ${cat.name}
                </a>
            </c:forEach>
        </div>

        <div class="flex items-center gap-2 self-end sm:self-auto flex-shrink-0">
            <span class="text-xs text-gray-400 font-semibold">Sắp xếp:</span>
            <select name="sort" onchange="location.href = '${pageContext.request.contextPath}/store?id=${shop.shopId}&cat=${selectedCategory}&sort=' + this.value;"
                    class="bg-white border border-gray-200 text-xs font-bold text-gray-700 rounded-full px-3 py-1.5 focus:outline-none focus:border-emerald-600 cursor-pointer shadow-2xs">
                <option value="featured" ${selectedSort eq 'featured' ? 'selected' : ''}>Nổi Bật Nhất</option>
                <option value="price_asc" ${selectedSort eq 'price_asc' ? 'selected' : ''}>Giá: Thấp Đến Cao</option>
                <option value="price_desc" ${selectedSort eq 'price_desc' ? 'selected' : ''}>Giá: Cao Đến Thấp</option>
                <option value="newest" ${selectedSort eq 'newest' ? 'selected' : ''}>Mới Thu Hoạch</option>
            </select>
        </div>
    </div>
</section>

