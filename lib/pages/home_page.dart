import 'dart:convert';
import 'package:coininfo/pages/details_page.dart';
import 'package:flutter/material.dart';
import 'package:coininfo/services/http_service.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? deviceHeight, deviceWidth;
  String selectedCoin = "Bitcoin";

  HTTPService? http;

  @override
  void initState() {
    super.initState();
    http = GetIt.instance.get<HTTPService>();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _selectedCoinDropdown(),
              _dataWidgets(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectedCoinDropdown() {
    List<String> coins = [
      "Bitcoin",
      "Ethereum",
      "Tether",
      "Cardano",
      "Ripple",
    ];
    List<DropdownMenuItem<String>> items = coins
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                )),
          ),
        )
        .toList();
    return DropdownButton(
      value: selectedCoin,
      items: items,
      onChanged: (dynamic value) {
        setState(() {
          selectedCoin = value;
        });
      },
      dropdownColor: const Color.fromRGBO(83, 88, 206, 1.0),
      iconSize: 30,
      icon: const Icon(
        Icons.arrow_drop_down_sharp,
        color: Colors.white,
      ),
      underline: Container(),
    );
  }

  Widget _dataWidgets() {
    return FutureBuilder(
      future: http!.get("/coins/${selectedCoin.toLowerCase()}"),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          Map data = jsonDecode(
            snapshot.data.toString(),
          );
          num usdPrice = data["market_data"]["current_price"]["usd"];
          num change24h = data["market_data"]["price_change_percentage_24h"];
          String imageUrl = data["image"]["large"];
          String description = data["description"]["en"];
          Map exchangeRates = data["market_data"]["current_price"];
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onDoubleTap: (() => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return DetailsPage(
                            rates: exchangeRates,
                          );
                        },
                      ),
                    )),
                child: _coinImageWidget(imageUrl),
              ),
              _currentPriceWidget(usdPrice),
              _percentageChangeWidget(change24h),
              _descriptionCardWidget(description),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  Widget _currentPriceWidget(num rate) {
    return Text(
      "${rate.toStringAsFixed(2)} USD",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _percentageChangeWidget(num change) {
    return Text("${change.toString()}%",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w300,
        ));
  }

  Widget _coinImageWidget(String imgUrl) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: deviceHeight! * 0.02,
      ),
      height: deviceHeight! * 0.15,
      width: deviceWidth! * 0.15,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imgUrl),
        ),
      ),
    );
  }

  Widget _descriptionCardWidget(String description) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String descriptionNoHTMLTags = description.replaceAll(exp, ' ');

    return Container(
      height: deviceHeight! * 0.45,
      width: deviceWidth! * 0.90,
      margin: EdgeInsets.symmetric(
        vertical: deviceHeight! * 0.05,
      ),
      padding: EdgeInsets.symmetric(
        vertical: deviceHeight! * 0.01,
        horizontal: deviceHeight! * 0.01,
      ),
      child: Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(
            descriptionNoHTMLTags,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
