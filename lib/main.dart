import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
//import 'screens/map_screen.dart';
import 'screens/construction_form_screen.dart';
import 'screens/construction_list_screen.dart';
import 'screens/draw_map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urban Relevé',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/map': (context) => DrawMapScreen(),
        '/form': (context) => const ConstructionFormScreen(polygonPoints: [],),
        '/list': (context) => ConstructionListScreen(constructions: const []),
      },
    );
  }
}
