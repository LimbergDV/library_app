import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/presentation/views/login_view.dart';
import 'features/books/presentation/viewmodels/books_viewmodel.dart';

/// Punto de entrada de la aplicación.
/// Se realiza la inyección de dependencias manual y se configuran los providers.
void main() {
  // Inicializar el contenedor de dependencias
  final injectionContainer = InjectionContainer();
  injectionContainer.init();

  runApp(MyApp(injectionContainer: injectionContainer));
}

class MyApp extends StatelessWidget {
  final InjectionContainer injectionContainer;

  const MyApp({super.key, required this.injectionContainer});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inyección de dependencias manual mediante Provider
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
        // Material Theme 3.0 obligatorio
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginView(),
        // Navegación 1.0 con rutas nombradas
        routes: {
          '/login': (_) => const LoginView(),
        },
      ),
    );
  }
}
