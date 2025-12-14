package com.example.demo2;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/demo2/filter")
public class FilterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 设置 request 和 session 属性
        req.setAttribute("request-msg", "www.yootk.com");
        req.getSession().setAttribute("session-msg", "edu.yootk.com");

        // 使用 RequestDispatcher.forward() 转发到 JSP
        // 注意：此转发会触发 FILTER（因配置了 FORWARD）
        req.getRequestDispatcher("/demo2/show.jsp").forward(req, resp);
    }
}