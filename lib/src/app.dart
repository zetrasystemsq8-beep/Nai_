import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/features/settings/presentation/providers/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = _buildMaterialApp(context, ref);
    return ScreenUtilWrapper(child: current);
  }

  Widget _buildMaterialApp(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'nai',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#008751'),
      darkTheme: buildDarkTheme(primaryColorHex: '#008751'),
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        return current;
      },
    );
  }
}
