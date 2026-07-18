import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/app.dart';


Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['https://ssmwuihkafrulmvtiuam.supabase.co'] ?? '',
    anonKey: dotenv.env['eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNzbXd1aWhrYWZydWxtdnRpdWFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA4Mjk2NjAsImV4cCI6MjA5NjQwNTY2MH0.e1PxmDW77ZhbonS-Z96SWA_sPyVGedzpZNZbJQz7pQo'] ?? '',
  );

  await AppConfig.init();
  await HiveService.instance.init();

  runApp(
    const LocalizationWrapper(
      child: StateWrapper(
        child: App(),
      ),
    ),
  );
}
