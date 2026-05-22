import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_scaffold.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  List<_CounterItem> _counters = [];
  final color = AppTheme.toolColors['counter']!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('counters') ?? [];
    setState(() {
      _counters = raw.map((s) => _CounterItem.fromJson(jsonDecode(s))).toList();
      if (_counters.isEmpty) {
        _counters = [_CounterItem(name: 'Counter 1', value: 0, step: 1)];
      }
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'counters', _counters.map((c) => jsonEncode(c.toJson())).toList());
  }

  void _add() {
    showDialog(
      context: context,
      builder: (_) => _AddCounterDialog(
        onAdd: (name, step) {
          setState(() => _counters.add(_CounterItem(name: name, value: 0, step: step)));
          _save();
        },
      ),
    );
  }

  void _reset(int i) {
    setState(() => _counters[i].value = 0);
    _save();
  }

  void _delete(int i) {
    setState(() => _counters.removeAt(i));
    _save();
  }

  void _increment(int i) {
    setState(() => _counters[i].value += _counters[i].step);
    _save();
  }

  void _decrement(int i) {
    setState(() => _counters[i].value -= _counters[i].step);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Counter',
      color: color,
      icon: Icons.add_circle_outline_rounded,
      child: Column(
        children: [
          Expanded(
            child: _counters.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 64, color: color.withAlpha(80)),
                        const SizedBox(height: 16),
                        const Text('No counters yet', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _counters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CounterCard(
                      item: _counters[i],
                      color: color,
                      onIncrement: () => _increment(i),
                      onDecrement: () => _decrement(i),
                      onReset: () => _reset(i),
                      onDelete: () => _delete(i),
                      onEdit: (name, step) {
                        setState(() {
                          _counters[i].name = name;
                          _counters[i].step = step;
                        });
                        _save();
                      },
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add counter'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterItem {
  String name;
  int value;
  int step;
  _CounterItem({required this.name, required this.value, required this.step});

  factory _CounterItem.fromJson(Map<String, dynamic> j) =>
      _CounterItem(name: j['name'], value: j['value'], step: j['step'] ?? 1);

  Map<String, dynamic> toJson() => {'name': name, 'value': value, 'step': step};
}

class _CounterCard extends StatelessWidget {
  final _CounterItem item;
  final Color color;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;
  final VoidCallback onDelete;
  final Function(String, int) onEdit;

  const _CounterCard({
    required this.item,
    required this.color,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('Step: ${item.step}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => _AddCounterDialog(
                      initialName: item.name,
                      initialStep: item.step,
                      onAdd: onEdit,
                    ),
                  ),
                  color: AppTheme.textSecondary,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  onPressed: onReset,
                  color: AppTheme.textSecondary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  onPressed: onDelete,
                  color: Colors.red.withAlpha(180),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleBtn(icon: Icons.remove_rounded, color: Colors.red, onTap: onDecrement),
                const SizedBox(width: 24),
                Container(
                  width: 100,
                  alignment: Alignment.center,
                  child: Text(
                    '${item.value}',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
                const SizedBox(width: 24),
                _CircleBtn(icon: Icons.add_rounded, color: Colors.green, onTap: onIncrement),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class _AddCounterDialog extends StatefulWidget {
  final Function(String, int) onAdd;
  final String? initialName;
  final int? initialStep;

  const _AddCounterDialog({required this.onAdd, this.initialName, this.initialStep});

  @override
  State<_AddCounterDialog> createState() => _AddCounterDialogState();
}

class _AddCounterDialogState extends State<_AddCounterDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _stepCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _stepCtrl = TextEditingController(text: '${widget.initialStep ?? 1}');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.initialName != null ? 'Edit counter' : 'Add counter'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Counter name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stepCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Step size', hintText: '1'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final name = _nameCtrl.text.trim().isEmpty ? 'Counter' : _nameCtrl.text.trim();
            final step = int.tryParse(_stepCtrl.text) ?? 1;
            widget.onAdd(name, step.abs().clamp(1, 9999));
            Navigator.pop(context);
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
