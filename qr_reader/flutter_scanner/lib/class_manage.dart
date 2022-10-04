import 'dart:convert';

class MyArrayBuffer {
  String? date;
  String? time;

  MyArrayBuffer({this.date, this.time});

  factory MyArrayBuffer.fromJson(Map<String, dynamic> jsonData) {
    return MyArrayBuffer(date: jsonData['date'], time: jsonData['time']);
  }

  static Map<String, dynamic> toMap(MyArrayBuffer myArr) => {
        'date': myArr.date,
        'time': myArr.time,
      };

  static String encode(List<MyArrayBuffer> myArr) => json.encode(
        myArr
            .map<Map<String, dynamic>>((music) => MyArrayBuffer.toMap(music))
            .toList(),
      );

  static List<MyArrayBuffer> decode(String myArr) =>
      (json.decode(myArr) as List<dynamic>)
          .map<MyArrayBuffer>((item) => MyArrayBuffer.fromJson(item))
          .toList();
}

class User {
  String? username;
  String? password;

  User({this.username, this.password});

  factory User.fromJson(Map<String, dynamic> jsonData) {
    return User(username: jsonData['username'], password: jsonData['password']);
  }
}

class VersionControl {
  String? version;

  VersionControl({this.version});

  factory VersionControl.fromJson(Map<String, dynamic> jsonData) {
    return VersionControl(version: jsonData['version']);
  }
}

class LinkReceive {
  String? username;
  String? password;

  LinkReceive({this.username, this.password});

  factory LinkReceive.fromJson(Map<String, dynamic> jsonData) {
    return LinkReceive(
        username: jsonData['username'], password: jsonData['password']);
  }
}
