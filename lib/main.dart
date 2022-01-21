import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'routes.dart';
import 'screens/splashScreen.dart';
import 'providers/appBarProvider.dart';
import 'providers/feedProvider.dart';
import 'providers/addPostScreenState.dart';
import 'providers/myProfileProvider.dart';
import 'providers/logHelper.dart';
import 'providers/regHelper.dart';
import 'providers/themeModel.dart';
import 'providers/spotlightTabProvider.dart';
import 'providers/clubTabProvider.dart';

String get nativeAdUnitId {
  if (kDebugMode) {
    return MobileAds.nativeAdTestUnitId;
  } else {
    if (Platform.isAndroid)
      return 'ca-app-pub-9528572745786880/1906037759';
    else
      return 'ca-app-pub-9528572745786880/6307954179';
  }
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.initialize(nativeAdUnitId: nativeAdUnitId);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppBarProvider()),
        ChangeNotifierProvider.value(value: FeedProvider()),
        ChangeNotifierProvider.value(value: NewPostHelper()),
        ChangeNotifierProvider.value(value: MyProfile()),
        ChangeNotifierProvider.value(value: LogHelper()),
        ChangeNotifierProvider.value(value: RegHelper()),
        ChangeNotifierProvider.value(value: ThemeModel()),
        ChangeNotifierProvider.value(value: SpotlightTabProvider()),
        ChangeNotifierProvider.value(value: ClubTabProvider()),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, theme, _) {
          // final bool darkMode = theme.darkMode;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            builder: EasyLoading.init(),
            onGenerateRoute: RouteGenerator.generateRoute,
            theme: ThemeData(
              // brightness: (darkMode) ? Brightness.dark : null,
              // primaryColorBrightness: (darkMode) ? Brightness.dark : null,
              // accentColorBrightness: (darkMode) ? Brightness.dark : null,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              primaryColor: theme.primary,
              accentColor: theme.accent,
            ),
          );
        },
      ),
    );
  }
}
