import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/services/snackbar_service.dart';
import 'package:baqaala/src/widgets/user/home.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final blueColor = Color(0XFF5e92f3);
  final yellowColor = Color(0XFFfdd835);

  TapGestureRecognizer _tapGestureRecognizer;
  bool _showSignIn;

  @override
  void initState() {
    super.initState();
    _showSignIn = true;
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showSignIn = !_showSignIn;
          print("Hello");
        });
      };
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = Provider.of<AuthModel>(context);
    return Scaffold(
        body: Stack(
      children: [
        buildBackgroundTopCircle(),
        buildBackgroundBottomCircle(),
        Builder(builder: (BuildContext context) {
          SnackBarService.instance.buildContext = context;

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 50, bottom: 40),
                child: Column(
                  children: [
                    Text(
                      _showSignIn ? "SIGN IN" : "CREATE ACCOUNT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    // buildAvatarContainer(),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      height: _showSignIn ? 240 : 400,
                      margin: EdgeInsets.only(top: _showSignIn ? 40 : 30),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                              spreadRadius: 1,
                              offset: Offset(0, 1),
                            )
                          ]),
                      child: SingleChildScrollView(
                        child: _showSignIn
                            ? buildSignInTextFieldSection(auth)
                            : buildSignUpTextFieldSection(auth),
                      ),
                    ),
                    _showSignIn
                        ? buildSingInBottomSection()
                        : buildSingUpBottomSection(),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    ));
  }

  Container buildSingInBottomSection() {
    final AuthModel auth = Provider.of<AuthModel>(context);
    final CartProvider cart = Provider.of<CartProvider>(context);

    return Container(
      margin: EdgeInsets.only(top: 50),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              print("Forget Password");
            },
            child: Text(
              "Forget Password ?",
              style: TextStyle(
                color: blueColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          RaisedButton(
            color: blueColor,
            elevation: 10,
            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 12),
            onPressed: () async {
              var res = await auth.login();
              if (res) {
                cart.clearAll();
                cart.getOrders();
                Get.off(Home(
                  autoRedirect: true,
                ));
              } else {
                // Get.snackbar('Error', 'Login Error');
              }
              print(res);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.arrow_right,
                  color: yellowColor,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          RichText(
            text: TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                      text: "Create an Account",
                      recognizer: _tapGestureRecognizer,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
          )
        ],
      ),
    );
  }

  Container buildSingUpBottomSection() {
    final AuthModel auth = Provider.of<AuthModel>(context);

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          RaisedButton(
            color: yellowColor,
            elevation: 10,
            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
            onPressed: auth.isRegisterBusy
                ? null
                : () {
                    auth.register();
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "SUBMIT",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.arrow_right,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 18,
          ),
          RichText(
            text: TextSpan(
                text: "Already have an account? ",
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                      text: "Sing in",
                      recognizer: _tapGestureRecognizer,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
          )
        ],
      ),
    );
  }

  Column buildSignInTextFieldSection(AuthModel auth) {
    return Column(
      children: [
        buildTextField("EMAIL ADDRESS", "", false, auth.emailController),
        SizedBox(
          height: 30,
        ),
        buildTextField("PASSWORD", "", true, auth.passwordController),
      ],
    );
  }

  Column buildSignUpTextFieldSection(AuthModel auth) {
    return Column(
      children: [
        buildTextField("FULL NAME", "", false, auth.fullNameController),
        SizedBox(
          height: 20,
        ),
        buildTextField("EMAIL ADDRESS", "", false, auth.emailController),
        SizedBox(
          height: 20,
        ),
        buildTextField("MOBILE NUMBER", "", false, auth.mobileNumberController),
        SizedBox(
          height: 20,
        ),
        buildTextField("PASSWORD", '', true, auth.passwordController),
      ],
    );
  }

  Container buildTextField(String labelText, String placeholder,
      bool isPassword, TextEditingController controller) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(color: blueColor, fontSize: 12),
          ),
          SizedBox(
            height: 5,
          ),
          TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(16),
                filled: true,
                fillColor: Colors.grey[200],
                hintText: placeholder,
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]),
                ),
              ))
        ],
      ),
    );
  }

  Container buildAvatarContainer() {
    return Container(
      margin: EdgeInsets.only(top: 24),
      width: 130,
      height: 130,
      decoration: BoxDecoration(
          color: _showSignIn ? yellowColor : Colors.grey[800],
          borderRadius: BorderRadius.circular(65),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 4,
              blurRadius: 20,
            ),
          ]),
      child: Center(
        child: Stack(
          children: [
            Positioned(
              left: 1.0,
              top: 3.0,
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: Colors.black.withOpacity(.1),
              ),
            ),
            Icon(
              Icons.person_outline,
              size: 60,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Positioned buildBackgroundBottomCircle() {
    return Positioned(
      top: MediaQuery.of(context).size.height -
          MediaQuery.of(context).size.width,
      right: MediaQuery.of(context).size.width / 2,
      child: Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width,
            )),
      ),
    );
  }

  Positioned buildBackgroundTopCircle() {
    return Positioned(
      top: 0,
      child: Transform.translate(
        offset: Offset(0.0, -MediaQuery.of(context).size.width / 1.3),
        child: Transform.scale(
          scale: 1.35,
          child: Container(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: _showSignIn ? Colors.green[600] : blueColor,
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width,
                )),
          ),
        ),
      ),
    );
  }
}
