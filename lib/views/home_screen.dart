import 'dart:async';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/model/data.dart';
import 'package:memory_game/views/won_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _previousIndex = -1;
  int countDownTime = 5;
  int gameDuration = -5;
  bool flip = false;
  bool start = false;
  bool wait = false;
  bool isFinished = false;
  Timer? timer;
  late Timer durationTimer;
  late int left;
  late List data;
  late List<bool> cardFlips;
  late List<GlobalKey<FlipCardState>> _cardStateKeys;

  void setDuration() {
    //Start Timer
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        countDownTime = (countDownTime - 1);
      });
    });

    //Start Duration
    durationTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        gameDuration = (gameDuration + 1);
      });
    });

    //startGameAfterDelay
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        start = true;
        timer!.cancel();
      });
    });
  }

  void initializeGameData() {
    data = createShuffledListFromImageSource();
    cardFlips = getInitialItemStateList();
    _cardStateKeys = createFlipCardStateKeysList();
    countDownTime = 5;
    left = (data.length ~/ 2);
    isFinished = false;
  }

  @override
  void initState() {
    setDuration();
    initializeGameData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
    durationTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return isFinished
        ? WonScreen(
            duration: gameDuration,
          )
        : Scaffold(
            backgroundColor: Colors.black26,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 60,
                    ),
                    TopTextRow(
                        left: left,
                        countDownTime: countDownTime,
                        gameDuration: gameDuration),
                    const SizedBox(
                      height: 70,
                    ),
                    GridView.builder(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) => start
                          ? FlipCard(
                              key: _cardStateKeys[index],
                              onFlip: () {
                                if (!flip) {
                                  flip = true;
                                  _previousIndex = index;
                                } else {
                                  flip = false;
                                  if (_previousIndex != index) {
                                    if (data[_previousIndex] != data[index]) {
                                      wait = true;

                                      Future.delayed(
                                          const Duration(milliseconds: 1500),
                                          () {
                                        _cardStateKeys[_previousIndex]
                                            .currentState!
                                            .toggleCard();
                                        _previousIndex = index;
                                        _cardStateKeys[_previousIndex]
                                            .currentState!
                                            .toggleCard();

                                        Future.delayed(
                                            const Duration(milliseconds: 160),
                                            () {
                                          setState(() {
                                            wait = false;
                                          });
                                        });
                                      });
                                    } else {
                                      cardFlips[_previousIndex] = false;
                                      cardFlips[index] = false;
                                  
                                      setState(() {
                                        left -= 1;
                                      });
                                      if (cardFlips.every((t) => t == false)) {
                                        Future.delayed(
                                            const Duration(milliseconds: 160),
                                            () {
                                          setState(() {
                                            isFinished = true;
                                            start = false;
                                          });
                                          durationTimer.cancel();
                                        });
                                      }
                                    }
                                  }
                                }
                                setState(() {});
                              },
                              flipOnTouch: wait ? false : cardFlips[index],
                              direction: FlipDirection.HORIZONTAL,
                              front: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: const DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      "assets/images/cover_image.jpg",
                                    ),
                                  ),
                                ),
                                margin: const EdgeInsets.all(4.0),
                              ),
                              back: getItem(index))
                          : getItem(index),
                      itemCount: data.length,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget getItem(int index) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(data[index])),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class TopTextRow extends StatelessWidget {
  final int left;
  final int gameDuration;
  final int countDownTime;
  const TopTextRow(
      {super.key,
      required this.left,
      required this.gameDuration,
      required this.countDownTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Remaining: $left',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        gameDuration >= 0
            ? Text(
                'Duration: ${gameDuration}s',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : Container(),
        countDownTime > 0
            ? Text(
                'Countdown: $countDownTime',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : Container()
      ],
    );
  }
}
