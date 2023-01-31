import 'package:flutter/material.dart';
import 'package:homestay_raya/views/screens/explorehomestayscreen.dart';
import 'package:homestay_raya/views/screens/myhomestayscreen.dart';
import '../../models/user.dart';
import '../screens/explorehomestayscreen.dart';
import '../screens/profilescreen.dart';

import 'EnterExitRoute.dart';

class MainMenuWidget extends StatefulWidget {
  final User user;
  const MainMenuWidget({super.key, required this.user});

  @override
  State<MainMenuWidget> createState() => _MainMenuWidgetState();
}

class _MainMenuWidgetState extends State<MainMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      elevation: 10,
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(widget.user.email.toString()),
            accountName: Text(widget.user.name.toString()),
            currentAccountPicture: const CircleAvatar(
              radius: 30.0,  backgroundImage: AssetImage('assets/11.png'),
           ),
          ),
          ListTile(
            title: const Text('Explore HomeStay'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  EnterExitRoute(
                      exitPage: ExploreHomestayScreen(user: widget.user), 
                      enterPage: ExploreHomestayScreen(user: widget.user)));
            },
          ),
          ListTile(
            title: const Text('My HomeStay'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  EnterExitRoute(
                      exitPage: ExploreHomestayScreen(user: widget.user),
                      enterPage: MyHomestayScreen(user: widget.user)));
            },
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  EnterExitRoute(
                      exitPage: ExploreHomestayScreen(user: widget.user), 
                      enterPage: ProfileScreen(user: widget.user)));
            },
          ),
        ],
      ),
    );
  }
}
