import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/settings/presentation/providers/theme_provider.dart';
import 'package:nai/src/features/chat/data/chat_history_store.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text(
          'This will permanently delete all your saved conversations. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ChatHistoryStore().clearAll();
      if (context.mounted) {
        showGlobalToast(message: 'Chat history cleared', status: 'success');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && context.isDarkMode);

    return Scaffold(
      appBar: const AppTopBar(title: 'Settings'),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md.w),
          children: [
            _SettingSection(
              title: 'Appearance',
              children: [
                _SettingItem(
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark theme',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).toggleDarkMode(value);
                    },
                  ),
                ),
                _SettingItem(
                  title: 'Font Size',
                  subtitle: 'Adjust text size',
                  onTap: () {
                    showGlobalToast(
                      message: 'Font size settings (coming soon)',
                      status: 'info',
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg.h),
            _SettingSection(
              title: 'Privacy & Security',
              children: [
                _SettingItem(
                  title: 'Clear Chat History',
                  subtitle: 'Delete all conversations',
                  onTap: () => _confirmClearHistory(context, ref),
                ),
                _SettingItem(
                  title: 'Data & Privacy',
                  subtitle: 'Manage your data',
                  onTap: () {
                    showGlobalToast(
                      message: 'Privacy settings (coming soon)',
                      status: 'info',
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg.h),
            _SettingSection(
              title: 'About',
              children: [
                _SettingItem(
                  title: 'Version',
                  subtitle: '1.0.0',
                ),
                _SettingItem(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () {
                    showGlobalToast(
                      message: 'Terms of Service (coming soon)',
                      status: 'info',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        ...children,
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return ListTile(
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing ?? Icon(
        IconsaxPlusLinear.arrow_right_3,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
