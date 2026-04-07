# Thiết Kế Cơ Sở Dữ Liệu SQLite - MediRemind

Hệ thống sử dụng mô hình cơ sở dữ liệu quan hệ để quản lý thông tin.

## 1. Sơ đồ thực thể (Table Schema)

### Bảng 1: `don_thuoc` (Prescriptions)
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | INTEGER (PK) | Mã định danh tự tăng |
| `tieu_de` | TEXT | Tên đơn thuốc (vd: Đau đầu) |
| `ngay_bat_dau` | TEXT | Định dạng ISO8601 |
| `ngay_ket_thuc` | TEXT | Định dạng ISO8601 |

### Bảng 2: `chi_tiet_thuoc` (Medicines)
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | INTEGER (PK) | Mã định danh tự tăng |
| `id_don_thuoc` | INTEGER (FK) | Liên kết với bảng `don_thuoc` |
| `ten_thuoc` | TEXT | Tên thuốc |
| `tong_kho` | INTEGER | Số lượng viên còn lại |
| `lieu_sang/trua/toi` | INTEGER | Liều lượng từng buổi |
| `gio_sang/trua/toi` | TEXT | Thời gian uống (HH:mm) |

### Bảng 3: `nhat_ky_uong` (History)
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | INTEGER (PK) | Mã định danh |
| `ngay_uong` | TEXT | Ngày ghi nhận (YYYY-MM-DD) |
| `ten_thuoc` | TEXT | Định danh thuốc đã uống |
| `buoi` | TEXT | Sáng, Trưa hoặc Tối |

## 2. Quy tắc ràng buộc
- **Xóa Cascade:** Khi một đơn thuốc bị xóa, tất cả dữ liệu liên quan trong bảng `chi_tiet_thuoc` và `nhat_ky_uong` sẽ tự động bị xóa theo để tránh rác dữ liệu.
