import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profilecenter/core/core.dart';
import 'package:profilecenter/providers/providers.dart';
import 'package:profilecenter/modules/splash/splash.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await setup();
  AppLanguageProvider appLanguage = AppLanguageProvider();
  await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

class MyApp extends StatelessWidget {
  final AppLanguageProvider appLanguage;

  MyApp({this.appLanguage});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguageProvider>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguageProvider>(builder: (context, model, child) {
        return MultiProvider(
            providers: onGenerateProviders(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: model.appLocale,
              supportedLocales: [
                const Locale('en', 'EN'),
                const Locale('fr', 'FR'),
                const Locale('es', 'ES'),
                const Locale('da', 'DA'),
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              onGenerateRoute: onGenerateRoute,
              home: SplashScreen(),
            ));
      }),
    );
  }
}
