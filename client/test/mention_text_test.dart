import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/widgets/mention_text.dart';

/// 编码格式中 mention 严格为 @label\uE000
const String _me = '\uE000';

void main() {
  group('Segment 模型', () {
    test('TextSegment 和 MentionSegment 基本功能', () {
      final textSeg = TextSegment('Hello');
      expect(textSeg.value, 'Hello');
      expect(textSeg.driverLength, 5);

      final mentionSeg1 = MentionSegment(label: 'users');
      expect(mentionSeg1.label, 'users');
      expect(mentionSeg1.driverLength, 1);

      final mentionSeg2 = MentionSegment(label: 'Alice');
      expect(mentionSeg2.label, 'Alice');
    });
  });

  group('MentionTextEditingController - 初始化与序列化', () {
    testWidgets('初始化：空文本、普通文本、编码格式', (WidgetTester tester) async {
      // 空文本
      final c1 = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c1)),
        ),
      );
      expect(c1.segments, isEmpty);
      expect(c1.displayText, '');
      expect(c1.displayText, isEmpty);

      // 普通文本
      final c2 = MentionTextEditingController(text: 'Hello');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c2)),
        ),
      );
      expect(c2.segments.length, 1);
      expect((c2.segments[0] as TextSegment).value, 'Hello');
      expect(c2.displayText, 'Hello');

      // 编码格式
      final c3 = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c3)),
        ),
      );
      expect(c3.segments.length, 3);
      expect(c3.displayText, 'Hello @Alice$_me world');
      expect(c3.segments.any((s) => s is MentionSegment && s.label == 'Alice'), isTrue);
    });

    testWidgets('序列化：encode/decode 往返', (WidgetTester tester) async {
      final original = 'Test @label1$_me end';
      final c1 = MentionTextEditingController(text: original);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c1)),
        ),
      );

      final exported = c1.displayText;
      expect(exported, original);

      final c2 = MentionTextEditingController(text: exported);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c2)),
        ),
      );
      expect(c2.displayText, original);
      expect(c2.displayText, c1.displayText);
    });

    testWidgets('严格格式：@label\\uE000 才解析为 mention', (WidgetTester tester) async {
      // 无结束符 → 纯文本
      final c1 = MentionTextEditingController(text: 'Hello @Alice world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c1)),
        ),
      );
      expect(c1.segments.length, 1);
      expect((c1.segments[0] as TextSegment).value, 'Hello @Alice world');

      // 有结束符 → mention
      final c2 = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c2)),
        ),
      );
      expect(c2.segments.length, 3);
      expect(c2.segments.any((s) => s is MentionSegment && s.label == 'Alice'), isTrue);
    });

    testWidgets('segments 只读', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'test');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );
      expect(() => controller.segments.add(TextSegment('new')), throwsUnsupportedError);
    });
  });

  group('MentionTextEditingController - 核心功能', () {
    testWidgets('insertMention', (WidgetTester tester) async {
      // 测试 insertMention 方法本身（模拟用户输入 @ 后选择 mention 的场景）
      final controller = MentionTextEditingController(text: 'Hello @');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 模拟用户输入 @ 后，mentionState 自动触发（真实场景）
      // 注意：这里手动设置是为了测试 insertMention 方法，实际使用中 mentionState 会由 _updateMentionState 自动设置
      controller.value = TextEditingValue(text: 'Hello @', selection: TextSelection.collapsed(offset: 7));
      await tester.pump();
      // 确保 mentionState 已设置（如果未自动设置，手动设置以测试 insertMention）
      if (controller.mentionState.value == null) {
        controller.mentionState.value = (startIndex: 6, query: '');
      }

      controller.insertMention('users');
      await tester.pump();

      expect(controller.displayText, 'Hello @users$_me');
      expect(controller.segments.length, 2);
      expect((controller.segments[1] as MentionSegment).label, 'users');

      // 无 state 时不执行（边界情况测试）
      final c2 = MentionTextEditingController(text: 'Hello');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c2)),
        ),
      );
      final len = c2.segments.length;
      c2.insertMention('label');
      expect(c2.segments.length, len);
    });

    testWidgets('mentionState 触发与清除', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 这里不要用 tester.enterText，因为 MentionTextField 内部的隐藏 TextField 是为了兼容测试查找，
      // 但它并不等价于真实的输入链路（真实逻辑由 controller.value 驱动）。
      controller.value = const TextEditingValue(
        text: 'Hello @',
        selection: TextSelection.collapsed(offset: 7),
      );
      await tester.pump();
      expect(controller.mentionState.value, isNotNull);
      expect(controller.mentionState.value!.startIndex, 6);
      expect(controller.mentionState.value!.query, '');

      controller.value = const TextEditingValue(
        text: 'Hello @al',
        selection: TextSelection.collapsed(offset: 9),
      );
      await tester.pump();
      expect(controller.mentionState.value!.query, 'al');

      controller.value = const TextEditingValue(
        text: 'Hello @al ',
        selection: TextSelection.collapsed(offset: 10),
      );
      await tester.pump();
      expect(controller.mentionState.value, isNull);
    });

    testWidgets('文本编辑：插入、删除、mention 前后操作', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 插入文本（模拟用户输入，而不是替换整个文本）
      controller.value = TextEditingValue(
        text: 'Hello world',
        selection: TextSelection.collapsed(offset: 11),
      );
      await tester.pump();
      expect(controller.displayText, 'Hello world');

      // 在 mention 后插入
      final c2 = MentionTextEditingController(text: 'Hello @Alice$_me');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c2)),
        ),
      );
      final driverText = c2.text;
      c2.value = TextEditingValue(
        text: '$driverText world',
        selection: TextSelection.collapsed(offset: driverText.length + 6),
      );
      await tester.pump();
      expect(c2.displayText, 'Hello @Alice$_me world');
    });

    testWidgets('删除 mention', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      final driverText = controller.text;
      final mentionPos = driverText.indexOf('\uE000');

      // 重构后使用原生 TextField 处理退格/删除，这里用 controller.value 模拟删除 placeholder
      final newDriverText = driverText.replaceRange(mentionPos, mentionPos + 1, '');
      controller.value = TextEditingValue(
        text: newDriverText,
        selection: TextSelection.collapsed(offset: mentionPos),
      );
      await tester.pump();

      // 验证 mention 已被删除
      expect(controller.displayText, isNot(contains('@Alice')));
      expect(controller.segments.any((s) => s is MentionSegment && s.label == 'Alice'), isFalse);
    });

    testWidgets('deleteBackward/deleteForward', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // deleteBackward - 删除普通文本（模拟删除最后一个字符）
      final t1 = controller.text;
      controller.value = TextEditingValue(
        text: t1.substring(0, t1.length - 1),
        selection: TextSelection.collapsed(offset: t1.length - 1),
      );
      await tester.pump();
      expect(controller.displayText, 'Hello worl');

      // deleteForward - 删除普通文本（模拟删除第一个字符）
      final t2 = controller.text;
      controller.value = TextEditingValue(
        text: t2.substring(1),
        selection: const TextSelection.collapsed(offset: 0),
      );
      await tester.pump();
      expect(controller.displayText, 'ello worl');

      // 删除选中内容（模拟用新 value 替换）
      final t3 = controller.text;
      controller.value = TextEditingValue(
        text: t3.replaceRange(0, 4, ''),
        selection: const TextSelection.collapsed(offset: 0),
      );
      await tester.pump();
      expect(controller.displayText, ' worl');

      // 删除 mention（模拟删除 placeholder）
      final c2 = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c2)),
        ),
      );
      final driverText = c2.text;
      final mentionPos = driverText.indexOf(_me);
      c2.value = TextEditingValue(
        text: driverText.replaceRange(mentionPos, mentionPos + 1, ''),
        selection: TextSelection.collapsed(offset: mentionPos),
      );
      await tester.pump();
      expect(c2.displayText, 'Hello  world');
      expect(c2.segments.any((s) => s is MentionSegment), isFalse);

      // 删除 mention（模拟删除 placeholder）
      final c3 = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c3)),
        ),
      );
      final driverText3 = c3.text;
      final mentionPos3 = driverText3.indexOf(_me);
      c3.value = TextEditingValue(
        text: driverText3.replaceRange(mentionPos3, mentionPos3 + 1, ''),
        selection: TextSelection.collapsed(offset: mentionPos3),
      );
      await tester.pump();
      expect(c3.displayText, 'Hello  world');
      expect(c3.segments.any((s) => s is MentionSegment), isFalse);
    });

    testWidgets('buildTextSpan', (WidgetTester tester) async {
      final c1 = MentionTextEditingController(text: 'Hello');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  Text.rich(c1.buildTextSpan(context: context, style: const TextStyle(), withComposing: false)),
            ),
          ),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);

      final c2 = MentionTextEditingController(text: 'Hello @Alice$_me');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  Text.rich(c2.buildTextSpan(context: context, style: const TextStyle(), withComposing: false)),
            ),
          ),
        ),
      );
      expect(find.textContaining('Hello'), findsOneWidget);
      // mention 由 WidgetSpan 渲染，显示 segment.label（无 @ 前缀）
      expect(find.text('Alice'), findsOneWidget);
    });
  });

  group('MentionTextEditingController - 边界情况', () {
    testWidgets('空、只有 mention、loadFromEncodedString', (WidgetTester tester) async {
      // 空
      final c1 = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c1)),
        ),
      );
      expect(c1.segments, isEmpty);
      expect(c1.displayText, isEmpty);

      // 只有 mention
      final c2 = MentionTextEditingController(text: '@Alice$_me');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c2)),
        ),
      );
      expect(c2.displayText, '@Alice$_me');
      expect(c2.segments.length, 1);
      expect(c2.segments.any((s) => s is MentionSegment && s.label == 'Alice'), isTrue);

      // loadFromEncodedString
      final c3 = MentionTextEditingController(text: 'Initial');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c3)),
        ),
      );
      c3.loadFromEncodedString('New @Bob$_me');
      await tester.pump();
      expect(c3.displayText, 'New @Bob$_me');
      expect(c3.segments.length, 2);
    });

    testWidgets('光标调整', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      final driverText = controller.text;
      final mentionPos = driverText.indexOf('\uE000');

      controller.value = TextEditingValue(
        text: driverText,
        selection: TextSelection.collapsed(offset: mentionPos - 1),
      );
      controller.value = TextEditingValue(
        text: driverText,
        selection: TextSelection.collapsed(offset: mentionPos),
      );
      await tester.pump();

      final finalPos = controller.selection.extentOffset;
      expect(finalPos == mentionPos || finalPos == mentionPos + 1, isTrue);
    });
  });

  group('MentionTextEditingController - 中文输入法支持', () {
    testWidgets('composing 状态立即处理文本变化', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // composing 状态 - 现在会立即处理（不再跳过）
      controller.value = TextEditingValue(
        text: 'Helloni',
        selection: TextSelection.collapsed(offset: 7),
        composing: TextRange(start: 4, end: 7),
      );
      await tester.pump();
      // 文本会被立即处理，不再跳过 composing 状态
      expect(controller.displayText, 'Helloni');
    });

    testWidgets('composing 时立即处理文本变化', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      final initialLen = controller.segments.length;
      final driverText = controller.text;
      controller.value = TextEditingValue(
        text: '$driverText你好',
        selection: TextSelection.collapsed(offset: driverText.length + 2),
        composing: TextRange(start: driverText.length, end: driverText.length + 2),
      );
      await tester.pump();

      // 现在会立即处理，segments 数量会增加
      expect(controller.segments.length, initialLen + 1);
      expect(controller.displayText, 'Hello @Alice$_me world你好');
    });
  });

  group('MentionTextField - Widget', () {
    testWidgets('基本渲染和自定义属性', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentionTextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter text'),
              minLines: 2,
              maxLines: 5,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('键盘 Backspace 删除 mention（整块删除）', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      final driverText = controller.text;
      final mentionPos = driverText.indexOf(_me);
      // 光标放在 placeholder 后面，按 backspace 应删除 placeholder，进而删除整个 mention segment
      controller.selection = TextSelection.collapsed(offset: mentionPos + 1);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(controller.displayText, 'Hello  world');
      expect(controller.segments.any((s) => s is MentionSegment && s.label == 'Alice'), isFalse);
    });

    testWidgets('键盘 Delete 删除 mention（整块删除）', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      final driverText = controller.text;
      final mentionPos = driverText.indexOf(_me);
      // 光标放在 placeholder 上，按 delete 应删除 placeholder，进而删除整个 mention segment
      controller.selection = TextSelection.collapsed(offset: mentionPos);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();

      expect(controller.displayText, 'Hello  world');
      expect(controller.segments.any((s) => s is MentionSegment && s.label == 'Alice'), isFalse);
    });

    testWidgets('overlay：↓选择后 Enter 确认插入正确候选', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '');

      FutureOr<List<MentionCandidate>> candidates(String query) {
        return const [
          MentionCandidate(label: 'users'),
          MentionCandidate(label: 'orders'),
        ];
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentionTextField(
              controller: controller,
              mentionCandidatesBuilder: candidates,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '@');
      await tester.pump(); // 触发 mentionState
      await tester.pump(); // 等待候选加载显示

      expect(find.text('users'), findsOneWidget);
      expect(find.text('orders'), findsOneWidget);

      // 默认选中第 0 个，按 ↓ 选中第 1 个，再按 Enter 插入
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(controller.displayText, '@orders$_me');
    });

    testWidgets('overlay：Esc 关闭候选列表', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '');

      FutureOr<List<MentionCandidate>> candidates(String query) {
        return const [MentionCandidate(label: 'users')];
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentionTextField(
              controller: controller,
              mentionCandidatesBuilder: candidates,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '@');
      await tester.pump();
      await tester.pump();

      expect(find.text('users'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(find.text('users'), findsNothing);
    });

    testWidgets('Enter=发送；Shift/Ctrl+Enter=换行（桌面端）', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '');
      int submitCount = 0;
      String? submitted;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentionTextField(
              controller: controller,
              maxLines: 5,
              onSubmitted: (v) {
                submitCount++;
                submitted = v;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();

      // Shift+Enter 插入换行，不发送
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(controller.displayText, 'a\n');
      expect(submitCount, 0);

      // 再补一个字符（简化：直接替换为期望文本），然后 Enter 发送
      await tester.enterText(find.byType(TextField), 'a\nb');
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(submitCount, 1);
      expect(submitted, 'a\nb');

      // Ctrl+Enter 也插入换行，不发送
      controller.value = const TextEditingValue(
        text: 'x',
        selection: TextSelection.collapsed(offset: 1),
      );
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(controller.displayText, 'x\n');
      expect(submitCount, 1);
    });

    testWidgets('IME composing 时 Enter 不触发发送', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '');
      int submitCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentionTextField(
              controller: controller,
              maxLines: 5,
              onSubmitted: (_) => submitCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      // 模拟中文输入法组字中：text 已有拼音，composing 未提交
      controller.value = const TextEditingValue(
        text: 'nihao',
        selection: TextSelection.collapsed(offset: 5),
        composing: TextRange(start: 0, end: 5),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(submitCount, 0);
      expect(controller.displayText, 'nihao');
    });

    testWidgets('表 token：hover 显示删除 icon，点击后从输入中移除', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '@users$_me');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentionTextField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(controller.displayText, '@users$_me');
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      // 用鼠标移入触发 hover，ValueKey 格式为 table_mention_${segment.label}
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer();
      await mouse.moveTo(tester.getCenter(find.byKey(const ValueKey('table_mention_users'))));
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(controller.displayText, '');
      expect(controller.segments.whereType<MentionSegment>().isEmpty, isTrue);
    });

    testWidgets('选区跨 mention 后 Backspace 删除（mention 作为原子 token）', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      final driverText = controller.text;
      final mentionPos = driverText.indexOf(_me);

      // 选中 "o " + mention + " w"（确保范围包含 placeholder）
      // driver: "Hello \uE000 world"（mentionPos 指向 placeholder）
      final start = (mentionPos - 2).clamp(0, driverText.length);
      final end = (mentionPos + 3).clamp(0, driverText.length);
      controller.selection = TextSelection(baseOffset: start, extentOffset: end);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      // mention 应被移除（并且选中范围对应的文本也被删除）
      expect(controller.segments.any((s) => s is MentionSegment && s.label == 'Alice'), isFalse);
      expect(controller.displayText, isNot(contains('@Alice')));
      expect(controller.displayText, contains('Hello'));
      // 选区会删掉 mention 周边部分字符，因此不强制包含完整 "world"
      expect(controller.displayText, contains('orld'));
    });

    testWidgets('复制为接近 displayText，粘贴回输入框可还原 mention', (WidgetTester tester) async {
      String? clipboardText;
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        switch (call.method) {
          case 'Clipboard.setData':
            clipboardText = (call.arguments as Map)['text'] as String?;
            return null;
          case 'Clipboard.getData':
            if (clipboardText == null) return null;
            return <String, dynamic>{'text': clipboardText};
          case 'Clipboard.hasStrings':
            return <String, dynamic>{'value': clipboardText != null};
        }
        return null;
      });

      final src = MentionTextEditingController(text: 'Hello @Alice$_me world');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: src)),
        ),
      );

      final driverText = src.text;
      final mentionPos = driverText.indexOf(_me);
      src.selection = TextSelection(baseOffset: mentionPos, extentOffset: mentionPos + 1);
      await tester.pump();

      await src.copySelectionToClipboard();
      final copied = clipboardText ?? '';

      expect(copied, contains('@Alice$_me'));

      // 粘贴回输入框应还原为 MentionSegment
      final dst = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: dst)),
        ),
      );
      await dst.pasteFromClipboard();
      await tester.pump();

      expect(dst.displayText, '@Alice$_me');
      expect(dst.segments.length, 1);
      expect(dst.segments.first is MentionSegment, isTrue);
      expect((dst.segments.first as MentionSegment).label, 'Alice');

      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });
  });

  group('MentionTextEditingController - dispose', () {
    testWidgets('dispose 清理资源', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: 'test');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );
      expect(controller.mentionState.value, isNull);
      controller.dispose();
      expect(() => controller.mentionState.value, returnsNormally);
    });
  });

  group('MentionTextEditingController - 完整用户场景', () {
    testWidgets('场景1: 完整的 mention 插入流程', (WidgetTester tester) async {
      // 用户输入普通文本
      final controller = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 1. 输入 "查询用户表 "
      controller.value = TextEditingValue(text: '查询用户表 ', selection: TextSelection.collapsed(offset: 6));
      await tester.pump();
      expect(controller.displayText, '查询用户表 ');
      expect(controller.mentionState.value, isNull);

      // 2. 输入 @ 符号，触发 mention 状态
      controller.value = TextEditingValue(text: '查询用户表 @', selection: TextSelection.collapsed(offset: 7));
      await tester.pump();
      expect(controller.mentionState.value, isNotNull);
      expect(controller.mentionState.value!.startIndex, 6);
      expect(controller.mentionState.value!.query, '');

      // 3. 输入查询文本 "users"
      controller.value = TextEditingValue(text: '查询用户表 @users', selection: TextSelection.collapsed(offset: 12));
      await tester.pump();
      expect(controller.mentionState.value, isNotNull);
      expect(controller.mentionState.value!.query, 'users');

      // 4. 插入 mention
      controller.insertMention('users');
      await tester.pump();
      expect(controller.displayText, '查询用户表 @users$_me');
      expect(controller.mentionState.value, isNull);
      expect(controller.segments.length, 2);
      expect((controller.segments[0] as TextSegment).value, '查询用户表 ');
      expect((controller.segments[1] as MentionSegment).label, 'users');

      // 5. 继续输入文本
      final driverText = controller.text;
      controller.value = TextEditingValue(
        text: '$driverText 的数据',
        selection: TextSelection.collapsed(offset: driverText.length + 4),
      );
      await tester.pump();
      expect(controller.displayText, '查询用户表 @users$_me 的数据');
      expect(controller.segments.length, 3);
      expect((controller.segments[2] as TextSegment).value, ' 的数据');
    });

    testWidgets('场景2: 多个 mention 的完整流程', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 1. 插入第一个 mention
      controller.value = TextEditingValue(text: '@', selection: TextSelection.collapsed(offset: 1));
      await tester.pump();
      controller.insertMention('users');
      await tester.pump();
      expect(controller.displayText, '@users$_me');

      // 2. 输入连接文本
      final driverText1 = controller.text;
      controller.value = TextEditingValue(
        text: '$driverText1 和 ',
        selection: TextSelection.collapsed(offset: driverText1.length + 3),
      );
      await tester.pump();
      expect(controller.displayText, '@users$_me 和 ');

      // 3. 插入第二个 mention
      final driverText2 = controller.text;
      controller.value = TextEditingValue(
        text: '$driverText2@',
        selection: TextSelection.collapsed(offset: driverText2.length + 1),
      );
      await tester.pump();
      controller.insertMention('orders');
      await tester.pump();
      expect(controller.displayText, '@users$_me 和 @orders$_me');
      expect(controller.segments.length, 3);
      expect((controller.segments[0] as MentionSegment).label, 'users');
      expect((controller.segments[1] as TextSegment).value, ' 和 ');
      expect((controller.segments[2] as MentionSegment).label, 'orders');
    });

    testWidgets('场景3: mention 在不同位置', (WidgetTester tester) async {
      // mention 在开头
      final c1 = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c1)),
        ),
      );
      c1.value = TextEditingValue(text: '@', selection: TextSelection.collapsed(offset: 1));
      await tester.pump();
      c1.insertMention('users');
      await tester.pump();
      expect(c1.displayText, '@users$_me');
      expect(c1.segments.length, 1);
      expect((c1.segments[0] as MentionSegment).label, 'users');

      // mention 在中间
      final c2 = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c2)),
        ),
      );
      c2.value = TextEditingValue(text: '查询 ', selection: TextSelection.collapsed(offset: 3));
      await tester.pump();
      c2.value = TextEditingValue(text: '查询 @', selection: TextSelection.collapsed(offset: 4));
      await tester.pump();
      c2.insertMention('users');
      await tester.pump();
      final driverText2 = c2.text;
      c2.value = TextEditingValue(
        text: '$driverText2 的数据',
        selection: TextSelection.collapsed(offset: driverText2.length + 4),
      );
      await tester.pump();
      expect(c2.displayText, '查询 @users$_me 的数据');
      expect(c2.segments.length, 3);

      // mention 在结尾
      final c3 = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: c3)),
        ),
      );
      c3.value = TextEditingValue(text: '查询 ', selection: TextSelection.collapsed(offset: 3));
      await tester.pump();
      c3.value = TextEditingValue(text: '查询 @', selection: TextSelection.collapsed(offset: 4));
      await tester.pump();
      c3.insertMention('users');
      await tester.pump();
      expect(c3.displayText, '查询 @users$_me');
      expect(c3.segments.length, 2);
      expect((c3.segments[1] as MentionSegment).label, 'users');
    });

    testWidgets('场景4: 删除 mention 后继续编辑', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '查询 @users$_me 的数据');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      expect(controller.displayText, '查询 @users$_me 的数据');
      expect(controller.segments.length, 3);

      // 删除 mention（使用 deleteBackward 方法）
      final driverText = controller.text;
      final mentionPos = driverText.indexOf(_me);
      // 重构后使用原生 TextField 处理退格/删除，这里用 controller.value 模拟删除 placeholder
      controller.value = TextEditingValue(
        text: driverText.replaceRange(mentionPos, mentionPos + 1, ''),
        selection: TextSelection.collapsed(offset: mentionPos),
      );
      await tester.pump();

      // 验证 mention 已被删除
      expect(controller.displayText, '查询  的数据');
      expect(controller.segments.length, 2);
      expect(controller.segments.any((s) => s is MentionSegment), isFalse);

      // 继续输入文本（在空格位置插入 "users"）
      final newDriverText = controller.text;
      // 在"查询"后（位置2）插入"users"
      controller.value = TextEditingValue(
        text: '${newDriverText.substring(0, 2)}users${newDriverText.substring(2)}',
        selection: TextSelection.collapsed(offset: 7),
      );
      await tester.pump();
      expect(controller.displayText, '查询users  的数据');
    });

    testWidgets('场景5: 在 mention 前后插入文本', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '查询 @users$_me 的数据');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 在 mention 前插入（在"查询"后插入"所有"）
      final driverText1 = controller.text;
      // 找到"查询"后的位置（索引2）
      controller.value = TextEditingValue(
        text: '${driverText1.substring(0, 2)}所有${driverText1.substring(2)}',
        selection: TextSelection.collapsed(offset: 5), // 在"所有"后
      );
      await tester.pump();
      expect(controller.displayText, '查询所有 @users$_me 的数据');

      // 在 mention 后插入
      final driverText2 = controller.text;
      final mentionPos = driverText2.indexOf(_me);
      controller.value = TextEditingValue(
        text: '${driverText2.substring(0, mentionPos + 1)} 表${driverText2.substring(mentionPos + 1)}',
        selection: TextSelection.collapsed(offset: mentionPos + 4),
      );
      await tester.pump();
      expect(controller.displayText, '查询所有 @users$_me 表 的数据');
    });

    testWidgets('场景6: 替换 mention 中的查询文本', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 输入 @users
      controller.value = TextEditingValue(text: '@users', selection: TextSelection.collapsed(offset: 6));
      await tester.pump();
      expect(controller.mentionState.value, isNotNull);
      expect(controller.mentionState.value!.query, 'users');

      // 删除 "users"，输入 "orders"（先删除，再输入）
      // 先删除 users（选中并删除）
      controller.value = TextEditingValue(
        text: '@',
        selection: TextSelection.collapsed(offset: 1),
      );
      await tester.pump();
      // 然后输入 orders
      controller.value = TextEditingValue(text: '@orders', selection: TextSelection.collapsed(offset: 7));
      await tester.pump();
      expect(controller.mentionState.value, isNotNull);
      expect(controller.mentionState.value!.query, 'orders');

      // 插入 mention
      controller.insertMention('orders');
      await tester.pump();
      expect(controller.displayText, '@orders$_me');
      expect((controller.segments[0] as MentionSegment).label, 'orders');
    });

    testWidgets('场景7: 取消 mention（输入空格）', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 输入 @users
      controller.value = TextEditingValue(text: '@users', selection: TextSelection.collapsed(offset: 6));
      await tester.pump();
      expect(controller.mentionState.value, isNotNull);

      // 输入空格，取消 mention 状态
      controller.value = TextEditingValue(text: '@users ', selection: TextSelection.collapsed(offset: 7));
      await tester.pump();
      expect(controller.mentionState.value, isNull);
      expect(controller.displayText, '@users ');
    });

    testWidgets('场景8: 从编码字符串恢复并继续编辑', (WidgetTester tester) async {
      // 模拟从服务器加载已保存的内容
      final encoded = '查询 @users$_me 和 @orders$_me 的数据';
      final controller = MentionTextEditingController(text: encoded);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      expect(controller.displayText, '查询 @users$_me 和 @orders$_me 的数据');
      // segments 数量可能因文本分割而不同，只要包含正确的 mention 即可
      final hasUsersMention = controller.segments.any((s) => s is MentionSegment && s.label == 'users');
      final hasOrdersMention = controller.segments.any((s) => s is MentionSegment && s.label == 'orders');
      expect(hasUsersMention, isTrue);
      expect(hasOrdersMention, isTrue);

      // 继续编辑：在末尾添加文本
      final driverText = controller.text;
      controller.value = TextEditingValue(
        text: '$driverText，按时间排序',
        selection: TextSelection.collapsed(offset: driverText.length + 6),
      );
      await tester.pump();
      expect(controller.displayText, '查询 @users$_me 和 @orders$_me 的数据，按时间排序');

      // 验证编码格式仍然正确
      expect(controller.displayText, contains('@users$_me'));
      expect(controller.displayText, contains('@orders$_me'));
    });

    testWidgets('场景9: 复杂的编辑操作（选中删除、替换）', (WidgetTester tester) async {
      final controller = MentionTextEditingController(text: '查询 @users$_me 和 @orders$_me');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MentionTextField(controller: controller)),
        ),
      );

      // 选中并删除第一个 mention 和中间的文本
      final driverText = controller.text;
      // driver string 结构: "查询 \uE000 和 \uE000"
      // segments: [TextSegment("查询 "), MentionSegment("users"), TextSegment(" 和 "), MentionSegment("orders")]
      // 需要选中从第一个 mention 开始到第二个 mention 之后，才能删除所有内容
      final firstMentionPos = driverText.indexOf(_me);
      final secondMentionPos = driverText.lastIndexOf(_me);

      // 选中从第一个 mention 开始到第二个 mention 之后
      final startPos = firstMentionPos; // 第一个 mention 开始
      final endPos = secondMentionPos + 1; // 第二个 mention 后
      controller.value = TextEditingValue(
        text: driverText,
        selection: TextSelection(baseOffset: startPos, extentOffset: endPos),
      );
      await tester.pump();
      // 模拟删除选中范围
      controller.value = TextEditingValue(
        text: driverText.replaceRange(startPos, endPos, ''),
        selection: TextSelection.collapsed(offset: startPos),
      );
      await tester.pump();

      // 验证选中范围内的内容被删除
      // 选中范围从第一个 mention 开始到第二个 mention 之后
      // 应该删除两个 mention 和中间的文本，只保留前面的 "查询"
      expect(controller.displayText, isNot(contains('@users')));
      expect(controller.displayText, isNot(contains('@orders')));
      // 验证 segments 中不包含任何 mention
      final hasAnyMention = controller.segments.any((s) => s is MentionSegment);
      expect(hasAnyMention, isFalse);
      // 验证前面未选中的文本保留
      expect(controller.displayText, contains('查询'));
    });
  });

  // 光标移动/方向键行为由 Flutter 原生 TextField/EditableText 负责，此处不再做 controller 级别的定制测试。
}
