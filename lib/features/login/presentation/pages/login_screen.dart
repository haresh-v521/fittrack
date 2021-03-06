import 'package:fittrack/common/general/circular_progress_indicator.dart';
import 'package:fittrack/common/general_widget.dart';
import 'package:fittrack/di/dependency_injection.dart';
import 'package:fittrack/features/home/presentation/widget/home_widget.dart';
import 'package:fittrack/features/login/presentation/bloc/bloc.dart';
import 'package:fittrack/features/login/presentation/widget/login_widget.dart';
import 'package:fittrack/main.dart';
import 'package:fittrack/ui_helper/images.dart';
import 'package:fittrack/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LogInScreen extends StatelessWidget {
  Bloc bloc = getIt<LogInBloc>();

  bool buttonStatus = false;
  String emailMsg = "Please Enter your Email";
  String passMsg = "Please Enter your Password";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Scr.setScreenSize(context);
    return SafeArea(
      child: Scaffold(
        body: BlocListener(
          cubit: bloc,
          listener: (BuildContext context, state) {
            if (state is LoadingBeginHomeState) isLoading = true;
            if (state is LoadingEndHomeState) isLoading = false;
            if (state is GetLogInButtonStatusState) {
              buttonStatus = state.errorStatusModel.buttonStatus;
              emailMsg = state.errorStatusModel.emailMsg;
              passMsg = state.errorStatusModel.passMsg;
            }
            if (state is GetLogInState) {
              if (state.logInModel.flag == 1) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
                );
              }
              Fluttertoast.showToast(msg: state.logInModel.msg);
            }
          },
          child: BlocBuilder(
            cubit: bloc,
            builder: (context, state) => Container(
              height: height,
              decoration: boxDecoration(
                image: bg_home_screen2,
              ),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        skipButton(context),
                        Container(height: Scr.screenHeight * 0.25, child: animatorLogo()),
                        LogInCard(
                          context,
                          bloc: bloc,
                          buttonStatus: buttonStatus,
                          emailMsg: emailMsg,
                          passMsg: passMsg,
                        )
                      ],
                    ),
                    if (isLoading) screenProgressIndicator
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
