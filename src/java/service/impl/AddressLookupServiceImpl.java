package service.impl;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import service.IAddressLookupService;

public class AddressLookupServiceImpl implements IAddressLookupService {

    private static final Logger LOGGER = Logger.getLogger(AddressLookupServiceImpl.class.getName());
    private static final Map<String, String> CACHE = new ConcurrentHashMap<>();

    private static final String API_BASE_URL = "https://provinces.open-api.vn/api/v1";

    private final HttpClient httpClient = HttpClient.newBuilder()
            .followRedirects(HttpClient.Redirect.NORMAL)
            .connectTimeout(Duration.ofSeconds(4))
            .build();

    private static final String FALLBACK_PROVINCES = "["
            + "{\"name\":\"Thành phố Hà Nội\",\"code\":1},"
            + "{\"name\":\"Thành phố Hồ Chí Minh\",\"code\":79},"
            + "{\"name\":\"Thành phố Đà Nẵng\",\"code\":48},"
            + "{\"name\":\"Thành phố Hải Phòng\",\"code\":31},"
            + "{\"name\":\"Thành phố Cần Thơ\",\"code\":92},"
            + "{\"name\":\"Tỉnh An Giang\",\"code\":89},"
            + "{\"name\":\"Tỉnh Bà Rịa - Vũng Tàu\",\"code\":77},"
            + "{\"name\":\"Tỉnh Bắc Giang\",\"code\":24},"
            + "{\"name\":\"Tỉnh Bắc Kạn\",\"code\":6},"
            + "{\"name\":\"Tỉnh Bạc Liêu\",\"code\":95},"
            + "{\"name\":\"Tỉnh Bắc Ninh\",\"code\":27},"
            + "{\"name\":\"Tỉnh Bến Tre\",\"code\":83},"
            + "{\"name\":\"Tỉnh Bình Định\",\"code\":52},"
            + "{\"name\":\"Tỉnh Bình Dương\",\"code\":74},"
            + "{\"name\":\"Tỉnh Bình Phước\",\"code\":70},"
            + "{\"name\":\"Tỉnh Bình Thuận\",\"code\":60},"
            + "{\"name\":\"Tỉnh Cà Mau\",\"code\":96},"
            + "{\"name\":\"Tỉnh Cao Bằng\",\"code\":4},"
            + "{\"name\":\"Tỉnh Đắk Lắk\",\"code\":66},"
            + "{\"name\":\"Tỉnh Đắk Nông\",\"code\":67},"
            + "{\"name\":\"Tỉnh Điện Biên\",\"code\":11},"
            + "{\"name\":\"Tỉnh Đồng Nai\",\"code\":75},"
            + "{\"name\":\"Tỉnh Đồng Tháp\",\"code\":87},"
            + "{\"name\":\"Tỉnh Gia Lai\",\"code\":64},"
            + "{\"name\":\"Tỉnh Hà Giang\",\"code\":2},"
            + "{\"name\":\"Tỉnh Hà Nam\",\"code\":35},"
            + "{\"name\":\"Tỉnh Hà Tĩnh\",\"code\":42},"
            + "{\"name\":\"Tỉnh Hải Dương\",\"code\":30},"
            + "{\"name\":\"Tỉnh Hậu Giang\",\"code\":93},"
            + "{\"name\":\"Tỉnh Hòa Bình\",\"code\":17},"
            + "{\"name\":\"Tỉnh Hưng Yên\",\"code\":33},"
            + "{\"name\":\"Tỉnh Khánh Hòa\",\"code\":56},"
            + "{\"name\":\"Tỉnh Kiên Giang\",\"code\":91},"
            + "{\"name\":\"Tỉnh Kon Tum\",\"code\":62},"
            + "{\"name\":\"Tỉnh Lai Châu\",\"code\":12},"
            + "{\"name\":\"Tỉnh Lâm Đồng\",\"code\":68},"
            + "{\"name\":\"Tỉnh Lạng Sơn\",\"code\":20},"
            + "{\"name\":\"Tỉnh Lào Cai\",\"code\":10},"
            + "{\"name\":\"Tỉnh Long An\",\"code\":80},"
            + "{\"name\":\"Tỉnh Nam Định\",\"code\":36},"
            + "{\"name\":\"Tỉnh Nghệ An\",\"code\":40},"
            + "{\"name\":\"Tỉnh Ninh Bình\",\"code\":37},"
            + "{\"name\":\"Tỉnh Ninh Thuận\",\"code\":58},"
            + "{\"name\":\"Tỉnh Phú Thọ\",\"code\":25},"
            + "{\"name\":\"Tỉnh Phú Yên\",\"code\":54},"
            + "{\"name\":\"Tỉnh Quảng Bình\",\"code\":44},"
            + "{\"name\":\"Tỉnh Quảng Nam\",\"code\":49},"
            + "{\"name\":\"Tỉnh Quảng Ngãi\",\"code\":51},"
            + "{\"name\":\"Tỉnh Quảng Ninh\",\"code\":22},"
            + "{\"name\":\"Tỉnh Quảng Trị\",\"code\":45},"
            + "{\"name\":\"Tỉnh Sóc Trăng\",\"code\":94},"
            + "{\"name\":\"Tỉnh Sơn La\",\"code\":14},"
            + "{\"name\":\"Tỉnh Tây Ninh\",\"code\":72},"
            + "{\"name\":\"Tỉnh Thái Bình\",\"code\":34},"
            + "{\"name\":\"Tỉnh Thái Nguyên\",\"code\":19},"
            + "{\"name\":\"Tỉnh Thanh Hóa\",\"code\":38},"
            + "{\"name\":\"Thành phố Huế\",\"code\":46},"
            + "{\"name\":\"Tỉnh Tiền Giang\",\"code\":82},"
            + "{\"name\":\"Tỉnh Trà Vinh\",\"code\":84},"
            + "{\"name\":\"Tỉnh Tuyên Quang\",\"code\":8},"
            + "{\"name\":\"Tỉnh Vĩnh Long\",\"code\":86},"
            + "{\"name\":\"Tỉnh Vĩnh Phúc\",\"code\":26},"
            + "{\"name\":\"Tỉnh Yên Bái\",\"code\":15}"
            + "]";

    @Override
    public String getProvincesJson() {
        String cacheKey = "provinces";
        String cached = CACHE.get(cacheKey);
        if (cached != null) {
            return cached;
        }

        String url = API_BASE_URL + "/p/";
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(4))
                    .header("Accept", "application/json")
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200 && response.body() != null && response.body().startsWith("[")) {
                String body = response.body();
                CACHE.put(cacheKey, body);
                return body;
            }
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Failed to fetch provinces from external API, using fallback: {0}", ex.getMessage());
        }

        return FALLBACK_PROVINCES;
    }

    @Override
    public String getDistrictsJson(String provinceCode) {
        if (provinceCode == null || !provinceCode.matches("^\\d+$")) {
            return "{\"districts\":[]}";
        }

        String cacheKey = "districts_" + provinceCode;
        String cached = CACHE.get(cacheKey);
        if (cached != null) {
            return cached;
        }

        String url = API_BASE_URL + "/p/" + provinceCode + "?depth=2";
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(4))
                    .header("Accept", "application/json")
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200 && response.body() != null && response.body().startsWith("{")) {
                String body = response.body();
                CACHE.put(cacheKey, body);
                return body;
            }
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Failed to fetch districts for province {0}: {1}", new Object[]{provinceCode, ex.getMessage()});
        }

        return "{\"districts\":[]}";
    }

    @Override
    public String getWardsJson(String districtCode) {
        if (districtCode == null || !districtCode.matches("^\\d+$")) {
            return "{\"wards\":[]}";
        }

        String cacheKey = "wards_" + districtCode;
        String cached = CACHE.get(cacheKey);
        if (cached != null) {
            return cached;
        }

        String url = API_BASE_URL + "/d/" + districtCode + "?depth=2";
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(4))
                    .header("Accept", "application/json")
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200 && response.body() != null && response.body().startsWith("{")) {
                String body = response.body();
                CACHE.put(cacheKey, body);
                return body;
            }
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Failed to fetch wards for district {0}: {1}", new Object[]{districtCode, ex.getMessage()});
        }

        return "{\"wards\":[]}";
    }
}
