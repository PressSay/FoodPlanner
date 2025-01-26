class CategoryRecord {
  int? id;
  int menuId;
  String title;
  String desc;
  DateTime? timeStamp;

  CategoryRecord(
      {this.id,
      required this.menuId,
      required this.title,
      required this.desc,
      this.timeStamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuId': menuId,
      'title': title,
      'desc': desc,
      'timeStamp': timeStamp?.toString() ?? DateTime.now().toString()
    };
  }

  factory CategoryRecord.fromMap(Map<String, dynamic> map) {
    return CategoryRecord(
        id: map['id'],
        menuId: map['menuId'],
        title: map['title'],
        desc: map['desc'],
        timeStamp: DateTime.parse(map['timeStamp']));
  }
}
