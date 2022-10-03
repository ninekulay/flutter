import 'package:shared_preferences/shared_preferences.dart';
import 'class_manage.dart';

class PresferenceManagement {
  List<MyArrayBuffer>? myArrayObject = [];

  getSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? newDatas = prefs.getString('data');
    if (newDatas != null) {
      final List<MyArrayBuffer> newData = MyArrayBuffer.decode(newDatas);
      return newData;
    } else {
      return null;
    }
  }

  saveStringValue(data) async {
    final prefs = await SharedPreferences.getInstance();
    final String? newDatas = prefs.getString('data');
    if (newDatas != null) {
      final List<MyArrayBuffer> newData = MyArrayBuffer.decode(newDatas);
      if (newData.isNotEmpty) {
        newData.add((data));
        final String encodedData = MyArrayBuffer.encode(newData);
        await prefs.setString('data', encodedData);
      } else {
        myArrayObject?.add((data));
        final String encodedData = MyArrayBuffer.encode(myArrayObject!);
        await prefs.setString('data', encodedData);
      }
    } else {
      myArrayObject?.add((data));
      final String encodedData = MyArrayBuffer.encode(myArrayObject!);
      await prefs.setString('data', encodedData);
    }
  }

  clearAllPrefernece() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('data');
      return true;
    } catch (e) {
      return false;
    }
  }

  deleteIndexPreference(index) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('data');
    if (data != null) {
      final List<MyArrayBuffer> items = MyArrayBuffer.decode(data);
      if (items.length > index) {
        items.removeAt(index);
        final String encodedData = MyArrayBuffer.encode(items);
        await prefs.setString('data', encodedData);
        return true;
      }
    } else {
      return false;
    }
  }
}
