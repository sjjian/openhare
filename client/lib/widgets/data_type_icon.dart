import 'package:flutter/material.dart';

import 'package:db_driver/db_driver.dart';

class DataTypeIcon extends StatelessWidget {
  final DataType type;
  final double? size;

  const DataTypeIcon({Key? key, required this.type, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      DataType.number => Icon(
          Icons.onetwothree,
          color: Colors.teal,
          size: size,
        ),
      DataType.char => Icon(
          Icons.abc,
          color: Colors.blueAccent,
          size: size,
        ),
      DataType.time => Icon(
          Icons.access_time,
          color: Colors.deepPurple,
          size: size,
        ),
      DataType.blob => Icon(
          Icons.insert_drive_file_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: size,
        ),
      DataType.json => Icon(
          Icons.data_object,
          color: Colors.orangeAccent,
          size: size,
        ),
      _ => Icon(
          Icons.question_mark,
          size: size,
        )
    };
  }
}
