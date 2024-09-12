import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double toolbarHeight;

  CustomAppBar({
    required this.title,
    this.toolbarHeight = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: "Inter",
        ), // Set the title text color
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white), // Set the back button color
        onPressed: () {
          Navigator.pop(context,true); // Navigate back when the button is pressed
        },
      ),
      backgroundColor: Color(0xFFF6821F), // Set your preferred background color
      toolbarHeight: toolbarHeight,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
