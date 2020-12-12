import 'dart:async';
import 'package:naqelapp/utilts/UI/toast_animation.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  static Timer toastTimer;
  static OverlayEntry _overlayEntry;

  static void showCustomToast(BuildContext context,
      String message,bool success) {

    if (toastTimer == null || !toastTimer.isActive) {
      _overlayEntry = createOverlayEntry(context, message,success);
      Overlay.of(context).insert(_overlayEntry);
      toastTimer = Timer(Duration(seconds: 3), () {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
        }
      });
    }

  }

  static OverlayEntry createOverlayEntry(BuildContext context,
      String message,bool success) {

    return OverlayEntry(
        builder: (context) => Positioned(
          bottom: 100.0,
          width: MediaQuery.of(context).size.width - 20,
          left: 10,
          child: ToastMessageAnimation(Material(
            elevation: 10.0,
            borderRadius: BorderRadius.circular(10),
            child:
            success==null?
            Container(
              padding:
              EdgeInsets.only(left: 10, right: 10,
                  top: 13, bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10)),

              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.info,color: Colors.white,),
                  SizedBox(width: 40),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),


            ):
            success? Container(
              padding:
              EdgeInsets.only(left: 10, right: 10,
                  top: 13, bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.green[500],
                  borderRadius: BorderRadius.circular(10)),

              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.done,color: Colors.white,),
                  SizedBox(width: 40),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),


            ) :
            Container(
              padding:
              EdgeInsets.only(left: 10, right: 10,
                  top: 13, bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.red[500],
                  borderRadius: BorderRadius.circular(10)),

              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.close,color: Colors.white,),
                  SizedBox(width: 40),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),


            ),
          )),
        ));
  }
}
