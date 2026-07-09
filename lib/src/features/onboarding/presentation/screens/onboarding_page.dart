import 'package:nai/src/imports/imports.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  late final List<Map<String, dynamic>> _onboardingData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _onboardingData = [
      {
        'title': 'onboarding.onboarding_title_1'.tr(),
        'subtitle': 'onboarding.onboarding_subtitle_1'.tr(),
        'pageWidget': Image.asset(
          'assets/icons/nai_logo.png',
          width: 200,
          height: 200,
        ),
      },
      {
        'title': 'onboarding.onboarding_title_2'.tr(),
        'subtitle': 'onboarding.onboarding_subtitle_2'.tr(),
        'pageWidget': Image.asset(
          'assets/icons/nai_logo.png',
          width: 200,
          height: 200,
        ),
      },
      {
        'title': 'onboarding.onboarding_title_3'.tr(),
        'subtitle': 'onboarding.onboarding_subtitle_3'.tr(),
        'pageWidget': Image.asset(
          'assets/icons/nai_logo.png',
          width: 200,
          height: 200,
        ),
      },
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return _OnboardingView(
      theme: theme,
      colorScheme: colorScheme,
      textTheme: textTheme,
      pageController: _pageController,
      currentIndex: _currentIndex,
      onboardingData: _onboardingData,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      onGetStarted: _onGetStarted,
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView({
    required this.theme,
    required this.colorScheme,
    required this.textTheme,
    required this.pageController,
    required this.currentIndex,
    required this.onboardingData,
    required this.onPageChanged,
    required this.onGetStarted,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final PageController pageController;
  final int currentIndex;
  final List<Map<String, dynamic>> onboardingData;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.lg.h,
                bottom: AppSpacing.md.h,
              ),
              child: Text(
                'NAI',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  fontSize: 26.sp,
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: onboardingData.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg.w,
                            ),
                            child: onboardingData[index]['pageWidget'] as Widget,
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl.w,
                        ),
                        child: Column(
                          children: [
                            Text(
                              onboardingData[index]['title'] as String,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontSize: 24.sp,
                              ),
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            Text(
                              onboardingData[index]['subtitle'] as String,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                                fontSize: 15.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSpacing.xl.w),
              child: AppButton(
                label: 'shared.get_started'.tr(),
                onPressed: onGetStarted,
                variant: ButtonVariant.primary,
                width: ButtonSize.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
