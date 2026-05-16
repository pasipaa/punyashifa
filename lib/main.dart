import 'package:flutter/material.dart';
import 'package:food_app/controllers/Product_controllers.dart';
import 'package:food_app/views/MainPage_view.dart'; // ← ganti ini
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
      ],
      child: MaterialApp(
        title: 'Food App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2D5016),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D5016)),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const MainPage(), // ← dari DashboardPage ke MainPage
      ),
    );
  }
}