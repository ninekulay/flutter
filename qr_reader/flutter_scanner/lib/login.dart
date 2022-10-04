import 'package:flutter/material.dart';
import 'api_manage.dart';
import 'qr_scan.dart';

class LoginPage extends StatelessWidget {
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  final MyApiManagement myApi = MyApiManagement();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: myApi.beforeInitial(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(title: Text("Connect Server")),
            body: Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Image.asset('assets/icon/icon.png',
                        fit: BoxFit.contain),
                  ),
                  const Text('Please wait...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          );
          // return ListView(
          //   children: [
          //     Expanded(
          //       child: Image.asset('assets/icon/icon.png', fit: BoxFit.contain),
          //     ),
          //     const Text('Plese wait...',
          //         textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          //   ],
          // );
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
                    TextFormField(
                        initialValue: 'Server : ${snapshot.data['username']}'),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Username',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (usernameController != "" &&
                              passwordController != "") {
                            Map<String, dynamic> data = {
                              "username": usernameController.text,
                              "password": passwordController.text
                            };
                            var checkLogin = await myApi.userLogin(data);
                            if (checkLogin == true) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const QRViewExample(),
                              ));
                            } else {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Login fail!!'),
                                  content: const Text(
                                      'กรุณาตรวจสอบ username , password'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
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
