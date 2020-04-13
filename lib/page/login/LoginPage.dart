import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_image/page/login/LoginForm.dart';
import 'package:multi_image/page/login/RegisterForm.dart';
import 'package:multi_image/r.dart';

class LoginPage extends StatelessWidget {
  var _pageController = new PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new Stack(
        children: <Widget>[
          Container(
            child:FlareActor(
              "assets/flrs/loginbg.flr",
              animation: "wave",
              fit: BoxFit.fill,
            ),
            height: ScreenUtil().setHeight(1200),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                height: ScreenUtil.getInstance().setHeight(40),
              ),
              new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: ScreenUtil.getInstance().setWidth(1080),
                  alignment: Alignment.centerLeft,
                  height: ScreenUtil.getInstance().setHeight(122),
                  padding:
                      EdgeInsets.all(ScreenUtil.getInstance().setWidth(30)),
                  child: new GestureDetector(
                    child: new Image(
                      image: AssetImage(R.assetsImgIcClose),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                new Image(
                  image: AssetImage(R.assetsImgLogo),
                  width: ScreenUtil.getInstance().setWidth(270),
                  height: ScreenUtil.getInstance().setWidth(270),
                ),
                // new Container(
                //   height: ScreenUtil.getInstance().setHeight(10),
                // ),
              ],
            ),
              new Container(
                child: new PageView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return index == 0
                        ? new LoginForm(_pageController)
                        : new RegisterForm(_pageController);
                  },
                  itemCount: 2,
                  controller: _pageController,
                ),
                height: ScreenUtil().setHeight(800),
                // width: ScreenUtil().setWidth(800),
              )
            ],
          ),
        ],
      )
    );
  }
}
