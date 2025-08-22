# 🌌 Anime Online 2D Game

Anime Online là một tựa game MMO 2D phong cách anime, mang đến trải nghiệm dễ chơi, gần gũi và tươi mới. Trò chơi được thiết kế với gameplay hiện đại, mượt mà và hỗ trợ đa nền tảng (PC & Mobile).

## 🚀 Công nghệ sử dụng

### Backend

- **Java + Netty**: Xử lý kết nối TCP/WebSocket thời gian thực.
- **PostgreSQL**: Lưu trữ tài khoản, nhân vật và vật phẩm.
- **MessagePack / Protobuf**: Serialize dữ liệu nhanh, gọn.
- **Game Loop**: Fixed Tick 30/s đảm bảo đồng bộ trạng thái.

### Frontend (Client)

- **Unity 2D (C#)**: Hiển thị nhân vật, map, combat và UI.
- **Client-side Prediction**: Giảm lag, tăng trải nghiệm mượt mà.
- **Đa nền tảng**: PC (Windows) và Android (APK).

### Công cụ hỗ trợ

- **GitHub Actions**: Tự động hóa CI/CD.
- **Docker**: Triển khai server dễ dàng.
- **Discord/Slack**: Quản lý cộng đồng và tiếp nhận phản hồi.

## 🏗️ Kiến trúc hệ thống
```
Client (Unity) ⇆ Netty Server (Java)
       |                 |
  Input/Output       Game Loop
       |                 |
     Database      (PostgreSQL)
```

- **Channel ↔ Player**: Mỗi client kết nối gắn với một nhân vật.
- **GameWorld**: Quản lý toàn bộ người chơi, quái, NPC và map.
- **ChannelGroup**: Broadcast cập nhật trạng thái đến tất cả client.

## ⚙️ Hướng dẫn chạy thử

### 1. Chạy server
```bash
# Clone repository
git clone https://github.com/NgDuong1624/Game2DOnline.git
cd Game2DOnline/server

# Build & run
./gradlew run
```

Server mặc định chạy tại `localhost:8080`.

### 2. Chạy client

- Mở Unity project trong thư mục `/client`.
- Build game cho PC hoặc Android.
- Kết nối tới `ws://localhost:8080`.

## 👨‍💻 Đóng góp

Chúng tôi hoan nghênh mọi Pull Request và Issue. Vui lòng đọc file CONTRIBUTING.md trước khi đóng góp.