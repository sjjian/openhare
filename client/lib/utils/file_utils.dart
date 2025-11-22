import 'dart:io';
import 'package:path/path.dart' as p;

/// 生成唯一的文件名，如果文件已存在则自动添加序号
/// 
/// [fileDir] 文件所在目录路径
/// [fileName] 原始文件名（包含扩展名）
/// 
/// 返回唯一的文件名。如果原文件不存在，返回原文件名；
/// 如果存在，则自动添加序号，例如：
/// - `filename.xlsx` -> `filename (1).xlsx` -> `filename (2).xlsx`
/// 
/// 最多尝试 10000 次，防止无限循环
String getUniqueFileName(String fileDir, String fileName) {
  final filePath = p.join(fileDir, fileName);
  final file = File(filePath);
  
  // 如果文件不存在，直接返回原文件名
  if (!file.existsSync()) {
    return fileName;
  }
  
  // 分离文件名和扩展名
  final extension = p.extension(fileName); // 包含点号，如 .xlsx
  final nameWithoutExt = p.basenameWithoutExtension(fileName);
  
  // 尝试添加序号
  int counter = 1;
  String newFileName;
  File newFile;
  
  do {
    newFileName = '$nameWithoutExt ($counter)$extension';
    newFile = File(p.join(fileDir, newFileName));
    counter++;
  } while (newFile.existsSync() && counter < 10000); // 防止无限循环
  
  return newFileName;
}

