import "dart:io";

void main() {
  File file = File("avatar_list.txt");
  List<String> lines = file.readAsLinesSync();
  print("Line counts before: ${lines.length}");
  print("Line counts after: ${lines.toSet().length}");
  String avatarList = "";
  for (String line in lines.toSet()) {
    avatarList += "$line\n";
  }
  print(avatarList);
  file.writeAsStringSync(avatarList);
  print("Done!");
}
