package util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import jakarta.servlet.http.Part; // Hoặc javax.servlet.http.Part nếu bạn dùng Tomcat/Servlet cũ

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

public class CloudinaryUtil {

    private static final Cloudinary cloudinary;

    static {
        // Điền 3 thông số lấy từ Dashboard Cloudinary của bạn vào đây
        cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", "hiest36g",
                "api_key", "472353765853945",
                "api_secret", "UyWHHpQNQyS-tEs333TwfGeig8s",
                "secure", true
        ));
    }

    /**
     * Tải file ảnh từ Servlet Part lên Cloudinary
     * @param part File nhận từ request.getPart(...)
     * @param folderName Tên thư mục trên Cloudinary (ví dụ: "shop_requests/cccd")
     * @return Chuỗi đường dẫn URL HTTPS an toàn do Cloudinary trả về
     */
    public static String uploadImage(Part part, String folderName) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }

        try (InputStream inputStream = part.getInputStream()) {
            byte[] fileBytes = inputStream.readAllBytes();

            Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.asMap(
                    "folder", folderName
            ));

            return (String) uploadResult.get("secure_url");
        }
    }
}