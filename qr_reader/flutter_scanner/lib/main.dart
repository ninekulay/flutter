// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'preference_manage.dart';
import 'api_manage.dart';
import 'class_manage.dart';
import 'custom_dialog.dart';

void main() async {
  runApp(const MaterialApp(home: MyHome()));
}

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
    var data =
        User(username: user['username'], password: user['password'].toString());
    return user;
  } catch (e) {
    print(e);
  }
}

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: beforeInitial(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Please wait get API...'));
        } else {
          if (snapshot.hasError)
            // ignore: curly_braces_in_flow_control_structures
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            // ignore: curly_braces_in_flow_control_structures
            return Scaffold(
              appBar: AppBar(title: const Text('Login Page')),
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(initialValue: '${snapshot.data['username']}'),
                    TextFormField(initialValue: '${snapshot.data['password']}'),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const QRViewExample(),
                          ));
                        },
                        child: const Text('Login QR Code system'),
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  List<MyArrayBuffer>? myArrayObject = [];
  final PresferenceManagement myPreference = PresferenceManagement();
  final MyApiManagement myApiManage = MyApiManagement();
  var dataFromPreference = [];
  final LoginPage logInPage = LoginPage();
  bool tappConfirm = false;
  bool tappYesNo = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    TextButton(
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Barcode Detail'),
                            content: Text(
                                'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    result = null;
                                  });
                                  Navigator.pop(context, 'Cancel');
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  var data = MyArrayBuffer(
                                      date: result!.code,
                                      time: DateTime.now().toString());
                                  myPreference.saveStringValue(data);
                                  setState(() {
                                    result = null;
                                  });
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context, 'Save');
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Show Barcode',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )
                  else
                    Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${describeEnum(snapshot.data!)}');
                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            var data =
                                await myPreference.getSharedPreferences();
                            if (data != null) {
                              dataFromPreference = data;
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Data in Record'),
                                  content: ListView.builder(
                                      itemCount: dataFromPreference.length,
                                      itemBuilder: (context, index) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return ListTile(
                                              title:
                                                  Text('index : ${index + 1}'),
                                              subtitle: Text(
                                                  'date : ${dataFromPreference[index].date} \ntime : ${dataFromPreference[index].time}'),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      size: 20.0,
                                                    ),
                                                    onPressed: () async {
                                                      var checkDelete =
                                                          await myPreference
                                                              .deleteIndexPreference(
                                                                  index);
                                                      if (checkDelete == true) {
                                                        await ConfirmDialogs
                                                            .conFirmationDialog(
                                                          context,
                                                          'ลบข้อมูลสำเร็จ',
                                                          '',
                                                        );
                                                        setState(() => {
                                                              tappConfirm =
                                                                  true,
                                                              Navigator.pop(
                                                                  context,
                                                                  'Cancel')
                                                            });
                                                        // showDialog<String>(
                                                        //   context: context,
                                                        //   builder: (BuildContext
                                                        //           context) =>
                                                        //       AlertDialog(
                                                        //     title: const Text(
                                                        //         'ลบสำเร็จ'),
                                                        //     actions: <Widget>[
                                                        //       TextButton(
                                                        //         onPressed: () =>
                                                        //             {
                                                        //           data = null,
                                                        //           Navigator.pop(
                                                        //               context,
                                                        //               'OK'),
                                                        //           Navigator.pop(
                                                        //               context,
                                                        //               'Cancel'),
                                                        //         },
                                                        //         child:
                                                        //             const Text(
                                                        //                 'OK'),
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        // );
                                                      } else {
                                                        // ignore: use_build_context_synchronously
                                                        await ConfirmDialogs
                                                            .conFirmationDialog(
                                                          context,
                                                          'ลบไม่สำเร็จ',
                                                          'กรุณาตรวจสอบข้อมูล',
                                                        );
                                                        setState(() => {
                                                              tappConfirm =
                                                                  true,
                                                              Navigator.pop(
                                                                  context,
                                                                  'Cancel')
                                                            });

                                                        // showDialog<String>(
                                                        //   context: context,
                                                        //   builder: (BuildContext
                                                        //           context) =>
                                                        //       AlertDialog(
                                                        //     title: const Text(
                                                        //         'ลบไม่สำเร็จ'),
                                                        //     actions: <Widget>[
                                                        //       TextButton(
                                                        //         onPressed: () =>
                                                        //             {
                                                        //           Navigator.pop(
                                                        //               context,
                                                        //               'OK'),
                                                        //           Navigator.pop(
                                                        //               context,
                                                        //               'Cancel'),
                                                        //         },
                                                        //         child:
                                                        //             const Text(
                                                        //                 'OK'),
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        // );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // ignore: use_build_context_synchronously
                              await ConfirmDialogs.conFirmationDialog(
                                context,
                                'ไม่พบข้อมูล',
                                'กรุณาตรวจสอบข้อมูล',
                              );
                              setState(() => tappConfirm = true);
                              // showDialog<String>(
                              //   context: context,
                              //   builder: (BuildContext context) => AlertDialog(
                              //     title: const Text('ไม่พบข้อมูล'),
                              //     actions: <Widget>[
                              //       TextButton(
                              //         onPressed: () => {
                              //           Navigator.pop(context, 'OK'),
                              //         },
                              //         child: const Text('OK'),
                              //       ),
                              //     ],
                              //   ),
                              // );
                            }
                          },
                          icon: Icon(
                            Icons.view_list,
                          ),
                          label: Text('List'),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            var datas =
                                await myPreference.getSharedPreferences();
                            if (datas != null) {
                              var statusSend =
                                  await myApiManage.postData(datas);
                              if (statusSend == true) {
                                // ignore: use_build_context_synchronously
                                await ConfirmDialogs.conFirmationDialog(
                                  context,
                                  'ส่งข้อมูลสำเร็จ',
                                  '',
                                );
                                setState(() => tappConfirm = true);
                              } else {
                                // ignore: use_build_context_synchronously
                                await ConfirmDialogs.conFirmationDialog(
                                  context,
                                  'ส่งข้อมูลไม่สำเร็จ',
                                  '',
                                );
                                setState(() => tappConfirm = true);
                              }
                              // showDialog<String>(
                              //   context: context,
                              //   builder: (BuildContext context) => AlertDialog(
                              //     title: const Text('ส่งข้อมูลสำเร็จ'),
                              //     actions: <Widget>[
                              //       TextButton(
                              //         onPressed: () => {
                              //           Navigator.pop(context, 'OK'),
                              //         },
                              //         child: const Text('OK'),
                              //       ),
                              //     ],
                              //   ),
                              // );
                            }
                          },
                          icon: Icon(
                            Icons.ios_share,
                          ),
                          label: const Text('Send'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final action = await YesNoDialogs.yesOrNoDialog(
                              context,
                              'ลบข้อมูลทั้งหมด',
                              'ต้องการลบข้อมูลที่บันทึกทั้งหมดหรือไม่ ?',
                            );
                            if (action == YesNoDialogsAction.yes) {
                              var checkRemovePref =
                                  await myPreference.clearAllPrefernece();
                              if (checkRemovePref == true) {
                                // ignore: use_build_context_synchronously
                                await ConfirmDialogs.conFirmationDialog(
                                  context,
                                  'ลบข้อมูลสำเร็จ',
                                  '',
                                );
                                setState(() => tappConfirm = true);
                              } else {
                                // ignore: use_build_context_synchronously
                                await ConfirmDialogs.conFirmationDialog(
                                  context,
                                  'ลบข้อมูลไม่สำเร็จ',
                                  '',
                                );
                                setState(() => tappConfirm = true);
                              }
                              setState(() => tappYesNo = true);
                            } else {
                              setState(() => tappYesNo = false);
                            }
                            // showDialog<String>(
                            //   context: context,
                            //   builder: (BuildContext context) => AlertDialog(
                            //     title: const Text('Delete All'),
                            //     content: Text('Confirm Delete all data!!!'),
                            //     actions: <Widget>[
                            //       TextButton(
                            //         onPressed: () =>
                            //             Navigator.pop(context, 'Cancel'),
                            //         child: const Text('Cancel'),
                            //       ),
                            //       TextButton(
                            //           onPressed: () async => {
                            //                 await myPreference
                            //                     .clearAllPrefernece(),
                            //                 Navigator.pop(context, 'Submit')
                            //               },
                            //           child: const Text('Submit')),
                            //     ],
                            //   ),
                            // );
                          },
                          icon: Icon(
                            Icons.clear,
                          ),
                          label: const Text('Clear All'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 233, 22, 22)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
