import 'package:client/core/connection/metadata.dart';
import 'package:client/core/connection/result_set.dart';
import 'package:flutter/material.dart';

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
          color: Colors.black87,
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

class ValueTypeIcon extends StatelessWidget {
  final ValueType type;
  final double? size;
  const ValueTypeIcon({Key? key, required this.type, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataType dt = switch (type) {
      ValueType.number => DataType.number,
      ValueType.bit => DataType.blob,
      ValueType.str => DataType.char,
      ValueType.time => DataType.time,
      ValueType.json => DataType.json,
    };
    return DataTypeIcon(
      type: dt,
      size: size,
    );
  }
}
