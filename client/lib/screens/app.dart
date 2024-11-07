import 'package:client/models/sessions.dart';
import 'package:client/providers/instances.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/screens/instances/instances.dart';
import 'package:client/screens/sessions/session_tabs.dart';
import 'package:client/screens/settings/settings.dart';
import 'package:client/screens/sessions/sessions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:client/screens/page_skeleton.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/sessions',
      debugLogDiagnostics: true,
      routes: [
        ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return ScaffoldWithNavRail(
                child: child,
              );
            },
            routes: [
              GoRoute(
                path: '/sessions',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                    child: PageSkeleton(
                        key: Key("sessions"),
                        topBar: SessionTabs(),
                        child: SQLEditPage())),
              ),
              GoRoute(
                path: '/instances',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                    child: PageSkeleton(
                        key: Key("instances"), child: InstancesPage())),
              ),
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                    child: PageSkeleton(
                        key: Key("settings"), child: SettingsPage())),
              ),
            ]),
      ]);

  @override
  Widget build(BuildContext context) {
    final instancesProvider = InstancesProvider();
    instancesProvider.loadInstance();
    final sessions = SessionsModel();
    final sessionProvider = SessionProvider(sessions.data.selected());
    final sessionListProvider = SessionListProvider(sessionProvider, sessions);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionProvider),
        ChangeNotifierProvider.value(value: sessionListProvider),
        ChangeNotifierProvider.value(value: instancesProvider)
      ],
      child: MaterialApp.router(
        title: 'Natuo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class ScaffoldWithNavRail extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNavRail({Key? key, required this.child}) : super(key: key);

  @override
  State<ScaffoldWithNavRail> createState() => _ScaffoldWithNavRailState();
}

class _ScaffoldWithNavRailState extends State<ScaffoldWithNavRail> {
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: <Widget>[
                  NavigationRail(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    useIndicator: true,
                    selectedIndex: _calculateSelectedIndex(context),
                    onDestinationSelected: (value) {
                      _onItemTapped(value, context);
                    },
                    extended: extended,
                    leading: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 35),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              extended = !extended;
                            });
                          },
                          child: extended
                              ? const Icon(Icons.menu_open)
                              : const Icon(Icons.menu),
                        ),
                      ],
                    ),
                    destinations: [
                      const NavigationRailDestination(
                        icon: Icon(Icons.personal_video),
                        label: Text(
                          "工作台",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDatabase,
                          color: Theme.of(context).iconTheme.color ??
                              Colors.black87,
                        ),
                        label: const Center(
                          child: Text(
                            "数据源",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const NavigationRailDestination(
                        icon: Icon(Icons.settings),
                        label: Center(
                          child: Text(
                            "设置",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    ],
                    trailing: const Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: FlutterLogo(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: widget.child)
                ],
              ),
            ),
          ],
        ));
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/sessions')) {
      return 0;
    }
    if (location.startsWith('/instances')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/sessions');
      case 1:
        GoRouter.of(context).go('/instances');
      case 2:
        GoRouter.of(context).go('/settings');
    }
  }
}
