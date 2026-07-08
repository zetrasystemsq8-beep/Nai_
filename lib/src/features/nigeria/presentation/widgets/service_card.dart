import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import '../../domain/entities/government_service.dart';

class ServiceCard extends StatelessWidget {
  final GovernmentService service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
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
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: AppCachedImage(
                    imageUrl: service.iconUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (service.isVerified)
                            Icon(
                              IconsaxPlusBold.verify,
                              size: 16.sp,
                              color: colorScheme.primary,
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Row(
                        children: [
                          Icon(
                            IconsaxPlusBold.star,
                            size: 14.sp,
                            color: const Color(0xFFFFB800),
                          ),
                          SizedBox(width: AppSpacing.xs.w),
                          Text(
                            service.rating.toStringAsFixed(1),
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${service.reviewCount})',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            if (service.tags.isNotEmpty)
              Wrap(
                spacing: AppSpacing.xs.w,
                children: service.tags.take(3).map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm.w,
                      vertical: AppSpacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: AppBorders.full,
                    ),
                    child: Text(
                      tag,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
