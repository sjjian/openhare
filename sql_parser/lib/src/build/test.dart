import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

// import 'utils.dart';

/// Returns all [TopLevelVariableElement] members in [reader]'s library that
/// have a type of [num].
Iterable<TopLevelVariableElement> topLevelNumVariables(LibraryReader reader) =>
    reader.allElements.whereType<TopLevelVariableElement>().where(
          (element) =>
              element.type.isDartCoreNum ||
              element.type.isDartCoreInt ||
              element.type.isDartCoreDouble,
        );

class PropertySumGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final sumNames = topLevelNumVariables(library)
        .map((element) => element.name)
        .join(' + ');

    return '''
num allSum() => $sumNames;
''';
  }
}

class MemberCountLibraryGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final topLevelVarCount = topLevelNumVariables(library).length;

    return '''
// Source library: ${library.element.source.uri}
const topLevelNumVarCount = $topLevelVarCount;
''';
  }
}
