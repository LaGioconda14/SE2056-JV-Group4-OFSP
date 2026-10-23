package controller.review;

import com.google.gson.Gson;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import model.User;

/** Shared HTTP behavior: session security, CSRF, JSON and safe error responses. */
final class ReviewHttp {
    private static final Gson JSON=new Gson();
    private static final SecureRandom RANDOM=new SecureRandom();
    private static final String CSRF="ofspReviewCsrf";
    private ReviewHttp() { }

    static User user(HttpServletRequest req) {
        HttpSession session=req.getSession(false);
        Object obj=session==null?null:session.getAttribute("user");
        if(!(obj instanceof User))throw new SecurityException("Please log in first");
        User u=(User)obj;
        if(u.getId()<=0)throw new SecurityException("Invalid account");
        if(!u.isActive())throw new SecurityException("Inactive or blocked account");
        return u;
    }

    static boolean role(User user,String wanted) {
        String actual=user.getRole();
        if(actual==null)return false;
        String a=actual.trim().toUpperCase(java.util.Locale.ROOT);
        String w=wanted.toUpperCase(java.util.Locale.ROOT);
        if("SHOP_OWNER".equals(w))return "SHOP_OWNER".equals(a)||"SELLER".equals(a);
        return w.equals(a);
    }
    static User authorized(HttpServletRequest req,String... roles) {
        User u=user(req);
        for(String role:roles)if(role(u,role))return u;
        throw new SecurityException("You do not have permission for this action");
    }
    static String csrf(HttpServletRequest req) {
        User ignored=user(req);
        HttpSession session=req.getSession(false);
        synchronized(session){
            String token=(String)session.getAttribute(CSRF);
            if(token==null){
                byte[] bytes=new byte[32];RANDOM.nextBytes(bytes);
                token=java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
                session.setAttribute(CSRF,token);
            }
            return token;
        }
    }
    static void requireCsrf(HttpServletRequest req) {
        HttpSession session=req.getSession(false);
        String saved=session==null?null:(String)session.getAttribute(CSRF);
        String provided=req.getHeader("X-CSRF-Token");
        if(provided==null)provided=req.getParameter("_csrf");
        if(saved==null||provided==null||!java.security.MessageDigest.isEqual(
                saved.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                provided.getBytes(java.nio.charset.StandardCharsets.UTF_8)))
            throw new SecurityException("Missing or invalid CSRF token");
    }
    static long positive(HttpServletRequest req,String key) {
        try {
            long value=Long.parseLong(req.getParameter(key));
            if(value<=0)throw new NumberFormatException();
            return value;
        }catch(NumberFormatException ex){throw new IllegalArgumentException("Invalid "+key);}
    }
    static int number(HttpServletRequest req,String key,int fallback) {
        String value=req.getParameter(key);
        if(value==null)return fallback;
        try{return Integer.parseInt(value);}catch(NumberFormatException ex){throw new IllegalArgumentException("Invalid "+key);}
    }
    static Map<String,Object> result(Object... entries) {
        Map<String,Object> m=new LinkedHashMap<>();
        for(int i=0;i+1<entries.length;i+=2)m.put(String.valueOf(entries[i]),entries[i+1]);
        return m;
    }
    static void send(HttpServletResponse response,int status,Object body) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control","no-store");
        JSON.toJson(body,response.getWriter());
    }
    static void error(HttpServletResponse resp,Exception ex)throws IOException {
        int status;
        if(ex instanceof SecurityException) status=403;
        else if(ex instanceof IllegalArgumentException)status=400;
        else if(ex instanceof java.sql.SQLException) {
            String state=((java.sql.SQLException)ex).getSQLState();
            status=state!=null && state.startsWith("23") ? 409 : 500;
        }
        else status=500;
        // Never expose SQL server internals to clients.
        String message=status==500?"An internal error occurred. Check server logs."
                      :status==409?"Review already exists or conflicts with a database rule"
                      :ex.getMessage();
        send(resp,status,Collections.singletonMap("error",message));
    }
}
