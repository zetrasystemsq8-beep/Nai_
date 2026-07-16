import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';
import 'package:nai/src/features/chat/data/chat_history_store.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _chatCount = 0;
  int _messageCount = 0;
  int _queryCount = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final sessions = await ChatHistoryStore().getAllSessions();
    var messageCount = 0;
    var queryCount = 0;
    for (final s in sessions) {
      messageCount += s.messages.length;
      queryCount += s.messages.where((m) => m.role == 'user').length;
    }
    if (mounted) {
      setState(() {
        _chatCount = sessions.length;
        _messageCount = messageCount;
        _queryCount = queryCount;
        _loadingStats = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).logout();
      // The session listener will automatically redirect to onboarding
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    
    // Get user from session provider instead of Firebase
    final sessionState = ref.watch(sessionProvider);
    final user = sessionState.user;
    
    final displayName = user?.name?.isNotEmpty == true ? user!.name! : 'NAI User';
    final zetraMail = user?.zetraMail ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

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
                    initial,
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                displayName,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm.h),
              if (zetraMail.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'ZetraMail',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      zetraMail,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                Text(
                  'ZetraMail',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: AppSpacing.xxl.h),
              _loadingStats
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCard(label: 'Chats', value: '$_chatCount'),
                        _StatCard(label: 'Messages', value: '$_messageCount'),
                        _StatCard(label: 'Queries', value: '$_queryCount'),
                      ],
                    ),
              SizedBox(height: AppSpacing.xxl.h),
              AppButton(
                label: 'Edit Profile',
                onPressed: () {
                  showGlobalToast(
                    message: 'Edit profile (coming soon)',
                    status: 'info',
                  );
                },
                isFullWidth: true,
                variant: ButtonVariant.primary,
              ),
              SizedBox(height: AppSpacing.md.h),
              AppButton(
                label: 'Logout',
                onPressed: _logout,
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
