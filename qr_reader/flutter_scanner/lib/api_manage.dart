import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'class_manage.dart';

class MyApiManagement {
  beforeInitial() async {
    try {
      var response = await http.get(
        Uri.parse("http://13.213.144.190:1880/api/flutter/get"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Basic YWRtaW46bWVpc21laXM=',
        },
      );
      Map<String, dynamic> user = jsonDecode(response.body);
      var data = User(
          username: user['username'], password: user['password'].toString());
      return user;
    } catch (e) {
      print(e);
    }
  }

  userLogin(data) async {
    try {
      var response = await http.post(
          Uri.parse("http://13.213.144.190:1880/api/flutter/login"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Basic YWRtaW46bWVpc21laXM=',
          },
          body: jsonEncode(data));
      print(response.statusCode);
      print(response.statusCode == 200);
      print(response.statusCode == "200");
      if (response.statusCode == 200) {
        print("login");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
    }
  }

  postData(data) async {
    final String encodedData = MyArrayBuffer.encode(data!);
    try {
      var response = await http.post(
          Uri.parse("http://13.213.144.190:1880/api/flutter/post"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Basic YWRtaW46bWVpc21laXM=',
          },
          // body: jsonEncode(data));
          body: encodedData);
      print(response.body);
      final prefs = await SharedPreferences.getInstance();
      final success = prefs.remove('data');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  getData() async {
    try {
      var response = await http
          .get(Uri.parse("http://13.213.144.190:1880/api/flutter/get"));
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  lastVersionAPK() async {
    try {
      var response = await http.get(
        Uri.parse("http://13.213.144.190:1880/api/flutter/version"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Basic YWRtaW46bWVpc21laXM=',
        },
      );
      Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print(e);
    }
  }
}
