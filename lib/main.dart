import 'package:flutter/material.dart';
import 'dadata_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Темная тема по умолчанию

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Отключение Debug Banner
      title: 'DaData App',
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomePage(onToggleTheme: _toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({required this.onToggleTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _dadataService = DaDataService();
  Map<String, dynamic>? _organizationInfo;
  bool _isLoading = false;
  bool _showAdvanced = false;

  Future<void> _fetchOrganizationInfo() async {
    setState(() {
      _isLoading = true;
      _organizationInfo = null;
      _showAdvanced = false;
    });
    final info = await _dadataService.getOrganizationInfo(_controller.text);
    setState(() {
      _isLoading = false;
      _organizationInfo = info;
    });
  }

  void _toggleAdvancedSearch() {
    setState(() {
      _showAdvanced = !_showAdvanced;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('DaData ИНН Поиск'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Введите ИНН',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchOrganizationInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Поиск'),
              ),
              if (_organizationInfo != null)
                Column(
                  children: [
                    SizedBox(height: 16),
                    _buildBasicInfo(context, textColor),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _toggleAdvancedSearch,
                      child: Text(_showAdvanced
                          ? 'Скрыть расширенный поиск'
                          : 'Расширенный поиск'),
                    ),
                    if (_showAdvanced) ...[
                      SizedBox(height: 16),
                      _buildAdvancedInfo(context, textColor),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context, Color textColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Название', _organizationInfo?['name']['full_with_opf'],
                Icons.business, textColor),
            _buildDivider(),
            _buildInfoRow('Адрес', _organizationInfo?['address']['value'],
                Icons.location_on, textColor),
            _buildDivider(),
            _buildInfoRow('ИНН', _organizationInfo?['inn'], Icons.numbers, textColor),
            _buildDivider(),
            _buildInfoRow('КПП', _organizationInfo?['kpp'], Icons.badge, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedInfo(BuildContext context, Color textColor) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow('ОГРН', _organizationInfo?['ogrn'], Icons.article, textColor),
      _buildDivider(),
      _buildInfoRow('Дата регистрации',
          _organizationInfo?['state']?['registration_date'], Icons.event, textColor),
      _buildDivider(),
      _buildInfoRow('Статус',
          _organizationInfo?['state']?['status'], Icons.info, textColor),
      _buildDivider(),
      _buildInfoRow('Тип организации',
          _organizationInfo?['opf']?['short'], Icons.apartment, textColor),
      _buildDivider(),
      _buildInfoRow('Руководитель',
          _organizationInfo?['management']?['name'], Icons.person, textColor),
      _buildDivider(),
      _buildInfoRow('Должность руководителя',
          _organizationInfo?['management']?['post'], Icons.work, textColor),
            ],
          ),
        ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value, IconData icon, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: textColor),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value?.toString() ?? 'Не указано', // Использование .toString()
                style: TextStyle(
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey,
      height: 20,
      thickness: 1,
    );
  }
}

