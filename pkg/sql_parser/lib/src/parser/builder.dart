library sql_parser.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'build/test.dart';

Builder sumBuilder(BuilderOptions options) =>
    SharedPartBuilder([PropertySumGenerator()], 'sum');
