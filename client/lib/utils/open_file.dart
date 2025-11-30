import 'dart:io';
import 'package:path/path.dart' as p;

/// 使用系统默认程序打开文件
/// 
/// [path] 文件路径
/// 
/// 返回 `true` 表示成功，`false` 表示文件不存在或操作失败
/// 抛出异常表示不支持的操作系统或其他错误
Future<bool> openFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return false;
  }

  // 使用平台特定的命令打开文件
  if (Platform.isMacOS) {
    final result = await Process.run('open', [path]);
    return result.exitCode == 0;
  } else if (Platform.isWindows) {
    // Windows: 使用 start "" "path" 格式，确保路径被正确引用
    // 空字符串作为标题参数，后面跟文件路径
    final result = await Process.run('cmd', ['/c', 'start', '""', path], runInShell: false);
    return result.exitCode == 0;
  } else if (Platform.isLinux) {
    final result = await Process.run('xdg-open', [path]);
    return result.exitCode == 0;
  } else {
    throw UnsupportedError('不支持的操作系统: ${Platform.operatingSystem}');
  }
}

/// 在文件管理器中打开文件所在文件夹并选中文件
/// 
/// [filePath] 文件路径
/// 
/// 返回 `true` 表示成功，`false` 表示文件不存在或操作失败
/// 抛出异常表示不支持的操作系统或其他错误
Future<bool> openFileInFolder(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    return false;
  }

  // 使用平台特定的命令打开文件所在文件夹并选中文件
  if (Platform.isMacOS) {
    // macOS: open -R 会打开 Finder 并选中文件
    final result = await Process.run('open', ['-R', filePath]);
    return result.exitCode == 0;
  } else if (Platform.isWindows) {
    // Windows: explorer /select, 会打开文件资源管理器并选中文件
    // 注意：/select, 和路径之间不能有空格
    // 注意：explorer 是 GUI 程序，即使成功也可能返回非零退出码，所以我们不检查退出码
    // 只要文件存在，我们就认为命令会成功执行
    try {
      // 使用 runInShell: true 让 shell 处理参数解析，确保路径中的空格和特殊字符被正确处理
      await Process.start('explorer', ['/select,$filePath'], runInShell: true);
      return true; // 文件存在且已尝试打开，认为成功
    } catch (e) {
      // 如果启动进程失败，返回 false
      return false;
    }
  } else if (Platform.isLinux) {
    // Linux: 打开文件所在文件夹
    final directory = p.dirname(filePath);
    final result = await Process.run('xdg-open', [directory]);
    return result.exitCode == 0;
  } else {
    throw UnsupportedError('不支持的操作系统: ${Platform.operatingSystem}');
  }
}

