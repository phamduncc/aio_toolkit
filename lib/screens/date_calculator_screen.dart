import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_scaffold.dart';

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.toolColors['date']!;
    return ToolScaffold(
      title: 'Tính ngày',
      color: color,
      icon: Icons.calendar_today_rounded,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: color,
            labelColor: color,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'Khoảng cách'),
              Tab(text: 'Cộng/trừ ngày'),
              Tab(text: 'Ngày làm việc'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _DateDiffTab(),
                _DateAddTab(),
                _WorkdaysTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDiffTab extends StatefulWidget {
  const _DateDiffTab();

  @override
  State<_DateDiffTab> createState() => _DateDiffTabState();
}

class _DateDiffTabState extends State<_DateDiffTab> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  final _fmt = DateFormat('dd/MM/yyyy');

  int get _days => _to.difference(_from).inDays.abs();
  int get _weeks => _days ~/ 7;
  int get _months {
    final a = _from.isBefore(_to) ? _from : _to;
    final b = _from.isBefore(_to) ? _to : _from;
    return (b.year - a.year) * 12 + b.month - a.month;
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.toolColors['date']!;
    final isPositive = _to.isAfter(_from) || _to == _from;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _DateCard(
            color: color,
            child: Column(
              children: [
                _DatePicker(
                  label: 'Ngày bắt đầu',
                  date: _from,
                  color: color,
                  onTap: () => _pickDate(true),
                  fmt: _fmt,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Icon(Icons.arrow_downward_rounded,
                      color: AppTheme.textSecondary),
                ),
                _DatePicker(
                  label: 'Ngày kết thúc',
                  date: _to,
                  color: color,
                  onTap: () => _pickDate(false),
                  fmt: _fmt,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(label: 'Ngày', value: '$_days', color: color),
              const SizedBox(width: 10),
              _StatBox(label: 'Tuần', value: '$_weeks', color: color),
              const SizedBox(width: 10),
              _StatBox(label: 'Tháng', value: '~$_months', color: color),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  isPositive
                      ? '${_fmt.format(_from)} → ${_fmt.format(_to)}'
                      : '${_fmt.format(_to)} → ${_fmt.format(_from)}',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_days ngày | $_weeks tuần $_days % 7 ngày',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _getDayLabel(),
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel() {
    if (_days == 0) return 'Cùng một ngày';
    if (_days < 7) return 'Chưa đầy 1 tuần';
    if (_days < 30) return 'Khoảng ${_days ~/ 7} tuần';
    if (_days < 365) return 'Khoảng ${_days ~/ 30} tháng';
    return 'Khoảng ${(_days / 365).toStringAsFixed(1)} năm';
  }
}

class _DateAddTab extends StatefulWidget {
  const _DateAddTab();

  @override
  State<_DateAddTab> createState() => _DateAddTabState();
}

class _DateAddTabState extends State<_DateAddTab> {
  DateTime _baseDate = DateTime.now();
  final _daysCtrl = TextEditingController(text: '0');
  final _monthsCtrl = TextEditingController(text: '0');
  final _yearsCtrl = TextEditingController(text: '0');
  bool _isAdd = true;
  final _fmtShort = DateFormat('dd/MM/yyyy');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _baseDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _baseDate = picked);
  }

  DateTime get _result {
    final d = int.tryParse(_daysCtrl.text) ?? 0;
    final m = int.tryParse(_monthsCtrl.text) ?? 0;
    final y = int.tryParse(_yearsCtrl.text) ?? 0;
    final mult = _isAdd ? 1 : -1;
    return DateTime(
      _baseDate.year + y * mult,
      _baseDate.month + m * mult,
      _baseDate.day + d * mult,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.toolColors['date']!;
    DateTime resultDate;
    try {
      resultDate = _result;
    } catch (_) {
      resultDate = DateTime.now();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _DateCard(
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ngày gốc',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: color.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            color: color, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _fmtShort.format(_baseDate),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: color),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _OpButton(
                        label: '+ Cộng',
                        selected: _isAdd,
                        onTap: () => setState(() => _isAdd = true),
                        color: Colors.green),
                    const SizedBox(width: 10),
                    _OpButton(
                        label: '- Trừ',
                        selected: !_isAdd,
                        onTap: () => setState(() => _isAdd = false),
                        color: Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _NumInput(
                            ctrl: _daysCtrl,
                            label: 'Ngày',
                            onChanged: (_) => setState(() {}))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _NumInput(
                            ctrl: _monthsCtrl,
                            label: 'Tháng',
                            onChanged: (_) => setState(() {}))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _NumInput(
                            ctrl: _yearsCtrl,
                            label: 'Năm',
                            onChanged: (_) => setState(() {}))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withAlpha(12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(50)),
            ),
            child: Column(
              children: [
                const Text('Kết quả',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text(
                  _fmtShort.format(resultDate),
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE', 'vi_VN').format(resultDate),
                  style: TextStyle(fontSize: 14, color: color.withAlpha(180)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkdaysTab extends StatefulWidget {
  const _WorkdaysTab();

  @override
  State<_WorkdaysTab> createState() => _WorkdaysTabState();
}

class _WorkdaysTabState extends State<_WorkdaysTab> {
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now().add(const Duration(days: 30));
  final _fmtShort = DateFormat('dd/MM/yyyy');
  bool _excludeSat = true;

  Future<void> _pick(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
      });
    }
  }

  int get _workdays {
    int count = 0;
    DateTime d = _from.isBefore(_to) ? _from : _to;
    final end = _from.isBefore(_to) ? _to : _from;
    while (d.isBefore(end) || d == end) {
      final wd = d.weekday;
      if (wd != DateTime.sunday &&
          (_excludeSat ? wd != DateTime.saturday : true)) {
        count++;
      }
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  int get _totalDays => _to.difference(_from).inDays.abs() + 1;
  int get _weekends => _totalDays - _workdays;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.toolColors['date']!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _DateCard(
            color: color,
            child: Column(
              children: [
                _DatePicker(
                    label: 'Từ ngày',
                    date: _from,
                    color: color,
                    onTap: () => _pick(true),
                    fmt: _fmtShort),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(Icons.arrow_downward_rounded,
                        color: AppTheme.textSecondary)),
                _DatePicker(
                    label: 'Đến ngày',
                    date: _to,
                    color: color,
                    onTap: () => _pick(false),
                    fmt: _fmtShort),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _excludeSat,
                      onChanged: (v) => setState(() => _excludeSat = v!),
                      activeColor: color,
                    ),
                    const Text('Không tính thứ 7',
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(label: 'Ngày làm', value: '$_workdays', color: color),
              const SizedBox(width: 10),
              _StatBox(
                  label: 'Cuối tuần',
                  value: '$_weekends',
                  color: Colors.orange),
              const SizedBox(width: 10),
              _StatBox(
                  label: 'Tổng ngày', value: '$_totalDays', color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime date;
  final Color color;
  final VoidCallback onTap;
  final DateFormat fmt;

  const _DatePicker(
      {required this.label,
      required this.date,
      required this.color,
      required this.onTap,
      required this.fmt});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: color, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                Text(fmt.format(date),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: color)),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_rounded, color: color.withAlpha(120), size: 16),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final Color color;
  final Widget child;
  const _DateCard({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(15),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _OpButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _OpButton(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withAlpha(20) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: color.withAlpha(80)) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? color : AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _NumInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final ValueChanged<String> onChanged;
  const _NumInput(
      {required this.ctrl, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      textAlign: TextAlign.center,
      decoration: InputDecoration(labelText: label, isDense: true),
    );
  }
}
