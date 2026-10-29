package controller.review;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;
import service.IReviewService;
import service.impl.ReviewServiceImpl;

/** FE-10 JSON endpoints. Frontend/order-history.jsp can be implemented later. */
@WebServlet(name="ReviewServlet",urlPatterns={"/reviews","/reviews/mine","/reviews/eligible","/reviews/csrf","/reviews/purchases","/reviews/shop-owned"})
public class ReviewServlet extends HttpServlet {
    private static final Logger LOG=Logger.getLogger(ReviewServlet.class.getName());
    private final IReviewService reviews=new ReviewServiceImpl();

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)
            throws ServletException,IOException {
        try {
            String path=req.getServletPath();
            if("/reviews/csrf".equals(path)) {
                ReviewHttp.send(resp,200,ReviewHttp.result("csrfToken",ReviewHttp.csrf(req)));
                return;
            }
            if("/reviews/purchases".equals(path)) {
                User u=ReviewHttp.authorized(req,"CUSTOMER");
                String type=req.getParameter("type");
                if(!"PRODUCT".equals(type)&&!"SHOP".equals(type))throw new IllegalArgumentException("Invalid type");
                ReviewHttp.send(resp,200,ReviewHttp.result("purchases",new dao.ReviewDAO().listPurchases(type,u.getId())));
                return;
            }
            if("/reviews/shop-owned".equals(path)) {
                User u=ReviewHttp.authorized(req,"SHOP_OWNER");
                String type=req.getParameter("type");
                if(!"PRODUCT".equals(type)&&!"SHOP".equals(type))throw new IllegalArgumentException("Invalid type");
                int page=ReviewHttp.number(req,"page",1);
                if(page<1||page>100000)throw new IllegalArgumentException("Invalid page");
                ReviewHttp.send(resp,200,ReviewHttp.result("reviews",new dao.ReviewDAO().listOwned(type,u.getId(),15,(page-1)*15),"page",page));
                return;
            }
            if("/reviews/mine".equals(path)) {
                User u=ReviewHttp.authorized(req,"CUSTOMER");
                String type=req.getParameter("type");int page=ReviewHttp.number(req,"page",1);
                ReviewHttp.send(resp,200,ReviewHttp.result("reviews",reviews.listMine(type,u.getId(),page),"page",page));
                return;
            }
            if("/reviews/eligible".equals(path)) {
                User u=ReviewHttp.authorized(req,"CUSTOMER");
                String type=req.getParameter("type");
                long ref=ReviewHttp.positive(req,"purchaseRef"); // orderItemId for PRODUCT, subOrderId for SHOP
                ReviewHttp.send(resp,200,ReviewHttp.result("eligible",reviews.canReview(type,u.getId(),ref)));
                return;
            }
            String type=req.getParameter("type");
            long target=ReviewHttp.positive(req,"targetId"); // productId or shopId
            int page=ReviewHttp.number(req,"page",1);
            ReviewHttp.send(resp,200,ReviewHttp.result("reviews",reviews.listPublic(type,target,page),
                    "rating",reviews.summary(type,target),"page",page));
        }catch(Exception ex){LOG.log(Level.WARNING,"FE-10 GET failed",ex);ReviewHttp.error(resp,ex);}
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)
            throws ServletException,IOException {
        try {
            req.setCharacterEncoding("UTF-8");
            User u=ReviewHttp.authorized(req,"CUSTOMER","SHOP_OWNER");
            ReviewHttp.requireCsrf(req);
            String action=req.getParameter("action");
            String type=req.getParameter("type");
            if("create".equalsIgnoreCase(action)) {
                if(!ReviewHttp.role(u,"CUSTOMER"))throw new SecurityException("Only customers may write reviews");
                long ref=ReviewHttp.positive(req,"purchaseRef");
                int rating=ReviewHttp.number(req,"rating",0);
                long id=reviews.create(type,u.getId(),ref,rating,req.getParameter("comment"));
                ReviewHttp.send(resp,201,ReviewHttp.result("reviewId",id,"type",type));
            } else if("edit".equalsIgnoreCase(action)) {
                if(!ReviewHttp.role(u,"CUSTOMER"))throw new SecurityException("Only customers may edit reviews");
                long id=ReviewHttp.positive(req,"reviewId");
                int rating=ReviewHttp.number(req,"rating",0);
                reviews.update(type,u.getId(),id,rating,req.getParameter("comment"));
                ReviewHttp.send(resp,200,ReviewHttp.result("updated",true));
            } else if("delete".equalsIgnoreCase(action)) {
                if(!ReviewHttp.role(u,"CUSTOMER"))throw new SecurityException("Only customers may delete reviews");
                reviews.delete(type,u.getId(),ReviewHttp.positive(req,"reviewId"));
                ReviewHttp.send(resp,200,ReviewHttp.result("deleted",true));
            } else if("reply".equalsIgnoreCase(action)) {
                if(!ReviewHttp.role(u,"SHOP_OWNER"))throw new SecurityException("Only shop owners may reply");
                String comment=req.getParameter("comment");
                if(comment==null||comment.trim().length()<2||comment.trim().length()>1500)
                    throw new IllegalArgumentException("Reply must be between 2 and 1500 characters");
                boolean ok=new dao.ReviewDAO().replyAsOwner(type,u.getId(),ReviewHttp.positive(req,"reviewId"),comment.trim());
                if(!ok)throw new SecurityException("This review does not belong to your shop");
                ReviewHttp.send(resp,200,ReviewHttp.result("replied",true));
            } else if("report".equalsIgnoreCase(action)) {
                long id=reviews.report(type,ReviewHttp.positive(req,"reviewId"),u.getId(),req.getParameter("reason"));
                ReviewHttp.send(resp,201,ReviewHttp.result("reportId",id));
            } else throw new IllegalArgumentException("Action must be create, edit, delete or report");
        }catch(Exception ex){LOG.log(Level.WARNING,"FE-10 POST failed",ex);ReviewHttp.error(resp,ex);}
    }
}
