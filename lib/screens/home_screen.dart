import 'package:animated_neumorphic/animated_neumorphic.dart';
import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fplwordle/helpers/utils/navigator.dart';
import 'package:fplwordle/helpers/widgets/dialog_helper.dart';
import 'package:fplwordle/models/user.dart';
import 'package:fplwordle/screens/profile_screen.dart';
import 'package:fplwordle/screens/settings_screen.dart';
import 'package:fplwordle/screens/shop_screen.dart';
import 'package:fplwordle/screens/signin_screen.dart';
import 'package:fplwordle/screens/tutorial_screen.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../helpers/utils/color_palette.dart';
import '../helpers/widgets/custom_btn.dart';
import '../helpers/widgets/custom_texts.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/sound_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  AuthProvider _authProvider = AuthProvider();
  GameProvider _miscProvider = GameProvider();
  ProfileProvider _profileProvider = ProfileProvider();
  SoundsProvider _soundsProvider = SoundsProvider();
  Duration _duration = Duration.zero;
  User? _user;
  List<Button> _buttons = [];

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _miscProvider = context.read<GameProvider>();
    _soundsProvider = context.read<SoundsProvider>();
    _soundsProvider.playGameMusic();
    _user = _authProvider.user;
    _duration = _miscProvider.durationUntilNextGame;
    _profileProvider = context.read<ProfileProvider>();
    if (_user != null) _profileProvider.createOrConfirmProfile(user: _user!);
    _buttons = [
      // play
      Button(icon: Icons.play_arrow, title: "Play", onTap: () {}),
      // multi player mode
      Button(icon: Icons.people, title: "Multiplayer", onTap: () {}),
      // leader board
      // Button(icon: Icons.leaderboard, title: "Leaderboard", onTap: () {}),
      // shop
      Button(
          icon: FontAwesomeIcons.coins,
          title: "Shop",
          onTap: () {
            if (_user == null) {
              _unAuthDialog();
            } else {
              transitioner(const ShopScreen(), context);
            }
          }),
      // how to play
      Button(icon: Icons.help, title: "How to play", onTap: () => transitioner(const TutorialScreen(), context)),
      // profile
      Button(icon: Icons.person, title: "Profile", onTap: () => transitioner(const ProfileScreen(), context)),
      // settings
      Button(icon: Icons.settings, title: "Settings", onTap: () => transitioner(const SettingsScreen(), context)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg2.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.8),
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width > 600 ? 50 : 20),
              child: SingleChildScrollView(
                child: Column(children: [
                  const SizedBox(height: 20),
                  // appbar
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    centerTitle: false,
                    title: appbarTitle(),
                    actions: [
                      // login
                      if (_user == null && MediaQuery.of(context).size.width > 600)
                        customButton(context,
                            icon: Icons.login,
                            text: "Sign In",
                            width: 120,
                            backgroundColor: Palette.scaffold,
                            onTap: () => transitioner(const SignInScreen(), context)),
                      const SizedBox(width: 15),
                      // free coins
                      if (!kIsWeb && _user != null)
                        InkWell(
                          onTap: () async {
                            await _soundsProvider.playClick();
                            if (mounted) {
                              customDialog(context: context, title: "Free coins", contentList: [
                                Center(
                                  child: Image.asset(
                                    'assets/coins.png',
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                bodyText(text: "Get 15 free coins daily"),
                                const SizedBox(height: 20),
                                customButton(context,
                                    icon: Icons.video_collection_sharp,
                                    text: "WATCH AN AD",
                                    width: 200,
                                    backgroundColor: Palette.cardBodyGreeen, onTap: () {
                                  // TODO: show ad (one daily)
                                }),
                              ]);
                            }
                          },
                          child: Center(
                            child: Image.asset(
                              'assets/gift.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        )
                            .animate(
                                onComplete: (controller) => controller.repeat(min: 0.95, max: 1.0, period: 1000.ms))
                            .scale(
                              delay: const Duration(milliseconds: 500),
                              duration: 1000.ms,
                            ),
                      const SizedBox(width: 15),
                      // countdown timer
                      InkWell(
                          onTap: () async {
                            await _soundsProvider.playClick();
                            if (mounted) {
                              customDialog(
                                context: context,
                                title: "Next game in",
                                contentList: [
                                  // countdown timer
                                  SlideCountdownSeparated(
                                    duration: _duration,
                                    shouldShowDays: (_) => false,
                                    shouldShowHours: (_) => true,
                                    shouldShowMinutes: (_) => true,
                                    shouldShowSeconds: (_) => true,
                                    showZeroValue: true,
                                    textDirection: TextDirection.ltr,
                                    curve: Curves.easeIn,
                                    onDone: () {
                                      setState(() async {
                                        _duration = await _miscProvider.setDurationUntilNextGame();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  // info text
                                  bodyText(text: "Puzzle resets 5:00PM UTC everyday", fontSize: 16),
                                  const SizedBox(height: 30),
                                  // close button
                                  SizedBox(
                                    width: 150,
                                    child: customButton(context,
                                        icon: Icons.close,
                                        text: "Close",
                                        onTap: () => popNavigator(context, rootNavigator: true)),
                                  )
                                ],
                              );
                            }
                          },
                          child: SlideCountdownSeparated(
                            duration: _duration,
                            shouldShowDays: (_) => false,
                            shouldShowHours: (_) => true,
                            shouldShowMinutes: (_) => true,
                            shouldShowSeconds: (_) => true,
                            showZeroValue: true,
                            textDirection: TextDirection.ltr,
                            curve: Curves.easeIn,
                            onDone: () async {
                              _duration = await _miscProvider.setDurationUntilNextGame();
                              setState(() {});
                            },
                          ))
                    ],
                  ),
                  const SizedBox(height: 30),
                  // logo
                  Center(
                    child: Container(
                      height: 200,
                      width: 300,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    )
                        .animate(onComplete: (controller) => controller.repeat(min: 0.95, max: 1.0, period: 1000.ms))
                        .scale(
                          duration: 1000.ms,
                        ),
                  ),
                  const SizedBox(height: 40),
                  // _buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return Column(
                            children: _buttons.map((button) {
                          return Container(margin: const EdgeInsets.only(bottom: 15), child: mobileButton(button));
                        }).toList());
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buttons.map((e) {
                            return Container(
                                margin: const EdgeInsets.only(right: 15),
                                child: InkWell(
                                  onTap: () async {
                                    await _soundsProvider.playClick();
                                    e.onTap();
                                  },
                                  child: AnimatedNeumorphicContainer(
                                      depth: 0,
                                      color: Palette.scaffold,
                                      width: 100,
                                      height: 100,
                                      radius: 25.0,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(e.icon, color: Colors.white, size: 30),
                                          const SizedBox(height: 10),
                                          bodyText(text: e.title, color: Colors.white, fontSize: 20, bold: true),
                                        ],
                                      )),
                                ));
                          }).toList(),
                        );
                      }
                    },
                  ),
                ]),
              ),
            )));
  }

  Widget appbarTitle() {
    Profile? profile = context.select<ProfileProvider, Profile?>((provider) => provider.profile);
    if (_user != null) {
      return Row(
        children: [
          // user name
          Center(child: bodyText(text: _user!.name!, color: Colors.white, fontSize: 20, bold: true)),
          const SizedBox(width: 8),
          // coins
          Center(child: Image.asset('assets/coin.png', height: 25, width: 25)),
          const SizedBox(width: 8),
          Center(
            child: bodyText(
                text: profile == null ? "0" : profile.coins.toString(), color: Colors.white, fontSize: 20, bold: true),
          ),
        ],
      );
    } else {
      if (MediaQuery.of(context).size.width < 600) {
        return Container(
          alignment: Alignment.centerLeft,
          height: 40,
          child: customButton(context,
              icon: Icons.login,
              text: "Sign In",
              width: 110,
              backgroundColor: Palette.scaffold,
              onTap: () => transitioner(const SignInScreen(), context)),
        );
      } else {
        return const Text('');
      }
    }
  }

  Widget mobileButton(Button button) {
    if (kIsWeb) {
      return customButton(
        context,
        icon: button.icon,
        text: button.title,
        backgroundColor: Palette.scaffold,
        onTap: () => button.onTap(),
      );
    } else {
      return customButton(
        context,
        icon: button.icon,
        text: button.title,
        backgroundColor: Palette.scaffold,
        onTap: () => button.onTap(),
      ).animate(onPlay: (controller) => controller.repeat(period: 2000.ms)).shimmer(
            delay: 1000.ms,
            duration: 2000.ms,
            color: Colors.white.withOpacity(0.8),
          );
    }
  }

  _unAuthDialog() {
    customDialog(context: context, title: "Sign In", contentList: [
      Center(
        child: bodyText(
            text: "You need to be signed in to access this feature", fontSize: 16, textAlign: TextAlign.center),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 150,
        child: customButton(context,
            icon: Icons.login, text: "Sign In", onTap: () => transitioner(const SignInScreen(), context)),
      )
    ]);
  }
}

class Button {
  String title;
  IconData icon;
  Function onTap;
  Button({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
