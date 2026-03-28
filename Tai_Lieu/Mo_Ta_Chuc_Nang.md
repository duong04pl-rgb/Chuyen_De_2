# BẢN MÔ TẢ CHỨC NĂNG - ỨNG DỤNG NHẮC UỐNG THUỐC 

## 1. Giới thiệu chung
* **Tên ứng dụng dự kiến:** MediRemind (hoặc Nhắc Nhở Uống Thuốc)
* **Nền tảng:** Mobile App (Android/iOS) phát triển bằng framework Flutter.
* **Mục tiêu:** Trợ lý sức khỏe cá nhân giúp người dùng quản lý lịch uống thuốc, phát báo thức/thông báo đúng giờ, giúp giảm thiểu tình trạng quên uống thuốc hoặc uống sai liều lượng, đặc biệt hữu ích cho người có bệnh lý nền hoặc người cao tuổi.

## 2. Các chức năng chính (Functional Requirements)

### 2.1. Quản lý Danh mục thuốc (Core Feature)
* **Thêm mới thuốc:** Cho phép nhập tên thuốc, chọn hình ảnh nhận diện (viên nang, viên nén, siro...), và liều lượng (ví dụ: 2 viên/lần).
* **Thiết lập lịch uống:** Cài đặt thời gian uống cụ thể (Sáng: 8h00, Tối: 20h00) hoặc uống theo chu kỳ (mỗi 8 tiếng).
* **Quản lý thời gian điều trị:** Thiết lập số ngày cần uống (ví dụ: uống kháng sinh trong 7 ngày).
* **Chỉnh sửa/Xóa:** Cập nhật hoặc xóa thông tin đơn thuốc.

### 2.2. Hệ thống Nhắc nhở (Notification System)
* **Thông báo đẩy (Push Notification):** Gửi thông báo đến màn hình điện thoại khi đến giờ uống thuốc.
* **Tương tác nhanh:** Người dùng có thể đánh dấu "Đã uống" (Taken) hoặc "Bỏ qua" (Skipped) trực tiếp trên giao diện.

### 2.3. Theo dõi & Lịch sử (Tracking & Dashboard)
* **Trang chủ (Today's Schedule):** Hiển thị danh sách các loại thuốc cần uống trong ngày hôm nay. Trạng thái hiển thị rõ ràng: Chưa uống, Đã uống, Đã quá giờ.
* **Lịch sử (History/Calendar):** Tích hợp bộ lịch (Calendar) để người dùng xem lại mức độ tuân thủ uống thuốc của các ngày trước đó.

### 2.4. Tính năng nâng cao (Dự kiến mở rộng)
* **Nhắc mua thêm thuốc (Refill Reminder):** Người dùng nhập tổng số lượng viên thuốc đang có, app tự động trừ lùi sau mỗi lần uống và nhắc nhở đi mua khi sắp hết.
* **Quản lý hồ sơ người thân:** Cho phép thêm lịch uống thuốc cho nhiều người trong gia đình (VD: mẹ, con cái).

## 3. Yêu cầu phi chức năng (Non-functional Requirements)
* **Giao diện (UI/UX):** Thiết kế tối giản, chữ to, màu sắc tương phản tốt để người lớn tuổi dễ nhìn và dễ thao tác.
* **Hiệu năng:** Gửi thông báo chính xác thời gian thực, hoạt động mượt mà và tiết kiệm pin.
