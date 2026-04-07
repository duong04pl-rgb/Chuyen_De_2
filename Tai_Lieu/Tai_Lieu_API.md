# Tài Liệu Thiết Kế Backend (API/Functions) - Tuần 3

Hệ thống sử dụng **SQLite** làm Backend cục bộ để quản lý dữ liệu đơn thuốc, chi tiết thuốc và lịch sử sử dụng của người dùng.

## 1. Danh sách các Hàm (Functions) xử lý chính

| Tên Hàm | Mục đích | Giao diện sử dụng |
| :--- | :--- | :--- |
| `layDanhSachDonThuoc` | Truy vấn toàn bộ dữ liệu từ DB để hiển thị. | Màn hình chính, Thống kê |
| `themDonThuoc` | Lưu đơn thuốc mới và các loại thuốc con. | Màn hình Thiết lập Đơn |
| `capNhatDonThuoc` | Cập nhật thông tin khi người dùng chỉnh sửa. | Màn hình Thiết lập Đơn |
| `xoaDonThuoc` | Xóa đơn thuốc và dữ liệu liên quan (Cascade). | Màn hình chính |
| `ghiNhanUongThuoc` | Cập nhật trạng thái uống thuốc hàng ngày. | Checkbox tại Màn hình chính |

---

## 2. Thiết kế chi tiết từng Hàm

### A. Hàm: `themDonThuoc`
- **Tên:** `insertPrescription(Prescription p)`
- **Đầu vào (Input):** Đối tượng `Prescription` (chứa tiêu đề, ngày bắt đầu/kết thúc và danh sách `MedicineDetail`).
- **Đầu ra (Output):** `Future<int>` (ID của đơn thuốc vừa tạo).
- **Logic Database:** - Thực hiện `INSERT` vào bảng `don_thuoc`.
  - Duyệt danh sách thuốc để `INSERT` vào bảng `chi_tiet_thuoc` kèm `id_don_thuoc`.

### B. Hàm: `layDanhSachDonThuoc`
- **Tên:** `getAllPrescriptions()`
- **Đầu vào (Input):** Không có.
- **Đầu ra (Output):** `Future<List<Prescription>>`.
- **Logic Database:**
  - `SELECT * FROM don_thuoc`.
  - Với mỗi dòng, truy vấn thêm từ bảng `chi_tiet_thuoc` và `nhat_ky_uong` để map vào đối tượng Dart.

### C. Hàm: `ghiNhanUongThuoc`
- **Tên:** `toggleHistory(String date, String medicineName, String session, bool isAdding)`
- **Đầu vào (Input):** Ngày (YYYY-MM-DD), Tên thuốc, Buổi (Sáng/Trưa/Tối), Hành động (Thêm/Xóa).
- **Đầu ra (Output):** `Future<void>`.
- **Logic Database:**
  - Nếu `isAdding == true`: `INSERT INTO nhat_ky_uong`.
  - Nếu `isAdding == false`: `DELETE FROM nhat_ky_uong` theo điều kiện trùng khớp.
