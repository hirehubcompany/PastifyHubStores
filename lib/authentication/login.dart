import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pastifyhubstores/authentication/register.dart';
import 'package:sizer/sizer.dart';
import '../utils/app color.dart';
import '../widgets/custom button.dart';
import '../widgets/custom input.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.backgroundLight,
          title: Text(
            'Login Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
              fontSize: 16.sp,
            ),
          ),
          content: Text(
            error,
            style: TextStyle(color: AppColors.textLight, fontSize: 12.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: AppColors.primary, fontSize: 12.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _loginAccount() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _loginEmail,
        password: _loginPassword,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is invalid.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  void _submitForm() async {
    setState(() => _loginFormLoading = true);

    String? _loginFeedback = await _loginAccount();
    if (_loginFeedback != null) {
      _alertDialogBuilder(_loginFeedback);
      setState(() => _loginFormLoading = false);
    }
  }

  bool _loginFormLoading = false;
  String _loginEmail = '';
  String _loginPassword = '';

  late FocusNode _passwordFocusNode;
  late FocusNode _emailFocusNode;

  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundLight,
                  AppColors.backgroundLight.withOpacity(0.9),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      Icon(
                        Icons.storefront,
                        size: 24.w,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 3.h),

                      // Title
                      Text(
                        'PastifyHubStores',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Subtitle
                      Text(
                        'Log in to explore and shop',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textLight.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),

                      // Email Input
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomInput(
                          hintText: 'Email Address',
                          onChanged: (value) => _loginEmail = value,
                          textInputAction: TextInputAction.next,
                          isPasswordField: false,
                          onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                          focusNode: _emailFocusNode,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Password Input
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomInput(
                          hintText: 'Password',
                          onChanged: (value) => _loginPassword = value,
                          isPasswordField: true,
                          focusNode: _passwordFocusNode,
                          onSubmitted: (_) => _submitForm(),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Login Button with Animation
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: _loginFormLoading ? null : _submitForm,
                          child: CustomBtn(
                            text: 'Log In',
                            outlineBtn: false,
                            isLoading: _loginFormLoading,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Create Account Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: CustomBtn(
                          text: 'Create Account',
                          outlineBtn: true,
                          isLoading: false,
                          color: AppColors.secondary,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Forgot Password
                      GestureDetector(
                        onTap: () {
                          // Implement forgot password logic
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}