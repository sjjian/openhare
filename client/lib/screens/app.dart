import 'package:client/screens/left_navigation.dart';
import 'package:client/screens/settings.dart';
import 'package:client/screens/sql_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:client/models/test.dart';
import 'package:provider/provider.dart';

class FleaSQLApp extends StatelessWidget {
  const FleaSQLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flea SQL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flea SQL'),
      debugShowCheckedModeBanner: false,
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
  @override
  Widget build(BuildContext context) {
    final page = Provider.of<PageNotifier>(context);
    return Scaffold(
        // backgroundColor: Theme.of(context).colorScheme.background,
        backgroundColor: Color.fromARGB(255, 243, 242, 242),
        body: Row(
          children: <Widget>[
            const LeftNavigation(),
            // const VerticalDivider(
            //   width: 1.0,
            //   // thickness: 0.5,
            //   color: Colors.grey,
            // ),
            const SizedBox(width: 3),
            Expanded(
                child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: page.page,
                    alignment: AlignmentDirectional.topCenter,
                    children: const [SQLEditPage(), SettingsPage()],
                  ),
                ),
              ],
            ))
          ],
        ));
  }
}
