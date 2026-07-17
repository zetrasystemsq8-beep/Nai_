import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/settings/presentation/providers/theme_provider.dart';
import 'package:nai/src/features/settings/presentation/providers/text_scale_provider.dart';
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

  Future<void> _showFontSizeDialog(BuildContext context, WidgetRef ref) async {
    final current = ref.read(textScaleProvider);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTextScale.values.map((scale) {
            return RadioListTile<AppTextScale>(
              title: Text(scale.label),
              value: scale,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(textScaleProvider.notifier).setScale(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDataPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Data & Privacy'),
        content: const SingleChildScrollView(
          child: Text(
            'NAI stores the following data locally on your device:\\n\\n'
            '• Your chat conversations, saved on-device so you can revisit them\\n'
            '• Cached AI responses, to answer repeated questions faster\\n\\n'
            'Your account (name and ZetraMail) is managed securely through our authentication system.\\n\\n'
            'When you ask NAI a question, it may search public Nigerian news and Wikipedia sources, and send your question to an AI language model to generate a response. No conversation data is sold or shared with advertisers.\\n\\n'
            'You can permanently delete all locally saved conversations at any time using "Clear Chat History" above.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using NAI, you agree to the following:\\n\\n'
            '1. NAI is an AI assistant and may occasionally provide inaccurate or incomplete information. Always verify important facts independently.\\n\\n'
            '2. NAI is intended for lawful, respectful use. Do not use NAI to generate harmful, illegal, or abusive content.\\n\\n'
            '3. Your use of NAI is at your own discretion. Zetra Systems is not liable for decisions made based on NAI\'s responses.\n\n'
            '4. These terms may be updated as NAI evolves. Continued use of the app constitutes acceptance of any changes.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && context.isDarkMode);
    final fontSize = ref.watch(textScaleProvider);

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
                  subtitle: fontSize.label,
                  onTap: () => _showFontSizeDialog(context, ref),
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
                  onTap: () => _showDataPrivacyDialog(context),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg.h),
            _SettingSection(
              title: 'Help',
              children: [
                _SettingItem(
                  title: 'Help & Support',
                  subtitle: 'Guides for NAI, Nigergram, and more',
                  onTap: () => context.push(AppRoutes.governmentServices),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg.h),
            _SettingSection(
              title: 'About NAI',
              children: [
                const _SettingItem(
                  title: 'NAI',
                  subtitle: "Nigeria's AI Assistant",
                ),
                const _SettingItem(
                  title: 'Version',
                  subtitle: '1.0.0',
                ),
                const _SettingItem(
                  title: 'Developed by Zetra',
                  subtitle: 'Powered by Zetra AI',
                ),
                _SettingItem(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () => _showTermsDialog(context),
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
      trailing: onTap != null
          ? (trailing ??
              Icon(
                IconsaxPlusLinear.arrow_right_3,
                color: colorScheme.onSurfaceVariant,
              ))
          : trailing,
      onTap: onTap,
    );
  }
}
