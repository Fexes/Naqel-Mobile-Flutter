import 'package:naqelapp/custom_drawer/company_drawer.dart';
import 'package:naqelapp/custom_drawer/company_drawer_user_controller.dart';
import 'package:naqelapp/styles/app_theme.dart';
import 'package:naqelapp/custom_drawer/driver_drawer_user_controller.dart';
import 'package:naqelapp/screens/home/driver/driver_jobs_screen.dart';

import 'package:flutter/material.dart';

import 'company_home_screen.dart';
import 'company_profile_screen.dart';
import 'company_questions_page.dart';




class CompanyNavigationHomeScreen extends StatefulWidget {
  @override
  _CompanyNavigationHomeScreenState createState() => _CompanyNavigationHomeScreenState();
}

class _CompanyNavigationHomeScreenState extends State<CompanyNavigationHomeScreen> {
  Widget screenView;
  DrawerIndex drawerIndex;
 // AnimationController sliderAnimationController;

  @override
  void initState() {
    drawerIndex = DrawerIndex.TRUCKS;
    screenView = const CompanyHomePage();
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
          body: CompanyDrawerUserController(
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
      if (drawerIndex == DrawerIndex.TRUCKS) {
        setState(() {
           screenView = const CompanyHomePage();
        });
      } else if (drawerIndex == DrawerIndex.PROFILE) {
        setState(() {
          screenView = const CompanyProfilePage();

        });
      }
      else if (drawerIndex == DrawerIndex.QUESTIONS) {
        setState(() {
          screenView = const CompanyQuestionsPage();

        });
      }

      else if (drawerIndex == DrawerIndex.FINANCIAL) {
        setState(() {
        // screenView = const TruckPage();
        });
      }


      else {
        //do in your way......
      }
    }
  }
}

