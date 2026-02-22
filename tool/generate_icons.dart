import 'dart:io';
import 'dart:convert';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

void log(String message) {
  print('[generator] $message');
}

void error(String message) {
  print('[generator][ERROR] $message');
}

String formatName(String name) {
  final splitName = name.toLowerCase().split('-');
  return splitName.map((word) {
    if (splitName.indexOf(word) == 0) return word;
    return word.replaceFirst(word[0], word[0].toUpperCase());
  }).join();
}

void saveContentToFile({required String filePath, required String content}) {
  final resultFile = File(filePath);

  if (!resultFile.existsSync()) {
    log('Creating file: $filePath');
    resultFile.createSync(recursive: true);
  }

  resultFile.writeAsStringSync('''// Auto generated File
// DON'T EDIT BY HAND

$content''');

  log('File written successfully: $filePath');
}

enum StyleFileData {
  regular(styleName: 'regular', idx: 0),
  thin(styleName: 'thin', idx: 1),
  light(styleName: 'light', idx: 2),
  bold(styleName: 'bold', idx: 3),
  fill(styleName: 'fill', idx: 4),
  duotone(styleName: 'duotone', idx: 5);

  const StyleFileData({required this.styleName, required this.idx});

  final String styleName;
  final int idx;
}

String escapeDartString(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r');
}

void generateIconsMetadata(List icons) {
  log('Generating icons metadata file');
  log('Total icons received: ${icons.length}');

  final stylesMaps = {
    for (final style in StyleFileData.values) style: <String>[],
  };

  final metadataEntries = <String>[];

  for (final icon in icons) {
    final rawName = icon['name'] as String;
    final fullName = rawName.split(",").first;

    final categories = (icon['categories'] as List<dynamic>? ?? [])
        .map((e) => "'${escapeDartString(e.toString())}'")
        .join(',');

    const ignoredTags = {'*new*'};

    final tags = (icon['tags'] as List<dynamic>? ?? [])
        .where((e) => !ignoredTags.contains(e.toString().toLowerCase()))
        .map((e) => "'${escapeDartString(e.toString())}'")
        .join(',');

    final codepoint = icon['codepoint'];

    final styleMapEntries = StyleFileData.values
        .map((style) {
          final formatted = formatName(fullName);
          return "'${style.styleName}': "
              "PhosphorIcons.$formatted("
              "PhosphorIconsStyle.${style.styleName})";
        })
        .join(',');

    metadataEntries.add('''
IconMetadata(
  '$fullName',
  [$categories],
  [$tags],
  $codepoint,
  {$styleMapEntries},
)
''');

    for (final style in StyleFileData.values) {
      final name = formatName(fullName);

      final mapEntryLine =
          "'$fullName': PhosphorIcons.$name("
          "PhosphorIconsStyle.${style.styleName})";

      stylesMaps[style]!.add(mapEntryLine);
    }
  }

  log('Building Dart class structure...');

  final iconMetadataClass = Class(
    (classBuilder) => classBuilder
      ..name = 'IconMetadata'
      ..fields.addAll([
        Field(
          (f) => f
            ..modifier = FieldModifier.final$
            ..type = Reference('String')
            ..name = 'name',
        ),
        Field(
          (f) => f
            ..modifier = FieldModifier.final$
            ..type = Reference('List<String>')
            ..name = 'categories',
        ),
        Field(
          (f) => f
            ..modifier = FieldModifier.final$
            ..type = Reference('List<String>')
            ..name = 'tags',
        ),
        Field(
          (f) => f
            ..modifier = FieldModifier.final$
            ..type = Reference('int')
            ..name = 'codepoint',
        ),
        Field(
          (f) => f
            ..modifier = FieldModifier.final$
            ..type = Reference('Map<String, PhosphorIconData>')
            ..name = 'styles',
        ),
      ])
      ..constructors.add(
        Constructor(
          (c) => c
            ..constant = true
            ..requiredParameters.addAll([
              Parameter(
                (p) => p
                  ..name = 'name'
                  ..toThis = true,
              ),
              Parameter(
                (p) => p
                  ..name = 'categories'
                  ..toThis = true,
              ),
              Parameter(
                (p) => p
                  ..name = 'tags'
                  ..toThis = true,
              ),
              Parameter(
                (p) => p
                  ..name = 'codepoint'
                  ..toThis = true,
              ),
              Parameter(
                (p) => p
                  ..name = 'styles'
                  ..toThis = true,
              ),
            ]),
        ),
      ),
  );

  final allIconsClass = Class(
    (classBuilder) => classBuilder
      ..abstract = true
      ..name = 'AllIcons'
      ..methods.addAll([
        buildGetterMethod(
          returnType: 'List<IconMetadata>',
          name: 'all',
          body: '[${metadataEntries.join(',')}]',
        ),
        buildGetterMethod(
          returnType: 'List<PhosphorIconData>',
          name: 'icons',
          body: 'allFlatIconsAsMap.values.toList()',
        ),
        buildGetterMethod(
          returnType: 'List<String>',
          name: 'names',
          body: 'allFlatIconsAsMap.keys.toList()',
        ),
        buildGetterMethod(
          returnType: 'Map<String, PhosphorIconData>',
          name: 'allFlatIconsAsMap',
          body: '''{
      ...regularIcons,
      ...thinIcons,
      ...lightIcons,
      ...boldIcons,
      ...fillIcons,
      ...duotoneIcons,
      }''',
        ),
        for (final entry in stylesMaps.entries)
          buildIconsMapGetterByStyle(style: entry.key, lines: entry.value),
      ]),
  );

  final allFilesLib = Library(
    (libraryBuilder) => libraryBuilder
      ..directives.addAll([
        Directive.import('package:phosphor_flutter/phosphor_flutter.dart'),
      ])
      ..body.addAll([iconMetadataClass, allIconsClass]),
  );

  log('Formatting generated Dart code...');

  final emitter = DartEmitter();
  final rawOutput = '${allFilesLib.accept(emitter)}';

  final generatedFileContent = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  ).format(rawOutput);

  saveContentToFile(
    filePath: '../lib/constants/all_icons.dart',
    content: generatedFileContent,
  );

  log('Icons metadata generation completed.');
}

Method buildGetterMethod({
  required String returnType,
  required String name,
  required String body,
}) {
  return Method(
    (methodBuilder) => methodBuilder
      ..static = true
      ..returns = Reference(returnType)
      ..type = MethodType.getter
      ..name = name
      ..lambda = true
      ..body = Code(body),
  );
}

Method buildIconsMapGetterByStyle({
  required StyleFileData style,
  required List<String> lines,
}) => buildGetterMethod(
  returnType: 'Map<String, PhosphorIconData>',
  name: '${style.styleName}Icons',
  body: '{${lines.join(',')}}',
);

void main() {
  try {
    log('Starting Dart generation...');

    final file = File('../tooling/icons_metadata.json');

    if (!file.existsSync()) {
      error('icons_metadata.json not found.');
      exit(1);
    }

    log('Reading icons_metadata.json...');
    final content = file.readAsStringSync();
    final List icons = jsonDecode(content);

    generateIconsMetadata(icons);

    log('Dart file generated successfully.');
    exit(0);
  } catch (e) {
    error('Generation failed: $e');
    exit(1);
  }
}
