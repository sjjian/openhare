import 'package:client/screens/page_skeleton.dart';
import 'package:client/widgets/const.dart';
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
      child: BodyPageSkeleton(
        header: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.about,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 产品描述部分
            Text(
              AppLocalizations.of(context)!.app_desc,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: kSpacingMedium),
            // 版本信息部分
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedWorkflowCircle06,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: kSpacingSmall),
                Text(
                  '${AppLocalizations.of(context)!.version}: $_version',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),
            // GitHub 地址部分
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedGithub,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: kIconSizeMedium,
                ),
                const SizedBox(height: kSpacingSmall),
                InkWell(
                  onTap: () => _launchUrl(
                    Uri.parse('https://github.com/sjjian/openhare'),
                  ),
                  child: Text(
                    'https://github.com/sjjian/openhare',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
