class TableRecord {
  int? id;
  String name;
  String desc;
  int numOfPeople;
  TableRecord(
      {this.id,
      required this.name,
      required this.desc,
      required this.numOfPeople});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'numOfPeople': numOfPeople,
    };
  }

  factory TableRecord.fromMap(Map<String, dynamic> map) {
    return TableRecord(
        id: map['id'],
        name: map['name'],
        desc: map['desc'],
        numOfPeople: map['numOfPeople']);
  }
}
