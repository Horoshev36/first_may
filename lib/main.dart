import 'dart:async';
import 'dart:developer';
import 'dart:io';


import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_may/app/app.dart';
import 'package:first_may/app/bloc/app_bloc.dart';
import 'package:first_may/di/app_locator.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await Locator.initBeforeAppLaunch();

  runZonedGuarded(() {
    runApp(
      BlocProvider(
        create: (context) => Locator.injection<AppBloc>(),
        child: App(
          Locator.injection(),
        ),
      ),
    );
    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(650, 500);
      win.minSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = "Custom window with Flutter";
      windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(alwaysOnTop: true);
      windowManager.waitUntilReadyToShow(windowOptions, () async {});
      win.show();
    });
  }, (error, stackTrace) {
    log('Catch error: \n $error');
    log('StackTrace: \n $stackTrace');
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

