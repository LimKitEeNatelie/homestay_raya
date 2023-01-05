import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/models/homestay.dart';
import 'package:homestay_raya/views/screens/newproductscreen.dart';
import 'package:homestay_raya/views/shared/mainmenu.dart';
import '../../models/user.dart';
import 'package:http/http.dart' as http;

class MyHomestayScreen extends StatefulWidget {
  final User user;
  const MyHomestayScreen({super.key, required this.user});

  @override
  State<MyHomestayScreen> createState() => _MyHomestayState();
}

class _MyHomestayState extends State<MyHomestayScreen> {
  var _lat, _lng;
  late Position _position;
  List<Homestay> homestayList = <Homestay>[];
  String titlecenter = "Loading...";
  var placemarks;
  late double screenHeight, screenWidth, resWidth;
  int rowcount = 2;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(title: const Text("My Homestay"), actions: [
            PopupMenuButton(itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("New Homestay"),
                ),
              ];
            }, onSelected: (value) {
              if (value == 0) {
                _gotoNewProduct();
                print("My account menu is selected.");
              } else if (value == 1) {
                print("Settings menu is selected.");
              } else if (value == 2) {
                print("Logout menu is selected.");
              }
            }),
          ]),
          body: homestayList.isEmpty
              ? Center(
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Your current homestay (${homestayList.length} found)",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        children: List.generate(homestayList.length, (index) {
                          return Card(
                            elevation: 10,
                            shadowColor: Colors.blueGrey,
                            child: Column(children: [
                              const SizedBox(height: 8),
                              Text(homestayList[index].homestayName.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Text(
                                  "RM ${homestayList[index].homestayPrice}/night"),
                              const SizedBox(height: 4),
                              Row(children: [
                                Flexible(
                                    flex: 5,
                                    child: Text(
                                        "     ${homestayList[index].homestayLat} , ")),
                                Flexible(
                                    flex: 5,
                                    child: Text(homestayList[index]
                                        .homestayLng
                                        .toString()))
                              ]),
                              Row(children: [
                                Flexible(
                                    flex: 5,
                                    child: Text(
                                        "         ${homestayList[index].homestayLocal} , ")),
                                Flexible(
                                    flex: 5,
                                    child: Text(homestayList[index]
                                        .homestayState
                                        .toString()))
                              ]),
                              const SizedBox(height: 10),
                              Flexible(
                                flex: 6,
                                child: CachedNetworkImage(
                                  width: 150,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      "${Config.server}/homestay_raya/assets/productimages/${homestayList[index].homestayId}.png",
                                  placeholder: (context, url) =>
                                      const LinearProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              const SizedBox(height: 15),
                            ]),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
          drawer: MainMenuWidget(user: widget.user)),
    );
  }

  Future<void> _gotoNewProduct() async {
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please register an account with us",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (await _checkPermissionGetLoc()) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => NewProductScreen(
                    position: _position,
                    user: widget.user,
                  )));
      _loadProducts();
    } else {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<bool> _checkPermissionGetLoc() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Please allow the app to access the location",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Geolocator.openLocationSettings();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      Geolocator.openLocationSettings();
      return false;
    }
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return true;
  }

  void _loadProducts() {
    if (widget.user.id == "0") {
      //check if the user is registered or not
      Fluttertoast.showToast(
          msg: "Please register an account first", //Show toast
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return; //exit method if true
    }
    //if registered user, continue get request
    http
        .get(
      Uri.parse(
          "${Config.server}/homestay_raya/php/loadsellerhomestay.php?userid=${widget.user.id}"),
    )
        .then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          var extractdata = jsondata['data'];
          if (extractdata['homestay'] != null) {
            homestayList = <Homestay>[];
            extractdata['homestay'].forEach((v) {
              homestayList.add(Homestay.fromJson(v));
            });
            titlecenter = "Found";
          } else {
            titlecenter =
                "No Homestay Available"; //if no data returned show title center
            homestayList.clear();
          }
        } else {
          titlecenter = "No Homestay Available";
        }
      } else {
        titlecenter = "No Homestay Available"; //status code other than 200
        homestayList.clear(); //clear productList array
      }
      setState(() {}); //refresh UI
    });
  }
}
