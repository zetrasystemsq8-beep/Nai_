import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';
import 'package:nai/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:nai/src/features/auth/presentation/screens/reset_password_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    Future<void> handleForgotPassword() async {
      if (!(_formKey.currentState?.validate() ?? false)) return;

      setState(() => _isSubmitting = true);

      final repository = ref.read(authRepositoryProvider);
      final email = _emailController.text.trim();
      final result = await repository.forgotPassword(email: email);

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      result.fold(
        (failure) {
          showToast(context, message: failure.message, status: 'error');
        },
        (_) {
          showToast(context, message: 'A code was sent to your ZetraMail', status: 'success');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(email: email),
            ),
          );
        },
      );
    }

    return _ForgotPasswordView(
      formKey: _formKey,
      emailController: _emailController,
      isLoading: _isSubmitting,
      onForgotPassword: handleForgotPassword,
      cs: cs,
      tt: tt,
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onForgotPassword,
    required this.cs,
    required this.tt,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onForgotPassword;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: ''),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl.h),
                Text(
                  'auth.forgot_password_title'.tr(),
                  style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  'auth.forgot_password_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.xxxl.h),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: emailController,
                        enabled: !isLoading,
                        label: 'ZetraMail',
                        hint: 'username@zetramail.ng',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(IconsaxPlusBold.sms),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'Please enter your ZetraMail';
                          }
                          if (!AppUtils.isValidEmail(v!)) {
                            return 'Enter a valid ZetraMail address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      AppButton(
                        label: 'auth.send_reset_link'.tr(),
                        isLoading: isLoading,
                        onPressed: isLoading ? null : onForgotPassword,
                        width: ButtonSize.large,
                        isFullWidth: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxxl.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'auth.back_to_login'.tr(),
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
