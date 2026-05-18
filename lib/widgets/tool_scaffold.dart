import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ToolScaffold extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Widget child;

  const ToolScaffold({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
      body: child,
    );
  }
}

class ResultCard extends StatelessWidget {
  final String result;
  final Color color;
  final String? label;

  const ResultCard({
    super.key,
    required this.result,
    required this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50), width: 1.5),
      ),
      child: Column(
        children: [
          if (label != null)
            Text(label!,
                style: TextStyle(
                    fontSize: 12,
                    color: color.withAlpha(180),
                    fontWeight: FontWeight.w500)),
          if (label != null) const SizedBox(height: 6),
          Text(
            result,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
