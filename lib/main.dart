import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/presentation/views/login_view.dart';
import 'features/books/presentation/viewmodels/books_viewmodel.dart';

void main() {
  final injectionContainer = InjectionContainer();
  injectionContainer.init();

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => MyApp(injectionContainer: injectionContainer),
    ),
  );
}

class MyApp extends StatelessWidget {
  final InjectionContainer injectionContainer;

  const MyApp({super.key, required this.injectionContainer});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => injectionContainer.authViewModel,
        ),
        ChangeNotifierProvider<BooksViewModel>(
          create: (_) => injectionContainer.booksViewModel,
        ),
      ],
      child: MaterialApp(
        title: 'Books App',
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        // Material Theme 3.0
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginView(),
        routes: {
          '/login': (_) => const LoginView(),
        },
      ),
    );
  }
}