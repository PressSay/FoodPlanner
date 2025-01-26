class MenuRecord {
  int? id;
  String title;
  bool isSelected;
  DateTime? timeStamp;

  MenuRecord(
      {this.id, required this.title, required this.isSelected, this.timeStamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isSelected': isSelected ? 1 : 0,
      'timeStamp': timeStamp?.toString() ?? DateTime.now().toString()
    };
  }

  factory MenuRecord.fromMap(Map<String, dynamic> map) {
    return MenuRecord(
        id: map['id'],
        title: map['title'],
        isSelected: map['isSelected'] == 1,
        timeStamp: DateTime.parse(map['timeStamp']));
  }
}
