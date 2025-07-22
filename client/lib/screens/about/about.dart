import 'package:client/screens/page_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    initVersion();
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> initVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      _version = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
      key: const Key("about"),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: Divider.createBorderSide(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.about,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 产品描述部分
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedInformationCircle,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.app_desc,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 版本信息部分
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedWorkflowCircle06,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${AppLocalizations.of(context)!.version}: $_version',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // GitHub 地址部分
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedGithub,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 24,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _launchUrl(
                          Uri.parse('https://github.com/sjjian/snowhare'),
                        ),
                        child: Text(
                          'https://github.com/sjjian/snowhare',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
