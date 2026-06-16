import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_controller.dart';
import 'package:client/services/sessions/session_metadata.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/widgets/loading.dart';

class SessionDrawerMetadata extends ConsumerWidget {
  const SessionDrawerMetadata({super.key});

  Widget loadingPage() {
    return const Align(
      alignment: Alignment.center,
      child: Loading.large(),
    );
  }

  Widget errorPage(BuildContext context, WidgetRef ref, String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          size: 48, // todo: 使用统一图标大小
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        const SizedBox(height: kSpacingSmall),
        Text(error),
        RectangleIconButton.medium(
          icon: Icons.refresh,
          onPressed: () {
            ref.read(selectedSessionMetadataProvider.notifier).refreshMetadata();
          },
        ),
      ],
    );
  }

  Widget bodyPage(TreeController<DataNode> controller, ScrollController scrollController) {
    return DataTree(controller: controller, scrollController: scrollController);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<SessionMetadataTreeModel> model = ref.watch(selectedSessionMetadataTreeProvider);
    SessionController sessionController = ref.watch(selectedSessionControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpacingTiny, kSpacingTiny, kSpacingTiny -2, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: model.when(
              data: (value) => bodyPage(value.metadataTreeCtrl, sessionController.metadataTreeScrollController),
              error: (error, trace) => errorPage(context, ref, error.toString()),
              loading: () => loadingPage(),
            ),
          ),
        ],
      ),
    );
  }
}
