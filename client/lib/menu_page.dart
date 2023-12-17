import 'package:flutter/material.dart';

class RootMenu extends StatefulWidget {
  const RootMenu({super.key});

  @override
  State<RootMenu> createState() => _RootMenuState();
}

class _RootMenuState extends State<RootMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: const SizedBox(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
              onPressed: null, icon: Icon(Icons.auto_awesome_mosaic_outlined)),
          IconButton(
              onPressed: null, icon: Icon(Icons.auto_awesome_mosaic_outlined)),
          IconButton(
              onPressed: null, icon: Icon(Icons.auto_awesome_mosaic_outlined)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: null, icon: Icon(Icons.settings)),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
