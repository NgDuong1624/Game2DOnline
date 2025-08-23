package com.astralshinobi.client;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class TestClient {
    public static void main(String[] args) throws Exception {
        Socket socket = new Socket("localhost", 8080);
        PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
        BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        // Gửi request hợp lệ
        out.println("{\"action\":\"get_user\",\"data\":{\"user_id\":1}}");
        System.out.println("Received: " + in.readLine());

        // Gửi request lỗi để test
        out.println("{\"data\":{\"user_id\":1}}");
        System.out.println("Received: " + in.readLine());

        socket.close();
    }
}