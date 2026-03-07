import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/api_service.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUnauthorizedHandler(() async {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      return;
    }
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  });

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(const MonitoringSystemApp());
}

class MonitoringSystemApp extends StatelessWidget {
  const MonitoringSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '设备监测系统',
      theme: AppTheme.lightTheme,
      navigatorKey: appNavigatorKey,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.splash,
      debugShowCheckedModeBanner: false,
    );
  }
}
