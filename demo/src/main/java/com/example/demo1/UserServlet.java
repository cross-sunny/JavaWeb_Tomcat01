package com.example.demo1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

// 映射URL：/user（替代之前的重复映射，统一处理登录/注册）
@WebServlet("/user")
public class UserServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 区分请求类型（登录/注册）
        String action = request.getParameter("action");
        if ("login".equals(action)) {
            handleLogin(request, response);
        } else if ("register".equals(action)) {
            handleRegister(request, response);
        }
    }

    // 处理登录逻辑（对接数据库）
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT * FROM user WHERE username=? AND password=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 登录成功：存储用户信息到session，跳转success.jsp
                request.getSession().setAttribute("loginUser", username);
                response.sendRedirect(request.getContextPath() + "/web/success.jsp");
            } else {
                // 登录失败：跳转回登录页并提示错误
                response.sendRedirect(request.getContextPath() + "/web/login.jsp?error=1");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/web/login.jsp?error=2");
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    // 处理注册逻辑（对接数据库）
    private void handleRegister(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        String realname = request.getParameter("realname");
        String password = request.getParameter("password");
        String repassword = request.getParameter("repassword");

        // 前端基础验证（密码一致）
        if (!password.equals(repassword)) {
            response.sendRedirect(request.getContextPath() + "/web/register.jsp?error=1");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            // 先检查用户名是否已存在
            String checkSql = "SELECT * FROM user WHERE username=?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 用户名已存在
                response.sendRedirect(request.getContextPath() + "/web/register.jsp?error=2");
                return;
            }

            // 插入新用户
            String insertSql = "INSERT INTO user (username, realname, password) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, username);
            pstmt.setString(2, realname);
            pstmt.setString(3, password);
            pstmt.executeUpdate();

            // 注册成功，跳转登录页
            response.sendRedirect(request.getContextPath() + "/web/login.jsp?registerSuccess=1");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/web/register.jsp?error=3");
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }
}