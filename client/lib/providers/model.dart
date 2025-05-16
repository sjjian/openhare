import 'package:client/models/interface.dart';
import 'package:client/models/objectbox.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/models/sessions.dart';

part 'model.g.dart';


@Riverpod(keepAlive: true)
ObjectBox objectbox(Ref ref) {
  return objectbox2;
}