import 'package:flutter/material.dart';


class ScreenButton extends StatelessWidget{
  const ScreenButton(
    {super.key, this.buttonText, this.color, this.onTap, this.textColor});
  final String? buttonText;
  final Widget? onTap; 
  final Color? color;
  final Color? textColor;
    
  
@override 
Widget build(BuildContext context){
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
         MaterialPageRoute(
          builder: (e) => onTap!,
          ),
          );
    },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
    decoration: BoxDecoration(
      color: color!,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40),
      ),
    ),
    child: Text(
      buttonText!,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: textColor!,
      ),
    ),
  ),
); 
}
}
