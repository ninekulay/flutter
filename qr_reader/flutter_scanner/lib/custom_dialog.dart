import 'package:flutter/material.dart';

enum YesNoDialogsAction { yes, no }

class YesNoDialogs {
  static Future<YesNoDialogsAction> yesOrNoDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(YesNoDialogsAction.no),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(YesNoDialogsAction.yes),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : YesNoDialogsAction.no;
  }
}

enum ConfirmDialogsAction { yes }

class ConfirmDialogs {
  static Future<ConfirmDialogsAction> conFirmationDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(ConfirmDialogsAction.yes),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : ConfirmDialogsAction.yes;
  }
}
