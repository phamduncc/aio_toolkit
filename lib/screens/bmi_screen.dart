import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_scaffold.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  double? _bmi;
  bool _isMetric = true;
  final color = AppTheme.toolColors['bmi']!;

  void _calc() {
    final w = double.tryParse(_weightCtrl.text);
    final h = double.tryParse(_heightCtrl.text);
    if (w == null || h == null || h == 0) {
      setState(() => _bmi = null);
      return;
    }
    double weightKg = w;
    double heightM = h;
    if (_isMetric) {
      heightM = h / 100;
    } else {
      weightKg = w * 0.453592;
      heightM = h * 0.0254;
    }
    setState(() => _bmi = weightKg / (heightM * heightM));
  }

  String get _category {
    if (_bmi == null) return '';
    if (_bmi! < 18.5) return 'Thiếu cân';
    if (_bmi! < 25) return 'Bình thường';
    if (_bmi! < 30) return 'Thừa cân';
    if (_bmi! < 35) return 'Béo phì độ I';
    if (_bmi! < 40) return 'Béo phì độ II';
    return 'Béo phì độ III';
  }

  Color get _categoryColor {
    if (_bmi == null) return color;
    if (_bmi! < 18.5) return Colors.blue;
    if (_bmi! < 25) return Colors.green;
    if (_bmi! < 30) return Colors.orange;
    return Colors.red;
  }

  String get _advice {
    if (_bmi == null) return '';
    if (_bmi! < 18.5) return 'Bạn nên tăng cường dinh dưỡng và tập thể dục đều đặn.';
    if (_bmi! < 25) return 'Tuyệt vời! Hãy duy trì lối sống lành mạnh này.';
    if (_bmi! < 30) return 'Nên tăng cường vận động và điều chỉnh chế độ ăn uống.';
    return 'Hãy tham khảo ý kiến bác sĩ để có kế hoạch giảm cân phù hợp.';
  }

  double get _idealWeightMin {
    final h = double.tryParse(_heightCtrl.text) ?? 0;
    if (h == 0) return 0;
    final hm = _isMetric ? h / 100 : h * 0.0254;
    return 18.5 * hm * hm * (_isMetric ? 1 : 2.20462);
  }

  double get _idealWeightMax {
    final h = double.tryParse(_heightCtrl.text) ?? 0;
    if (h == 0) return 0;
    final hm = _isMetric ? h / 100 : h * 0.0254;
    return 24.9 * hm * hm * (_isMetric ? 1 : 2.20462);
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Chỉ số BMI',
      color: color,
      icon: Icons.monitor_weight_outlined,
      child: SingleChildScrollView(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Đơn vị:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      _UnitToggle(
                        labels: const ['Metric (kg/cm)', 'Imperial (lb/in)'],
                        selected: _isMetric ? 0 : 1,
                        color: color,
                        onChanged: (i) { setState(() { _isMetric = i == 0; _bmi = null; }); },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _calc(),
                          decoration: InputDecoration(
                            labelText: 'Cân nặng',
                            suffixText: _isMetric ? 'kg' : 'lb',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _calc(),
                          decoration: InputDecoration(
                            labelText: 'Chiều cao',
                            suffixText: _isMetric ? 'cm' : 'in',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_bmi != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: _categoryColor.withAlpha(25), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  children: [
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: _categoryColor,
                        letterSpacing: -2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _categoryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _category,
                        style: TextStyle(color: _categoryColor, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BmiScale(bmi: _bmi!),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: _categoryColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _advice,
                              style: TextStyle(fontSize: 13, color: _categoryColor.withAlpha(200)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_idealWeightMin > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Cân nặng lý tưởng: ${_idealWeightMin.toStringAsFixed(1)} – ${_idealWeightMax.toStringAsFixed(1)} ${_isMetric ? "kg" : "lb"}',
                        style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _BmiReferenceTable(),
          ],
        ),
      ),
    );
  }
}

class _BmiScale extends StatelessWidget {
  final double bmi;
  const _BmiScale({required this.bmi});

  @override
  Widget build(BuildContext context) {
    final clampedBmi = bmi.clamp(10.0, 45.0);
    final position = (clampedBmi - 10) / 35;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(colors: [
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.red,
                  Colors.deepOrange,
                ]),
              ),
            ),
            Positioned(
              left: (position * (MediaQuery.of(context).size.width - 80)).clamp(0, MediaQuery.of(context).size.width - 80),
              top: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            Text('18.5', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            Text('25', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            Text('30', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            Text('45', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _BmiReferenceTable extends StatelessWidget {
  final List<List<String>> _rows = const [
    ['< 18.5', 'Thiếu cân', '🔵'],
    ['18.5 – 24.9', 'Bình thường', '🟢'],
    ['25 – 29.9', 'Thừa cân', '🟠'],
    ['30 – 34.9', 'Béo phì độ I', '🔴'],
    ['≥ 35', 'Béo phì độ II+', '🔴'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bảng phân loại BMI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          ..._rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Text(r[2], style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    SizedBox(width: 90, child: Text(r[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    Text(r[1], style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final Color color;
  final ValueChanged<int> onChanged;

  const _UnitToggle({required this.labels, required this.selected, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) => GestureDetector(
        onTap: () => onChanged(i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: EdgeInsets.only(right: i < labels.length - 1 ? 6 : 0),
          decoration: BoxDecoration(
            color: selected == i ? color.withAlpha(20) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: selected == i ? Border.all(color: color.withAlpha(80)) : null,
          ),
          child: Text(
            labels[i],
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected == i ? color : AppTheme.textSecondary),
          ),
        ),
      )),
    );
  }
}
