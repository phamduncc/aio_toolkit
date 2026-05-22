import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_scaffold.dart';

class PercentageScreen extends StatefulWidget {
  const PercentageScreen({super.key});

  @override
  State<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends State<PercentageScreen>
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
    final color = AppTheme.toolColors['percentage']!;
    return ToolScaffold(
      title: 'Percentage',
      color: color,
      icon: Icons.percent_rounded,
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
              Tab(text: 'X% of Y'),
              Tab(text: 'Increase/decrease'),
              Tab(text: 'Compare'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _PercentOfTab(),
                _PercentChangeTab(),
                _PercentCompareTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentOfTab extends StatefulWidget {
  const _PercentOfTab();

  @override
  State<_PercentOfTab> createState() => _PercentOfTabState();
}

class _PercentOfTabState extends State<_PercentOfTab> {
  final _pCtrl = TextEditingController();
  final _vCtrl = TextEditingController();
  String? _result;

  void _calc() {
    final p = double.tryParse(_pCtrl.text);
    final v = double.tryParse(_vCtrl.text);
    if (p == null || v == null) {
      setState(() => _result = null);
      return;
    }
    final r = p / 100 * v;
    setState(() => _result = '${_fmt(p)}% of ${_fmt(v)} = ${_fmt(r)}');
  }

  String _fmt(double v) => v == v.truncateToDouble()
      ? v.toInt().toString()
      : v
          .toStringAsFixed(4)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.toolColors['percentage']!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Calculate X% of Y',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => _calc(),
                        decoration: const InputDecoration(
                            labelText: 'X (percent)', suffixText: '%'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('of',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _vCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => _calc(),
                        decoration:
                            const InputDecoration(labelText: 'Y (value)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_result != null)
                  ResultCard(result: _result!, color: color, label: 'Result'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick examples',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 10),
                ...[
                  ['10% of 500', '= 50'],
                  ['20% of 250', '= 50'],
                  ['15% of 200', '= 30'],
                ].map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e[0],
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13)),
                          Text(e[1],
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                  fontSize: 13)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentChangeTab extends StatefulWidget {
  const _PercentChangeTab();

  @override
  State<_PercentChangeTab> createState() => _PercentChangeTabState();
}

class _PercentChangeTabState extends State<_PercentChangeTab> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  String? _result;
  bool? _isIncrease;

  void _calc() {
    final from = double.tryParse(_fromCtrl.text);
    final to = double.tryParse(_toCtrl.text);
    if (from == null || to == null || from == 0) {
      setState(() {
        _result = null;
        _isIncrease = null;
      });
      return;
    }
    final change = (to - from) / from * 100;
    setState(() {
      _isIncrease = change >= 0;
      _result = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Calculate percent change',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fromCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => _calc(),
                        decoration:
                            const InputDecoration(labelText: 'Original value'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: AppTheme.textSecondary),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _toCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => _calc(),
                        decoration:
                            const InputDecoration(labelText: 'New value'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_result != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (_isIncrease! ? Colors.green : Colors.red)
                          .withAlpha(15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (_isIncrease! ? Colors.green : Colors.red)
                            .withAlpha(60),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _isIncrease!
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: _isIncrease! ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _isIncrease! ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isIncrease! ? 'Increase' : 'Decrease',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isIncrease! ? Colors.green : Colors.red,
                          ),
                        ),
                        if (_fromCtrl.text.isNotEmpty &&
                            _toCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${_fromCtrl.text} → ${_toCtrl.text}',
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Value after increase/decrease %',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                _QuickPercentAdjust(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPercentAdjust extends StatefulWidget {
  @override
  State<_QuickPercentAdjust> createState() => _QuickPercentAdjustState();
}

class _QuickPercentAdjustState extends State<_QuickPercentAdjust> {
  final _vCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  String? _incResult;
  String? _decResult;

  void _calc() {
    final v = double.tryParse(_vCtrl.text);
    final p = double.tryParse(_pCtrl.text);
    if (v == null || p == null) {
      setState(() {
        _incResult = null;
        _decResult = null;
      });
      return;
    }
    final inc = v * (1 + p / 100);
    final dec = v * (1 - p / 100);
    setState(() {
      _incResult = inc.toStringAsFixed(2);
      _decResult = dec.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _vCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _calc(),
                decoration:
                    const InputDecoration(labelText: 'Value', isDense: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _pCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _calc(),
                decoration: const InputDecoration(
                    labelText: 'Percent', suffixText: '%', isDense: true),
              ),
            ),
          ],
        ),
        if (_incResult != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.green.withAlpha(15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      const Text('After increase',
                          style: TextStyle(fontSize: 11, color: Colors.green)),
                      Text(_incResult!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.red.withAlpha(15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      const Text('After decrease',
                          style: TextStyle(fontSize: 11, color: Colors.red)),
                      Text(_decResult!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PercentCompareTab extends StatefulWidget {
  const _PercentCompareTab();

  @override
  State<_PercentCompareTab> createState() => _PercentCompareTabState();
}

class _PercentCompareTabState extends State<_PercentCompareTab> {
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  String? _result;
  String? _aOfB;
  String? _bOfA;

  void _calc() {
    final a = double.tryParse(_aCtrl.text);
    final b = double.tryParse(_bCtrl.text);
    if (a == null || b == null || b == 0) {
      setState(() {
        _result = null;
        _aOfB = null;
        _bOfA = null;
      });
      return;
    }
    final diff = (a - b).abs();
    final pct = diff / b * 100;
    setState(() {
      _result = a > b
          ? 'A is ${pct.toStringAsFixed(2)}% greater than B'
          : a < b
              ? 'A is ${pct.toStringAsFixed(2)}% less than B'
              : 'A equals B';
      _aOfB = a != 0 ? '${(b / a * 100).toStringAsFixed(2)}%' : null;
      _bOfA = '${(a / b * 100).toStringAsFixed(2)}%';
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.toolColors['percentage']!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Compare two values',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calc(),
                    decoration: const InputDecoration(labelText: 'Value A'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('vs',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.textSecondary)),
                ),
                Expanded(
                  child: TextField(
                    controller: _bCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calc(),
                    decoration: const InputDecoration(labelText: 'Value B'),
                  ),
                ),
              ],
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              ResultCard(result: _result!, color: color),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_aOfB != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: color.withAlpha(10),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Text('B is $_aOfB of A',
                                style: TextStyle(fontSize: 12, color: color)),
                          ],
                        ),
                      ),
                    ),
                  if (_aOfB != null) const SizedBox(width: 8),
                  if (_bOfA != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: color.withAlpha(10),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Text('A is $_bOfA of B',
                                style: TextStyle(fontSize: 12, color: color)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

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
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}
