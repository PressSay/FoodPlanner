class TableRecord {
  int? id;
  String name;
  String desc;
  int numOfPeople;
  DateTime? timeStamp;

  TableRecord(
      {this.id,
      required this.name,
      required this.desc,
      required this.numOfPeople,
      this.timeStamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'numOfPeople': numOfPeople,
      'timeStamp': timeStamp?.toString() ?? DateTime.now().toString()
    };
  }

  factory TableRecord.fromMap(Map<String, dynamic> map) {
    return TableRecord(
        id: map['id'],
        name: map['name'],
        desc: map['desc'],
        numOfPeople: map['numOfPeople'],
        timeStamp: DateTime.parse(map['timeStamp']));
  }
}
