import 'package:client/models/test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeftNavigation extends StatefulWidget {
  const LeftNavigation({super.key});

  @override
  State<LeftNavigation> createState() => _LeftNavigationState();
}

class _LeftNavigationState extends State<LeftNavigation> {
  @override
  Widget build(BuildContext context) {
    final page = Provider.of<PageNotifier>(context);
    return SizedBox(
      width: 60,
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
          child: SizedBox(
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      page.toHome();
                    },
                    isSelected: page.page == 0,
                    icon: const Icon(Icons.auto_awesome_mosaic_outlined,
                        color: Colors.grey, size: 36),
                    selectedIcon: const Icon(
                      Icons.auto_awesome_mosaic,
                      size: 36,
                    )),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          page.toSettingPage();
                        },
                        isSelected: page.page == 1,
                        icon: const Icon(
                          Icons.settings_outlined,
                          size: 36,
                          color: Colors.grey,
                        ),
                        selectedIcon: const Icon(Icons.settings, size: 36),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10)
              ],
            ),
          )),
    );
  }
}
