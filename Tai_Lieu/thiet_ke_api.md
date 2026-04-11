Phân Tích và Thiết Kế API Đơn Giản (Python + FastAPI)
Công Nghệ Sử Dụng
Framework: FastAPI (Python, dễ học, tự động tạo docs).
Database: SQLite (đơn giản, không cần cài đặt server).
ORM: SQLAlchemy (để quản lý database).
Authentication: API Key đơn giản (gửi trong header).
Base URL: http://localhost:8000 (cho local development).
Models (Sử dụng Pydantic cho validation)
User: id, email, name, api_key.
Prescription: id, user_id, title, start_date, end_date, medicines (list), history (dict).
MedicineDetail: id, prescription_id, name, total_stock, morning_dose, midday_dose, evening_dose, morning_time, midday_time, evening_time.
Endpoints Đơn Giản
Authentication: Chỉ đăng ký và lấy API key.
Prescriptions: CRUD cơ bản.
Medicines: CRUD trong prescription.
History: Cập nhật đơn giản.
Authentication
POST /register: Tạo user và trả API key.
POST /login: Kiểm tra và trả API key (giả lập).
Prescriptions
GET /prescriptions: List tất cả prescriptions của user (dùng API key).
POST /prescriptions: Tạo mới.
GET /prescriptions/{id}: Lấy chi tiết.
PUT /prescriptions/{id}: Cập nhật.
DELETE /prescriptions/{id}: Xóa.
Medicines
GET /prescriptions/{id}/medicines: List medicines trong prescription.
POST /prescriptions/{id}/medicines: Thêm medicine.
PUT /prescriptions/{id}/medicines/{med_id}: Cập nhật medicine.
DELETE /prescriptions/{id}/medicines/{med_id}: Xóa medicine.
History
POST /prescriptions/{id}/history: Cập nhật history cho ngày cụ thể.
Bảo Mật
API Key trong header: X-API-Key: your_key.
Không có rate limiting phức tạp.
Tích Hợp với Flutter
Sử dụng package http như trước.
Gửi API key trong headers.
