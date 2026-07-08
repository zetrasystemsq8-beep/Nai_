import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import '../../domain/entities/wiki_entry.dart';

class WikiResultCard extends StatelessWidget {
  final WikiEntry entry;
  final VoidCallback onTap;

  const WikiResultCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.card,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        margin: EdgeInsets.only(bottom: AppSpacing.md.h),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: AppBorders.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm.w,
                          vertical: AppSpacing.xs.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: AppBorders.full,
                        ),
                        child: Text(
                          entry.category,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                if (entry.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: AppCachedImage(
                      imageUrl: entry.imageUrl,
                      height: 60.h,
                      width: 60.w,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              entry.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.clock,
                  size: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: AppSpacing.xs.w),
                Text(
                  entry.lastUpdated.toIso8601String().split('T').first,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  IconsaxPlusLinear.eye,
                  size: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: AppSpacing.xs.w),
                Text(
                  entry.readCount.toString(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
