import 'database_helper.dart'; 
import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; 
import 'dart:io'; 
void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();
  await localNotifier.setup(appName: 'MediRemind', shortcutPolicy: ShortcutPolicy.requireCreate);
  runApp(const MediRemindApp());
}

class MediRemindApp extends StatelessWidget {
  const MediRemindApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const MainNavigation(),
    );
  }
}

// --- MODEL DỮ LIỆU ---
class MedicineDetail {
  String name;
  int totalStock;
  int morningDose; int middayDose; int eveningDose;
  TimeOfDay? morningTime; TimeOfDay? middayTime; TimeOfDay? eveningTime;

  MedicineDetail({
    required this.name, required this.totalStock,
    this.morningDose = 0, this.middayDose = 0, this.eveningDose = 0,
    this.morningTime, this.middayTime, this.eveningTime,
  });

  Map<String, dynamic> toMap() => {
    'name': name, 'totalStock': totalStock,
    'mDose': morningDose, 'midDose': middayDose, 'eDose': eveningDose,
    'mTime': morningTime != null ? "${morningTime!.hour}:${morningTime!.minute}" : null,
    'midTime': middayTime != null ? "${middayTime!.hour}:${middayTime!.minute}" : null,
    'eTime': eveningTime != null ? "${eveningTime!.hour}:${eveningTime!.minute}" : null,
  };

  factory MedicineDetail.fromMap(Map<String, dynamic> map) => MedicineDetail(
    name: map['name'], totalStock: map['totalStock'],
    morningDose: map['mDose'] ?? 0, middayDose: map['midDose'] ?? 0, eveningDose: map['eDose'] ?? 0,
    morningTime: map['mTime'] != null ? TimeOfDay(hour: int.parse(map['mTime'].split(':')[0]), minute: int.parse(map['mTime'].split(':')[1])) : null,
    middayTime: map['midTime'] != null ? TimeOfDay(hour: int.parse(map['midTime'].split(':')[0]), minute: int.parse(map['midTime'].split(':')[1])) : null,
    eveningTime: map['eTime'] != null ? TimeOfDay(hour: int.parse(map['eTime'].split(':')[0]), minute: int.parse(map['eTime'].split(':')[1])) : null,
  );
}

class Prescription {
  String id;
  String title;
  DateTime startDate; DateTime endDate;
  List<MedicineDetail> medicines;
  Map<String, List<String>> history; 

  Prescription({required this.id, required this.title, required this.startDate, required this.endDate, required this.medicines, Map<String, List<String>>? history}) 
    : history = history ?? {};

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'start': startDate.toIso8601String(), 'end': endDate.toIso8601String(),
    'medicines': medicines.map((m) => m.toMap()).toList(),
    'history': history,
  };

  factory Prescription.fromMap(Map<String, dynamic> map) => Prescription(
    id: map['id'], title: map['title'],
    startDate: DateTime.parse(map['start']), endDate: DateTime.parse(map['end']),
    medicines: (map['medicines'] as List).map((m) => MedicineDetail.fromMap(m)).toList(),
    history: (map['history'] as Map<String, dynamic>?)?.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    ) ?? {},
  );
}

// --- GIAO DIỆN CHÍNH ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<Prescription> prescriptions = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(minutes: 1), (t) => _checkNotifications());
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  Future<void> _saveData() async {
    // Duyệt qua danh sách hiện tại và lưu từng đơn vào SQLite
    for (var pres in prescriptions) {
      await DatabaseHelper.instance.savePrescription(pres);
    }
  }

  Future<void> _loadData() async {
    // 1. Gọi Database lấy danh sách đã lưu
    final data = await DatabaseHelper.instance.getAllPrescriptions();
    
    // 2. Cập nhật lên màn hình
    setState(() {
      prescriptions = data;
    });
  }

  void _checkNotifications() {
    final now = DateTime.now();
    for (var pres in prescriptions) {
      if (now.isBefore(pres.startDate) || now.isAfter(pres.endDate)) continue;
      for (var med in pres.medicines) {
        _notifyMatch(med.morningTime, now, "${med.name} (Sáng)");
        _notifyMatch(med.middayTime, now, "${med.name} (Trưa)");
        _notifyMatch(med.eveningTime, now, "${med.name} (Tối)");
      }
    }
  }

  void _notifyMatch(TimeOfDay? t, DateTime now, String label) {
    if (t != null && t.hour == now.hour && t.minute == now.minute) {
      LocalNotification(title: "Nhắc uống thuốc", body: "Đã đến giờ uống $label").show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: [
        PrescriptionListScreen(
          prescriptions: prescriptions, 
          onUpdate: () { setState(() {}); _saveData(); },
          onDelete: (i) async { 
  // 1. Lấy ID của đơn thuốc để xóa trong SQLite
  final idToDelete = prescriptions[i].id;

  // 2. Gọi DatabaseHelper xóa hẳn trong máy (Nhớ dùng await)
  await DatabaseHelper.instance.deletePrescription(idToDelete);

  // 3. Xóa trên màn hình để người dùng thấy
  setState(() {
    prescriptions.removeAt(i);
  });
},
        ),
        HistoryChartScreen(prescriptions: prescriptions),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Đơn thuốc'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
        ],
      ),
    );
  }
}

// --- MÀN HÌNH DANH SÁCH ĐƠN THUỐC ---
class PrescriptionListScreen extends StatelessWidget {
  final List<Prescription> prescriptions;
  final VoidCallback onUpdate;
  final Function(int) onDelete;
  const PrescriptionListScreen({super.key, required this.prescriptions, required this.onUpdate, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    String today = DateTime.now().toString().split(' ')[0];
    return Scaffold(
      appBar: AppBar(title: const Text("Đơn Thuốc Của Tôi")),
      body: ListView.builder(
        itemCount: prescriptions.length,
        itemBuilder: (ctx, i) {
          final p = prescriptions[i];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${p.startDate.day}/${p.startDate.month} - ${p.endDate.day}/${p.endDate.month}"),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () async {
                  final res = await Navigator.push(context, MaterialPageRoute(builder: (c) => AddPrescriptionScreen(editPres: p)));
                  if (res != null) { prescriptions[i] = res; onUpdate(); }
                }),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onDelete(i)),
              ]),
              children: p.medicines.map((m) => Column(children: [
                ListTile(title: Text(m.name, style: const TextStyle(color: Colors.teal)), subtitle: Text("Kho: ${m.totalStock}")),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _check(p, m, "morning", today, m.morningDose, onUpdate),
                  _check(p, m, "midday", today, m.middayDose, onUpdate),
                  _check(p, m, "evening", today, m.eveningDose, onUpdate),
                ]),
                const SizedBox(height: 10),
              ])).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        final res = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddPrescriptionScreen()));
        if (res != null) { prescriptions.add(res); onUpdate(); }
      }, child: const Icon(Icons.add)),
    );
  }

  Widget _check(Prescription p, MedicineDetail m, String session, String date, int dose, VoidCallback update) {
    if (dose == 0) return const SizedBox.shrink();
    String key = "${m.name}_$session";
    bool isTaken = p.history[date]?.contains(key) ?? false;
    return Column(children: [
      Text(session == "morning" ? "Sáng" : session == "midday" ? "Trưa" : "Tối", style: const TextStyle(fontSize: 12)),
      Checkbox(value: isTaken, onChanged: (v) {
        if (v == true) { p.history.putIfAbsent(date, () => []).add(key); m.totalStock -= dose; }
        else { p.history[date]?.remove(key); m.totalStock += dose; }
        update();
      }),
    ]);
  }
}

// --- MÀN HÌNH THÊM / SỬA ---
class AddPrescriptionScreen extends StatefulWidget {
  final Prescription? editPres;
  const AddPrescriptionScreen({super.key, this.editPres});
  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  late TextEditingController _tCtrl;
  late DateTime _s; late DateTime _e;
  List<MedicineDetail> _ms = [];

  @override
  void initState() {
    super.initState();
    _tCtrl = TextEditingController(text: widget.editPres?.title ?? "");
    _s = widget.editPres?.startDate ?? DateTime.now();
    _e = widget.editPres?.endDate ?? DateTime.now().add(const Duration(days: 7));
    _ms = widget.editPres != null ? List.from(widget.editPres!.medicines) : [];
  }

  void _dialog({MedicineDetail? em, int? index}) {
    String name = em?.name ?? ""; int stock = em?.totalStock ?? 0;
    int sD = em?.morningDose ?? 0; int tD = em?.middayDose ?? 0; int cD = em?.eveningDose ?? 0;
    TimeOfDay? sT = em?.morningTime; TimeOfDay? tT = em?.middayTime; TimeOfDay? cT = em?.eveningTime;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setStateD) => AlertDialog(
      title: const Text("Thông tin thuốc"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: TextEditingController(text: name), onChanged: (v) => name = v, decoration: const InputDecoration(labelText: "Tên thuốc")),
        TextField(controller: TextEditingController(text: stock.toString()), onChanged: (v) => stock = int.tryParse(v) ?? 0, decoration: const InputDecoration(labelText: "Tổng số viên trong kho"), keyboardType: TextInputType.number),
        _row("Sáng", sD, sT, (v) => sD = v, (t) => setStateD(() => sT = t)),
        _row("Trưa", tD, tT, (v) => tD = v, (t) => setStateD(() => tT = t)),
        _row("Tối", cD, cT, (v) => cD = v, (t) => setStateD(() => cT = t)),
      ])),
      actions: [ElevatedButton(onPressed: () {
        final n = MedicineDetail(name: name, totalStock: stock, morningDose: sD, middayDose: tD, eveningDose: cD, morningTime: sT, middayTime: tT, eveningTime: cT);
        setState(() { if (index != null) _ms[index] = n; else _ms.add(n); });
        Navigator.pop(ctx);
      }, child: const Text("Lưu"))],
    )));
  }

  Widget _row(String l, int d, TimeOfDay? t, Function(int) oD, Function(TimeOfDay) oT) {
    return Row(children: [
      Expanded(child: TextField(controller: TextEditingController(text: d.toString()), onChanged: (v) => oD(int.tryParse(v) ?? 0), decoration: InputDecoration(labelText: "Liều $l"))),
      IconButton(icon: const Icon(Icons.access_time), onPressed: () async {
        final res = await showTimePicker(context: context, initialTime: t ?? TimeOfDay.now());
        if (res != null) oT(res);
      }),
    ]);
  }

  // --- HÀM MỚI: Định dạng chuỗi thời gian để hiển thị ---
  String _formatMedTimes(MedicineDetail med) {
    List<String> times = [];
    if (med.morningTime != null) {
      times.add("Sáng: ${med.morningTime!.hour.toString().padLeft(2, '0')}:${med.morningTime!.minute.toString().padLeft(2, '0')}");
    }
    if (med.middayTime != null) {
      times.add("Trưa: ${med.middayTime!.hour.toString().padLeft(2, '0')}:${med.middayTime!.minute.toString().padLeft(2, '0')}");
    }
    if (med.eveningTime != null) {
      times.add("Tối: ${med.eveningTime!.hour.toString().padLeft(2, '0')}:${med.eveningTime!.minute.toString().padLeft(2, '0')}");
    }
    return times.isEmpty ? "Chưa đặt giờ" : times.join(" - ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thiết lập Đơn")),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(10), child: TextField(controller: _tCtrl, decoration: const InputDecoration(labelText: "Tên đơn thuốc", border: OutlineInputBorder()))),
        ListTile(title: const Text("Thời gian đơn thuốc"), subtitle: Text("${_s.day}/${_s.month} - ${_e.day}/${_e.month}"), onTap: () async {
          final res = await showDateRangePicker(context: context, firstDate: DateTime(2024), lastDate: DateTime(2030));
          if (res != null) setState(() { _s = res.start; _e = res.end; });
        }),
        Expanded(
          // --- CẬP NHẬT: Thêm Subtitle vào ListTile ---
          child: ListView.builder(
            itemCount: _ms.length, 
            itemBuilder: (ctx, i) => ListTile(
              title: Text(_ms[i].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(
                _formatMedTimes(_ms[i]), 
                style: const TextStyle(color: Colors.teal, fontSize: 13, fontWeight: FontWeight.w500)
              ),
              trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _dialog(em: _ms[i], index: i))
            )
          ),
        ),
        ElevatedButton(onPressed: () => _dialog(), child: const Text("Thêm thuốc")),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white), onPressed: () => Navigator.pop(context, Prescription(id: widget.editPres?.id ?? DateTime.now().toString(), title: _tCtrl.text, startDate: _s, endDate: _e, medicines: _ms, history: widget.editPres?.history)), child: const Text("HOÀN TẤT ĐƠN THUỐC")))
      ]),
    );
  }
}

// --- BIỂU ĐỒ CUSTOM (GIỮ NGUYÊN) ---
class HistoryChartScreen extends StatelessWidget {
  final List<Prescription> prescriptions;
  const HistoryChartScreen({super.key, required this.prescriptions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thống kê tuân thủ")),
      body: prescriptions.isEmpty ? const Center(child: Text("Chưa có dữ liệu")) : ListView.builder(
        itemCount: prescriptions.length,
        itemBuilder: (ctx, i) => _buildCustomChart(prescriptions[i]),
      ),
    );
  }

  Widget _buildCustomChart(Prescription pres) {
    final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    return Container(
      height: 450, padding: const EdgeInsets.all(16), margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(pres.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 15,
            children: List.generate(pres.medicines.length, (idx) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24, height: 12,
                    decoration: BoxDecoration(color: colors[idx % colors.length].withOpacity(0.3), border: Border.all(color: colors[idx % colors.length], width: 1.5)),
                  ),
                  const SizedBox(width: 4),
                  Text(pres.medicines[idx].name, style: const TextStyle(fontSize: 12)),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                const Column(
                  children: [
                    Expanded(child: Center(child: Text("Tối", style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(child: Center(child: Text("Trưa", style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(child: Center(child: Text("Sáng", style: TextStyle(fontWeight: FontWeight.bold)))),
                  ],
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: Colors.black, width: 1.5), bottom: BorderSide(color: Colors.black, width: 1.5)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(7, (i) {
                              String dateKey = monday.add(Duration(days: i)).toString().split(' ')[0];
                              return Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.black12, width: 0.5))),
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(pres.medicines.length, (j) {
                                      final med = pres.medicines[j];
                                      final h = pres.history[dateKey] ?? [];
                                      int sDose = h.contains("${med.name}_morning") ? med.morningDose : 0;
                                      int tDose = h.contains("${med.name}_midday") ? med.middayDose : 0;
                                      int cDose = h.contains("${med.name}_evening") ? med.eveningDose : 0;
                                      Color baseColor = colors[j % colors.length];

                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 1),
                                          child: Container(
                                            decoration: BoxDecoration(border: Border.all(color: baseColor, width: 1.5)),
                                            child: Column(
                                              children: [
                                                _buildBox(cDose, baseColor),
                                                const Divider(height: 1, color: Colors.black54),
                                                _buildBox(tDose, baseColor),
                                                const Divider(height: 1, color: Colors.black54),
                                                _buildBox(sDose, baseColor),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(7, (i) => Expanded(
                          child: Center(child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(['T2','T3','T4','T5','T6','T7','CN'][i], style: const TextStyle(fontWeight: FontWeight.bold)),
                          )),
                        )),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(int dose, Color color) {
    return Expanded(
      child: Container(
        color: color.withOpacity(0.15),
        child: Center(
          child: Text(
            dose.toString(), 
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: dose == 0 ? Colors.black38 : Colors.black
            ),
          ),
        ),
      ),
    );
  }
}