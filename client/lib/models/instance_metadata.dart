
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

part 'instance_metadata.freezed.dart';

@freezed
abstract class InstanceMetadataModel with _$InstanceMetadataModel {
  const factory InstanceMetadataModel({
    MetaDataNode? metadata,
    TreeController<DataNode>? metadataController,
  }) = _InstanceMetadataModel;
}
