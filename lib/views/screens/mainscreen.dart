import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../shared/mainmenu.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
   Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(title: const Text("Explore HomeStay")),
          body: const Center(child: Text("Explore HomeStay")),
          drawer:  MainMenuWidget(user:widget.user),
        ));
  }
}