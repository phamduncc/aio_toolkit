import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_scaffold.dart';

class RandomScreen extends StatefulWidget {
  const RandomScreen({super.key});

  @override
  State<RandomScreen> createState() => _RandomScreenState();
}

class _RandomScreenState extends State<RandomScreen>
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
    final color = AppTheme.toolColors['random']!;
    return ToolScaffold(
      title: 'Số ngẫu nhiên',
      color: color,
      icon: Icons.casino_rounded,
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
              Tab(text: 'Random số'),
              Tab(text: 'Xúc xắc'),
              Tab(text: 'Chọn ngẫu nhiên'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _RandomNumberTab(),
                _DiceTab(),
                _PickRandomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RandomNumberTab extends StatefulWidget {
  const _RandomNumberTab();

  @override
  State<_RandomNumberTab> createState() => _RandomNumberTabState();
}

class _RandomNumberTabState extends State<_RandomNumberTab> {
  final _minCtrl = TextEditingController(text: '1');
  final _maxCtrl = TextEditingController(text: '100');
  int _count = 1;
  List<int> _results = [];
  final _rng = Random();
  final color = AppTheme.toolColors['random']!;

  void _generate() {
    final min = int.tryParse(_minCtrl.text) ?? 1;
    final max = int.tryParse(_maxCtrl.text) ?? 100;
    if (min >= max) return;
    setState(() {
      _results =
          List.generate(_count, (_) => min + _rng.nextInt(max - min + 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _RandCard(
            color: color,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Từ'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('—',
                          style: TextStyle(
                              fontSize: 20, color: AppTheme.textSecondary)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Đến'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Số lượng:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _SmallStepBtn(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          if (_count > 1) setState(() => _count--);
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_count',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: color)),
                    ),
                    _SmallStepBtn(
                        icon: Icons.add_rounded,
                        onTap: () {
                          if (_count < 10) setState(() => _count++);
                        }),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.casino_rounded),
                    label: const Text('Tạo số ngẫu nhiên'),
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                  ),
                ),
              ],
            ),
          ),
          if (_results.isNotEmpty) ...[
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
                  if (_results.length == 1)
                    Text(
                      '${_results[0]}',
                      style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: color,
                          letterSpacing: -2),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: _results
                          .map((r) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('$r',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: color)),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: _results.join(', ')));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Đã sao chép!'),
                            duration: Duration(seconds: 1)),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded,
                            size: 14, color: color.withAlpha(150)),
                        const SizedBox(width: 4),
                        Text('Sao chép',
                            style: TextStyle(
                                fontSize: 12, color: color.withAlpha(150))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiceTab extends StatefulWidget {
  const _DiceTab();

  @override
  State<_DiceTab> createState() => _DiceTabState();
}

class _DiceTabState extends State<_DiceTab> {
  final _rng = Random();
  List<int> _dice = [1];
  int _sides = 6;
  final color = AppTheme.toolColors['random']!;

  static const _diceIcons = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];

  void _roll() {
    setState(() =>
        _dice = List.generate(_dice.length, (_) => 1 + _rng.nextInt(_sides)));
  }

  @override
  Widget build(BuildContext context) {
    final total = _dice.fold(0, (a, b) => a + b);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _RandCard(
            color: color,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Số mặt:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Wrap(
                      spacing: 8,
                      children: [4, 6, 8, 10, 12, 20]
                          .map((s) => GestureDetector(
                                onTap: () => setState(() {
                                  _sides = s;
                                  _dice = List.filled(_dice.length, 1);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _sides == s
                                        ? color.withAlpha(20)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: _sides == s
                                        ? Border.all(color: color.withAlpha(80))
                                        : null,
                                  ),
                                  child: Text('d$s',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _sides == s
                                              ? color
                                              : AppTheme.textSecondary,
                                          fontSize: 13)),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Số xúc xắc:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _SmallStepBtn(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          if (_dice.length > 1) {
                            setState(() =>
                                _dice = _dice.sublist(0, _dice.length - 1));
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('${_dice.length}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: color)),
                    ),
                    _SmallStepBtn(
                        icon: Icons.add_rounded,
                        onTap: () {
                          if (_dice.length < 6) {
                            setState(() => _dice = [..._dice, 1]);
                          }
                        }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _roll,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: color.withAlpha(30),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _dice
                        .map((d) => Text(
                              _sides == 6 && d >= 1 && d <= 6
                                  ? _diceIcons[d - 1]
                                  : '$d',
                              style: TextStyle(
                                  fontSize: _sides == 6 ? 52 : 40,
                                  color: color),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  if (_dice.length > 1)
                    Text('Tổng: $total',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: color)),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, color: color, size: 16),
                        const SizedBox(width: 6),
                        Text('Chạm để tung xúc xắc',
                            style: TextStyle(
                                color: color,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickRandomTab extends StatefulWidget {
  const _PickRandomTab();

  @override
  State<_PickRandomTab> createState() => _PickRandomTabState();
}

class _PickRandomTabState extends State<_PickRandomTab> {
  final _inputCtrl = TextEditingController();
  String? _picked;
  List<String> _items = [];
  final _rng = Random();
  final color = AppTheme.toolColors['random']!;

  void _parse() {
    setState(() {
      _items = _inputCtrl.text
          .split(RegExp(r'[,\n]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    });
  }

  void _pick() {
    if (_items.isEmpty) return;
    setState(() => _picked = _items[_rng.nextInt(_items.length)]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _RandCard(
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Nhập danh sách (phân cách bằng dấu phẩy hoặc xuống dòng)',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 10),
                TextField(
                  controller: _inputCtrl,
                  maxLines: 4,
                  onChanged: (_) => _parse(),
                  decoration: const InputDecoration(
                    hintText: 'An, Bình, Châu, Dũng...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                if (_items.isNotEmpty)
                  Text('${_items.length} mục',
                      style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _items.isNotEmpty ? _pick : null,
                    icon: const Icon(Icons.shuffle_rounded),
                    label: const Text('Chọn ngẫu nhiên'),
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                  ),
                ),
              ],
            ),
          ),
          if (_picked != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: color.withAlpha(30),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Column(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    _picked!,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text('Được chọn!',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RandCard extends StatelessWidget {
  final Color color;
  final Widget child;
  const _RandCard({required this.color, required this.child});

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

class _SmallStepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallStepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textSecondary),
      ),
    );
  }
}
