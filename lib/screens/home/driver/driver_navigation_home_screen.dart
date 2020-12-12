import 'package:naqelapp/models/driver/DriverQuestions.dart';
import 'package:naqelapp/screens/home/driver/driver_questions_page.dart';
import 'package:naqelapp/styles/app_theme.dart';
import 'package:naqelapp/custom_drawer/driver_drawer_user_controller.dart';
import 'package:naqelapp/custom_drawer/driver_drawer.dart';
import 'package:naqelapp/screens/home/driver/driver_jobs_screen.dart';

import 'package:flutter/material.dart';

import 'permits_page.dart';
import 'driver_profile_screen.dart';
import 'trucks_screen.dart';


class DriverNavigationHomeScreen extends StatefulWidget {
  @override
  _DriverNavigationHomeScreenState createState() => _DriverNavigationHomeScreenState();
}

class _DriverNavigationHomeScreenState extends State<DriverNavigationHomeScreen> {
  Widget screenView;
  DrawerIndex drawerIndex;
 // AnimationController sliderAnimationController;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const DriverHomePage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DriverDrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,

            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
            },
            screenView: screenView,
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.HOME) {
        setState(() {
          screenView = const DriverHomePage();
        });
      } else if (drawerIndex == DrawerIndex.ACCOUNT) {
        setState(() {
          screenView = const DriverProfilePage();

        });
      }
      else if (drawerIndex == DrawerIndex.TRUCK) {
        setState(() {
         screenView = const TruckPage();
        });
      }
      else if (drawerIndex == DrawerIndex.PERMITS) {
        setState(() {
          screenView = const PermitPage();
        });
      }
      else if (drawerIndex == DrawerIndex.QUESTIONS) {
        setState(() {
          screenView = const QuestionsPage();
        });
      }
      else {
        //do in your way......
      }
    }
  }
}

