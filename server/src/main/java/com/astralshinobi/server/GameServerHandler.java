package com.astralshinobi.server;

import com.astralshinobi.db.DatabaseManager;
import com.astralshinobi.dto.UsersDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

public class GameServerHandler extends SimpleChannelInboundHandler<String> {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    static {
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.configure(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
    }

    @Override
    protected void channelRead0(ChannelHandlerContext ctx, String msg) throws Exception {
        try {
            // Parse JSON request
            var request = objectMapper.readTree(msg);

            // Kiểm tra trường "action"
            if (request.get("action") == null || !request.get("action").isTextual()) {
                ctx.writeAndFlush("{\"status\":\"error\",\"message\":\"Missing or invalid 'action' field\"}\n");
                return;
            }
            String action = request.get("action").asText();

            if ("get_user".equals(action)) {
                // Kiểm tra trường "data" và "user_id"
                if (request.get("data") == null || request.get("data").get("user_id") == null || !request.get("data").get("user_id").isInt()) {
                    ctx.writeAndFlush("{\"status\":\"error\",\"message\":\"Missing or invalid 'user_id' in 'data'\"}\n");
                    return;
                }
                int userId = request.get("data").get("user_id").asInt();

                UsersDTO user = DatabaseManager.getUserById(userId);
                if (user != null) {
                    String response = objectMapper.writeValueAsString(
                            new Response("success", user)
                    );
                    ctx.writeAndFlush(response + "\n");
                } else {
                    ctx.writeAndFlush("{\"status\":\"error\",\"message\":\"User not found\"}\n");
                }
            } else {
                ctx.writeAndFlush("{\"status\":\"error\",\"message\":\"Unknown action: " + action + "\"}\n");
            }
        } catch (Exception e) {
            ctx.writeAndFlush("{\"status\":\"error\",\"message\":\"Invalid JSON: " + e.getMessage() + "\"}\n");
        }
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        cause.printStackTrace();
        ctx.writeAndFlush("{\"status\":\"error\",\"message\":\"Server error: " + cause.getMessage() + "\"}\n");
        ctx.close();
    }

    private record Response(String status, Object data) {}
}