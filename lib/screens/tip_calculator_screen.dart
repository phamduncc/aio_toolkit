import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_scaffold.dart';

class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  final _billCtrl = TextEditingController();
  double _tipPercent = 10;
  int _people = 2;
  final color = AppTheme.toolColors['tip']!;

  double get _bill => double.tryParse(_billCtrl.text) ?? 0;
  double get _tipAmount => _bill * _tipPercent / 100;
  double get _total => _bill + _tipAmount;
  double get _perPerson => _people > 0 ? _total / _people : 0;
  double get _tipPerPerson => _people > 0 ? _tipAmount / _people : 0;

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)} triệu';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Chia tiền',
      color: color,
      icon: Icons.receipt_long_rounded,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _InputCard(
              color: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _billCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      labelText: 'Tổng hóa đơn',
                      prefixText: '₫ ',
                      prefixStyle: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 22),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Tiền tip: ${_tipPercent.toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: color,
                      thumbColor: color,
                      inactiveTrackColor: color.withAlpha(40),
                      overlayColor: color.withAlpha(30),
                    ),
                    child: Slider(
                      value: _tipPercent,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      onChanged: (v) => setState(() => _tipPercent = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [0, 5, 10, 15, 20, 25, 30]
                        .map((p) => GestureDetector(
                              onTap: () => setState(() => _tipPercent = p.toDouble()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _tipPercent == p ? color.withAlpha(20) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: _tipPercent == p ? Border.all(color: color.withAlpha(80)) : null,
                                ),
                                child: Text('$p%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _tipPercent == p ? color : AppTheme.textSecondary,
                                    )),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text('Số người:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const Spacer(),
                      _StepBtn(icon: Icons.remove_rounded, onTap: () { if (_people > 1) setState(() => _people--); }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_people', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
                      ),
                      _StepBtn(icon: Icons.add_rounded, onTap: () => setState(() => _people++)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_bill > 0) ...[
              _ResultGrid(
                items: [
                  _ResultItem('Tiền tip', _fmt(_tipAmount), color),
                  _ResultItem('Tổng cộng', _fmt(_total), color),
                  _ResultItem('Tip / người', _fmt(_tipPerPerson), Colors.purple),
                  _ResultItem('Mỗi người trả', _fmt(_perPerson), Colors.green),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withAlpha(12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withAlpha(40)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hóa đơn gốc:', style: TextStyle(fontSize: 14)),
                        Text('₫${_fmt(_bill)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tip (${_tipPercent.toInt()}%):', style: const TextStyle(fontSize: 14)),
                        Text('+₫${_fmt(_tipAmount)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_people người × ₫${_fmt(_perPerson)}:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('₫${_fmt(_total)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final Color color;
  final Widget child;
  const _InputCard({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppTheme.textSecondary),
      ),
    );
  }
}

class _ResultItem {
  final String label;
  final String value;
  final Color color;
  const _ResultItem(this.label, this.value, this.color);
}

class _ResultGrid extends StatelessWidget {
  final List<_ResultItem> items;
  const _ResultGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: items.map((item) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.color.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            Text(
              '₫${item.value}',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: item.color),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
