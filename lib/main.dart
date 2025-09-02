import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favoritosProvider.dart';
import 'screens/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritosProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pokedex',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}