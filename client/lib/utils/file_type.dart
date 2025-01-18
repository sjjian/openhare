import 'package:collection/collection.dart';

enum FileType {
  png,
  jpeg,
  gif,
  unknow
}

FileType getFileType(List<int> data)  {
  const equality =  ListEquality<int>();
  if (equality.equals(data.take(4).toList(), [0x89, 0x50, 0x4E, 0x47])) {
    return FileType.png;
  } else if (equality.equals(data.take(3).toList(), [0xFF, 0xD8, 0xFF])) {
    return FileType.jpeg;
  } else if (equality.equals(data.take(3).toList(), [0x47, 0x49, 0x46])) {
    return FileType.gif; 
  } else {
    return FileType.unknow;
  }
}