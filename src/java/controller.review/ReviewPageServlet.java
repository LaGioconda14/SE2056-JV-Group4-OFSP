package controller.review;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name="ReviewPageServlet",urlPatterns={"/review-center","/reviews/explore","/admin/reviews","/shop/reviews"})
public class ReviewPageServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)
            throws ServletException,IOException {
        String path=req.getServletPath();
        String target;
        try {
        switch(path){
            case "/review-center":
                ReviewHttp.authorized(req,"CUSTOMER");target="/WEB-INF/views/review/center.jsp";break;
            case "/admin/reviews":
                ReviewHttp.authorized(req,"ADMIN");target="/WEB-INF/views/review/admin.jsp";break;
            case "/shop/reviews":
                ReviewHttp.authorized(req,"SHOP_OWNER");target="/WEB-INF/views/review/shop.jsp";break;
            case "/reviews/explore":
                String type=req.getParameter("type");
                if(!"SHOP".equals(type)&&!"PRODUCT".equals(type)){
                    resp.sendError(400,"Choose PRODUCT or SHOP");return;
                }
                try{
                    long id=Long.parseLong(req.getParameter("targetId"));
                    if(id<=0)throw new NumberFormatException();
                    req.setAttribute("reviewType",type);req.setAttribute("targetId",id);
                }catch(NumberFormatException ex){resp.sendError(400,"Invalid targetId");return;}
                target="/WEB-INF/views/review/explore.jsp";break;
            default:resp.sendError(404);return;
        }
        req.getRequestDispatcher(target).forward(req,resp);
        } catch (SecurityException denied) {
            if(req.getSession(false)==null || req.getSession(false).getAttribute("user")==null)
                resp.sendRedirect(req.getContextPath()+"/login");
            else resp.sendError(HttpServletResponse.SC_FORBIDDEN,"You do not have permission to view this page");
        }
    }
}
