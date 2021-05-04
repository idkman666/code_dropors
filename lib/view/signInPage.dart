import 'package:dropors/service/authenticationService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObsecure = true;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconBuilder(),
          formBuilder(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<AuthenticationService>().singIn(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim());
                },
                child: Text("Sign In"),
              ),
              ElevatedButton(onPressed: () {}, child: Text("Sign Up"))
            ],
          )
        ],
      ),
    );
  }

  Widget iconBuilder() {
    return Text("hello");
  }

  Widget formBuilder() {
    return Card(
      elevation: 8.0,
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Username")),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_isObsecure == true
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isObsecure = !_isObsecure;
                        });
                      },
                    )),
                obscureText: _isObsecure,
              ),
              buttonsBuilder()
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonsBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            context.read<AuthenticationService>().singIn(
                email: emailController.text.trim(),
                password: passwordController.text.trim());
          },
          child: Text("Sign In"),
        ),
        ElevatedButton(onPressed: () {}, child: Text("Sign Up"))
      ],
    );
  }
}
