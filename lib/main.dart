import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/app.dart';

// ⚠️ PER-APP: change this for each of your 8 apps
const String kAppId = 'app_one';
const String kCurrentVersion = '1.0.0';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await AppConfig.init();
  await HiveService.instance.init();

  String? forceUpdateUrl;

  try {
    final update = await Supabase.instance.client
        .from('app_versions')
        .select()
        .eq('app_id', kAppId)
        .single();

    if (_isOutdated(kCurrentVersion, update['minimum_version'] as String)) {
      forceUpdateUrl = update['apk_url'] as String;
    }
  } catch (_) {
    // Fail open: if the check itself fails (network, missing row, etc.),
    // don't block app launch.
  }

  if (forceUpdateUrl != null) {
    runApp(_ForceUpdateApp(apkUrl: forceUpdateUrl));
    return;
  }

  runApp(
    const LocalizationWrapper(
      child: StateWrapper(
        child: App(),
      ),
    ),
  );
}

bool _isOutdated(String current, String minimum) {
  List<int> parse(String v) =>
      v.split('.').map((p) => int.tryParse(p) ?? 0).toList();

  final c = parse(current);
  final m = parse(minimum);
  final len = c.length > m.length ? c.length : m.length;

  for (var i = 0; i < len; i++) {
    final cv = i < c.length ? c[i] : 0;
    final mv = i < m.length ? m[i] : 0;
    if (cv != mv) return cv < mv;
  }
  return false;
}

class _ForceUpdateApp extends StatelessWidget {
  final String apkUrl;
  const _ForceUpdateApp({required this.apkUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'A new version of this app is required to continue.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => launchUrl(
                    Uri.parse(apkUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Update Required'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
