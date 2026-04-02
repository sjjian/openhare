import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/ai.dart';
import 'package:client/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LLM API setting dialog', () {
    testWidgets('create mode prefills official endpoint and shows new actions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: _DialogTestApp(),
        ),
      );

      await tester.tap(find.byKey(const Key('open-create-dialog')));
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Description'), findsNothing);
      expect(find.text('https://api.openai.com/v1'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Fetch models'), findsNothing);
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
    });

    testWidgets('create mode auto fills name when left blank', (tester) async {
      LLMAgentSettingModel? submitted;

      await tester.pumpWidget(
        ProviderScope(
          child: _DialogTestApp(
            onSubmit: (setting, _) {
              submitted = setting;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('open-create-dialog')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('llm-api-key-field')), 'sk-test');
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('llm-model-field')),
          matching: find.byType(EditableText),
        ),
        'gpt-4.1',
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.name, 'OpenAI / gpt-4.1');
      expect(submitted!.baseUrl, 'https://api.openai.com/v1');
      expect(submitted!.apiKey, 'sk-test');
      expect(submitted!.modelName, 'gpt-4.1');
    });

    testWidgets('edit mode keeps original values', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: _DialogTestApp(),
        ),
      );

      await tester.tap(find.byKey(const Key('open-edit-dialog')));
      await tester.pumpAndSettle();

      expect(find.text('https://api.deepseek.com/v1'), findsOneWidget);
      expect(find.text('deepseek-chat'), findsOneWidget);
      expect(find.text('DeepSeek Prod'), findsOneWidget);
    });

    testWidgets('edit mode preserves existing status when connection fields stay unchanged', (tester) async {
      LLMAgentStatusModel? submittedStatus;

      await tester.pumpWidget(
        ProviderScope(
          child: _DialogTestApp(
            onSubmit: (setting, status) {
              submittedStatus = status;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('open-edit-dialog')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submittedStatus, isNotNull);
      expect(submittedStatus!.state, LLMAgentState.available);
    });

    testWidgets('edit mode clears synced status when connection fields change without retest', (tester) async {
      LLMAgentStatusModel? submittedStatus;

      await tester.pumpWidget(
        ProviderScope(
          child: _DialogTestApp(
            onSubmit: (setting, status) {
              submittedStatus = status;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('open-edit-dialog')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('llm-model-field')),
          matching: find.byType(EditableText),
        ),
        'gpt-5.5',
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submittedStatus, isNull);
    });

    testWidgets('reset form restores saved values in edit mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: _DialogTestApp(),
        ),
      );

      await tester.tap(find.byKey(const Key('open-edit-dialog')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('llm-name-field')), 'Changed name');
      await tester.enterText(find.byKey(const Key('llm-base-url-field')), 'https://example.com/v1');
      await tester.enterText(find.byKey(const Key('llm-api-key-field')), 'sk-changed');
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('llm-model-field')),
          matching: find.byType(EditableText),
        ),
        'gpt-5.5',
      );

      await tester.tap(find.text('Reset form'));
      await tester.pumpAndSettle();

      expect(find.text('DeepSeek Prod'), findsOneWidget);
      expect(find.text('https://api.deepseek.com/v1'), findsOneWidget);
      expect(find.text('deepseek-chat'), findsOneWidget);
    });
  });
}

class _DialogTestApp extends StatelessWidget {
  final void Function(LLMAgentSettingModel setting, LLMAgentStatusModel? status)? onSubmit;

  const _DialogTestApp({this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Column(
              children: [
                TextButton(
                  key: const Key('open-create-dialog'),
                  onPressed: () {
                    showLLMApiSettingDialog(
                      context,
                      'Create',
                      null,
                      onSubmit ?? _noopSubmit,
                    );
                  },
                  child: const Text('Open create'),
                ),
                TextButton(
                  key: const Key('open-edit-dialog'),
                  onPressed: () {
                    showLLMApiSettingDialog(
                      context,
                      'Update',
                      LLMAgentModel(
                        id: const LLMAgentId(value: 1),
                        setting: const LLMAgentSettingModel(
                          name: 'DeepSeek Prod',
                          baseUrl: 'https://api.deepseek.com/v1',
                          apiKey: 'sk-existing',
                          modelName: 'deepseek-chat',
                        ),
                        status: const LLMAgentStatusModel(state: LLMAgentState.available),
                      ),
                      onSubmit ?? _noopSubmit,
                    );
                  },
                  child: const Text('Open edit'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _noopSubmit(LLMAgentSettingModel setting, LLMAgentStatusModel? status) {}
