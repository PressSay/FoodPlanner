class TableRecord {
  int? id;
  String name;
  String desc;
  bool isLock;
  TableRecord(
      {this.id, required this.name, required this.desc, required this.isLock});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'isLock': isLock ? 1 : 0,
    };
  }

  factory TableRecord.fromMap(Map<String, dynamic> map) {
    return TableRecord(
        id: map['id']?.toInt() ?? 0,
        name: map['name'] ?? '',
        desc: map['desc'] ?? '',
        isLock: map['isLock'] == 1);
  }
}
