import 'package:flutter/material.dart';

SnackBar getToastySnackBar({
  required String msg,
  Color bgColor = const Color(0xe8000000),
  Duration duration = const Duration(milliseconds: 1300),
  BuildContext? context
})
=> SnackBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  dismissDirection: DismissDirection.down,
  padding: EdgeInsets.zero,
  margin: (context != null)
      ? EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height*0.1
      )
      : const EdgeInsets.only(
      bottom: 50
  )
  ,
  behavior: SnackBarBehavior.floating,
  duration: duration,
  content: Center(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: bgColor,
      ),
      child: Text(msg),
    ),
  ),
);