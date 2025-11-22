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
    final result = await Process.run('start', [path], runInShell: true);
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
    final result = await Process.run('explorer', ['/select,', filePath], runInShell: true);
    return result.exitCode == 0;
  } else if (Platform.isLinux) {
    // Linux: 打开文件所在文件夹
    final directory = p.dirname(filePath);
    final result = await Process.run('xdg-open', [directory]);
    return result.exitCode == 0;
  } else {
    throw UnsupportedError('不支持的操作系统: ${Platform.operatingSystem}');
  }
}

