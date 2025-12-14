package com.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

/**
 * 全局登录过滤器：适配当前web目录结构，放行所有公开资源
 */
public class LoginFilter extends HttpFilter {
    private String authKey; // Session中用户登录标识的Key
    private static final String ONLINE_USERS = "onlineUsers"; // 全局在线用户状态

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        super.init(filterConfig);
        this.authKey = filterConfig.getInitParameter("auth");
        System.out.println("【登录过滤器】初始化成功！用户标识Key：" + this.authKey);
    }

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        String contextPath = request.getContextPath();
        // 计算相对路径（去掉项目部署路径）
        String relativeURI = request.getRequestURI().substring(contextPath.length());

        // 1. 放行所有公开资源（web目录下的公开JSP + 静态资源）
        // 公开JSP：登录/注册/验证码/检查页
        boolean isPublicJsp = relativeURI.equals("/web/login.jsp")
                || relativeURI.equals("/web/check.jsp")
                || relativeURI.equals("/web/captcha.jsp")
                || relativeURI.equals("/web/register.jsp")
                || relativeURI.equals("/web/logout.jsp")
                || relativeURI.equals("/web/logout_only.jsp");

        // 静态资源：web目录下的.css/.png文件
        boolean isStaticResource = relativeURI.startsWith("/web/")
                && (relativeURI.endsWith(".css") || relativeURI.endsWith(".png"));

        if (isPublicJsp || isStaticResource) {
            chain.doFilter(request, response);
            return;
        }

        // 2. 校验用户标识Key配置
        if (authKey == null || authKey.trim().isEmpty()) {
            chain.doFilter(request, response);
            return;
        }

        // 3. 获取当前会话（不主动创建Session）
        HttpSession session = request.getSession(false);
        Object loginUser = (session != null) ? session.getAttribute(authKey) : null;


        // 核心：检查用户是否被踢出
        if (loginUser != null) {
            String userId = loginUser.toString();
            @SuppressWarnings("unchecked")
            Map<String, Boolean> onlineUsers = (Map<String, Boolean>) getServletContext().getAttribute(ONLINE_USERS);

            if (onlineUsers != null && Boolean.TRUE.equals(onlineUsers.get(userId))) {
                if (session != null) session.invalidate();
                response.setContentType("text/html;charset=utf-8");
                PrintWriter out = response.getWriter();
                out.write("<script>alert('您已被管理员强制踢出！请重新登录');window.location.href='" + contextPath + "/web/login.jsp';</script>");
                out.flush();
                out.close();
                System.out.println("【拦截】用户" + userId + "访问" + relativeURI + "被踢除");
                return;
            }
        }


        // 4. 拦截未登录用户
        if (loginUser == null) {
            response.sendRedirect(contextPath + "/web/login.jsp?error=5");
            System.out.println("【拦截】未登录用户访问" + relativeURI + "→跳登录页");
            return;
        }

        // 5. 管理员页面权限控制（仅zjy可访问admin_online.jsp）
        if (relativeURI.equals("/web/admin_online.jsp") && !"zjy".equals(loginUser.toString())) {
            response.sendRedirect(contextPath + "/web/login.jsp?error=4");
            System.out.println("【拦截】非管理员" + loginUser + "尝试访问管理页");
            return;
        }

        // 6. 放行合法请求
        System.out.println("【放行】用户" + loginUser + "访问" + relativeURI);
        chain.doFilter(request, response);
    }
}