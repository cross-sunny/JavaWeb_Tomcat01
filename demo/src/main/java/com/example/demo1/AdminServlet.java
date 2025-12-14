package com.example.demo1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@WebServlet("/web/admin/kickout")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String currentUser = (String) session.getAttribute("loginUser");

        // 仅允许用户名为 "zjy" 的管理员执行踢人操作
        if (!"zjy".equals(currentUser)) {
            resp.sendRedirect(req.getContextPath() + "/web/login.jsp?error=4");
            return;
        }

        String userId = req.getParameter("userId");
        if (userId == null || userId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/web/admin_online.jsp?error=1");
            return;
        }

        // 初始化在线用户映射（线程安全的ConcurrentHashMap）
        Map<String, Boolean> onlineUsers = (Map<String, Boolean>) req.getServletContext().getAttribute("onlineUsers");
        if (onlineUsers == null) {
            onlineUsers = new ConcurrentHashMap<>();
            req.getServletContext().setAttribute("onlineUsers", onlineUsers);
        }

        // 标记用户为“已踢出”
        onlineUsers.put(userId, true);
        System.out.println("【管理员 zjy】已将用户 [" + userId + "] 踢出系统");

        // 重定向回管理页面
        resp.sendRedirect(req.getContextPath() + "/web/admin_online.jsp?success=kicked");
    }
}