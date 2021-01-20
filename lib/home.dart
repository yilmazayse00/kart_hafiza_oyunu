import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:memory_card_game/ad_manager.dart';

int level = 8;
double sizeH, sizeW;

class Home extends StatefulWidget {
  final int size;

  const Home({Key key, this.size = 8}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BannerAd _bannerAd;
  List<GlobalKey<FlipCardState>> cardStateKeys = [];
  List<bool> cardFlips = [];
  List<String> data = [];
  int previousIndex = -1;
  bool flip = false;

  int time = 0;
  Timer timer;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.size; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
      cardFlips.add(true);
    }
    for (var i = 0; i < widget.size / 2; i++) {
      data.add(i.toString());
    }
    for (var i = 0; i < widget.size / 2; i++) {
      data.add(i.toString());
    }
    startTimer();
    data.shuffle();

    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.fullBanner,
    );
    _loadBannerAd();

  }

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  // @override
  // void dispose() {
  //   _bannerAd?.dispose();
  //   super.dispose();
  // }

  startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        time = time + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: sizeH / 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.exit_to_app),
                        color: Colors.green,
                        iconSize: 35,
                        onPressed: () => exit(0),
                      ),
                      Text(
                        "$time",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      IconButton(
                        icon: Icon(Icons.repeat),
                        color: Colors.green,
                        iconSize: 35,
                        onPressed: (){
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Home(
                              size: level,
                            ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Theme(
                  data: ThemeData.dark(),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) => FlipCard(
                        key: cardStateKeys[index],
                        onFlip: () {
                          if (!flip) {
                            flip = true;
                            previousIndex = index;
                          } else {
                            flip = false;
                            if (previousIndex != index) {
                              if (data[previousIndex] != data[index]) {
                                cardStateKeys[previousIndex]
                                    .currentState
                                    .toggleCard();
                                previousIndex = index;
                              } else {
                                cardFlips[previousIndex] = false;
                                cardFlips[index] = false;
                                print(cardFlips);
                                if (cardFlips.every((t) => t == false)) {
                                  showResult();
                                }
                              }
                            }
                          }
                        },
                        direction: FlipDirection.HORIZONTAL,
                        flipOnTouch: cardFlips[index],
                        front: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.green.withOpacity(0.3),
                          ),
                          margin: EdgeInsets.all(4.0),
                        ),
                        back: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.lightGreen,
                          ),
                          margin: EdgeInsets.all(4.0),
                          child: Center(
                            child: Text(
                              "${data[index]}",
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                        ),
                      ),
                      itemCount: data.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showResult() {
    timer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          "Tebrikler!",
        ),
        content: Text(
          '$time saniyede tamamladınız.',
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Home(
                    size: level,
                  ),
                ),
              );
              level += 2;
            },
            child: Row(
              children: [
                Text(
                  'Sonraki oyun',
                  style: TextStyle(color: Colors.green, fontSize: 15.0),
                ),
                Icon(
                  Icons.navigate_next,
                  color: Colors.lightGreen,
                  size: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
