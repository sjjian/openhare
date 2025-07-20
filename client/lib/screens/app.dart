import 'package:client/screens/instances/instance_add.dart';
import 'package:client/screens/instances/instance_tables.dart';
import 'package:client/screens/instances/instance_update.dart';
import 'package:client/screens/settings/settings.dart';
import 'package:client/screens/about/about.dart';
import 'package:client/screens/sessions/sessions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class App extends ConsumerWidget {
  App({super.key});

  final GoRouter _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/sessions',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: "/sessions",
          pageBuilder: (context, state) =>
              const NoTransitionPage<void>(child: SessionsPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage<void>(child: SettingsPage()),
        ),
        // About 页面
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) =>
              const NoTransitionPage<void>(child: AboutPage()),
        ),
        ShellRoute(
            navigatorKey: _shellNavigatorKey,
            pageBuilder:
                (BuildContext context, GoRouterState state, Widget child) {
              return NoTransitionPage<void>(child: child);
            },
            routes: [
              GoRoute(
                path: "/instances",
                redirect: (context, state) {
                  return lastInstancePage;
                },
              ),
              GoRoute(
                path: '/instances/list',
                pageBuilder: (context, state) {
                  lastInstancePage = '/instances/list';
                  return const NoTransitionPage<void>(child: InstancesPage());
                },
              ),
              GoRoute(
                path: '/instances/add',
                pageBuilder: (context, state) {
                  lastInstancePage = '/instances/add';
                  return const NoTransitionPage<void>(child: AddInstancePage());
                },
              ),
              GoRoute(
                path: '/instances/update',
                pageBuilder: (context, state) {
                  lastInstancePage = '/instances/update';
                  return const NoTransitionPage<void>(
                      child: UpdateInstancePage());
                },
              ),
            ]),
      ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(settingNotifierProvider);

    return MaterialApp.router(
      title: 'snowhare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness:
              model.theme == "dark" ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      themeMode: (model.theme == "dark") ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(model.language),
    );
  }
}

String lastInstancePage = "/instances/list";

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
    return Row(
      children: <Widget>[
        NavigationRail(
          minWidth: 70,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceDim, // navigation color
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
                color: Theme.of(context).iconTheme.color ?? Colors.black87,
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
            ),
            // About 页面
            const NavigationRailDestination(
              icon: Icon(Icons.info_outline),
              label: Center(
                child: Text(
                  "关于",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  "assets/icons/logo.png",
                  height: 36,
                  width: 36,
                ),
              ),
            ),
          ),
        ),
        Expanded(child: widget.child)
      ],
    );
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
    if (location.startsWith('/about')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == _ScaffoldWithNavRailState._calculateSelectedIndex(context)) {
      return;
    }
    switch (index) {
      case 0:
        GoRouter.of(context).go('/sessions');
      case 1:
        GoRouter.of(context).go('/instances');
      case 2:
        GoRouter.of(context).go('/settings');
      case 3:
        GoRouter.of(context).go('/about');
    }
  }
}
