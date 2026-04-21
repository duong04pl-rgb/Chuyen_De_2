CHƯƠNG 1: TỔNG QUAN VỀ ĐỀ TÀI
1.1. Lý do chọn đề tài
Trong bối cảnh xã hội hiện đại, nhu cầu chăm sóc sức khỏe ngày càng được quan tâm, đặc biệt là đối với người cao tuổi, người mắc bệnh mãn tính hoặc người phải sử dụng thuốc theo liệu trình dài ngày. Tuy nhiên, việc quên uống thuốc, uống sai liều lượng hoặc không đúng thời gian vẫn diễn ra phổ biến, gây ảnh hưởng nghiêm trọng đến hiệu quả điều trị.
Bên cạnh đó, sự phát triển mạnh mẽ của công nghệ di động và các thiết bị thông minh đã tạo điều kiện thuận lợi để xây dựng các ứng dụng hỗ trợ chăm sóc sức khỏe cá nhân. Việc phát triển một ứng dụng nhắc nhở uống thuốc không chỉ giúp người dùng tuân thủ đúng liệu trình điều trị mà còn góp phần nâng cao chất lượng cuộc sống.
Xuất phát từ thực tế đó, đề tài “Xây dựng ứng dụng nhắc nhở uống thuốc” được lựa chọn nhằm giải quyết bài toán quản lý và nhắc nhở sử dụng thuốc một cách hiệu quả, tiện lợi và chính xác.
1.2. Mục tiêu của đề tài
1.2.1. Mục tiêu về chức năng nghiệp vụ
+Xây dựng hệ thống cho phép người dùng: 
-Thêm, sửa, xóa thông tin thuốc. 
-Thiết lập lịch uống thuốc theo giờ, ngày hoặc chu kỳ. 
-Nhận thông báo nhắc nhở đúng thời điểm. 
+Quản lý lịch sử uống thuốc: 
-Ghi nhận trạng thái đã uống/chưa uống. 
-Theo dõi mức độ tuân thủ liệu trình. 
+Hỗ trợ phân loại thuốc: 
-Theo loại bệnh, thời gian sử dụng hoặc mức độ ưu tiên. 
+Cung cấp giao diện thân thiện, dễ sử dụng cho nhiều đối tượng người dùng.
1.2.2. Mục tiêu về mặt kỹ thuật
+Xây dựng ứng dụng trên nền tảng: 
-Mobile (Android) hoặc Desktop (Python/Tkinter) tùy định hướng triển khai. 
+Sử dụng cơ sở dữ liệu: 
-SQLite để lưu trữ dữ liệu cục bộ. 
+Áp dụng kiến trúc phần mềm rõ ràng: 
-MVC hoặc MVVM. 
+Tích hợp chức năng: 
-Notification (thông báo nhắc nhở). 
-Quản lý dữ liệu hiệu quả và tối ưu. 
+Đảm bảo ứng dụng hoạt động ổn định, hiệu năng tốt.
1.2.3. Mục tiêu về an toàn và bảo mật thông tin
+Bảo vệ dữ liệu người dùng: 
-Mã hóa thông tin quan trọng (nếu cần). 
+Xây dựng cơ chế đăng nhập: 
-Xác thực người dùng (username/password). 
+Hạn chế truy cập trái phép: 
-Phân quyền cơ bản nếu có nhiều vai trò. 
+Đảm bảo dữ liệu không bị mất mát: 
-Sao lưu dữ liệu định kỳ (backup).
1.2.4. Mục tiêu học thuật và phát triển cá nhân
+Áp dụng kiến thức đã học: 
-Lập trình (Python/Java/Android). 
-Cơ sở dữ liệu (SQLite/MySQL). 
-Phân tích và thiết kế hệ thống. 
+Nâng cao kỹ năng: 
-Tư duy logic và giải quyết vấn đề. 
-Thiết kế giao diện người dùng (UI/UX). 
-Làm việc với dự án thực tế. 
+Làm quen với quy trình phát triển phần mềm: 
-Từ phân tích → thiết kế → triển khai → kiểm thử. 
1.3. Đối tượng và Phạm vi nghiên cứu
1.3.1. Đối tượng nghiên cứu
+Người dùng cá nhân có nhu cầu: 
-Nhắc nhở uống thuốc. 
-Quản lý lịch trình sử dụng thuốc. 
+Đối tượng cụ thể: 
-Người cao tuổi. 
-Người bận rộn. 
-Bệnh nhân cần uống thuốc định kỳ.
1.3.2. Phạm vi nghiên cứu
+Phạm vi chức năng: 
-Tập trung vào quản lý thuốc và nhắc nhở. 
-Không bao gồm chẩn đoán bệnh. 
+Phạm vi công nghệ: 
-Ứng dụng chạy cục bộ (offline). 
+Phạm vi triển khai: 
-Chạy trên một thiết bị (không đồng bộ cloud ở giai đoạn đầu). 
+Giới hạn: 
-Không tích hợp với thiết bị y tế thông minh. 
-Không hỗ trợ đa nền tảng nâng cao (giai đoạn đầu).
1.4. Phương pháp nghiên cứu
1.4.1. Phương pháp nghiên cứu lý thuyết
+Thu thập tài liệu: 
-Tài liệu về chăm sóc sức khỏe. 
-Các ứng dụng tương tự trên thị trường. 
+Nghiên cứu công nghệ: 
-SQLite, Android/Python. 
-Notification system. 
+Phân tích yêu cầu: 
-Xác định chức năng cần thiết.
1.4.2. Phương pháp phân tích và thiết kế hệ thống
+Phân tích yêu cầu người dùng. 
+Xây dựng: 
-Use Case Diagram. 
-Class Diagram. 
-Database schema. 
+Thiết kế giao diện: 
-Mockup UI/UX. 
+Lựa chọn kiến trúc phù hợp.
1.4.3. Phương pháp thực nghiệm và phát triển phần mềm
+Tiến hành lập trình ứng dụng. 
+Kiểm thử: 
-Unit test. 
-Test chức năng. 
+Đánh giá: 
-Hiệu năng. 
-Trải nghiệm người dùng. 
+Cải tiến và tối ưu hệ thống.
1.5. Ý nghĩa thực tiễn của đề tài
1.5.1. Đối với người dùng
+Giúp người dùng: 
-Không quên uống thuốc. 
-Uống thuốc đúng giờ, đúng liều. 
+Nâng cao hiệu quả điều trị bệnh. 
+Dễ sử dụng, tiện lợi, hỗ trợ mọi lúc mọi nơi. 
+Giảm phụ thuộc vào người khác trong việc nhắc nhở. 
1.5.2. Đối với nhóm thực hiện
+Củng cố kiến thức đã học: 
-Lập trình, cơ sở dữ liệu, thiết kế hệ thống. 
+Tích lũy kinh nghiệm: 
-Xây dựng một sản phẩm thực tế. 
+Phát triển kỹ năng: 
-Làm việc nhóm (nếu có). 
-Quản lý thời gian và dự án. 
+Tạo nền tảng cho các dự án lớn hơn trong tương lai.
