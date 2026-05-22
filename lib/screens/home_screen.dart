import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'unit_converter_screen.dart';
import 'percentage_screen.dart';
import 'date_calculator_screen.dart';
import 'counter_screen.dart';
import 'bmi_screen.dart';
import 'tip_calculator_screen.dart';
import 'random_screen.dart';
import 'hash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _recentTools = [];

  final List<Map<String, dynamic>> _tools = [
    {
      'id': 'converter',
      'title': 'Unit Converter',
      'subtitle': 'Mass, length, temperature...',
      'icon': Icons.swap_horiz_rounded,
      'color': AppTheme.toolColors['converter']!,
      'screen': const UnitConverterScreen(),
    },
    {
      'id': 'percentage',
      'title': 'Percentage',
      'subtitle': 'Calculate %, increase/decrease, compare',
      'icon': Icons.percent_rounded,
      'color': AppTheme.toolColors['percentage']!,
      'screen': const PercentageScreen(),
    },
    {
      'id': 'date',
      'title': 'Date Calculator',
      'subtitle': 'Date range, add/subtract days',
      'icon': Icons.calendar_today_rounded,
      'color': AppTheme.toolColors['date']!,
      'screen': const DateCalculatorScreen(),
    },
    {
      'id': 'counter',
      'title': 'Counter',
      'subtitle': 'Count multiple items, save history',
      'icon': Icons.add_circle_outline_rounded,
      'color': AppTheme.toolColors['counter']!,
      'screen': const CounterScreen(),
    },
    {
      'id': 'bmi',
      'title': 'BMI Calculator',
      'subtitle': 'Calculate BMI & health assessment',
      'icon': Icons.monitor_weight_outlined,
      'color': AppTheme.toolColors['bmi']!,
      'screen': const BmiScreen(),
    },
    {
      'id': 'tip',
      'title': 'Split Bill',
      'subtitle': 'Calculate tip & split group bill',
      'icon': Icons.receipt_long_rounded,
      'color': AppTheme.toolColors['tip']!,
      'screen': const TipCalculatorScreen(),
    },
    {
      'id': 'random',
      'title': 'Random',
      'subtitle': 'Random numbers, dice, pick from list',
      'icon': Icons.casino_rounded,
      'color': AppTheme.toolColors['random']!,
      'screen': const RandomScreen(),
    },
    {
      'id': 'hash',
      'title': 'Text Tools',
      'subtitle': 'Base64, character count, case conversion',
      'icon': Icons.text_fields_rounded,
      'color': AppTheme.toolColors['hash']!,
      'screen': const HashScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentTools = prefs.getStringList('recent_tools') ?? [];
    });
  }

  Future<void> _saveRecent(String toolId) async {
    final prefs = await SharedPreferences.getInstance();
    _recentTools.remove(toolId);
    _recentTools.insert(0, toolId);
    if (_recentTools.length > 3) _recentTools = _recentTools.sublist(0, 3);
    await prefs.setStringList('recent_tools', _recentTools);
    setState(() {});
  }

  void _openTool(Map<String, dynamic> tool) {
    _saveRecent(tool['id']);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => tool['screen']),
    );
  }

  List<Map<String, dynamic>> get _recentToolData => _recentTools
      .map((id) => _tools.firstWhere((t) => t['id'] == id,
          orElse: () => <String, dynamic>{}))
      .where((t) => t.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.grid_view_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AIO Toolkit',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'All-in-one toolkit',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_recentToolData.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const Text(
                        'Recently used',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 72,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _recentToolData
                              .map((t) => _RecentChip(
                                    tool: t,
                                    onTap: () => _openTool(t),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const Text(
                      'All tools',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ToolCard(
                    tool: _tools[index],
                    onTap: () => _openTool(_tools[index]),
                  ),
                  childCount: _tools.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  final Map<String, dynamic> tool;
  final VoidCallback onTap;

  const _RecentChip({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: (tool['color'] as Color).withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (tool['color'] as Color).withAlpha(60),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tool['icon'] as IconData,
                color: tool['color'] as Color, size: 20),
            const SizedBox(width: 8),
            Text(
              tool['title'] as String,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tool['color'] as Color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final Map<String, dynamic> tool;
  final VoidCallback onTap;

  const _ToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = tool['color'] as Color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(30),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tool['icon'] as IconData, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                tool['title'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tool['subtitle'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
