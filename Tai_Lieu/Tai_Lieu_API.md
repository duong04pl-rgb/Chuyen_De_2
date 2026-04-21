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
- **Tên:** `themDonThuoc(DonThuoc dt)`
- **Đầu vào (Input):** Đối tượng `DonThuoc` (chứa tiêu đề, ngày bắt đầu/kết thúc và danh sách `ChiTietThuoc`).
- **Đầu ra (Output):** `Future<int>` (ID của đơn thuốc vừa tạo).
- **Logic Database:** - Thực hiện `INSERT` vào bảng `don_thuoc`.
  - Duyệt danh sách thuốc để `INSERT` vào bảng `chi_tiet_thuoc` kèm `id_don_thuoc`.

### B. Hàm: `layDanhSachDonThuoc`
- **Tên:** `layTatCaDonThuoc()`
- **Đầu vào (Input):** Không có.
- **Đầu ra (Output):** `Future<List<DonThuoc>>`.
- **Logic Database:**
  - `SELECT * FROM don_thuoc`.
  - Với mỗi dòng, truy vấn thêm từ bảng `chi_tiet_thuoc` và `nhat_ky_uong` để map vào đối tượng Dart.

### C. Hàm: `ghiNhanUongThuoc`
- **Tên:** `ghiNhanUongThuoc(String date, String medicineName, String session, bool isAdding)`
- **Đầu vào (Input):** Ngày (YYYY-MM-DD), Tên thuốc, Buổi (Sáng/Trưa/Tối), Hành động (Thêm/Xóa).
- **Đầu ra (Output):** `Future<void>`.
- **Logic Database:**
  - Nếu `isAdding == true`: `INSERT INTO nhat_ky_uong`.
  - Nếu `isAdding == false`: `DELETE FROM nhat_ky_uong` theo điều kiện trùng khớp.

## 1. Tổng Quan Dự Án

### 1.1 Mục Tiêu
MediRemind là ứng dụng Flutter giúp người dùng quản lý đơn thuốc và nhận thông báo nhắc nhở uống thuốc đúng giờ. Backend API được thiết kế để cung cấp dịch vụ lưu trữ và quản lý dữ liệu đơn thuốc từ xa, thay thế cho việc lưu trữ cục bộ.

### 1.2 Kiến Trúc Hệ Thống
- **Frontend:** Flutter app (Material Design 3)
- **Backend:** Dart server sử dụng Shelf framework
- **Database:** JSON file (có thể mở rộng sang database thực)
- **Communication:** HTTP REST API với JSON
- **Authentication:** Chưa triển khai (có thể thêm sau)

---

## 2. Thiết Kế Backend API

### 2.1 Công Nghệ Sử Dụng
- **Ngôn ngữ:** Dart
- **Framework:** Shelf (HTTP server)
- **Middleware:** CORS headers, Request logging
- **Data Storage:** JSON file (`backend/data/prescriptions.json`)
- **Dependencies:** shelf, shelf_router, shelf_cors_headers, uuid

### 2.2 Cấu Trúc Dữ Liệu

#### Prescription (Đơn Thuốc)
```json
{
  "id": "string (UUID)",
  "title": "string - Tên đơn thuốc",
  "start": "string (ISO date) - Ngày bắt đầu",
  "end": "string (ISO date) - Ngày kết thúc",
  "medicines": "Array<MedicineDetail> - Danh sách thuốc",
  "history": "Map<string, Array<string>> - Lịch sử uống thuốc"
}
```

#### MedicineDetail (Chi Tiết Thuốc)
```json
{
  "name": "string - Tên thuốc",
  "totalStock": "int - Tổng số lượng",
  "mDose": "int - Liều sáng",
  "midDose": "int - Liều trưa",
  "eDose": "int - Liều tối",
  "mTime": "string - Giờ uống sáng (HH:MM)",
  "midTime": "string - Giờ uống trưa (HH:MM)",
  "eTime": "string - Giờ uống tối (HH:MM)"
}
```

---

## 3. Danh Sách API/Function Chính

| STT | Tên API | Method | Mục Đích | Giao Diện Tương Ứng |
|-----|---------|--------|----------|-------------------|
| 1 | `/health` | GET | Kiểm tra trạng thái server | N/A (Health check nội bộ) |
| 2 | `/prescriptions` | GET | Lấy danh sách đơn thuốc | Màn hình danh sách đơn thuốc |
| 3 | `/prescriptions/{id}` | GET | Lấy chi tiết đơn thuốc | Màn hình chi tiết đơn thuốc |
| 4 | `/prescriptions` | POST | Tạo đơn thuốc mới | Màn hình thêm đơn thuốc |
| 5 | `/prescriptions/{id}` | PUT | Cập nhật đơn thuốc | Màn hình chỉnh sửa đơn thuốc |
| 6 | `/prescriptions/{id}` | DELETE | Xóa đơn thuốc | Nút xóa trong danh sách |

---

## 4. Thiết Kế Chi Tiết Từng API

### 4.1 GET /health
**Mục đích:** Kiểm tra trạng thái hoạt động của server

**Thông số kỹ thuật:**
- **URL:** `http://localhost:8080/health`
- **Method:** GET
- **Headers:** Không yêu cầu
- **Body:** Không có

**Response:**
- **Status Code:** 200 OK
- **Content-Type:** application/json
- **Body:**
  ```json
  {
    "status": "ok"
  }
  ```

**Database:** Không tương tác database

**Xử lý lỗi:** Không có lỗi đặc biệt

---

### 4.2 GET /prescriptions
**Mục đích:** Lấy danh sách tất cả đơn thuốc trong hệ thống

**Thông số kỹ thuật:**
- **URL:** `http://localhost:8080/prescriptions`
- **Method:** GET
- **Headers:** Không yêu cầu
- **Body:** Không có

**Response:**
- **Status Code:** 200 OK
- **Content-Type:** application/json
- **Body:** Array of Prescription objects
  ```json
  [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Đơn thuốc Mùa đông",
      "start": "2026-04-11",
      "end": "2026-04-18",
      "medicines": [
        {
          "name": "Paracetamol",
          "totalStock": 30,
          "mDose": 1,
          "midDose": 0,
          "eDose": 1,
          "mTime": "08:00",
          "midTime": null,
          "eTime": "20:00"
        }
      ],
      "history": {
        "2026-04-11": ["Uống Sáng", "Uống Tối"]
      }
    }
  ]
  ```

**Database:** Đọc từ file `backend/data/prescriptions.json`

**Xử lý lỗi:**
- Nếu file không tồn tại: Trả về mảng rỗng `[]`

---

### 4.3 GET /prescriptions/{id}
**Mục đích:** Lấy thông tin chi tiết của một đơn thuốc cụ thể

**Thông số kỹ thuật:**
- **URL:** `http://localhost:8080/prescriptions/{id}`
- **Method:** GET
- **Path Parameters:**
  - `id` (string, required): UUID của đơn thuốc
- **Headers:** Không yêu cầu
- **Body:** Không có

**Response:**
- **Status Code:** 200 OK / 404 Not Found
- **Content-Type:** application/json
- **Body (Success):**
  ```json
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Đơn thuốc Mùa đông",
    "start": "2026-04-11",
    "end": "2026-04-18",
    "medicines": [...],
    "history": {...}
  }
  ```
- **Body (Error):**
  ```json
  {
    "error": "Prescription not found"
  }
  ```

**Database:** Tìm kiếm trong file `backend/data/prescriptions.json`

**Xử lý lỗi:**
- 404: Nếu không tìm thấy đơn thuốc với ID được cung cấp

---

### 4.4 POST /prescriptions
**Mục đích:** Tạo mới một đơn thuốc

**Thông số kỹ thuật:**
- **URL:** `http://localhost:8080/prescriptions`
- **Method:** POST
- **Headers:**
  - `Content-Type: application/json`
- **Body:** Prescription object (không cần trường `id`)
  ```json
  {
    "title": "Đơn thuốc mới",
    "start": "2026-04-11",
    "end": "2026-04-18",
    "medicines": [
      {
        "name": "Aspirin",
        "totalStock": 20,
        "mDose": 1,
        "midDose": 1,
        "eDose": 0,
        "mTime": "07:30",
        "midTime": "12:00",
        "eTime": null
      }
    ],
    "history": {}
  }
  ```

**Response:**
- **Status Code:** 200 OK / 400 Bad Request
- **Content-Type:** application/json
- **Body (Success):** Prescription object với `id` được tạo
- **Body (Error):**
  ```json
  {
    "error": "Invalid request body"
  }
  ```

**Database:** Thêm vào file `backend/data/prescriptions.json`

**Xử lý lỗi:**
- 400: Nếu body request không hợp lệ hoặc thiếu trường bắt buộc

---

### 4.5 PUT /prescriptions/{id}
**Mục đích:** Cập nhật thông tin của một đơn thuốc đã tồn tại

**Thông số kỹ thuật:**
- **URL:** `http://localhost:8080/prescriptions/{id}`
- **Method:** PUT
- **Path Parameters:**
  - `id` (string, required): UUID của đơn thuốc cần cập nhật
- **Headers:**
  - `Content-Type: application/json`
- **Body:** Prescription object đầy đủ

**Response:**
- **Status Code:** 200 OK / 404 Not Found / 400 Bad Request
- **Content-Type:** application/json
- **Body (Success):** Prescription object đã được cập nhật
- **Body (Error 404):**
  ```json
  {
    "error": "Prescription not found"
  }
  ```
- **Body (Error 400):**
  ```json
  {
    "error": "Invalid request body"
  }
  ```

**Database:** Cập nhật trong file `backend/data/prescriptions.json`

**Xử lý lỗi:**
- 404: Nếu không tìm thấy đơn thuốc với ID được cung cấp
- 400: Nếu body request không hợp lệ

---

### 4.6 DELETE /prescriptions/{id}
**Mục đích:** Xóa một đơn thuốc khỏi hệ thống

**Thông số kỹ thuật:**
- **URL:** `http://localhost:8080/prescriptions/{id}`
- **Method:** DELETE
- **Path Parameters:**
  - `id` (string, required): UUID của đơn thuốc cần xóa
- **Headers:** Không yêu cầu
- **Body:** Không có

**Response:**
- **Status Code:** 200 OK / 404 Not Found
- **Content-Type:** application/json
- **Body (Success):**
  ```json
  {
    "message": "Deleted successfully"
  }
  ```
- **Body (Error):**
  ```json
  {
    "error": "Prescription not found"
  }
  ```

**Database:** Xóa khỏi file `backend/data/prescriptions.json`

**Xử lý lỗi:**
- 404: Nếu không tìm thấy đơn thuốc với ID được cung cấp

---

## 5. Cơ Sở Dữ Liệu

### 5.1 Kiến Trúc Lưu Trữ
- **Loại:** File-based JSON storage
- **Vị trí:** `backend/data/prescriptions.json`
- **Format:** JSON array chứa các Prescription objects
- **Persistence:** Dữ liệu được lưu ngay lập tức sau mỗi thao tác write

### 5.2 Ưu Điểm
- Đơn giản, không cần cài đặt database server
- Dễ backup và migrate
- Phù hợp cho prototype và small-scale applications

### 5.3 Nhược Điểm
- Không hỗ trợ concurrent access
- Performance kém với dữ liệu lớn
- Không có transaction safety

### 5.4 Kế Hoạch Mở Rộng
- Chuyển sang SQLite/PostgreSQL khi scale up
- Thêm authentication và user isolation
- Implement caching layer



# Mô tả thiết kế DB

## Giới thiệu

`chuyende2` là ứng dụng Flutter hỗ trợ quản lý đơn thuốc, nhắc giờ uống thuốc và theo dõi lịch sử tuân thủ.

## Thiết kế cơ sở dữ liệu

Toàn bộ khởi tạo file SQLite, tạo bảng và thao tác CRUD được định nghĩa trong `lib/database_helper.dart` (lớp `DatabaseHelper`). Trên Windows/Linux, `main.dart` gán `databaseFactory` cho `sqflite_common_ffi` để `sqflite` hoạt động; bản thân helper chỉ import `package:sqflite/sqflite.dart`.

### 0) Khởi tạo kết nối (theo `DatabaseHelper`)

- **Singleton**: `DatabaseHelper.instance` giữ một `Database?` tĩnh, tránh mở nhiều kết nối song song.
- **Tên file**: `mediremind.db`, đường dẫn đầy đủ = `join(getDatabasesPath(), 'mediremind.db')`.
- **`openDatabase`**: `version: 1`, callback `onCreate: _createDB` tạo schema lần đầu.
- **`onConfigure`**: thực thi `PRAGMA foreign_keys = ON` trước khi dùng DB để SQLite áp dụng khóa ngoại và `ON DELETE CASCADE`.

### 1) Mô hình dữ liệu tổng quan

- Một `don_thuoc` có nhiều `chi_tiet_thuoc` (1-N).
- Một `don_thuoc` có nhiều bản ghi `nhat_ky_uong` (1-N).
- Xóa một `don_thuoc` sẽ tự động xóa toàn bộ dữ liệu con nhờ `ON DELETE CASCADE`.

Quan hệ logic:

```text
don_thuoc (1) ---- (N) chi_tiet_thuoc
    |
    +---- (N) nhat_ky_uong
```

### 2) DDL (đúng theo `_createDB`)

Các câu lệnh dưới đây tương ứng với chuỗi SQL trong `database_helper.dart` (hàm `_createDB`).

```sql
CREATE TABLE don_thuoc (
  id TEXT PRIMARY KEY,
  title TEXT,
  start_date TEXT,
  end_date TEXT
);

CREATE TABLE chi_tiet_thuoc (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  don_thuoc_id TEXT,
  name TEXT,
  total_stock INTEGER,
  morning_dose INTEGER,
  midday_dose INTEGER,
  evening_dose INTEGER,
  morning_time TEXT,
  midday_time TEXT,
  evening_time TEXT,
  FOREIGN KEY (don_thuoc_id) REFERENCES don_thuoc (id) ON DELETE CASCADE
);

CREATE TABLE nhat_ky_uong (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  don_thuoc_id TEXT,
  date TEXT,
  history_key TEXT,
  FOREIGN KEY (don_thuoc_id) REFERENCES don_thuoc (id) ON DELETE CASCADE
);
```

### 3) Chi tiết các bảng

#### Bảng `don_thuoc`

Lưu thông tin chung của một đơn thuốc.

- `id` (TEXT, PK): mã định danh đơn thuốc.
- `title` (TEXT): tên đơn thuốc.
- `start_date` (TEXT): ngày bắt đầu (ISO-8601).
- `end_date` (TEXT): ngày kết thúc (ISO-8601).

#### Bảng `chi_tiet_thuoc`

Lưu danh sách thuốc thuộc một đơn.

- `id` (INTEGER, PK, AUTOINCREMENT): khóa chính.
- `don_thuoc_id` (TEXT, FK): tham chiếu `don_thuoc.id`.
- `name` (TEXT): tên thuốc.
- `total_stock` (INTEGER): tổng số viên còn lại trong kho.
- `morning_dose`, `midday_dose`, `evening_dose` (INTEGER): liều uống theo buổi.
- `morning_time`, `midday_time`, `evening_time` (TEXT): giờ nhắc (định dạng `HH:mm`).

#### Bảng `nhat_ky_uong`

Lưu lịch sử đã uống theo ngày và ca uống.

- `id` (INTEGER, PK, AUTOINCREMENT): khóa chính.
- `don_thuoc_id` (TEXT, FK): tham chiếu `don_thuoc.id`.
- `date` (TEXT): ngày ghi nhận (định dạng `yyyy-MM-dd`).
- `history_key` (TEXT): khóa ca uống, ví dụ `Paracetamol_morning`.

### 4) Ánh xạ cột ↔ model `Prescription` / `MedicineDetail`

Helper đọc/ghi qua các model khai báo trong `lib/main.dart` (import chéo từ `database_helper.dart`).

| Bảng / cột DB | Nguồn khi ghi (`savePrescription`) | Ghi chú |
|---------------|-----------------------------------|----------|
| `don_thuoc.id`, `title` | `p.id`, `p.title` | `insert` với `ConflictAlgorithm.replace` → cùng `id` thì ghi đè (upsert đơn). |
| `start_date`, `end_date` | `p.startDate`, `p.endDate` | `toIso8601String()`. |
| `chi_tiet_thuoc.*` | `MedicineDetail.toMap()` → `mDose`/`midDose`/`eDose`, `mTime`/`midTime`/`eTime` | Map sang `morning_dose`, …, `evening_time`. |
| `nhat_ky_uong.date`, `history_key` | `p.history` | Mỗi phần tử trong `List<String>` của một ngày là một dòng `nhat_ky_uong`. |

Khi đọc (`getAllPrescriptions`), dữ liệu từ `chi_tiet_thuoc` được gom lại thành `MedicineDetail.fromMap({...})` với key `mDose`, `midDose`, … đúng với `fromMap` trong `main.dart`.

### 5) Quy tắc toàn vẹn dữ liệu

- Bật ràng buộc khóa ngoại bằng `PRAGMA foreign_keys = ON`.
- Dùng `ON DELETE CASCADE` để tránh bản ghi mồ côi khi xóa đơn thuốc.
- Lưu/cập nhật đơn thuốc theo transaction để đảm bảo đồng bộ dữ liệu cha-con.

### 6) Luồng ghi/đọc/xóa (theo các hàm public trong helper)

- **`savePrescription(Prescription p)`**: mở một `db.transaction`: (1) `insert` vào `don_thuoc` với replace theo `id`; (2) `delete` mọi dòng `chi_tiet_thuoc` và `nhat_ky_uong` có `don_thuoc_id = p.id`; (3) lặp `insert` từng thuốc và từng cặp `(date, history_key)` trong `p.history`. Chiến lược này đảm bảo khi sửa đơn, danh sách thuốc và lịch sử trên DB trùng với object trong bộ nhớ.
- **`getAllPrescriptions()`**: `query('don_thuoc')`, với mỗi `id` thực hiện hai `query` lọc theo `don_thuoc_id`, ghép thành `List<Prescription>`.
- **`deletePrescription(String id)`**: `delete` một dòng trong `don_thuoc`; nhờ FK + cascade, các bản ghi con tương ứng cũng bị xóa.

## Công nghệ sử dụng

- Flutter
- SQLite (`sqflite`, `sqflite_common_ffi`)
- `local_notifier` cho nhắc giờ uống thuốc
- `google_mlkit_text_recognition` và `image_picker` cho quét đơn từ ảnh

