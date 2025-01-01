class MenuRecord {
  int? id;
  String title;
  bool isSelected;

  MenuRecord({this.id, required this.title, required this.isSelected});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isSelected': isSelected ? 1 : 0,
    };
  }

  factory MenuRecord.fromMap(Map<String, dynamic> map) {
    return MenuRecord(
        id: map['id'], title: map['title'], isSelected: map['isSelected'] == 1);
  }
}
