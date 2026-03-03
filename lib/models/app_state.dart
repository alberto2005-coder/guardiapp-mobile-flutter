import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_widgets_guardiapp/models/models.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';

class AppState extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  final List<Teacher> _teachers = [];
  final List<Student> _students = [];
  final List<Shift> _shifts = [];
  final List<Absence> _absences = [];
  final List<String> _departments = [
    'General',
    'Science',
    'Math',
    'History',
    'Arts',
    'PE',
  ];

  bool _is7DayView = true;
  DateTime _focusedDate = DateTime.now();
  String? _currentBackgroundPath;
  final List<String> _availableBackgrounds = [];

  bool _isAuthenticated = false;
  String _currentUserRole = '';
  String _currentUserName = '';
  String _currentUserId = '';
  String _adminPassword = 'admin';
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  List<Teacher> get teachers => List.unmodifiable(_teachers);
  List<Student> get students => List.unmodifiable(_students);
  List<Shift> get shifts => List.unmodifiable(_shifts);
  List<Absence> get absences => List.unmodifiable(_absences);
  List<String> get departments => List.unmodifiable(_departments);
  bool get is7DayView => _is7DayView;
  DateTime get focusedDate => _focusedDate;
  String? get currentBackgroundPath => _currentBackgroundPath;
  List<String> get availableBackgrounds =>
      List.unmodifiable(_availableBackgrounds);

  bool get isCustomBackground =>
      _currentBackgroundPath != null &&
      !_currentBackgroundPath!.startsWith('assets/');

  bool get isAuthenticated => _isAuthenticated;
  String get currentUserRole => _currentUserRole;
  String get currentUserName => _currentUserName;
  String get currentUserId => _currentUserId;
  bool get isAdmin => _currentUserRole == 'admin';

  bool canEditShift(Shift shift) {
    if (isAdmin) return true;
    return shift.teacherId == _currentUserId;
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  int get totalTeachers => _teachers.length;
  int get teachersOnLeave => _absences
      .where(
        (a) =>
            a.status == AbsenceStatus.approved &&
            a.startDate.isBefore(DateTime.now()) &&
            a.endDate.isAfter(DateTime.now()),
      )
      .length;
  int get teachersAvailable => totalTeachers - teachersOnLeave;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Simulate a small delay for the skeleton to be visible
      await Future.delayed(const Duration(milliseconds: 1500));
      final prefs = await SharedPreferences.getInstance();

      final teachersString = prefs.getString('teachers');
      if (teachersString != null) {
        print('DEBUG: Loading teachers from storage');
        final List<dynamic> decoded = jsonDecode(teachersString);
        _teachers.clear();
        _teachers.addAll(decoded.map((e) => Teacher.fromJson(e)));
      } else {
        print('DEBUG: No teachers valid in storage');
        _teachers.clear();
      }

      final shiftsString = prefs.getString('shifts');
      if (shiftsString != null) {
        final List<dynamic> decoded = jsonDecode(shiftsString);
        _shifts.clear();
        _shifts.addAll(decoded.map((e) => Shift.fromJson(e)));
      } else {
        _shifts.clear();
      }

      final notificationsString = prefs.getString('notifications');
      if (notificationsString != null) {
        final List<dynamic> decoded = jsonDecode(notificationsString);
        _notifications.clear();
        _notifications.addAll(decoded.map((e) => AppNotification.fromJson(e)));
      } else {
        _notifications.clear();
      }

      final absencesString = prefs.getString('absences');
      if (absencesString != null) {
        final List<dynamic> decoded = jsonDecode(absencesString);
        _absences.clear();
        _absences.addAll(decoded.map((e) => Absence.fromJson(e)));
      } else {
        _absences.clear();
      }

      final studentsString = prefs.getString('students');
      if (studentsString != null) {
        print('DEBUG: Loading students from storage');
        final List<dynamic> decoded = jsonDecode(studentsString);
        _students.clear();
        _students.addAll(decoded.map((e) => Student.fromJson(e)));
      } else {
        print('DEBUG: No students found in storage');
        _students.clear();
      }

      if (_teachers.isNotEmpty) {
        final teacherIds = _teachers.map((t) => t.id).toSet();
        _shifts.removeWhere((s) => !teacherIds.contains(s.teacherId));
        _absences.removeWhere((a) => !teacherIds.contains(a.teacherId));
      } else {
        _shifts.clear();
        _absences.clear();
      }

      final savedAdminPass = prefs.getString('adminPassword');
      if (savedAdminPass != null) {
        _adminPassword = savedAdminPass;
      }

      if (_teachers.isEmpty && _students.isEmpty) {
        print('DEBUG: Storage empty, seeding initial data');
        _seedData();
        _saveData();
      }

      _is7DayView = prefs.getBool('is7DayView') ?? true;

      final themeIndex = prefs.getInt('themeMode');
      if (themeIndex != null) {
        _themeMode = ThemeMode.values[themeIndex];
      }

      final languageCode = prefs.getString('languageCode');
      if (languageCode != null) {
        _locale = Locale(languageCode);
      }

      final savedDepartments = prefs.getStringList('departments');
      if (savedDepartments != null) {
        _departments.clear();
        _departments.addAll(savedDepartments);
      }

      final savedBackground = prefs.getString('currentBackgroundPath');
      if (savedBackground != null && File(savedBackground).existsSync()) {
        _currentBackgroundPath = savedBackground;
      }

      await _loadBackgrounds();

      // If we had a saved background but it wasn't valid file (maybe it was an asset), check if it's an asset
      if (_currentBackgroundPath == null &&
          savedBackground != null &&
          savedBackground.startsWith('assets/')) {
        _currentBackgroundPath = savedBackground;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final teachersJson = jsonEncode(_teachers.map((e) => e.toJson()).toList());
    await prefs.setString('teachers', teachersJson);

    final shiftsJson = jsonEncode(_shifts.map((e) => e.toJson()).toList());
    await prefs.setString('shifts', shiftsJson);

    final notificationsJson = jsonEncode(
      _notifications.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('notifications', notificationsJson);

    final absencesJson = jsonEncode(_absences.map((e) => e.toJson()).toList());
    await prefs.setString('absences', absencesJson);

    final studentsJson = jsonEncode(_students.map((e) => e.toJson()).toList());
    await prefs.setString('students', studentsJson);

    await prefs.setString('adminPassword', _adminPassword);

    await prefs.setBool('is7DayView', _is7DayView);
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setString('languageCode', _locale.languageCode);

    await prefs.setStringList('departments', _departments);

    if (_currentBackgroundPath != null) {
      await prefs.setString('currentBackgroundPath', _currentBackgroundPath!);
    } else {
      await prefs.remove('currentBackgroundPath');
    }
  }

  String? login(String username, String password) {
    if (username == 'admin' && password == _adminPassword) {
      _isAuthenticated = true;
      _currentUserRole = 'admin';
      _currentUserName = 'Administrator';
      _currentUserId = 'admin';
      notifyListeners();
      return null;
    }

    try {
      final teacher = _teachers.firstWhere((t) => t.name == username);
      if (teacher.password == password) {
        _isAuthenticated = true;
        _currentUserRole = 'teacher';
        _currentUserName = teacher.name;
        _currentUserId = teacher.id;
        final index = _teachers.indexWhere((t) => t.id == teacher.id);
        if (index != -1) {
          _teachers[index] = Teacher(
            id: teacher.id,
            name: teacher.name,
            role: teacher.role,
            initials: teacher.initials,
            avatarColor: teacher.avatarColor,
            department: teacher.department,
            isOnline: true,
            password: teacher.password,
            backgroundPath: teacher.backgroundPath,
          );
          _currentBackgroundPath = teacher.backgroundPath;
          _saveData();
        }
        notifyListeners();
        return null;
      }
    } catch (e) {}

    return 'Invalid credentials';
  }

  void loginViaBiometrics() {
    _isAuthenticated = true;
    _currentUserRole = 'admin';
    _currentUserName = 'Administrator';
    _currentUserId = 'admin';
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _currentUserRole = '';
    _currentUserName = '';
    _currentUserId = '';
    notifyListeners();
  }

  void registerTeacher(
    String name,
    String subject,
    String password, {
    String department = 'General',
  }) {
    if (_teachers.any((t) => t.name == name)) {
      throw Exception('User already exists');
    }

    addTeacher(name, subject, password: password, department: department);
  }

  void updateTeacher(Teacher teacher) {
    final index = _teachers.indexWhere((t) => t.id == teacher.id);
    if (index != -1) {
      _teachers[index] = teacher;

      // If the updated teacher is the current user, update session info
      if (_currentUserId == teacher.id) {
        _currentUserName = teacher.name;
      }

      _saveData();
      notifyListeners();
    }
  }

  void updateProfile({String? name, String? password, String? department}) {
    if (_currentUserRole == 'admin') {
      if (password != null && password.isNotEmpty) {
        _adminPassword = password;
      }

      _saveData();
      notifyListeners();
    } else {
      final index = _teachers.indexWhere((t) => t.name == _currentUserName);
      if (index != -1) {
        final t = _teachers[index];
        _teachers[index] = Teacher(
          id: t.id,
          name: name ?? t.name,
          role: t.role,
          initials: t.initials,
          avatarColor: t.avatarColor,
          department: department ?? t.department,
          isOnline: t.isOnline,
          password: password ?? t.password,
          backgroundPath: t.backgroundPath,
        );

        if (name != null) {
          _currentUserName = name;
          _currentUserId =
              t.id; // Ensure ID matches, though it shouldn't change
        }

        _saveData();
        notifyListeners();
      }
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveData();
    notifyListeners();
  }

  void switchLanguage() {
    _locale = _locale.languageCode == 'en'
        ? const Locale('es')
        : const Locale('en');
    _saveData();
    notifyListeners();
  }

  void toggleView() {
    _is7DayView = !_is7DayView;
    _saveData();
    notifyListeners();
  }

  void updateFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void addTeacher(
    String name,
    String role, {
    String password = '1234',
    String department = 'General',
  }) {
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
    final color =
        Colors.primaries[name.length % Colors.primaries.length].shade100;

    _teachers.add(
      Teacher(
        id: _uuid.v4(),
        name: name,
        role: role,
        initials: initials,
        avatarColor: color,
        department: department,
        isOnline: true,
        password: password,
      ),
    );
    _saveData();
    notifyListeners();
  }

  void deleteTeacher(String id) {
    _teachers.removeWhere((t) => t.id == id);
    _shifts.removeWhere((s) => s.teacherId == id);
    _saveData();
    notifyListeners();
  }

  void addShift(
    String teacherId,
    DateTime date,
    String startTime,
    String endTime,
    String subject,
  ) {
    final teacher = _teachers.firstWhere(
      (t) => t.id == teacherId,
      orElse: () => _teachers.first,
    );

    _shifts.add(
      Shift(
        id: _uuid.v4(),
        teacherId: teacher.id,
        teacherName: teacher.name,
        date: date,
        startTime: startTime,
        endTime: endTime,
        subject: subject,
        color: Colors.blue.shade100,
      ),
    );
    _saveData();
    notifyListeners();
  }

  void deleteShift(String id) {
    _shifts.removeWhere((s) => s.id == id);
    _saveData();
    notifyListeners();
  }

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  void addLocalizedNotification(
    String titleKey,
    String messageKey, {
    Map<String, String>? args,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        title: AppStrings.get('en', titleKey, args),
        message: AppStrings.get('en', messageKey, args),
        timestamp: DateTime.now(),
        titleKey: titleKey,
        messageKey: messageKey,
        args: args,
      ),
    );
    _saveData();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _saveData();
    notifyListeners();
  }

  void requestAbsence(
    String teacherId,
    DateTime start,
    DateTime end,
    AbsenceType type,
  ) {
    final teacher = _teachers.firstWhere((t) => t.id == teacherId);
    _absences.add(
      Absence(
        id: _uuid.v4(),
        teacherId: teacher.id,
        teacherName: teacher.name,
        startDate: start,
        endDate: end,
        type: type,
      ),
    );

    addLocalizedNotification(
      'notification_new_request_title',
      'notification_new_request_body',
      args: {'name': teacher.name},
    );

    _saveData();
    notifyListeners();
  }

  void updateAbsenceStatus(String id, AbsenceStatus status) {
    final index = _absences.indexWhere((a) => a.id == id);
    if (index != -1) {
      _absences[index].status = status;

      addLocalizedNotification(
        'notification_request_updated_title',
        'notification_request_updated_body',
        args: {'name': _absences[index].teacherName, 'status': status.name},
      );

      _saveData();
      notifyListeners();
    }
  }

  void dispose() {
    super.dispose();
  }

  void deleteAbsence(String id) {
    _absences.removeWhere((a) => a.id == id);
    _saveData();
    notifyListeners();
  }

  void addStudent(String name, String grade, String email, DateTime dob) {
    _students.add(
      Student(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        grade: grade,
        parentEmail: email,
        avatarColor:
            Colors.primaries[_students.length % Colors.primaries.length],
        dateOfBirth: dob,
      ),
    );
    _saveData();
    notifyListeners();
  }

  void updateStudent(
    String id,
    String name,
    String grade,
    String email,
    DateTime dob,
  ) {
    final index = _students.indexWhere((s) => s.id == id);
    if (index != -1) {
      _students[index] = Student(
        id: id,
        name: name,
        grade: grade,
        parentEmail: email,
        avatarColor: _students[index].avatarColor,
        dateOfBirth: dob,
      );
      _saveData();
      notifyListeners();
    }
  }

  void deleteStudent(String id) {
    _students.removeWhere((s) => s.id == id);
    _saveData();
    notifyListeners();
  }

  void addDepartment(String name) {
    if (!_departments.contains(name)) {
      _departments.add(name);
      _saveData();
      notifyListeners();
    }
  }

  void removeDepartment(String name) {
    if (_departments.length > 1 && _departments.contains(name)) {
      _departments.remove(name);
      _saveData();
      notifyListeners();
    }
  }

  final List<DateTime> _holidays = [
    DateTime(2025, 1, 1),
    DateTime(2025, 1, 2),
    DateTime(2025, 1, 6),
    DateTime(2025, 2, 28),
    DateTime(2025, 4, 17),
    DateTime(2025, 4, 18),
    DateTime(2025, 5, 1),
    DateTime(2025, 6, 19),
    DateTime(2025, 8, 15),
    DateTime(2025, 10, 12),
    DateTime(2025, 11, 1),
    DateTime(2025, 12, 6),
    DateTime(2025, 12, 8),
    DateTime(2025, 12, 25),
  ];

  bool isHoliday(DateTime date) {
    return _holidays.any(
      (h) => h.year == date.year && h.month == date.month && h.day == date.day,
    );
  }

  String? getHolidayName(DateTime date) {
    if (date.month == 1 && date.day == 1) return 'Año Nuevo';
    if (date.month == 1 && date.day == 2) return 'Toma de Granada';
    if (date.month == 1 && date.day == 6) return 'Día de Reyes';
    if (date.month == 2 && date.day == 28) return 'Día de Andalucía';
    if (date.month == 4 && date.day == 17) return 'Jueves Santo';
    if (date.month == 4 && date.day == 18) return 'Viernes Santo';
    if (date.month == 5 && date.day == 1) return 'Fiesta del Trabajo';
    if (date.month == 6 && date.day == 19) return 'Corpus Christi';
    if (date.month == 8 && date.day == 15) return 'Asunción';
    if (date.month == 10 && date.day == 12) return 'Fiesta Nacional';
    if (date.month == 11 && date.day == 1) return 'Todos los Santos';
    if (date.month == 12 && date.day == 6) return 'Constitución';
    if (date.month == 12 && date.day == 8) return 'Inmaculada';
    if (date.month == 12 && date.day == 25) return 'Navidad';
    return 'Festivo';
  }

  void _seedData() {}

  void hardReset() {
    _shifts.clear();
    _absences.clear();
    _seedData();
    _saveData();
    notifyListeners();
  }

  Future<void> _loadBackgrounds() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final bgDir = Directory('${appDir.path}/custom_backgrounds');
      if (!bgDir.existsSync()) {
        bgDir.createSync(recursive: true);
      }

      _availableBackgrounds.clear();
      await for (final entity in bgDir.list()) {
        if (entity is File) {
          final lower = entity.path.toLowerCase();
          if (lower.endsWith('.jpg') ||
              lower.endsWith('.png') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.gif')) {
            _availableBackgrounds.add(entity.path);
          }
        }
      }

      try {
        // Try to load asset manifest to find default backgrounds
        final manifestContent = await rootBundle.loadString(
          'AssetManifest.json',
        );
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        final backgroundAssets = manifestMap.keys
            .where((String key) => key.startsWith('assets/backgrounds/'))
            .toList();

        _availableBackgrounds.addAll(backgroundAssets);
      } catch (e) {
        print('Note: No default assets loaded from AssetManifest.json ($e)');
        // Fallback: Hardcoded list of default backgrounds to ensure they show up
        // even if AssetManifest is missing (e.g. build issues).
        final hardcodedDefaults = [
          'assets/backgrounds/fondo1.jpg',
          'assets/backgrounds/fondo2.jpg',
          'assets/backgrounds/fondo3.jpg',
          'assets/backgrounds/fondo4.jpg',
          'assets/backgrounds/fondo5.jpg',
          'assets/backgrounds/fondo6.gif',
          'assets/backgrounds/fondo7.gif',
          'assets/backgrounds/fondo8.gif',
          'assets/backgrounds/fondo9.gif',
          'assets/backgrounds/fondo10.gif',
        ];
        _availableBackgrounds.addAll(hardcodedDefaults);
      }
    } catch (e) {
      print('Error loading backgrounds: $e');
    }
  }

  Future<void> importBackground() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'gif'],
      );

      if (result != null && result.files.single.path != null) {
        final sourceFile = File(result.files.single.path!);
        final appDir = await getApplicationDocumentsDirectory();
        final bgDir = Directory('${appDir.path}/custom_backgrounds');
        if (!bgDir.existsSync()) {
          bgDir.createSync(recursive: true);
        }

        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        final targetFile = await sourceFile.copy('${bgDir.path}/$fileName');

        _availableBackgrounds.add(targetFile.path);
        _currentBackgroundPath = targetFile.path;
        _saveData();
        notifyListeners();
      }
    } catch (e) {
      print('Error importing background: $e');
      rethrow;
    }
  }

  void setBackground(String? path) {
    _currentBackgroundPath = path;

    // Save to user profile if logged in as teacher
    if (_isAuthenticated && _currentUserRole == 'teacher') {
      final index = _teachers.indexWhere((t) => t.id == _currentUserId);
      if (index != -1) {
        _teachers[index] = Teacher(
          id: _teachers[index].id,
          name: _teachers[index].name,
          role: _teachers[index].role,
          initials: _teachers[index].initials,
          avatarColor: _teachers[index].avatarColor,
          department: _teachers[index].department,
          isOnline: _teachers[index].isOnline,
          password: _teachers[index].password,
          backgroundPath: path,
        );
      }
    }

    _saveData();
    notifyListeners();
  }

  void deleteBackground(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
      _availableBackgrounds.remove(path);
      if (_currentBackgroundPath == path) {
        _currentBackgroundPath = null;
      }
      _saveData();
      notifyListeners();
    } catch (e) {
      print('Error deleting background: $e');
    }
  }
}
