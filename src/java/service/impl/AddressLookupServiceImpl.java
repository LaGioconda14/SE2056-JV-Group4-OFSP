package service.impl;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.dto.common.Province;
import service.IAddressLookupService;

public class AddressLookupServiceImpl implements IAddressLookupService {

    private static final Logger LOGGER = Logger.getLogger(AddressLookupServiceImpl.class.getName());
    private static final Map<String, String> CACHE = new ConcurrentHashMap<>();

    private static final String API_BASE_URL = "https://provinces.open-api.vn/api/v2";

    private final HttpClient httpClient = HttpClient.newBuilder()
            .followRedirects(HttpClient.Redirect.NORMAL)
            .connectTimeout(Duration.ofSeconds(4))
            .build();

    private static final List<Province> PROVINCE_LIST = new ArrayList<>();
    static {
        PROVINCE_LIST.add(new Province(1, "Thành phố Hà Nội"));
        PROVINCE_LIST.add(new Province(4, "Tỉnh Cao Bằng"));
        PROVINCE_LIST.add(new Province(8, "Tỉnh Tuyên Quang"));
        PROVINCE_LIST.add(new Province(11, "Tỉnh Điện Biên"));
        PROVINCE_LIST.add(new Province(12, "Tỉnh Lai Châu"));
        PROVINCE_LIST.add(new Province(14, "Tỉnh Sơn La"));
        PROVINCE_LIST.add(new Province(15, "Tỉnh Lào Cai"));
        PROVINCE_LIST.add(new Province(19, "Tỉnh Thái Nguyên"));
        PROVINCE_LIST.add(new Province(20, "Tỉnh Lạng Sơn"));
        PROVINCE_LIST.add(new Province(22, "Thành phố Quảng Ninh"));
        PROVINCE_LIST.add(new Province(24, "Thành phố Bắc Ninh"));
        PROVINCE_LIST.add(new Province(25, "Tỉnh Phú Thọ"));
        PROVINCE_LIST.add(new Province(31, "Thành phố Hải Phòng"));
        PROVINCE_LIST.add(new Province(33, "Tỉnh Hưng Yên"));
        PROVINCE_LIST.add(new Province(37, "Tỉnh Ninh Bình"));
        PROVINCE_LIST.add(new Province(38, "Tỉnh Thanh Hóa"));
        PROVINCE_LIST.add(new Province(40, "Tỉnh Nghệ An"));
        PROVINCE_LIST.add(new Province(42, "Tỉnh Hà Tĩnh"));
        PROVINCE_LIST.add(new Province(44, "Tỉnh Quảng Trị"));
        PROVINCE_LIST.add(new Province(46, "Thành phố Huế"));
        PROVINCE_LIST.add(new Province(48, "Thành phố Đà Nẵng"));
        PROVINCE_LIST.add(new Province(51, "Tỉnh Quảng Ngãi"));
        PROVINCE_LIST.add(new Province(52, "Tỉnh Gia Lai"));
        PROVINCE_LIST.add(new Province(56, "Tỉnh Khánh Hòa"));
        PROVINCE_LIST.add(new Province(66, "Tỉnh Đắk Lắk"));
        PROVINCE_LIST.add(new Province(68, "Tỉnh Lâm Đồng"));
        PROVINCE_LIST.add(new Province(75, "Thành phố Đồng Nai"));
        PROVINCE_LIST.add(new Province(79, "Thành phố Hồ Chí Minh"));
        PROVINCE_LIST.add(new Province(80, "Tỉnh Tây Ninh"));
        PROVINCE_LIST.add(new Province(82, "Tỉnh Đồng Tháp"));
        PROVINCE_LIST.add(new Province(86, "Tỉnh Vĩnh Long"));
        PROVINCE_LIST.add(new Province(91, "Tỉnh An Giang"));
        PROVINCE_LIST.add(new Province(92, "Thành phố Cần Thơ"));
        PROVINCE_LIST.add(new Province(96, "Tỉnh Cà Mau"));
    }

    private static final String FALLBACK_PROVINCES = "["
            + "{\"name\":\"Thành phố Hà Nội\",\"code\":1},"
            + "{\"name\":\"Tỉnh Cao Bằng\",\"code\":4},"
            + "{\"name\":\"Tỉnh Tuyên Quang\",\"code\":8},"
            + "{\"name\":\"Tỉnh Điện Biên\",\"code\":11},"
            + "{\"name\":\"Tỉnh Lai Châu\",\"code\":12},"
            + "{\"name\":\"Tỉnh Sơn La\",\"code\":14},"
            + "{\"name\":\"Tỉnh Lào Cai\",\"code\":15},"
            + "{\"name\":\"Tỉnh Thái Nguyên\",\"code\":19},"
            + "{\"name\":\"Tỉnh Lạng Sơn\",\"code\":20},"
            + "{\"name\":\"Thành phố Quảng Ninh\",\"code\":22},"
            + "{\"name\":\"Thành phố Bắc Ninh\",\"code\":24},"
            + "{\"name\":\"Tỉnh Phú Thọ\",\"code\":25},"
            + "{\"name\":\"Thành phố Hải Phòng\",\"code\":31},"
            + "{\"name\":\"Tỉnh Hưng Yên\",\"code\":33},"
            + "{\"name\":\"Tỉnh Ninh Bình\",\"code\":37},"
            + "{\"name\":\"Tỉnh Thanh Hóa\",\"code\":38},"
            + "{\"name\":\"Tỉnh Nghệ An\",\"code\":40},"
            + "{\"name\":\"Tỉnh Hà Tĩnh\",\"code\":42},"
            + "{\"name\":\"Tỉnh Quảng Trị\",\"code\":44},"
            + "{\"name\":\"Thành phố Huế\",\"code\":46},"
            + "{\"name\":\"Thành phố Đà Nẵng\",\"code\":48},"
            + "{\"name\":\"Tỉnh Quảng Ngãi\",\"code\":51},"
            + "{\"name\":\"Tỉnh Gia Lai\",\"code\":52},"
            + "{\"name\":\"Tỉnh Khánh Hòa\",\"code\":56},"
            + "{\"name\":\"Tỉnh Đắk Lắk\",\"code\":66},"
            + "{\"name\":\"Tỉnh Lâm Đồng\",\"code\":68},"
            + "{\"name\":\"Thành phố Đồng Nai\",\"code\":75},"
            + "{\"name\":\"Thành phố Hồ Chí Minh\",\"code\":79},"
            + "{\"name\":\"Tỉnh Tây Ninh\",\"code\":80},"
            + "{\"name\":\"Tỉnh Đồng Tháp\",\"code\":82},"
            + "{\"name\":\"Tỉnh Vĩnh Long\",\"code\":86},"
            + "{\"name\":\"Tỉnh An Giang\",\"code\":91},"
            + "{\"name\":\"Thành phố Cần Thơ\",\"code\":92},"
            + "{\"name\":\"Tỉnh Cà Mau\",\"code\":96}"
            + "]";

    @Override
    public List<Province> getAllProvinces() {
        return Collections.unmodifiableList(PROVINCE_LIST);
    }

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
    public String getWardsJson(String provinceCode) {
        if (provinceCode == null || !provinceCode.matches("^\\d+$")) {
            return "{\"wards\":[]}";
        }

        String cacheKey = "wards_" + provinceCode;
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
            LOGGER.log(Level.WARNING, "Failed to fetch wards for province {0}: {1}", new Object[]{provinceCode, ex.getMessage()});
        }

        return "{\"wards\":[]}";
    }
}
