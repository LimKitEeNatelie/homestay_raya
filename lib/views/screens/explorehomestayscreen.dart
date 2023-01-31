import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/models/homestay.dart';
import 'package:homestay_raya/views/screens/buyerhomestaydetails.dart';
import 'package:homestay_raya/views/screens/newproductscreen.dart';
import 'package:homestay_raya/views/shared/mainmenu.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import 'package:http/http.dart' as http;

class ExploreHomestayScreen extends StatefulWidget {
  final User user;
  const ExploreHomestayScreen({super.key, required this.user});

  @override
  State<ExploreHomestayScreen> createState() => _ExploreHomestayScreenState();
}

class _ExploreHomestayScreenState extends State<ExploreHomestayScreen> {
  var _lat, _lng;
  late Position _position;
  List<Homestay> homestayList = <Homestay>[];
  String titlecenter = "Loading...";
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  var placemarks;
  late double screenHeight, screenWidth, resWidth;
  var seller;
  var color;
  TextEditingController searchController = TextEditingController();
  String search = "all";
  int rowcount = 2;
  var numofpage, curpage = 1;
  int numberofresult = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadProducts("all", 1);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      rowcount = 3;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(title: const Text("Explore Homestay"), actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _loadSearchDialog();
              },
            ),
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
                        "Current homestays ($numberofresult found)",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.all(5.0),
                        crossAxisCount: 2,
                        children: List.generate(homestayList.length, (index) {
                          return Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.white70, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.blueGrey,
                              child: InkWell(
                                onTap: () {
                                  _showDetails(index);
                                },
                                child: Column(children: [
                                  const SizedBox(height: 15),
                                  Flexible(
                                    flex: 6,
                                    child: CachedNetworkImage(
                                      width: resWidth / 2,
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
                                  Text(
                                      truncateString(
                                          homestayList[index]
                                              .homestayName
                                              .toString(),
                                          15),
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
                                            "        ${homestayList[index].homestayLocal} , ")),
                                    Flexible(
                                        flex: 5,
                                        child: Text(
                                            "${homestayList[index].homestayState}")),
                                  ]),
                                  const SizedBox(height: 8),
                                ]),
                              ));
                        }),
                      ),
                    ),
                    //pagination widget
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: numofpage,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          //build the list for textbutton with scroll
                          if ((curpage - 1) == index) {
                            //set current page number active
                            color = Colors.red;
                          } else {
                            color = Colors.black;
                          }
                          return TextButton(
                              onPressed: () =>
                                  {_loadProducts(search, index + 1)},
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(color: color, fontSize: 18),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
          drawer: MainMenuWidget(user: widget.user)),
    );
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void _loadProducts(String search, int pageno) {
    curpage = pageno; //init current page
    numofpage ?? 1; //get total num of pages if not by default set to only 1

    http
        .get(
      Uri.parse(
          "${Config.server}/homestay_raya/php/loadallproducts.php?search=$search&pageno=$pageno"),
    )
        .then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        var jsondata =
            jsonDecode(response.body); //decode response body to jsondata array
        if (jsondata['status'] == 'success') {
          //check if status data array is success
          var extractdata = jsondata['data']; //extract data from jsondata array

          if (extractdata['homestays'] != null) {
            numofpage = int.parse(jsondata['numofpage']); //get number of pages
            numberofresult = int.parse(jsondata[
                'numberofresult']); //get total number of result returned
            //check if  array object is not null
            homestayList = <Homestay>[]; //complete the array object definition
            extractdata['homestays'].forEach((v) {
              //traverse products array list and add to the list object array productList
              homestayList.add(Homestay.fromJson(
                  v)); //add each product array to the list object array productList
            });
            titlecenter = "Found";
          } else {
            titlecenter = "No Homestay Available";
            homestayList.clear();
          }
        }
      } else {
        titlecenter = "No Homestay Available"; //status code other than 200
        homestayList.clear(); //clear productList array
      }
      setState(() {}); //refresh UI
    });
  }

  _showDetails(int index) async {
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
    Homestay homestay = Homestay.fromJson(homestayList[index].toJson());
    loadSingleSeller(index);
    Timer(const Duration(seconds: 1), () {
      if (seller != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (content) => BuyerHomestayDetails(
                      user: widget.user,
                      homestay: homestay,
                      seller: seller,
                    )));
      }
    });
  }

  void _loadSearchDialog() {
    searchController.text = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                title: const Text(
                  "Search ",
                ),
                content: SizedBox(
                  //height: screenHeight / 4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      search = searchController.text;
                      Navigator.of(context).pop();
                      _loadProducts(search, 1);
                    },
                    child: const Text("Search"),
                  )
                ],
              );
            },
          );
        });
  }

  loadSingleSeller(int index) {
    http.post(Uri.parse("${Config.server}/homestay_raya/php/load_seller.php"),
        body: {"sellerid": homestayList[index].userId}).then((response) {
      print(response.body);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == "success") {
        seller = User.fromJson(jsonResponse['data']);
      }
    });
  }
}
