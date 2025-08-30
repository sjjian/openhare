import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/widgets/loading.dart';

class SessionDrawerMetadata extends ConsumerWidget {
  const SessionDrawerMetadata({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TreeController<DataNode>? controller =
        ref.watch(sessionMetadataNotifierProvider);
    Widget body = const Align(
      alignment: Alignment.center,
      child: Loading.large(),
    );

    if (controller != null) {
      body = DataTree(controller: controller);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: body),
      ],
    );
  }
}
