import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:food_app/controllers/Product_controllers.dart';
import 'package:food_app/widgets/auth_provider.dart';
import 'package:food_app/views/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D5016),
          ),
        ),
        home: const SplashView(),
      ),
    );
  }
}