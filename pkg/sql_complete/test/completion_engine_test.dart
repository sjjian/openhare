import 'package:sql_complete/training.dart';
import 'package:test/test.dart';

import 'sample_spans.dart';

void main() {
  const catalog = SqlCompleteCatalog(
    keywords: [
      SqlCompleteCatalogEntry(text: 'SELECT', kind: SqlCompleteKind.keyword),
      SqlCompleteCatalogEntry(text: 'FROM', kind: SqlCompleteKind.keyword),
      SqlCompleteCatalogEntry(text: 'WHERE', kind: SqlCompleteKind.keyword),
    ],
    objects: [
      SqlCompleteCatalogEntry(text: 'users', kind: SqlCompleteKind.table),
      SqlCompleteCatalogEntry(text: 'orders', kind: SqlCompleteKind.table),
      SqlCompleteCatalogEntry(text: 'id', kind: SqlCompleteKind.column),
      SqlCompleteCatalogEntry(text: 'name', kind: SqlCompleteKind.column),
    ],
    related: {
      't': [
        SqlCompleteCatalogEntry(text: 'id', kind: SqlCompleteKind.column),
        SqlCompleteCatalogEntry(text: 'name', kind: SqlCompleteKind.column),
      ],
    },
  );

  test('当前语句为空不弹窗', () {
    final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
    expect(
      engine
          .complete(const SqlCompletionRequest(sqlPrefix: '', lineBefore: ''))
          .isEmpty,
      isTrue,
    );
    expect(
      engine
          .complete(const SqlCompletionRequest(
            sqlPrefix: 'SELECT * FROM db WHERE id = 1 LIMIT 1; ',
            lineBefore: 'SELECT * FROM db WHERE id = 1 LIMIT 1; ',
          ))
          .isEmpty,
      isTrue,
    );
  });

  test('无模型时空词不倾倒 catalog', () {
    final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT id FROM ',
      lineBefore: 'SELECT id FROM ',
    ));
    expect(result.isEmpty, isTrue);
  });

  test('FROM 后空词靠模型出表', () async {
    final predictor = await _tinyFromPredictor();
    final engine = SqlCompletionEngine(enableModel: false, 
      predictor: predictor,
      catalog: catalog,
    );
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT id FROM ',
      lineBefore: 'SELECT id FROM ',
    ));
    expect(result.input, '');
    expect(result.items.map((i) => i.text), contains('users'));
    expect(
      result.items.where((i) => i.kind == SqlCompleteKind.table).isNotEmpty,
      isTrue,
    );
  });

  test('半截词 sel 合并 catalog 模糊', () {
    final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'sel',
      lineBefore: 'sel',
    ));
    expect(result.input, 'sel');
    expect(result.items.any((i) => i.text.toUpperCase() == 'SELECT'), isTrue);
  });

  test('语句首字母 s：模型 select 优先于短关键字 S3 fuzzy', () async {
    final catalogWithS3 = SqlCompleteCatalog(
      keywords: [
        ...catalog.keywords,
        const SqlCompleteCatalogEntry(text: 'S3', kind: SqlCompleteKind.keyword),
        const SqlCompleteCatalogEntry(text: 'SET', kind: SqlCompleteKind.keyword),
      ],
      objects: catalog.objects,
      related: catalog.related,
    );
    final trainer = SqlTokenTrainer(
      config: const TrainConfig(
        epochs: 25,
        learningRate: 1e-2,
        embedDim: 16,
        hiddenDim: 16,
        numLayers: 1,
        logEvery: 0,
        shuffle: true,
        seed: 11,
        valRatio: 0,
        prefixStride: 1,
      ),
    );
    final ckpt = await trainer.fit([
      for (var i = 0; i < 30; i++)
        const SqlSample(sql: 'SELECT id FROM users'),
      for (var i = 0; i < 5; i++)
        const SqlSample(sql: 'INSERT INTO users VALUES (1)'),
    ]);
    final engine = SqlCompletionEngine(enableModel: false, 
      predictor: ckpt.toPredictor(),
      catalog: catalogWithS3,
      topK: 24,
    );
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 's',
      lineBefore: 's',
    ));
    expect(result.items, isNotEmpty);
    expect(result.items.first.text.toLowerCase(), 'select');
  });

  test('点号上下文用 related', () {
    final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT t.',
      lineBefore: 'SELECT t.',
    ));
    expect(result.input, '');
    expect(result.items.map((i) => i.text), containsAll(['id', 'name']));
    // related 求交：不应出现无关表名
    expect(result.items.map((i) => i.text), isNot(contains('users')));
  });

  test('点号后半截词过滤 related', () {
    final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT t.na',
      lineBefore: 'SELECT t.na',
    ));
    expect(result.items.map((i) => i.text), contains('name'));
    expect(result.items.map((i) => i.text), isNot(contains('id')));
  });

  test('点号无 related 则空', () {
    final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT unknown.',
      lineBefore: 'SELECT unknown.',
    ));
    expect(result.isEmpty, isTrue);
  });

  test('currentStatementPrefix 截到当前语句且只 trimLeft', () {
    expect(
      SqlCompletionEngine.currentStatementPrefix('SELECT 1;\n  '),
      '',
    );
    expect(
      SqlCompletionEngine.currentStatementPrefix('SELECT 1;\nSELECT id FROM'),
      'SELECT id FROM',
    );
    // 保留尾部空格，避免 FROM␠ 被 trim 成 FROM 后误判半截词。
    expect(
      SqlCompletionEngine.currentStatementPrefix('SELECT 1;\n  FROM '),
      'FROM ',
    );
  });

  test('related 对 t1 / t1_1 exact 查找，互不抢绑', () {
    const cat = SqlCompleteCatalog(
      related: {
        't1': [
          SqlCompleteCatalogEntry(text: 'a', kind: SqlCompleteKind.column),
        ],
        't1_1': [
          SqlCompleteCatalogEntry(text: 'b', kind: SqlCompleteKind.column),
        ],
      },
    );
    final engine = SqlCompletionEngine(enableModel: false, catalog: cat);
    final t1 = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT t1.',
      lineBefore: 'SELECT t1.',
    ));
    expect(t1.items.map((i) => i.text), ['a']);
    expect(t1.items.map((i) => i.text), isNot(contains('b')));

    final t11 = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT t1_1.',
      lineBefore: 'SELECT t1_1.',
    ));
    expect(t11.items.map((i) => i.text), ['b']);
    expect(t11.items.map((i) => i.text), isNot(contains('a')));
  });

  test('related 键大小写不敏感', () {
    const cat = SqlCompleteCatalog(
      related: {
        'users': [
          SqlCompleteCatalogEntry(text: 'id', kind: SqlCompleteKind.column),
        ],
      },
    );
    final engine = SqlCompletionEngine(enableModel: false, catalog: cat);
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT Users.',
      lineBefore: 'SELECT Users.',
    ));
    expect(result.items.map((i) => i.text), contains('id'));
  });

  group('双通道：模型 top fuzzy ∪ 全量 catalog fuzzy', () {
    const mergeCatalog = SqlCompleteCatalog(
      keywords: [
        SqlCompleteCatalogEntry(text: 'SELECT', kind: SqlCompleteKind.keyword),
        SqlCompleteCatalogEntry(text: 'FROM', kind: SqlCompleteKind.keyword),
        SqlCompleteCatalogEntry(text: 'UPDATE', kind: SqlCompleteKind.keyword),
      ],
      objects: [
        SqlCompleteCatalogEntry(text: 'users', kind: SqlCompleteKind.table),
        SqlCompleteCatalogEntry(text: 't_sales', kind: SqlCompleteKind.table),
        SqlCompleteCatalogEntry(text: 'orders', kind: SqlCompleteKind.table),
        SqlCompleteCatalogEntry(text: 'user_id', kind: SqlCompleteKind.column),
        SqlCompleteCatalogEntry(text: 'name', kind: SqlCompleteKind.column),
      ],
      related: {
        't': [
          SqlCompleteCatalogEntry(text: 'id', kind: SqlCompleteKind.column),
          SqlCompleteCatalogEntry(text: 'name', kind: SqlCompleteKind.column),
          SqlCompleteCatalogEntry(text: 'created_at', kind: SqlCompleteKind.column),
        ],
      },
    );

    test('有半截词：模型候选经 fuzzy，滤不中的不进 A', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: 'SELECT',
            id: 1,
            score: 0.9,
            kind: SqlCompleteKind.keyword,
          ),
          Prediction(
            token: 'FROM',
            id: 2,
            score: 0.5,
            kind: SqlCompleteKind.keyword,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'sel',
        lineBefore: 'sel',
      ));
      expect(result.input, 'sel');
      // SELECT fuzzy 命中；FROM 不命中，不进模型通道
      expect(result.items.map((i) => i.text.toUpperCase()), contains('SELECT'));
      // 全量 fuzzy 也不该把 FROM 扫进来
      expect(
        result.items.any((i) => i.text.toUpperCase() == 'FROM'),
        isFalse,
      );
    });

    test('有半截词：全量 catalog fuzzy 补模型未覆盖项', () {
      // 模型只给无关关键字；slct 仍能从全量 fuzzy 出 SELECT
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: 'WHERE',
            id: 1,
            score: 0.99,
            kind: SqlCompleteKind.keyword,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'slct',
        lineBefore: 'slct',
      ));
      expect(result.items.any((i) => i.text.toUpperCase() == 'SELECT'), isTrue);
      // WHERE 对 slct 不 fuzzy，不应出现
      expect(
        result.items.any((i) => i.text.toUpperCase() == 'WHERE'),
        isFalse,
      );
    });

    test('有半截词：模型命中项永远排在全量 fuzzy 之前', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<TABLE>',
            id: 0,
            score: 0.4,
            kind: SqlCompleteKind.table,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM us',
        lineBefore: 'SELECT * FROM us',
      ));
      expect(result.input, 'us');
      expect(result.items.map((i) => i.text), contains('users'));
      // users 来自模型 TABLE 展开，应在列表前部（先于仅靠全量 fuzzy 的项）
      final usersIdx = result.items.indexWhere((i) => i.text == 'users');
      expect(usersIdx, 0);
    });

    test('有半截词：模型与全量 fuzzy 同名去重，保留模型分', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: 'SELECT',
            id: 1,
            score: 0.88,
            kind: SqlCompleteKind.keyword,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'sel',
        lineBefore: 'sel',
      ));
      final selects =
          result.items.where((i) => i.text.toUpperCase() == 'SELECT').toList();
      expect(selects, hasLength(1));
      // 保留模型通道的 score，而非 fuzzy 通道分数
      expect(selects.single.score, 0.88);
    });

    test('有半截词：大小写不同视为同一项去重', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: 'select',
            id: 1,
            score: 0.7,
            kind: SqlCompleteKind.keyword,
          ),
        ]),
        catalog: const SqlCompleteCatalog(
          keywords: [
            SqlCompleteCatalogEntry(text: 'SELECT', kind: SqlCompleteKind.keyword),
          ],
        ),
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'sel',
        lineBefore: 'sel',
      ));
      expect(
        result.items.where((i) => i.text.toLowerCase() == 'select'),
        hasLength(1),
      );
      expect(result.items.first.text, 'select');
      expect(result.items.first.score, 0.7);
    });

    test('有半截词：TABLE 展开经 fuzzy 命中非前缀表名', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<TABLE>',
            id: 0,
            score: 0.6,
            kind: SqlCompleteKind.table,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM ts',
        lineBefore: 'SELECT * FROM ts',
      ));
      expect(result.items.map((i) => i.text), contains('t_sales'));
      expect(result.items.map((i) => i.text), isNot(contains('orders')));
    });

    test('有半截词：关键字预测与表 fuzzy 可同时出现，模型关键字在前', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: 'UPDATE',
            id: 1,
            score: 0.55,
            kind: SqlCompleteKind.keyword,
          ),
        ]),
        catalog: mergeCatalog,
      );
      // "up" fuzzy → UPDATE；同时 "users" 含 u+p? users: u,s,e,r,s — 无 p，不命中
      // "t_sales" 无 u/p 连续。UPDATE 命中。
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'up',
        lineBefore: 'up',
      ));
      expect(result.items.map((i) => i.text.toUpperCase()), contains('UPDATE'));
      expect(result.items.first.text.toUpperCase(), 'UPDATE');
    });

    test('无半截词：不扫全量 catalog fuzzy', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<TABLE>',
            id: 0,
            score: 0.9,
            kind: SqlCompleteKind.table,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM ',
        lineBefore: 'SELECT * FROM ',
      ));
      expect(result.input, '');
      // 只有模型展开的表，没有仅靠 fuzzy 才会出现的「半截 typo」路径；
      // 关键字不应被空半截灌进列表。
      expect(result.items.every((i) => i.kind == SqlCompleteKind.table), isTrue);
      expect(result.items.map((i) => i.text).toSet(), containsAll(['users', 't_sales', 'orders']));
      expect(
        result.items.any((i) => i.kind == SqlCompleteKind.keyword),
        isFalse,
      );
    });

    test('无半截词且无模型：空结果，不倾倒 catalog', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: mergeCatalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM ',
        lineBefore: 'SELECT * FROM ',
      ));
      expect(result.isEmpty, isTrue);
    });

    test('无半截词 + 点号：related 全集，不进 fuzzy', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<COLUMN>',
            id: 0,
            score: 0.8,
            kind: SqlCompleteKind.column,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT t.',
        lineBefore: 'SELECT t.',
      ));
      expect(result.input, '');
      expect(
        result.items.map((i) => i.text).toSet(),
        {'id', 'name', 'created_at'},
      );
      expect(result.items.map((i) => i.text), isNot(contains('users')));
    });

    test('有半截词 + 点号：只对 related 做 fuzzy，不扫全库', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<COLUMN>',
            id: 0,
            score: 0.8,
            kind: SqlCompleteKind.column,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT t.na',
        lineBefore: 'SELECT t.na',
      ));
      expect(result.items.map((i) => i.text), contains('name'));
      expect(result.items.map((i) => i.text), isNot(contains('id')));
      expect(result.items.map((i) => i.text), isNot(contains('users')));
      expect(result.items.map((i) => i.text), isNot(contains('t_sales')));
    });

    test('有半截词 + 点号无 related：空结果', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<COLUMN>',
            id: 0,
            score: 0.8,
            kind: SqlCompleteKind.column,
          ),
        ]),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT unknown.x',
        lineBefore: 'SELECT unknown.x',
      ));
      expect(result.isEmpty, isTrue);
    });

    test('exact 半截词：分数为 1.0 且不垫底', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: mergeCatalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT',
        lineBefore: 'SELECT',
      ));
      expect(result.items.first.text.toUpperCase(), 'SELECT');
      expect(result.items.first.score, 1.0);
      expect(result.items.first.matchPositions, isNotNull);
      expect(result.items.first.matchPositions, [0, 1, 2, 3, 4, 5]);
    });

    test('exact 半截词大小写不敏感', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: mergeCatalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'select',
        lineBefore: 'select',
      ));
      expect(result.items.first.text.toUpperCase(), 'SELECT');
      expect(result.items.first.score, 1.0);
      expect(result.items.first.matchPositions, [0, 1, 2, 3, 4, 5]);
    });

    test('fuzzy 命中带 matchPositions', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: mergeCatalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'slct',
        lineBefore: 'slct',
      ));
      final select =
          result.items.firstWhere((i) => i.text.toUpperCase() == 'SELECT');
      expect(select.matchPositions, isNotNull);
      expect(select.matchPositions, isNotEmpty);
      expect(select.matchPositions!.length, 4); // s,l,c,t
    });

    test('maxItems 截断仍保持模型在前', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<TABLE>',
            id: 0,
            score: 0.95,
            kind: SqlCompleteKind.table,
          ),
        ]),
        catalog: mergeCatalog,
        maxItems: 2,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM u',
        lineBefore: 'SELECT * FROM u',
      ));
      expect(result.items.length, lessThanOrEqualTo(2));
      // 模型展开的 users 应排在截断列表最前
      expect(result.items.first.text, 'users');
      expect(result.items.first.kind, SqlCompleteKind.table);
    });

    test('maxExpandPerPrediction 只限制模型展开，不限制全量 fuzzy', () {
      final many = SqlCompleteCatalog(
        objects: [
          for (var i = 0; i < 30; i++)
            SqlCompleteCatalogEntry(text: 'user_$i', kind: SqlCompleteKind.table),
        ],
      );
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<TABLE>',
            id: 0,
            score: 0.9,
            kind: SqlCompleteKind.table,
          ),
        ]),
        catalog: many,
        maxExpandPerPrediction: 3,
        maxItems: 100,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM us',
        lineBefore: 'SELECT * FROM us',
      ));
      // 模型最多展开 3 个；全量 fuzzy 仍可继续补更多 user_*
      expect(result.items.length, greaterThan(3));
      expect(result.items.every((i) => i.text.startsWith('user_')), isTrue);
    });

    test('模型异常时仍走全量 fuzzy', () {
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _ThrowingPredictor(),
        catalog: mergeCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'sel',
        lineBefore: 'sel',
      ));
      expect(result.items.any((i) => i.text.toUpperCase() == 'SELECT'), isTrue);
    });

    test('训练小模型：半截词双通道可用', () async {
      final predictor = await _tinyFromPredictor();
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: predictor,
        catalog: catalog,
      );
      final typo = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'slct',
        lineBefore: 'slct',
      ));
      expect(typo.items.any((i) => i.text.toUpperCase() == 'SELECT'), isTrue);

      final hit = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT id FROM us',
        lineBefore: 'SELECT id FROM us',
      ));
      expect(hit.items.map((i) => i.text), contains('users'));
      expect(hit.items.first.text.toLowerCase(), 'users');
    });

    test('训练小模型：无半截词不进 fuzzy', () async {
      final predictor = await _tinyFromPredictor();
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: predictor,
        catalog: catalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT id FROM ',
        lineBefore: 'SELECT id FROM ',
      ));
      expect(result.input, '');
      expect(result.items.map((i) => i.kind), contains(SqlCompleteKind.table));
    });
  });

  test('半截词从当前语句取，与预测前缀剥离一致', () {
    final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT 1;  sel',
      lineBefore: 'sel',
    ));
    expect(result.input, 'sel');
    expect(result.items.any((i) => i.text.toUpperCase() == 'SELECT'), isTrue);
  });

  group('静态 helper', () {
    test('isDotContext', () {
      expect(SqlCompletionEngine.isDotContext(''), isFalse);
      expect(SqlCompletionEngine.isDotContext('t'), isFalse);
      expect(SqlCompletionEngine.isDotContext('t.'), isTrue);
      expect(SqlCompletionEngine.isDotContext('t.na'), isTrue);
      expect(SqlCompletionEngine.isDotContext('t.na '), isFalse);
      expect(SqlCompletionEngine.isDotContext('SELECT t1_1.'), isTrue);
      expect(SqlCompletionEngine.isDotContext('a.b.c'), isTrue);
    });

    test('extractInput / qualifierBeforeDot / extractWordBefore', () {
      expect(SqlCompletionEngine.extractInput(''), '');
      expect(SqlCompletionEngine.extractInput('FROM '), '');
      expect(SqlCompletionEngine.extractInput('t.'), '');
      expect(SqlCompletionEngine.extractInput('t.na'), 'na');
      expect(SqlCompletionEngine.extractInput('SELECT user_name'), 'user_name');
      expect(SqlCompletionEngine.qualifierBeforeDot('SELECT t.'), 't');
      expect(SqlCompletionEngine.qualifierBeforeDot('SELECT t1_1.col'), 't1_1');
      expect(SqlCompletionEngine.qualifierBeforeDot('SELECT a.b.'), 'b');
      expect(SqlCompletionEngine.qualifierBeforeDot('nodot'), isNull);
      expect(SqlCompletionEngine.extractWordBefore('ab_cd', 5), 'ab_cd');
      expect(SqlCompletionEngine.extractWordBefore('x ab_cd', 7), 'ab_cd');
    });

    test('isModelPlaceholder', () {
      expect(SqlCompletionEngine.isModelPlaceholder('<TABLE>'), isTrue);
      expect(SqlCompletionEngine.isModelPlaceholder('<OBJ>'), isTrue);
      expect(SqlCompletionEngine.isModelPlaceholder('<FOO>'), isTrue);
      expect(SqlCompletionEngine.isModelPlaceholder('select'), isFalse);
      expect(SqlCompletionEngine.isModelPlaceholder('<TABLE'), isFalse);
    });

    test('currentStatementPrefix 多语句与仅空白', () {
      expect(SqlCompletionEngine.currentStatementPrefix('a;b;c'), 'c');
      expect(SqlCompletionEngine.currentStatementPrefix(';'), '');
      expect(SqlCompletionEngine.currentStatementPrefix('  \n\t'), '');
      expect(
        SqlCompletionEngine.currentStatementPrefix('SELECT 1;--x\nWHERE '),
        '--x\nWHERE ',
      );
    });
  });

  group('字符串内不补全', () {
    test('未闭合单引号', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
      expect(
        engine
            .complete(const SqlCompletionRequest(
              sqlPrefix: "SELECT * FROM t WHERE name = 'hel",
              lineBefore: "SELECT * FROM t WHERE name = 'hel",
            ))
            .isEmpty,
        isTrue,
      );
    });

    test('未闭合双引号', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
      expect(
        engine
            .complete(const SqlCompletionRequest(
              sqlPrefix: 'SELECT "hel',
              lineBefore: 'SELECT "hel',
            ))
            .isEmpty,
        isTrue,
      );
    });

    test('转义后仍在单引号内', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
      expect(
        engine
            .complete(const SqlCompletionRequest(
              sqlPrefix: r"SELECT 'it\'s",
              lineBefore: r"SELECT 'it\'s",
            ))
            .isEmpty,
        isTrue,
      );
    });

    test('已闭合字符串后可继续补全', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: "SELECT 'x' fro",
        lineBefore: "SELECT 'x' fro",
      ));
      expect(result.input, 'fro');
      expect(result.items.any((i) => i.text.toUpperCase() == 'FROM'), isTrue);
    });

    test('lineAfter 参与光标处字符串判定', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: "SELECT '",
        lineBefore: "SELECT '",
        lineAfter: "x' FROM",
      ));
      expect(result.isEmpty, isTrue);
    });

    test('PG 双引号是标识符，MySQL 双引号是字符串', () {
      expect(
        SqlCompletionEngine.isInsideString(
          'SELECT "col',
          dialect: DialectType.pg,
        ),
        isFalse,
      );
      expect(
        SqlCompletionEngine.isInsideString(
          'SELECT "col',
          dialect: DialectType.mysql,
        ),
        isTrue,
      );
      // PG 下半截标识符仍可走 catalog 补全
      final engine = SqlCompletionEngine(
        enableModel: false,
        catalog: catalog,
        dialect: DialectType.pg,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT us',
        lineBefore: 'SELECT us',
      ));
      expect(result.items.map((i) => i.text), contains('users'));
    });

    test('PG 引擎：双引号半截标识符可补全', () {
      final engine = SqlCompletionEngine(
        enableModel: false,
        catalog: catalog,
        dialect: DialectType.pg,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT "us',
        lineBefore: 'SELECT "us',
      ));
      expect(result.isEmpty, isFalse);
      expect(result.items.map((i) => i.text), contains('users'));
    });

    test('MySQL 双引号字符串内不补全', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT "col',
        lineBefore: 'SELECT "col',
      ));
      expect(result.isEmpty, isTrue);
    });

    test('串内分号不切开当前语句', () {
      expect(
        SqlCompletionEngine.currentStatementPrefix("SELECT ';' FROM t"),
        "SELECT ';' FROM t",
      );
      expect(
        SqlCompletionEngine.currentStatementPrefix(
          "SELECT 1; SELECT ';' FROM u",
        ),
        "SELECT ';' FROM u",
      );
    });

    test('注释内分号不切开当前语句', () {
      // 真分号在 SELECT 1 后；注释里的 ; 忽略，当前语句含行注释前缀。
      expect(
        SqlCompletionEngine.currentStatementPrefix('SELECT 1;-- x;y\nFROM t'),
        '-- x;y\nFROM t',
      );
      expect(
        SqlCompletionEngine.lastBareSemicolon('-- only;comment\nSELECT x'),
        -1,
      );
      expect(
        SqlCompletionEngine.currentStatementPrefix('SELECT /* ; */ id FROM u'),
        'SELECT /* ; */ id FROM u',
      );
    });
  });

  group('catalog / 排序 / 截断', () {
    test('allFlat 含关键字与对象', () {
      expect(
        catalog.allFlat.map((e) => e.text).toList(),
        containsAll(['SELECT', 'users', 'id']),
      );
    });

    test('maxItems 截断', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog, maxItems: 1);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 's',
        lineBefore: 's',
      ));
      expect(result.items, hasLength(1));
    });

    test('同名大小写去重，保留先写入的模型项', () async {
      final predictor = await _tinyFromPredictor();
      final dupCatalog = SqlCompleteCatalog(
        keywords: const [
          SqlCompleteCatalogEntry(text: 'Users', kind: SqlCompleteKind.keyword),
        ],
        objects: const [
          SqlCompleteCatalogEntry(text: 'users', kind: SqlCompleteKind.table),
          SqlCompleteCatalogEntry(text: 'orders', kind: SqlCompleteKind.table),
        ],
        related: catalog.related,
      );
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: predictor,
        catalog: dupCatalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT id FROM ',
        lineBefore: 'SELECT id FROM ',
      ));
      final usersHits =
          result.items.where((i) => i.text.toLowerCase() == 'users').toList();
      expect(usersHits, hasLength(1));
    });

    test('无模型半截词：表名前缀命中', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM us',
        lineBefore: 'SELECT * FROM us',
      ));
      expect(result.input, 'us');
      expect(result.items.map((i) => i.text), contains('users'));
      expect(result.items.map((i) => i.text), isNot(contains('orders')));
    });
  });

  group('纯数字半截词不弹窗', () {
    const numericCatalog = SqlCompleteCatalog(
      objects: [
        SqlCompleteCatalogEntry(text: 'user_123', kind: SqlCompleteKind.table),
        SqlCompleteCatalogEntry(text: 'order_12', kind: SqlCompleteKind.table),
      ],
    );

    test('数字字面量不触发对象补全', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: numericCatalog);
      for (final prefix in const [
        'SELECT * FROM t WHERE id = 12',
        'SELECT 1',
        'SELECT * FROM t LIMIT 10',
      ]) {
        final result = engine.complete(
          SqlCompletionRequest(sqlPrefix: prefix, lineBefore: prefix),
        );
        expect(result.isEmpty, isTrue, reason: prefix);
        expect(result.input, isEmpty, reason: prefix);
      }
    });

    test('含数字但非纯数字的半截词照常补全', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: numericCatalog);
      const prefix = 'SELECT * FROM user_1';
      final result = engine.complete(
        const SqlCompletionRequest(sqlPrefix: prefix, lineBefore: prefix),
      );
      expect(result.input, 'user_1');
      expect(result.items.map((i) => i.text), contains('user_123'));
    });
  });

  group('模型占位符展开', () {
    test('FROM 后半截词 us：模型 TABLE 展开并过滤', () async {
      final predictor = await _tinyFromPredictor();
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: predictor,
        catalog: catalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT id FROM us',
        lineBefore: 'SELECT id FROM us',
      ));
      expect(result.input, 'us');
      expect(result.items.map((i) => i.text), contains('users'));
      expect(result.items.map((i) => i.text), isNot(contains('orders')));
      // TABLE 不应展开成列
      expect(
        result.items.any((i) => i.kind == SqlCompleteKind.column),
        isFalse,
      );
    });

    test('有模型 + 点号半截：仅 related 内补，不扫全库', () async {
      final predictor = await _tinyFromPredictor();
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: predictor,
        catalog: catalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT t.n',
        lineBefore: 'SELECT t.n',
      ));
      expect(result.items.map((i) => i.text), contains('name'));
      expect(result.items.map((i) => i.text), isNot(contains('users')));
      expect(result.items.map((i) => i.text), isNot(contains('id')));
    });

    test('点号上下文模型候选也会与 related 求交', () async {
      final predictor = await _tinyFromPredictor();
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: predictor,
        catalog: catalog,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT t.',
        lineBefore: 'SELECT t.',
      ));
      expect(result.items.map((i) => i.text).toSet(), {'id', 'name'});
    });

    test('alias 角色归 <TABLE>，展开对齐表', () {
      expect(
        TokenExtractor.outputPlaceholderFor(SqlCompleteKind.alias),
        TokenExtractor.tableToken,
      );
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<TABLE>',
            id: 0,
            score: 0.9,
            kind: SqlCompleteKind.table,
          ),
        ]),
        catalog: catalog,
        maxExpandPerPrediction: 10,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM ',
        lineBefore: 'SELECT * FROM ',
      ));
      expect(result.items.map((i) => i.text), contains('users'));
      expect(result.items.map((i) => i.text), contains('orders'));
      expect(
        result.items.any((i) => i.kind == SqlCompleteKind.column),
        isFalse,
      );
    });

    test('<OBJ> 展开优先表且受 maxExpand 截断', () {
      final many = SqlCompleteCatalog(
        objects: [
          for (var i = 0; i < 20; i++)
            SqlCompleteCatalogEntry(text: 't$i', kind: SqlCompleteKind.table),
          for (var i = 0; i < 20; i++)
            SqlCompleteCatalogEntry(text: 'c$i', kind: SqlCompleteKind.column),
        ],
      );
      final engine = SqlCompletionEngine(enableModel: false, 
        predictor: _StubPredictor(const [
          Prediction(
            token: '<OBJ>',
            id: 0,
            score: 0.8,
            kind: SqlCompleteKind.object,
          ),
        ]),
        catalog: many,
        maxExpandPerPrediction: 5,
      );
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT * FROM ',
        lineBefore: 'SELECT * FROM ',
      ));
      expect(result.items, hasLength(5));
      expect(
        result.items.every((i) => i.kind == SqlCompleteKind.table),
        isTrue,
      );
    });

    test('无模型 exact 前缀不垫底', () {
      final engine = SqlCompletionEngine(enableModel: false, catalog: catalog);
      final result = engine.complete(const SqlCompletionRequest(
        sqlPrefix: 'SELECT',
        lineBefore: 'SELECT',
      ));
      expect(result.items.first.text.toUpperCase(), 'SELECT');
      expect(result.items.first.score, 1.0);
      expect(result.items.first.matchPositions, isNotNull);
    });
  });

  group('占位符类型映射', () {
    test('kindOfObjectPlaceholder', () {
      expect(
        TokenExtractor.kindOfObjectPlaceholder('<TABLE>'),
        SqlCompleteKind.table,
      );
      expect(
        TokenExtractor.kindOfObjectPlaceholder('<COLUMN>'),
        SqlCompleteKind.column,
      );
      expect(
        TokenExtractor.kindOfObjectPlaceholder('<DATABASE>'),
        SqlCompleteKind.database,
      );
      expect(
        TokenExtractor.kindOfObjectPlaceholder('<OBJ>'),
        SqlCompleteKind.object,
      );
      expect(TokenExtractor.kindOfObjectPlaceholder('<ALIAS>'), isNull);
      expect(TokenExtractor.kindOfObjectPlaceholder('<UNK>'), isNull);
      expect(TokenExtractor.kindOfObjectPlaceholder('select'), isNull);
    });

    test('outputPlaceholderFor：alias 归入 TABLE', () {
      expect(
        TokenExtractor.outputPlaceholderFor(SqlCompleteKind.alias),
        '<TABLE>',
      );
      expect(
        TokenExtractor.outputPlaceholderFor(SqlCompleteKind.table),
        '<TABLE>',
      );
    });
  });

  group('copyWith', () {
    test('catalog 热更新复用 predictor', () async {
      final predictor = await _tinyFromPredictor();
      final engine = SqlCompletionEngine(
        enableModel: false,
        predictor: predictor,
        catalog: catalog,
      );
      final next = engine.copyWith(
        catalog: SqlCompleteCatalog(
          keywords: catalog.keywords,
          objects: [
            ...catalog.objects,
            const SqlCompleteCatalogEntry(
              text: 'accounts',
              kind: SqlCompleteKind.table,
            ),
          ],
          related: catalog.related,
        ),
      );
      expect(identical(next.predictor, engine.predictor), isTrue);
      expect(next.dialect, engine.dialect);
      final result = next.complete(const SqlCompletionRequest(
        sqlPrefix: 'acc',
        lineBefore: 'acc',
      ));
      expect(result.items.map((i) => i.text), contains('accounts'));
    });

    test('无模型时换方言仍保持无 predictor', () {
      final engine = SqlCompletionEngine(
        enableModel: false,
        catalog: catalog,
        dialect: DialectType.mysql,
      );
      final next = engine.copyWith(dialect: DialectType.pg);
      expect(next.predictor, isNull);
      expect(next.dialect, DialectType.pg);
    });
  });

  group('推理前缀截断', () {
    test('超过 maxPosLen 仍可预测', () async {
      final predictor = await _tinyFromPredictor();
      final long = List.filled(80, 'id').join(' , ');
      final prefix = 'SELECT $long FROM';
      final preds = predictor.predict(prefix, topK: 5);
      expect(preds, isNotEmpty);
    });
  });
}

/// 固定返回给定预测，绕过真实模型。
class _StubPredictor implements SqlNextTokenPredictor {
  final List<Prediction> fixed;

  _StubPredictor(this.fixed);

  @override
  List<Prediction> predict(String sqlPrefix, {int topK = 8}) =>
      fixed.take(topK).toList();
}

/// 模拟模型抛错，验证仍可走全量 fuzzy。
class _ThrowingPredictor implements SqlNextTokenPredictor {
  @override
  List<Prediction> predict(String sqlPrefix, {int topK = 8}) {
    throw StateError('boom');
  }
}

Future<SqlTokenPredictor> _tinyFromPredictor() async {
  final samples = [
    for (final table in ['users', 'orders', 't'])
      sampleWithSpans(
        'SELECT id FROM $table',
        const [SqlCompleteKind.column, SqlCompleteKind.table],
      ),
    for (final table in ['users', 'orders'])
      sampleWithSpans(
        'SELECT name FROM $table',
        const [SqlCompleteKind.column, SqlCompleteKind.table],
      ),
  ];
  final trainer = SqlTokenTrainer(
    config: const TrainConfig(
      epochs: 20,
      learningRate: 1e-2,
      embedDim: 16,
      hiddenDim: 16,
      numLayers: 1,
      logEvery: 0,
      shuffle: true,
      seed: 3,
      valRatio: 0,
      prefixStride: 1,
    ),
  );
  final ckpt = await trainer.fit(samples);
  return ckpt.toPredictor();
}
