import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

class CodeHighlighter extends StatelessWidget {
  final String code;
  final String language;
  final TextStyle? textStyle;

  const CodeHighlighter({
    super.key,
    required this.code,
    this.language = 'plaintext',
    this.textStyle,
  });

  Color _getKeywordColor(BuildContext context) =>
      context.theme.colorScheme.primary;

  Color _getStringColor(BuildContext context) =>
      const Color(0xFF4CAF50);

  Color _getCommentColor(BuildContext context) =>
      context.theme.colorScheme.onSurfaceVariant;

  Color _getNumberColor(BuildContext context) =>
      const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: AppBorders.sm,
        border: Border.all(color: colorScheme.outline),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
              child: Text(
                language.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: textStyle ??
                    TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.sp,
                      color: colorScheme.onSurface,
                      height: 1.6,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
