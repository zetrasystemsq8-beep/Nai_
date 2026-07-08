import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

class MarkdownRenderer extends StatelessWidget {
  final String content;
  final TextStyle? baseStyle;
  final TextStyle? headingStyle;

  const MarkdownRenderer({
    super.key,
    required this.content,
    this.baseStyle,
    this.headingStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (String line in lines) {
      if (line.isEmpty) {
        widgets.add(SizedBox(height: AppSpacing.sm.h));
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
            child: Text(
              line.replaceFirst('# ', ''),
              style: headingStyle ??
                  textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
            child: Text(
              line.replaceFirst('## ', ''),
              style: headingStyle ??
                  textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.md.w, bottom: AppSpacing.xs.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: baseStyle ?? textTheme.bodyMedium,
                ),
                Expanded(
                  child: Text(
                    line.replaceFirst(RegExp(r'^[-*] '), ''),
                    style: baseStyle ?? textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('> ')) {
        widgets.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
            padding: EdgeInsets.all(AppSpacing.md.w),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
              color: colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: AppBorders.sm,
            ),
            child: Text(
              line.replaceFirst('> ', ''),
              style: baseStyle ??
                  textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('`')) {
        widgets.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
            padding: EdgeInsets.all(AppSpacing.sm.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: AppBorders.xs,
            ),
            child: Text(
              line.replaceAll('`', ''),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
            child: Text(
              line,
              style: baseStyle ?? textTheme.bodyMedium,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
