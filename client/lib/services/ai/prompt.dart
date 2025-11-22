// 下面的prompt 都用英文
import 'package:client/models/sessions.dart';
import 'package:client/models/tasks.dart';
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

// 导入任务的文件命名
const exportDataFileRenameTemplate = """
你的任务是帮我给数据导出任务的导出文件命名, 你需要根据SQL查询和一些背景信息, 给出一个合适的文件名。
SQL:
{sql}

数据库信息:
schema名称: {schemaName}

当前时间: {currentTime}
语言偏好: {language}

tips: 
- 名称不要太长, 最好概况业务或者查询意图，不需要后缀

输出json格式:
{
  "fileName": "文件名",
  "desc": "当前导出任务对应的业务描述或者意图描述"
}
""";

String getExportDataFileRenamePrompt(ExportDataParameters parameters, String language) {
  return exportDataFileRenameTemplate.replaceAll("{sql}", parameters.query)
      .replaceAll("{schemaName}", parameters.schema)
      .replaceAll("{currentTime}", DateTime.now().toIso8601String())
      .replaceAll("{language}", language);
}