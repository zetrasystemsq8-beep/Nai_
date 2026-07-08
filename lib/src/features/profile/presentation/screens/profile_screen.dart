import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: 'Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            children: [
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'U',
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                'User Profile',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                'user@nai.ai',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(label: 'Chats', value: '12'),
                  _StatCard(label: 'Messages', value: '245'),
                  _StatCard(label: 'Queries', value: '89'),
                ],
              ),
              SizedBox(height: AppSpacing.xxl.h),
              AppButton(
                label: 'Edit Profile',
                onPressed: () {},
                isFullWidth: true,
                variant: ButtonVariant.primary,
              ),
              SizedBox(height: AppSpacing.md.h),
              AppButton(
                label: 'Logout',
                onPressed: () => context.go(AppRoutes.home),
                isFullWidth: true,
                variant: ButtonVariant.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: AppSpacing.xs.h),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
