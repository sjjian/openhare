import 'package:client/menu_page.dart';
import 'package:client/sql_edit_page.dart';
import 'package:flutter/material.dart';

class FleaSQLApp extends StatelessWidget {
  const FleaSQLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flea SQL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flea SQL'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: <Widget>[
          RootMenu(),
          VerticalDivider(
            thickness: 1,
            width: 1,
          ),
          Expanded(
            child: IndexedStack(
              alignment: AlignmentDirectional.topCenter,
              children: [SQLEditPage()],
            ),
          )
        ],
      ),
    );
  }
}
