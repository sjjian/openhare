// 帮我写一个llm prompt模板，用于查看我当前连的ai接口是不是可用的
const testTemplate = """
为了确认你是可用的, 仅返回一个数字1给我即可
""";

const chatTemplate = """
You are a helpful assistant. You are talking to a user who is using a database tool. You are helping the user to answer questions about the database.
tips: 
- 返回的信息中，如果包含SQL则每个SQL都独立使用```sql```包裹。
""";