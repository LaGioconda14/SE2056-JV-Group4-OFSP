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

/** FE-10.2 moderation. Does not implement the separate FE-12 module. */
@WebServlet(name="ReviewModerationServlet",urlPatterns={"/admin/review-reports"})
public class ReviewModerationServlet extends HttpServlet {
    private static final Logger LOG=Logger.getLogger(ReviewModerationServlet.class.getName());
    private final IReviewService reviews=new ReviewServiceImpl();
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)
            throws ServletException,IOException {
        try {
            ReviewHttp.authorized(req,"ADMIN");
            int page=ReviewHttp.number(req,"page",1);
            ReviewHttp.send(resp,200,ReviewHttp.result("reports",reviews.pendingReports(page),"page",page));
        }catch(Exception ex){LOG.log(Level.WARNING,"FE-10 moderation list failed",ex);ReviewHttp.error(resp,ex);}
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)
            throws ServletException,IOException {
        try {
            User admin=ReviewHttp.authorized(req,"ADMIN");
            ReviewHttp.requireCsrf(req);
            reviews.moderate(ReviewHttp.positive(req,"reportId"),admin.getId(),req.getParameter("action"));
            ReviewHttp.send(resp,200,ReviewHttp.result("moderated",true));
        }catch(Exception ex){LOG.log(Level.WARNING,"FE-10 moderation update failed",ex);ReviewHttp.error(resp,ex);}
    }
}
