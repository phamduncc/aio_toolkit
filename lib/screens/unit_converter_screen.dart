import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_scaffold.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Unit Converter',
      color: AppTheme.toolColors['converter']!,
      icon: Icons.swap_horiz_rounded,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.toolColors['converter']!,
            labelColor: AppTheme.toolColors['converter']!,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'Mass'),
              Tab(text: 'Length'),
              Tab(text: 'Temperature'),
              Tab(text: 'Area'),
              Tab(text: 'Volume'),
              Tab(text: 'Currency'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ConverterTab(type: 'weight'),
                _ConverterTab(type: 'length'),
                _ConverterTab(type: 'temperature'),
                _ConverterTab(type: 'area'),
                _ConverterTab(type: 'volume'),
                _ConverterTab(type: 'currency'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConverterTab extends StatefulWidget {
  final String type;
  const _ConverterTab({required this.type});

  @override
  State<_ConverterTab> createState() => _ConverterTabState();
}

class _ConverterTabState extends State<_ConverterTab> {
  final TextEditingController _fromCtrl = TextEditingController();
  String _fromUnit = '';
  String _toUnit = '';
  double? _result;

  static const Map<String, List<String>> _units = {
    'weight': ['kg', 'g', 'mg', 'lb', 'oz', 'ton'],
    'length': ['m', 'km', 'cm', 'mm', 'inch', 'ft', 'yard', 'mile'],
    'temperature': ['°C', '°F', 'K'],
    'area': ['m²', 'km²', 'cm²', 'ha', 'ft²', 'acre'],
    'volume': ['L', 'mL', 'm³', 'cm³', 'gallon', 'fl oz'],
    'currency': ['VND', 'USD', 'EUR', 'JPY', 'KRW', 'GBP', 'CNY', 'THB'],
  };

  static const Map<String, Map<String, double>> _ratesVnd = {
    'VND': {'VND': 1, 'USD': 1/25450.0, 'EUR': 1/27300.0, 'JPY': 1/170.0, 'KRW': 1/19.0, 'GBP': 1/32200.0, 'CNY': 1/3510.0, 'THB': 1/710.0},
    'USD': {'VND': 25450, 'USD': 1, 'EUR': 1/1.073, 'JPY': 149.5, 'KRW': 1340.0, 'GBP': 0.789, 'CNY': 7.24, 'THB': 35.8},
    'EUR': {'VND': 27300, 'USD': 1.073, 'EUR': 1, 'JPY': 160.5, 'KRW': 1438.0, 'GBP': 0.847, 'CNY': 7.77, 'THB': 38.4},
    'JPY': {'VND': 170, 'USD': 0.0067, 'EUR': 0.0062, 'JPY': 1, 'KRW': 8.97, 'GBP': 0.0053, 'CNY': 0.048, 'THB': 0.24},
    'KRW': {'VND': 19, 'USD': 0.00075, 'EUR': 0.00069, 'JPY': 0.111, 'KRW': 1, 'GBP': 0.00059, 'CNY': 0.0054, 'THB': 0.027},
    'GBP': {'VND': 32200, 'USD': 1.267, 'EUR': 1.181, 'JPY': 189.5, 'KRW': 1697, 'GBP': 1, 'CNY': 9.18, 'THB': 45.4},
    'CNY': {'VND': 3510, 'USD': 0.138, 'EUR': 0.129, 'JPY': 20.65, 'KRW': 185, 'GBP': 0.109, 'CNY': 1, 'THB': 4.95},
    'THB': {'VND': 710, 'USD': 0.0279, 'EUR': 0.026, 'JPY': 4.17, 'KRW': 37.4, 'GBP': 0.022, 'CNY': 0.202, 'THB': 1},
  };

  @override
  void initState() {
    super.initState();
    final units = _units[widget.type]!;
    _fromUnit = units[0];
    _toUnit = units.length > 1 ? units[1] : units[0];
  }

  double _convert(double val, String from, String to) {
    if (widget.type == 'temperature') return _convertTemp(val, from, to);
    if (widget.type == 'currency') {
      final fromRates = _ratesVnd[from];
      if (fromRates == null) return val;
      return val * (fromRates[to] ?? 1.0);
    }
    final toBase = _toBaseRate(from);
    final fromBase = _toBaseRate(to);
    if (toBase == 0 || fromBase == 0) return val;
    return val * toBase / fromBase;
  }

  double _toBaseRate(String unit) {
    switch (widget.type) {
      case 'weight':
        switch (unit) {
          case 'kg': return 1;
          case 'g': return 0.001;
          case 'mg': return 0.000001;
          case 'lb': return 0.453592;
          case 'oz': return 0.0283495;
          case 'ton': return 1000;
        }
      case 'length':
        switch (unit) {
          case 'm': return 1;
          case 'km': return 1000;
          case 'cm': return 0.01;
          case 'mm': return 0.001;
          case 'inch': return 0.0254;
          case 'ft': return 0.3048;
          case 'yard': return 0.9144;
          case 'mile': return 1609.34;
        }
      case 'area':
        switch (unit) {
          case 'm²': return 1;
          case 'km²': return 1e6;
          case 'cm²': return 0.0001;
          case 'ha': return 10000;
          case 'ft²': return 0.092903;
          case 'acre': return 4046.86;
        }
      case 'volume':
        switch (unit) {
          case 'L': return 1;
          case 'mL': return 0.001;
          case 'm³': return 1000;
          case 'cm³': return 0.001;
          case 'gallon': return 3.78541;
          case 'fl oz': return 0.0295735;
        }
    }
    return 1;
  }

  double _convertTemp(double val, String from, String to) {
    double celsius;
    switch (from) {
      case '°C': celsius = val; break;
      case '°F': celsius = (val - 32) * 5 / 9; break;
      case 'K': celsius = val - 273.15; break;
      default: celsius = val;
    }
    switch (to) {
      case '°C': return celsius;
      case '°F': return celsius * 9 / 5 + 32;
      case 'K': return celsius + 273.15;
      default: return celsius;
    }
  }

  void _calculate() {
    final val = double.tryParse(_fromCtrl.text);
    if (val == null) {
      setState(() => _result = null);
      return;
    }
    setState(() => _result = _convert(val, _fromUnit, _toUnit));
  }

  void _swap() {
    setState(() {
      final tmp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tmp;
      if (_result != null) {
        _fromCtrl.text = _formatNum(_result!);
        _calculate();
      }
    });
  }

  String _formatNum(double v) {
    if (v.abs() >= 1e9) return v.toStringAsExponential(4);
    if (v.abs() < 0.0001 && v != 0) return v.toStringAsExponential(4);
    final s = v.toStringAsFixed(6);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final units = _units[widget.type]!;
    final color = AppTheme.toolColors['converter']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: color.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _UnitRow(
                  label: 'From',
                  units: units,
                  selected: _fromUnit,
                  onChanged: (v) { setState(() { _fromUnit = v!; _calculate(); }); },
                  controller: _fromCtrl,
                  onInput: (_) => _calculate(),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _swap,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.swap_vert_rounded, color: color, size: 22),
                  ),
                ),
                const SizedBox(height: 12),
                _UnitRow(
                  label: 'To',
                  units: units,
                  selected: _toUnit,
                  onChanged: (v) { setState(() { _toUnit = v!; _calculate(); }); },
                  controller: null,
                  onInput: null,
                  resultValue: _result != null ? _formatNum(_result!) : null,
                ),
              ],
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withAlpha(50)),
              ),
              child: Column(
                children: [
                  Text(
                    '${_fromCtrl.text} $_fromUnit = ${_formatNum(_result!)} $_toUnit',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _fromCtrl.clear();
                setState(() => _result = null);
              },
              icon: const Icon(Icons.clear_rounded, size: 18),
              label: const Text('Clear'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  final String label;
  final List<String> units;
  final String selected;
  final ValueChanged<String?> onChanged;
  final TextEditingController? controller;
  final ValueChanged<String>? onInput;
  final String? resultValue;

  const _UnitRow({
    required this.label,
    required this.units,
    required this.selected,
    required this.onChanged,
    required this.controller,
    required this.onInput,
    this.resultValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: controller != null
              ? TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  onChanged: onInput,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(fontSize: 13),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        resultValue ?? '—',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              items: units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
