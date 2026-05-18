import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_scaffold.dart';

class HashScreen extends StatefulWidget {
  const HashScreen({super.key});

  @override
  State<HashScreen> createState() => _HashScreenState();
}

class _HashScreenState extends State<HashScreen>
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
    final color = AppTheme.toolColors['hash']!;
    return ToolScaffold(
      title: 'Mã hóa Text',
      color: color,
      icon: Icons.text_fields_rounded,
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
              Tab(text: 'Base64'),
              Tab(text: 'Đếm văn bản'),
              Tab(text: 'Biến đổi chữ'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _Base64Tab(),
                _TextCountTab(),
                _CaseTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Base64Tab extends StatefulWidget {
  const _Base64Tab();

  @override
  State<_Base64Tab> createState() => _Base64TabState();
}

class _Base64TabState extends State<_Base64Tab> {
  final _inputCtrl = TextEditingController();
  final _outputCtrl = TextEditingController();
  bool _isEncoding = true;
  String? _error;
  final color = AppTheme.toolColors['hash']!;

  void _convert() {
    final input = _inputCtrl.text;
    if (input.isEmpty) {
      setState(() {
        _outputCtrl.clear();
        _error = null;
      });
      return;
    }
    try {
      if (_isEncoding) {
        final encoded = base64.encode(utf8.encode(input));
        setState(() {
          _outputCtrl.text = encoded;
          _error = null;
        });
      } else {
        final decoded = utf8.decode(base64.decode(input));
        setState(() {
          _outputCtrl.text = decoded;
          _error = null;
        });
      }
    } catch (_) {
      setState(() {
        _outputCtrl.clear();
        _error = 'Dữ liệu không hợp lệ';
      });
    }
  }

  void _swap() {
    final tmp = _inputCtrl.text;
    setState(() {
      _inputCtrl.text = _outputCtrl.text;
      _outputCtrl.text = tmp;
      _isEncoding = !_isEncoding;
    });
    _convert();
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Đã sao chép!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _TextCard(
            color: color,
            label: _isEncoding ? 'Text gốc' : 'Base64',
            controller: _inputCtrl,
            onChanged: (_) => _convert(),
            action: IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18),
              onPressed: () {
                _inputCtrl.clear();
                _convert();
              },
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ModeChip(
                  label: 'Mã hóa',
                  selected: _isEncoding,
                  color: color,
                  onTap: () {
                    setState(() => _isEncoding = true);
                    _convert();
                  }),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _swap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: color.withAlpha(15), shape: BoxShape.circle),
                  child: Icon(Icons.swap_vert_rounded, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              _ModeChip(
                  label: 'Giải mã',
                  selected: !_isEncoding,
                  color: color,
                  onTap: () {
                    setState(() => _isEncoding = false);
                    _convert();
                  }),
            ],
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.red.withAlpha(15),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            )
          else
            _TextCard(
              color: color,
              label: _isEncoding ? 'Base64' : 'Text gốc',
              controller: _outputCtrl,
              onChanged: null,
              readOnly: true,
              action: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () => _copy(_outputCtrl.text),
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _TextCountTab extends StatefulWidget {
  const _TextCountTab();

  @override
  State<_TextCountTab> createState() => _TextCountTabState();
}

class _TextCountTabState extends State<_TextCountTab> {
  final _inputCtrl = TextEditingController();
  final color = AppTheme.toolColors['hash']!;

  int get _chars => _inputCtrl.text.length;
  int get _charsNoSpace => _inputCtrl.text.replaceAll(' ', '').length;
  int get _words => _inputCtrl.text.trim().isEmpty
      ? 0
      : _inputCtrl.text.trim().split(RegExp(r'\s+')).length;
  int get _lines =>
      _inputCtrl.text.isEmpty ? 0 : _inputCtrl.text.split('\n').length;
  int get _sentences => _inputCtrl.text.isEmpty
      ? 0
      : _inputCtrl.text
          .split(RegExp(r'[.!?]+'))
          .where((s) => s.trim().isNotEmpty)
          .length;
  int get _paragraphs => _inputCtrl.text.isEmpty
      ? 0
      : _inputCtrl.text
          .split(RegExp(r'\n\s*\n'))
          .where((s) => s.trim().isNotEmpty)
          .length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: color.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: TextField(
              controller: _inputCtrl,
              maxLines: 6,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Nhập hoặc dán văn bản vào đây...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _StatTile('Ký tự', '$_chars', color, Icons.text_fields_rounded),
              _StatTile('Ký tự (ko khoảng trắng)', '$_charsNoSpace', color,
                  Icons.abc_rounded),
              _StatTile('Từ', '$_words', Colors.green, Icons.article_rounded),
              _StatTile('Câu', '$_sentences', Colors.orange,
                  Icons.short_text_rounded),
              _StatTile(
                  'Dòng', '$_lines', Colors.purple, Icons.wrap_text_rounded),
              _StatTile('Đoạn văn', '$_paragraphs', Colors.teal,
                  Icons.subject_rounded),
            ],
          ),
          if (_inputCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat('~${(_words / 200).toStringAsFixed(1)} phút',
                      'Đọc (200 từ/phút)'),
                  _MiniStat('~${(_words / 130).toStringAsFixed(1)} phút',
                      'Nói (130 từ/phút)'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CaseTab extends StatefulWidget {
  const _CaseTab();

  @override
  State<_CaseTab> createState() => _CaseTabState();
}

class _CaseTabState extends State<_CaseTab> {
  final _inputCtrl = TextEditingController();
  final color = AppTheme.toolColors['hash']!;

  String _toTitleCase(String s) => s.split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1).toLowerCase();
      }).join(' ');

  String _toSentenceCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  String _toCamelCase(String s) {
    final words = s.trim().split(RegExp(r'[\s_\-]+'));
    if (words.isEmpty) return s;
    return words[0].toLowerCase() +
        words
            .sublist(1)
            .map((w) => w.isEmpty
                ? ''
                : w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join('');
  }

  String _toSnakeCase(String s) =>
      s.trim().split(RegExp(r'[\s\-]+')).map((w) => w.toLowerCase()).join('_');

  String _toKebabCase(String s) =>
      s.trim().split(RegExp(r'[\s_]+')).map((w) => w.toLowerCase()).join('-');

  @override
  Widget build(BuildContext context) {
    final text = _inputCtrl.text;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: color.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: TextField(
              controller: _inputCtrl,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Nhập văn bản...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...[
            ['UPPERCASE', text.toUpperCase(), Icons.arrow_upward_rounded],
            ['lowercase', text.toLowerCase(), Icons.arrow_downward_rounded],
            ['Title Case', _toTitleCase(text), Icons.title_rounded],
            [
              'Sentence case',
              _toSentenceCase(text),
              Icons.text_rotation_none_rounded
            ],
            ['camelCase', _toCamelCase(text), Icons.code_rounded],
            ['snake_case', _toSnakeCase(text), Icons.remove_rounded],
            ['kebab-case', _toKebabCase(text), Icons.horizontal_rule_rounded],
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CaseRow(
                  label: item[0] as String,
                  value: item[1] as String,
                  icon: item[2] as IconData,
                  color: color,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: item[1] as String));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Đã sao chép!'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                ),
              )),
        ],
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onCopy;

  const _CaseRow(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500)),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (value.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16),
              onPressed: onCopy,
              color: color,
            ),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  final Color color;
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final Widget? action;

  const _TextCard({
    required this.color,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.readOnly = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                const Spacer(),
                if (action != null) action!,
              ],
            ),
          ),
          TextField(
            controller: controller,
            onChanged: onChanged,
            readOnly: readOnly,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(20) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: color.withAlpha(80)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? color : AppTheme.textSecondary,
              fontSize: 13),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatTile(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}
