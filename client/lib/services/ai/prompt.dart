// 下面的prompt 都用英文
import 'package:client/models/sessions.dart';
import 'package:db_driver/db_driver.dart';

const testTemplate = """
To confirm that you are available, please only return a number 1 to me.
""";

const chatTemplate = """
You are a helpful assistant. You are talking to a user who is using a database tool. You are helping the user to answer questions about the database.
db type: {dbType}
current schema table info:
```
{tables}
```
tips: 
- If the reply contains SQL, each SQL should be wrapped in one ```sql``` block.
""";

String genChatSystemPrompt(SessionAIChatModel model) {
  String prompt = chatTemplate;
  if (model.dbType != null) {
    prompt = prompt.replaceAll("{dbType}", model.dbType!.name);
  }
  final tables = model.chatModel.tables[model.currentSchema ?? ""];
  // 通过metadata build table 信息
  final schema = MetaDataNode(MetaType.instance, "", items: model.metadata);
  final schemaNodes =
      schema.getChildren(MetaType.schema, model.currentSchema ?? "");

  if (tables == null || tables.isEmpty || schemaNodes.isEmpty) {
    return prompt.replaceAll("{tables}", "");
  }

  final tableInfos = schemaNodes.where((e) {
    if (e.type == MetaType.table && tables.containsKey(e.value)) {
      return true;
    }
    return false;
  });

  return prompt.replaceAll(
      "{tables}", tableInfos.map((e) => e.toString()).join("\n"));
}
