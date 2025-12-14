package com.example.demo1;

import jakarta.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;

public class ParameterUtil {

    public static String getParameter(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value != null) {
            try {
                if ("ISO-8859-1".equalsIgnoreCase(request.getCharacterEncoding())) {
                    value = new String(value.getBytes("ISO-8859-1"), "UTF-8");
                }
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        }
        return value;
    }
}
