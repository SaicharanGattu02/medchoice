import 'package:fieldsenses/screens/LogIn.dart';
import 'package:fieldsenses/screens/NoGPS.dart';
import 'package:fieldsenses/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../preferences.dart';
import '../services/UserApi.dart';
import '../services/otherservices.dart';
import 'PunchInOut.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String token="";
  String status="";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate to the next screen after the animation
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), () async {
        if(token!=""){
          if (!(await checkGPSstatus())) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => NoGPS()));
           }else{
            GetPuchInStatus();
          }
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LogIn()));
        }
      });
    });
    Fetchdetails();
  }

  Future<void> GetPuchInStatus() async {
    final Response = await Userapi.GetPuchInStatusApi();
    if(Response != null){
      setState(() {
        if (Response.settings?.success == 1) {
          status=Response?.status??"";
          if(status=="Punch in" || status=="Punch out"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Punching()));
          }
        }
      });
    } else {

    }
  }


  Fetchdetails() async {
    var Token = (await PreferenceService().getString('token'))??"";
    setState(() {
      token=Token;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
            // colors: [Color(0xFF4BA8FE), Color(0xFF0573DA)],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Image.asset(
              "assets/medchoiceLogo.png",
              width: 200,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
