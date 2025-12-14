package com.example.listener;

import com.example.demo1.DBUtil;
import jakarta.servlet.ServletRequestEvent;
import jakarta.servlet.ServletRequestListener;
import jakarta.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class VideoViewListener implements ServletRequestListener {
    private static final String VIDEO_PATH_PATTERN = ".*/uploads/.*\\.mp4";
    private static final String LOGIN_SESSION_KEY = "loginUser";
    // 防重复：Session中存储“视频路径→最后统计时间”，5秒内重复请求不统计
    private static final String SESSION_KEY_VIEW_RECORD = "videoViewRecord";
    private static final long DUPLICATE_INTERVAL = 5000; // 5秒

    @Override
    public void requestInitialized(ServletRequestEvent sre) {
        HttpServletRequest request = (HttpServletRequest) sre.getServletRequest();
        String requestURI = request.getRequestURI();
        boolean isLogin = request.getSession().getAttribute(LOGIN_SESSION_KEY) != null;
        boolean isVideoRequest = requestURI.matches(VIDEO_PATH_PATTERN);

        if (isLogin && isVideoRequest) {
            // 1. 从Session获取防重复记录
            Map<String, Long> viewRecord = (Map<String, Long>) request.getSession().getAttribute(SESSION_KEY_VIEW_RECORD);
            if (viewRecord == null) {
                viewRecord = new HashMap<>();
                request.getSession().setAttribute(SESSION_KEY_VIEW_RECORD, viewRecord);
            }

            // 2. 判断是否是重复请求（5秒内同一视频）
            long currentTime = System.currentTimeMillis();
            Long lastViewTime = viewRecord.get(requestURI);
            if (lastViewTime != null && (currentTime - lastViewTime) < DUPLICATE_INTERVAL) {
                System.out.println("【视频监听器】跳过重复请求：" + requestURI);
                return;
            }

            // 3. 不是重复请求，更新统计
            viewRecord.put(requestURI, currentTime);
            System.out.println("【视频监听器】✅ 统计有效请求：" + requestURI);
            updateVideoViewCount(requestURI);
        }
    }

    @Override
    public void requestDestroyed(ServletRequestEvent sre) {
        // 无需修改
    }

    // 数据库统计逻辑（不变）
    private void updateVideoViewCount(String videoPath) {
        Connection conn = null;
        PreparedStatement pstmtQuery = null;
        PreparedStatement pstmtUpdate = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            String querySql = "SELECT view_count FROM video_view WHERE video_path = ?";
            pstmtQuery = conn.prepareStatement(querySql);
            pstmtQuery.setString(1, videoPath);
            rs = pstmtQuery.executeQuery();

            if (rs.next()) {
                int currentCount = rs.getInt("view_count");
                String updateSql = "UPDATE video_view SET view_count = ? WHERE video_path = ?";
                pstmtUpdate = conn.prepareStatement(updateSql);
                pstmtUpdate.setInt(1, currentCount + 1);
                pstmtUpdate.setString(2, videoPath);
                pstmtUpdate.executeUpdate();
                System.out.println("【视频监听器】统计成功：" + videoPath + " → 次数：" + (currentCount + 1));
            } else {
                String insertSql = "INSERT INTO video_view (video_path, view_count) VALUES (?, 1)";
                pstmtUpdate = conn.prepareStatement(insertSql);
                pstmtUpdate.setString(1, videoPath);
                pstmtUpdate.executeUpdate();
                System.out.println("【视频监听器】统计成功：新增记录 → " + videoPath + " → 次数：1");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("【视频监听器】数据库错误：" + e.getMessage());
        } finally {
            DBUtil.close(rs, pstmtQuery, conn);
            DBUtil.close(null, pstmtUpdate, null);
        }
    }
}