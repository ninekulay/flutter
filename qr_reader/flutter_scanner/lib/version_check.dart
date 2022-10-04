// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'api_manage.dart';
import 'login.dart';
import 'custom_dialog.dart';

/// example widget for ota_update plugin
// class MyAppVersion extends StatefulWidget {
//   @override
//   MyAppVersionCheck createState() => MyAppVersionCheck();
// }

// class MyAppVersionCheck extends State<MyAppVersion> {

//   @override
//   Widget build(BuildContext context) {
//     if (currentEvent == null) {
//       return Container();
//     }
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: Text(
//               'OTA status: ${currentEvent.status} : ${currentEvent.value} \n'),
//         ),
//       ),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  final MyApiManagement myApi = MyApiManagement();
  OtaEvent? currentEvent;

  tryOtaUpdate() async {
    try {
      //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
      OtaUpdate()
          .execute(
        'https://fd9d-202-176-126-188.ap.ngrok.io/flutter/',
        destinationFilename: 'app-arm64-v8a-release.apk',
      )
          .listen(
        (OtaEvent event) {
          setState(() => currentEvent = event);
        },
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle.isEmpty ? 'Not set' : subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: myApi.lastVersionAPK(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              appBar: AppBar(title: Text("Version Check")),
              body: Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Image.asset('assets/icon/icon.png',
                          fit: BoxFit.contain),
                    ),
                    const Text('Version checking...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // ignore: curly_braces_in_flow_control_structures
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data['version'] == _packageInfo.version) {
            return LoginPage();
          } else {
            print(snapshot.data['version'] == _packageInfo.version);

            return Scaffold(
              appBar: AppBar(title: const Text('Version Control')),
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                        initialValue:
                            'Last Version : ${snapshot.data['version']}'),
                    TextFormField(
                        initialValue: 'My Version : ${_packageInfo.version}'),
                    Column(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () async {
                            tryOtaUpdate();
                            if (currentEvent != null) {
                              Text(
                                  'OTA status: ${currentEvent!.status} : ${currentEvent!.value} \n');
                            }
                          },
                          child: const Text('Update version'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop');
                            Navigator.pop(context);
                          },
                          child: const Text('ยกเลิก'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
            // return Scaffold(
            //   appBar: AppBar(title: const Text('Login Page')),
            //   body: Center(
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: <Widget>[
            //         // _infoTile('App name', _packageInfo.appName),
            //         // _infoTile('Package name', _packageInfo.packageName),
            //         _infoTile('App version', _packageInfo.version),
            //         _infoTile('Build number', _packageInfo.buildNumber),
            //         _infoTile('Last version', snapshot.data['version']),
            //         _infoTile('Last build', snapshot.data['build_number']),
            //         // _infoTile('Build signature', _packageInfo.buildSignature),
            //       ],
            //     ),
            //   ),
            // );
          }
        });
  }
}
