package controller.review;

import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

/** FE-10.1: add and view photos for product reviews only. */
@WebServlet(name="ReviewImageServlet",urlPatterns={"/reviews/images"})
@MultipartConfig(maxFileSize=3*1024*1024, maxRequestSize=4*1024*1024)
public class ReviewImageServlet extends HttpServlet {
    private static final Logger LOG=Logger.getLogger(ReviewImageServlet.class.getName());
    private final ReviewDAO dao=new ReviewDAO();
    private static final int MAX_BYTES=3*1024*1024;

    private Path imageDirectory() throws IOException {
        // Configurable outside the deployed WAR (survives redeploys). Example:
        // -Dofsp.review.uploadDir=C:/OFSP/review-images
        String value=System.getProperty("ofsp.review.uploadDir");
        if(value==null||value.trim().isEmpty())
            value=Paths.get(System.getProperty("user.home"),"ofsp-review-images").toString();
        Path dir=Paths.get(value).toAbsolutePath().normalize();
        Files.createDirectories(dir);
        return dir;
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)
            throws ServletException,IOException {
        Path saved=null;
        try {
            User user=ReviewHttp.authorized(req,"CUSTOMER");
            ReviewHttp.requireCsrf(req);
            long reviewId=ReviewHttp.positive(req,"reviewId");
            Part part=req.getPart("image");
            if(part==null||part.getSize()<1||part.getSize()>MAX_BYTES)
                throw new IllegalArgumentException("Attach a JPG/PNG image smaller than 3 MB");
            String mime;byte[] header=new byte[8];
            try(InputStream in=part.getInputStream()) {
                int read=0;
                while(read<8){int next=in.read(header,read,8-read);if(next<0)break;read+=next;}
                boolean png=read==8&&(header[0]&255)==137&&header[1]==80&&header[2]==78
                    &&header[3]==71&&header[4]==13&&header[5]==10&&header[6]==26&&header[7]==10;
                boolean jpeg=read>=3&&(header[0]&255)==255&&(header[1]&255)==216&&(header[2]&255)==255;
                if(!png&&!jpeg)throw new IllegalArgumentException("Only JPG or PNG images are accepted");
                mime=png?"image/png":"image/jpeg";
            }
            String extension="image/png".equals(mime)?".png":".jpg";
            String name=UUID.randomUUID().toString()+extension;
            saved=imageDirectory().resolve(name);
            try(InputStream in=part.getInputStream()){
                Files.copy(in,saved,StandardCopyOption.REPLACE_EXISTING);
            }
            long imageId=dao.addProductImage(reviewId,user.getId(),name,mime);
            ReviewHttp.send(resp,201,ReviewHttp.result("imageId",imageId,
                    "imageUrl",req.getContextPath()+"/reviews/images?imageId="+imageId));
        }catch(Exception ex){
            if(saved!=null){try{Files.deleteIfExists(saved);}catch(IOException ignored){}}
            LOG.log(Level.WARNING,"FE-10 image upload failed",ex);
            ReviewHttp.error(resp,ex);
        }
    }

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)
            throws ServletException,IOException {
        try {
            String imageParam=req.getParameter("imageId");
            if(imageParam==null){
                long reviewId=ReviewHttp.positive(req,"reviewId");
                // List only public/author-visible images to avoid leaking hidden review photos.
                List<Long> ids=dao.imageIds(reviewId);
                User user=null;
                try{user=ReviewHttp.user(req);}catch(SecurityException ignored){}
                long viewerId=user==null?0:user.getId();
                boolean admin=user!=null&&ReviewHttp.role(user,"ADMIN");
                java.util.List<Long> visible=new java.util.ArrayList<>();
                for(Long id:ids)if(dao.findImage(id,viewerId,admin)!=null)visible.add(id);
                ReviewHttp.send(resp,200,ReviewHttp.result("imageIds",visible));
                return;
            }
            long imageId=ReviewHttp.positive(req,"imageId");
            User user=null;
            try{user=ReviewHttp.user(req);}catch(SecurityException ignored){}
            ReviewDAO.ImageInfo info=dao.findImage(imageId,user==null?0:user.getId(),
                    user!=null&&ReviewHttp.role(user,"ADMIN"));
            if(info==null){resp.sendError(HttpServletResponse.SC_NOT_FOUND);return;}
            // Storage name is created only by this servlet; never use a client-supplied filename.
            if(!info.storageName.matches("[0-9a-fA-F-]{36}\\.(jpg|png)"))
                throw new IOException("Invalid image storage record");
            if(!("image/jpeg".equals(info.mimeType)||"image/png".equals(info.mimeType)))
                throw new IOException("Invalid image MIME type");
            Path file=imageDirectory().resolve(info.storageName).normalize();
            if(!Files.isRegularFile(file)){resp.sendError(HttpServletResponse.SC_NOT_FOUND);return;}
            resp.setContentType(info.mimeType);
            resp.setHeader("X-Content-Type-Options","nosniff");
            resp.setHeader("Cache-Control","private, max-age=60");
            try(java.io.OutputStream out=resp.getOutputStream()) {Files.copy(file,out);}
        }catch(Exception ex){LOG.log(Level.WARNING,"FE-10 image GET failed",ex);ReviewHttp.error(resp,ex);}
    }
}
