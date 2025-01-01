class CategoryRecord {
  int? id;
  int menuId;
  String title;
  String desc;

  CategoryRecord(
      {this.id, required this.menuId, required this.title, required this.desc});

  Map<String, dynamic> toMap() {
    return {'id': id, 'menuId': menuId, 'title': title, 'desc': desc};
  }

  factory CategoryRecord.fromMap(Map<String, dynamic> map) {
    return CategoryRecord(
      id: map['id'],
      menuId: map['menuId'],
      title: map['title'],
      desc: map['desc'],
    );
  }
}
