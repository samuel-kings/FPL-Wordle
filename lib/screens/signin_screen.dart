import 'package:animated_neumorphic/animated_neumorphic.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fplwordle/consts/routes.dart';
import 'package:fplwordle/helpers/utils/color_palette.dart';
import 'package:fplwordle/helpers/utils/navigator.dart';
import 'package:fplwordle/helpers/widgets/custom_texts.dart';
import 'package:fplwordle/helpers/widgets/snack_bar_helper.dart';
import 'package:fplwordle/main.dart';
import 'package:fplwordle/providers/auth_provider.dart';
import 'package:fplwordle/providers/sound_provider.dart';
import 'package:fplwordle/screens/signup_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/widgets/loading_animation.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  AuthProvider _authProvider = AuthProvider();
  SoundsProvider _soundsProvider = SoundsProvider();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();

  bool _isEmailAuthLoading = false;
  bool _isGoogleAuthLoading = false;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _soundsProvider = context.read<SoundsProvider>();
    _soundsProvider.stopGameMusic();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // mobile view
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0,
                title: Row(
                  children: [
                    Image.asset(
                      'assets/icon.png',
                      height: 25,
                    ),
                    const SizedBox(width: 5),
                    headingText(text: 'Fantasy Football Guesser', variation: 2, fontSize: 16)
                  ],
                ),
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Palette.scaffold.withOpacity(0.85),
                  padding: const EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            // heading
                            Align(
                                alignment: Alignment.centerLeft,
                                child: headingText(text: 'SIGN IN', variation: 3, fontSize: 45)),
                            const SizedBox(height: 20),
                            // email
                            Align(alignment: Alignment.centerLeft, child: bodyText(text: 'Email Address')),
                            AnimatedNeumorphicContainer(
                              depth: 0,
                              color: const Color(0xFF1E293B),
                              height: 50,
                              radius: 16.0,
                              child: DefaultTextStyle(
                                style: GoogleFonts.ntr(),
                                child: TextFormField(
                                  controller: _email,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.ntr(color: Colors.white, fontSize: 16),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                    hintText: 'example@gmail.com',
                                    hintStyle: GoogleFonts.ntr(color: Colors.grey, fontSize: 16),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // password
                            Align(alignment: Alignment.centerLeft, child: bodyText(text: 'Create Password')),
                            AnimatedNeumorphicContainer(
                              depth: 0,
                              color: const Color(0xFF1E293B),
                              height: 50,
                              radius: 16.0,
                              child: TextFormField(
                                  controller: _password,
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.done,
                                  obscureText: _hidePassword,
                                  obscuringCharacter: '*',
                                  keyboardType: TextInputType.visiblePassword,
                                  style: GoogleFonts.ntr(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                                      hintText: '********',
                                      hintStyle: GoogleFonts.ntr(color: Colors.grey, fontSize: 16),
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _hidePassword = !_hidePassword;
                                          });
                                        },
                                        icon: Icon(
                                          _hidePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.white,
                                        ),
                                      ))),
                            ),
                            const SizedBox(height: 30),
                            // buttons
                            InkWell(
                              onTap: _isGoogleAuthLoading
                                  ? null
                                  : () async {
                                      FocusScope.of(context).unfocus();
                                      // validate email
                                      if (EmailValidator.validate(_email.text.trim()) == false) {
                                        snackBarHelper(context,
                                            message: 'Invalid email', type: AnimatedSnackBarType.error);
                                        return;
                                      }

                                      // validate password
                                      if (_password.text.trim().isEmpty || _password.text.trim().length < 8) {
                                        snackBarHelper(context,
                                            message: 'Password should be at least 8 characters',
                                            type: AnimatedSnackBarType.error);
                                        return;
                                      }

                                      setState(() {
                                        _isEmailAuthLoading = true;
                                      });

                                      TextInput.finishAutofillContext();

                                      bool success = await _authProvider.emailSignIn(
                                          email: _email.text.trim(), password: _password.text.trim());

                                      setState(() {
                                        _isEmailAuthLoading = false;
                                      });

                                      if (success && mounted) {
                                        pushAndRemoveNavigator(const MyApp(), context);
                                      } else {
                                        snackBarHelper(context,
                                            message: _authProvider.error, type: AnimatedSnackBarType.error);
                                      }
                                    },
                              child: AnimatedNeumorphicContainer(
                                depth: 0,
                                color: Palette.primary,
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                radius: 16.0,
                                child: _isEmailAuthLoading
                                    ? loadingAnimation()
                                    : Center(child: headingText(text: 'Continue', color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // don't have an account
                            Center(
                              child: RichText(
                                  text: TextSpan(
                                      text: 'DON\'T HAVE  AN ACCOUNT?  ',
                                      style: GoogleFonts.ntr(
                                          color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                                      children: [
                                    TextSpan(
                                        text: 'SIGN UP',
                                        style: GoogleFonts.ntr(
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            transitioner(const SignupScreen(), context, Routes.signup);
                                          })
                                  ])),
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: Colors.white, thickness: 1.5),
                            const SizedBox(height: 10),
                            // google login button
                            Center(
                              child: bodyText(text: 'Or sign in with', color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: _isEmailAuthLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isGoogleAuthLoading = true;
                                      });

                                      bool success = await _authProvider.googleAuth();

                                      setState(() {
                                        _isGoogleAuthLoading = false;
                                      });

                                      if (success && mounted) {
                                        pushAndRemoveNavigator(const MyApp(), context);
                                      } else {
                                        snackBarHelper(context,
                                            message: _authProvider.error, type: AnimatedSnackBarType.error);
                                      }
                                    },
                              child: AnimatedNeumorphicContainer(
                                depth: 0,
                                color: const Color(0xFF1E293B),
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                radius: 16.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/google.png', width: 20, height: 20),
                                    const SizedBox(width: 10),
                                    headingText(text: 'Google', color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // privacy policy (rich text)
                            RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: 'By signing up, you agree to our ',
                                    style: GoogleFonts.ntr(color: Colors.white, fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Terms of Service',
                                          style: GoogleFonts.ntr(
                                              color: Palette.primary, fontSize: 16, fontWeight: FontWeight.bold),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              launchUrl(
                                                Uri.parse('https://www.fplwordle.com/tos'),
                                                mode: LaunchMode.inAppWebView,
                                              );
                                            })
                                    ]))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
        } else {
          // desktop view
          return Scaffold(
              body: Row(
            children: [
              // left side
              Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/bg1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Palette.scaffold.withOpacity(0.85),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        // appbar
                        AppBar(
                            backgroundColor: Colors.transparent,
                            automaticallyImplyLeading: false,
                            elevation: 0,
                            title: Row(
                              children: [
                                Image.asset(
                                  'assets/icon.png',
                                  height: 25,
                                ),
                                const SizedBox(width: 5),
                                headingText(text: 'Fantasy Football Guesser', variation: 2, fontSize: 16)
                              ],
                            ),
                            actions: [
                              Container(
                                margin: const EdgeInsets.only(right: 10.0),
                                alignment: Alignment.center,
                                child: RichText(
                                    text: TextSpan(
                                        text: 'DON\'T HAVE  AN ACCOUNT?  ',
                                        style: GoogleFonts.ntr(
                                            color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                                        children: [
                                      TextSpan(
                                          text: 'SIGN UP',
                                          style: GoogleFonts.ntr(
                                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              transitioner(const SignupScreen(), context, Routes.signup);
                                            })
                                    ])),
                              )
                            ]),
                        const Spacer(),
                        // text
                        Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              headingText(text: 'WELCOME BACK', variation: 3, fontSize: 30),
                              const SizedBox(height: 10),
                              bodyText(
                                  text: "Sign in to sync your progress and continue where you left off", fontSize: 16)
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
              // right side
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                color: Palette.scaffold,
                padding: const EdgeInsets.all(50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // heading
                      Align(
                          alignment: Alignment.centerLeft,
                          child: headingText(text: 'SIGN IN', variation: 3, fontSize: 45)),
                      const SizedBox(height: 20),
                      // email
                      Align(alignment: Alignment.centerLeft, child: bodyText(text: 'Email Address')),
                      AnimatedNeumorphicContainer(
                        depth: 0,
                        color: const Color(0xFF1E293B),
                        height: 50,
                        radius: 16.0,
                        child: TextFormField(
                          controller: _email,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.ntr(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                            hintText: 'example@gmail.com',
                            hintStyle: GoogleFonts.ntr(color: Colors.grey, fontSize: 16),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // password
                      Align(alignment: Alignment.centerLeft, child: bodyText(text: 'Create Password')),
                      AnimatedNeumorphicContainer(
                        depth: 0,
                        color: const Color(0xFF1E293B),
                        height: 50,
                        radius: 16.0,
                        child: TextFormField(
                            controller: _password,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            obscureText: _hidePassword,
                            keyboardType: TextInputType.visiblePassword,
                            style: GoogleFonts.ntr(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                                hintText: '********',
                                hintStyle: GoogleFonts.ntr(color: Colors.grey, fontSize: 16),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white,
                                  ),
                                ))),
                      ),
                      const SizedBox(height: 30),
                      // buttons
                      InkWell(
                        onTap: _isGoogleAuthLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();
                                // validate email
                                if (EmailValidator.validate(_email.text.trim()) == false) {
                                  snackBarHelper(context, message: 'Invalid email', type: AnimatedSnackBarType.error);
                                  return;
                                }

                                // validate password
                                if (_password.text.trim().isEmpty || _password.text.trim().length < 8) {
                                  snackBarHelper(context,
                                      message: 'Password should be at least 8 characters',
                                      type: AnimatedSnackBarType.error);
                                  return;
                                }

                                setState(() {
                                  _isEmailAuthLoading = true;
                                });

                                TextInput.finishAutofillContext();

                                bool success = await _authProvider.emailSignIn(
                                    email: _email.text.trim(), password: _password.text.trim());

                                setState(() {
                                  _isEmailAuthLoading = false;
                                });

                                if (success && mounted) {
                                  transitioner(const HomeScreen(), context, Routes.home);
                                } else {
                                  snackBarHelper(context,
                                      message: _authProvider.error, type: AnimatedSnackBarType.error);
                                }
                              },
                        child: AnimatedNeumorphicContainer(
                          depth: 0,
                          color: Palette.primary,
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          radius: 16.0,
                          child: _isEmailAuthLoading
                              ? loadingAnimation()
                              : Center(child: headingText(text: 'Continue', color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white, thickness: 1.5),
                      const SizedBox(height: 10),
                      // google login button
                      Center(
                        child: bodyText(text: 'Or sign in with', color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _isEmailAuthLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isGoogleAuthLoading = true;
                                });

                                bool success = await _authProvider.googleAuth();

                                setState(() {
                                  _isGoogleAuthLoading = false;
                                });

                                if (success && mounted) {
                                  pushAndRemoveNavigator(const MyApp(), context);
                                } else {
                                  snackBarHelper(context,
                                      message: _authProvider.error, type: AnimatedSnackBarType.error);
                                }
                              },
                        child: AnimatedNeumorphicContainer(
                          depth: 0,
                          color: const Color(0xFF1E293B),
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          radius: 16.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/google.png', width: 20, height: 20),
                              const SizedBox(width: 10),
                              headingText(text: 'Google', color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // privacy policy (rich text)
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: 'By signing up, you agree to our ',
                              style: GoogleFonts.ntr(color: Colors.white, fontSize: 16),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Terms of Service',
                                    style: GoogleFonts.ntr(
                                        color: Palette.primary, fontSize: 16, fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrl(
                                          Uri.parse('https://www.fplwordle.com/tos'),
                                          mode: LaunchMode.inAppWebView,
                                        );
                                      })
                              ]))
                    ],
                  ),
                ),
              ),
            ],
          ));
        }
      },
    );
  }
}
