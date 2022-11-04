import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:link_speak/firebase_options.dart';
import 'package:provider/provider.dart';

import 'providers/addPostScreenState.dart';
import 'providers/adminFlaresProvider.dart';
import 'providers/adminPostsProvider.dart';
import 'providers/appBarProvider.dart';
import 'providers/clubTabProvider.dart';
import 'providers/feedProvider.dart';
import 'providers/flareTabProvider.dart';
import 'providers/logHelper.dart';
import 'providers/myProfileProvider.dart';
import 'providers/regHelper.dart';
import 'providers/themeModel.dart';
import 'routes.dart';
import 'screens/splashScreen.dart';
import 'widgets/misc/bodyWrapper.dart';

//firebase deploy --only 
//firebase deploy --only hosting:linkspeakmain
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if ((!kIsWeb && Platform.isIOS) || kIsWeb)
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  else
    await Firebase.initializeApp();
  if (!kIsWeb) await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();
  @override
  Widget build(BuildContext context) {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid && !kIsWeb)
      mapsImplementation.useAndroidViewSurface = false;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (!kIsWeb)
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
          ChangeNotifierProvider.value(value: FlareTabProvider()),
          ChangeNotifierProvider.value(value: ClubTabProvider()),
          ChangeNotifierProvider.value(value: AdminPostsProvider()),
          ChangeNotifierProvider.value(value: AdminFlaresProvider())
        ],
        child: Consumer<ThemeModel>(
            builder: (context, theme, _) =>
                // final bool darkMode = theme.darkMode;
                BodyWrap(
                    child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: FlutterWebFrame(
                          backgroundColor: Colors.white,
                          maximumSize: Size(
                              475,
                              MediaQueryData.fromWindow(
                                      WidgetsBinding.instance.window)
                                  .size
                                  .height),
                          enabled: kIsWeb &&
                                  MediaQueryData.fromWindow(
                                              WidgetsBinding.instance.window)
                                          .size
                                          .width >
                                      800 ||
                              MediaQueryData.fromWindow(
                                          WidgetsBinding.instance.window)
                                      .size
                                      .width >
                                  800,
                          builder: (_) => MaterialApp(
                              scrollBehavior: MyCustomScrollBehavior(),
                              debugShowCheckedModeBanner: false,
                              home: const SplashScreen(),
                              builder: EasyLoading.init(),
                              onGenerateRoute: RouteGenerator.generateRoute,
                              theme: ThemeData(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  colorScheme: ColorScheme(
                                      brightness: Brightness.light,
                                      background: Colors.white,
                                      onBackground: Colors.transparent,
                                      error: Colors.red,
                                      onError: Colors.transparent,
                                      surface: Colors.white,
                                      onSurface: Colors.transparent,
                                      primary: theme.primary,
                                      onPrimary: Colors.transparent,
                                      secondary: theme.accent,
                                      onSecondary: Colors.transparent))),
                        )))));
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}
