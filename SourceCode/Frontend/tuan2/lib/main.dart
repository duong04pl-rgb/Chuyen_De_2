import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:convert';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localNotifier.setup(
    appName: 'MediRemind',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
  runApp(const MediRemindApp());
}

class MediRemindApp extends StatelessWidget {
  const MediRemindApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediRemind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MainNavigation(),
    );
  }
}

// --- MODEL DỮ LIỆU ---
class Medicine {
  String id;
  String name;
  String type;
  String time;
  String dosage; //
  int durationDays; //
  Map<String, bool> history;

  Medicine({
    required this.id,
    required this.name,
    required this.type,
    required this.time,
    required this.dosage,
    required this.durationDays,
    Map<String, bool>? history,
  }) : history = history ?? {};

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'type': type, 'time': time,
    'dosage': dosage, 'durationDays': durationDays, 'history': history,
  };

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
    id: map['id'], name: map['name'], type: map['type'],
    time: map['time'], dosage: map['dosage'], durationDays: map['durationDays'],
    history: Map<String, bool>.from(map['history'] ?? {}),
  );
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<Medicine> medicines = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => _checkAndNotify());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('med_data', json.encode(medicines.map((m) => m.toMap()).toList()));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('med_data');
    if (data != null) {
      setState(() {
        medicines = (json.decode(data) as List).map((m) => Medicine.fromMap(m)).toList();
      });
    }
  }

  void _checkAndNotify() {
    final now = DateTime.now();
    final todayKey = now.toString().split(' ')[0];
    
    for (var med in medicines) {
      if (med.history[todayKey] == true) continue;
      final match = RegExp(r'(\d+):(\d+)').firstMatch(med.time);
      if (match != null) {
        int medHour = int.parse(match.group(1)!);
        int medMinute = int.parse(match.group(2)!);
        if (med.time.contains("PM") && medHour < 12) medHour += 12;
        int medTotal = medHour * 60 + medMinute;
        int nowTotal = now.hour * 60 + now.minute;
        if (nowTotal == medTotal) _showNotification("Đến giờ uống thuốc", "Dùng ${med.name} (${med.dosage})");
        else if (nowTotal == medTotal + 30) _showNotification("NHẮC LẦN 2", "Chưa uống ${med.name}!");
      }
    }
  }

  void _showNotification(String title, String body) {
    LocalNotification(title: title, body: body).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            medicines: medicines, 
            onUpdate: () { setState(() {}); _saveData(); },
          ),
          HistoryScreen(medicines: medicines),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Hôm nay'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch sử'),
        ],
      ),
    );
  }
}

// --- TRANG CHỦ ---
class HomeScreen extends StatelessWidget {
  final List<Medicine> medicines;
  final VoidCallback onUpdate;

  const HomeScreen({super.key, required this.medicines, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    String todayKey = DateTime.now().toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch uống hôm nay"), centerTitle: true),
      body: medicines.isEmpty
          ? const Center(child: Text("Chưa có lịch nhắc nào."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                bool isTakenToday = med.history[todayKey] ?? false;

                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: isTakenToday,
                      onChanged: (val) {
                        med.history[todayKey] = val!;
                        onUpdate();
                      },
                    ),
                    title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${med.time} | Liều: ${med.dosage}"), // Cập nhật liều lượng
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) => AddMedicineScreen(editMed: med)));
                            if (result != null) {
                              medicines[index] = result;
                              onUpdate();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            medicines.removeAt(index);
                            onUpdate();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMedicineScreen()));
          if (result != null) {
            medicines.add(result);
            onUpdate();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- MÀN HÌNH THÊM THUỐC (GIỮ GIAO DIỆN CŨ + THÊM 2 Ô MỚI) ---
class AddMedicineScreen extends StatefulWidget {
  final Medicine? editMed;
  const AddMedicineScreen({super.key, this.editMed});
  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController; //
  late TextEditingController _durationController; //
  late String _selectedType;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // Giữ nguyên logic khởi tạo cũ của Dương Liêm
    _nameController = TextEditingController(text: widget.editMed?.name ?? "");
    _selectedType = widget.editMed?.type ?? "Viên nén";
    _selectedTime = const TimeOfDay(hour: 8, minute: 0);

    // --- [MỚI] Khởi tạo 2 ô nhập liệu mới ---
    _dosageController = TextEditingController(text: widget.editMed?.dosage ?? "");
    _durationController = TextEditingController(text: widget.editMed?.durationDays.toString() ?? "7");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose(); //
    _durationController.dispose(); //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.editMed == null ? "Thêm lịch mới" : "Sửa thông tin")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tên thuốc")),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: _selectedType,
              items: ["Viên nén", "Siro", "Viên nang", "Khác"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedType = val.toString()),
              decoration: const InputDecoration(labelText: "Loại thuốc"),
            ),
            const SizedBox(height: 15),
            // --- [MỚI] Thêm ô nhập Liều lượng ---
            TextField(controller: _dosageController, decoration: const InputDecoration(labelText: "Liều lượng (VD: 1 viên, 5ml)")),
            const SizedBox(height: 15),
            // --- [MỚI] Thêm ô nhập Số ngày uống ---
            TextField(controller: _durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Số ngày uống")),
            const SizedBox(height: 15),
            ListTile(
              title: Text("Giờ: ${_selectedTime.format(context)}"),
              onTap: () async {
                final p = await showTimePicker(context: context, initialTime: _selectedTime);
                if (p != null) setState(() => _selectedTime = p);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) return;
                Navigator.pop(context, Medicine(
                  id: widget.editMed?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  type: _selectedType,
                  time: _selectedTime.format(context),
                  dosage: _dosageController.text, //
                  durationDays: int.tryParse(_durationController.text) ?? 7, //
                  history: widget.editMed?.history, 
                ));
              }, 
              child: const Text("XÁC NHẬN")
            ),
          ],
        ),
      ),
    );
  }
}

// --- NHẬT KÝ ---
class HistoryScreen extends StatefulWidget {
  final List<Medicine> medicines;
  const HistoryScreen({super.key, required this.medicines});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    String dateKey = _selectedDay.toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(title: const Text("Nhật ký tuân thủ")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2024),
            lastDay: DateTime.utc(2030),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (s, f) => setState(() => _selectedDay = s),
            headerStyle: const HeaderStyle(formatButtonVisible: false),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.medicines.length,
              itemBuilder: (context, index) {
                final med = widget.medicines[index];
                bool isTaken = med.history[dateKey] ?? false;
                return ListTile(
                  leading: Icon(isTaken ? Icons.check_circle : Icons.cancel, color: isTaken ? Colors.green : Colors.red),
                  title: Text(med.name),
                  subtitle: Text(isTaken ? "Đã uống" : "Chưa hoàn thành"),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}