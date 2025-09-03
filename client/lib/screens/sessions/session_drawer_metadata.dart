import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/widgets/loading.dart';

class SessionDrawerMetadata extends ConsumerWidget {
  const SessionDrawerMetadata({Key? key}) : super(key: key);

  Widget loadingPage() {
    return const Align(
      alignment: Alignment.center,
      child: Loading.large(),
    );
  }

  Widget errorPage(
      BuildContext context, WidgetRef ref, String error, SessionId sessionId) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: kSpacingSmall),
        Text(error),
        RectangleIconButton.medium(
          icon: Icons.refresh,
          onPressed: () {
            ref
                .read(sessionMetadataServicesProvider(sessionId).notifier)
                .refresh();
          },
        )
      ],
    );
  }

  Widget bodyPage(TreeController<DataNode> controller) {
    return DataTree(controller: controller);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionMetadataTreeModel? model =
        ref.watch(sessionMetadataNotifierProvider);

    if (model == null) {
      return loadingPage();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: model.metadataTreeCtrl.match(
          (value) => bodyPage(value),
          (error) => errorPage(context, ref, error, model.sessionId),
          () => loadingPage(),
        )),
      ],
    );
  }
}
