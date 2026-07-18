import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';
import 'package:nai/src/features/auth/presentation/providers/auth_provider.dart';

/// Second step of the forgot-password flow. The user arrives here
/// after ForgotPasswordScreen requests a code, which is delivered
/// to their ZetraMail inbox. They enter the code plus a new
/// password here to complete the reset.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.confirmPasswordReset(
      email: widget.email,
      code: _codeController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    result.fold(
      (failure) {
        showToast(context, message: failure.message, status: 'error');
      },
      (_) {
        showToast(context, message: 'Password updated. Please log in.', status: 'success');
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.forgotPassword(email: widget.email);

    setState(() => _isResending = false);

    if (!mounted) return;

    result.fold(
      (failure) {
        showToast(context, message: failure.message, status: 'error');
      },
      (_) {
        showToast(context, message: 'A new code was sent to your ZetraMail', status: 'success');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

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
                Icon(IconsaxPlusBold.sms_tracking, size: 56, color: cs.primary),
                SizedBox(height: AppSpacing.lg.h),
                Text(
                  'Reset your password',
                  style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  'Open your ZetraMail in the Zetra ID app, copy the code, and set a new password below.',
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.xxxl.h),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _codeController,
                        enabled: !_isSubmitting,
                        label: 'Verification code',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(IconsaxPlusBold.key),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'Enter the code from your ZetraMail';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      AppTextField(
                        controller: _newPasswordController,
                        enabled: !_isSubmitting,
                        label: 'New password',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(IconsaxPlusBold.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'Please enter a new password';
                          }
                          if (v!.length < 8) {
                            return 'auth.password_too_short'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      AppTextField(
                        controller: _confirmPasswordController,
                        enabled: !_isSubmitting,
                        label: 'auth.confirm_password'.tr(),
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(IconsaxPlusBold.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.confirm_password_required'.tr();
                          }
                          if (v != _newPasswordController.text) {
                            return 'auth.passwords_do_not_match'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      AppButton(
                        label: 'Reset password',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        width: ButtonSize.large,
                        isFullWidth: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                TextButton(
                  onPressed: _isResending ? null : _handleResend,
                  child: Text(
                    _isResending ? 'Sending...' : "Didn't get a code? Resend",
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
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
