import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image/Config.dart';
import 'package:multi_image/entity/coin_info_entity.dart';
import 'package:multi_image/entity/login_entity.dart';
import 'package:multi_image/event/LoginEvent.dart';
import 'package:multi_image/http/HttpRequest.dart';
import 'package:multi_image/page/login/LoginPage.dart';
import 'package:multi_image/page/my/CollectedPage.dart';
import 'package:multi_image/page/my/RankPage.dart';
import 'package:multi_image/r.dart';
import 'package:multi_image/widget/T.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Drawer/dialog.dart';

import '../../Api.dart';
import '../../main.dart';
import '../BrowserPage.dart';

class MyFragment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyFragmentState();
  }
}

class MyFragmentState extends State<MyFragment>
    with AutomaticKeepAliveClientMixin {
  String headPath = null;

  void goLogin() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            resizeToAvoidBottomPadding: false,
            body: new LoginPage(),
          );
        },
      ),
    );
  }

  LoginEntity userEntity;
  CoinInfoEntity coinInfoEntity;

//获取本地用户信息
  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String info = prefs.getString(Config.SP_USER_INFO);
    if(null == info) {
      userEntity = null;
      return;
    }
    if (null != info && info.isNotEmpty) {
      Map userMap = json.decode(info);
      setState(() {
        userEntity = new LoginEntity.fromJson(userMap);
      });
    }
    if (prefs.containsKey(Config.SP_HEAD_PATH)) {
      String temp = prefs.getString(Config.SP_HEAD_PATH);
      setState(() {
        headPath = temp;
      });
    }
    getCoinCount();
  }

  // 清除本地用户信息
  Future<void> clearUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Config.SP_HEAD_PATH, null);
    prefs.setString(Config.SP_USER_INFO, null);
    await HttpRequest.getInstance().get(Api.LOGOUT,successCallBack: (data){});
    eventBus.fire(LoginOutEvent());  // 发送退出登录事件广播
    T.showToast('已退出登录');
  }

//  获取积分
  getCoinCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String info = prefs.getString(Config.SP_USER_INFO);
    if(null == info) {
      userEntity = null;
      return;
    }
    
    HttpRequest.getInstance().get(Api.COIN_USERINFO, successCallBack: (data) {
      Map userMap = json.decode(data);
      setState(() {
        coinInfoEntity = CoinInfoEntity.fromJson(userMap);
      });
    }, errorCallBack: (code, msg) {});
  }

  @override
  void initState() {
    super.initState();
    eventBus.on<LoginEvent>().listen((event) { // 监听到登录事件 获取存到本地的用户信息
      setState(() {
        getUserInfo();
      });
    });
    eventBus.on<LoginOutEvent>().listen((event) async { // 监听退出登录事件 退出登录就重新刷新数据
        setState(() {
          userEntity = null;
          coinInfoEntity = null;
          headPath = null;
        });
    });
    if (null == userEntity) {
      getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: new Column(
          children: <Widget>[
            new Container(
              decoration: headPath == null
                  ? BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    )
                  : new BoxDecoration(
                      image: new DecorationImage(
                        image: FileImage(File(headPath)),
                        fit: BoxFit.fill,
                      ),
                    ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: new Column(
                  children: <Widget>[
                    AppBar(
                      actions: <Widget>[
                        new InkWell(
                          child: Padding(
                            padding: EdgeInsets.all(
                                ScreenUtil.getInstance().setWidth(55)),
                            child: new Image(
                              image: AssetImage(R.assetsImgIcRank),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .push(new MaterialPageRoute(builder: (_) {
                              return new RankPage();
                            }));
                          },
                        )
                      ],
                      // backgroundColor: Colors.transparent,
                      elevation: 0, //去掉阴影效果
                    ),
                    Container(
                      height: ScreenUtil.getInstance().setWidth(50),
                    ),
                    new GestureDetector(
                      child: new ClipOval(
                        child: new Image(
                          image: null == headPath
                              ? AssetImage(R.assetsImgImgUserHead)
                              : FileImage(new File(headPath)),
                          width: ScreenUtil.getInstance().setWidth(220),
                          height: ScreenUtil.getInstance().setWidth(220),
                        ),
                      ),
                      onTap: () async {
                        if (null != userEntity) {
                          var image = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          File croppedFile = await ImageCropper.cropImage(
                              sourcePath: image.path,
                              aspectRatioPresets: [
                                CropAspectRatioPreset.square,
                              ],
                              androidUiSettings: AndroidUiSettings(
                                  toolbarTitle: '裁剪',
                                  toolbarColor: Theme.of(context).primaryColor,
                                  toolbarWidgetColor: Colors.white,
                                  initAspectRatio: CropAspectRatioPreset.square,
                                  hideBottomControls: true,
                                  lockAspectRatio: true),
                              iosUiSettings: IOSUiSettings(
                                minimumAspectRatio: 1.0,
                              ));
                          if (null != croppedFile) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString(
                                Config.SP_HEAD_PATH, croppedFile.path);
                            setState(() {
                              headPath = croppedFile.path;
                            });
                          }
                        } else {
                          goLogin();
                        }
                      },
                    ),
                    new Container(
                      height: ScreenUtil.getInstance().setWidth(30),
                    ),
                    new Text(
                      null == userEntity ? "去登陆" : userEntity.nickname,
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(60),
                          color: Colors.white),
                    ),
                    new Container(
                      height: ScreenUtil.getInstance().setWidth(20),
                    ),
                    new Text(
                      null == userEntity ? "ID:---" : "ID:${userEntity.id}",
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(35),
                          color: Colors.white),
                    ),
                    new Container(
                      height: ScreenUtil.getInstance().setWidth(20),
                    ),
                    new Text(
                      null == coinInfoEntity
                          ? "等级:---   排名：--"
                          : "等级:1   排名：${coinInfoEntity.rank}",
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(35),
                          color: Colors.white),
                    ),
                    new Container(
                      height: ScreenUtil.getInstance().setWidth(50),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: <Widget>[
                    new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.getInstance().setWidth(45),
                              top: ScreenUtil.getInstance().setWidth(45),
                              bottom: ScreenUtil.getInstance().setWidth(45),
                              right: ScreenUtil.getInstance().setWidth(35)),
                          child: new Image(
                            image: AssetImage(R.assetsImgImgStar),
                            width: ScreenUtil.getInstance().setWidth(60),
                            height: ScreenUtil.getInstance().setWidth(60),
                          ),
                        ),
                        new Expanded(
                            child: new Text(
                          "我的积分",
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(40),
                              color: Theme.of(context).primaryColor),
                        )),
                        new Text(
                          null == coinInfoEntity
                              ? ""
                              : "${coinInfoEntity.coinCount}",
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(40),
                              color: Colors.black38),
                        ),
                        new Padding(
                          padding: EdgeInsets.only(
                              right: ScreenUtil.getInstance().setWidth(45)),
                          child: IconButton(
                            onPressed: (){},
                              icon: Image(
                                image: AssetImage(R.assetsImgImgRight),
                                width: ScreenUtil.getInstance().setWidth(55),
                                height: ScreenUtil.getInstance().setWidth(55),
                              )),
                        )
                      ],
                    ),
                    // 我的收藏
                    new GestureDetector(
                      onTap: () {
                        if(userEntity == null){
                          T.showToast("请先登录");
                          return;
                        }
                        Navigator.of(context)
                            .push(new MaterialPageRoute(builder: (_) {
                          return new CollectedPage();
                        }));
                      },
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil.getInstance().setWidth(45),
                                top: ScreenUtil.getInstance().setWidth(45),
                                bottom: ScreenUtil.getInstance().setWidth(45),
                                right: ScreenUtil.getInstance().setWidth(35)),
                            child: new Image(
                              image: AssetImage(R.assetsImgImgHeart),
                              width: ScreenUtil.getInstance().setWidth(60),
                              height: ScreenUtil.getInstance().setWidth(60),
                            ),
                          ),
                          new Expanded(
                              child: new Text(
                            "我的收藏",
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(40),
                                color: Theme.of(context).primaryColor),
                          )),
                          new Padding(
                            padding: EdgeInsets.only(
                                right: ScreenUtil.getInstance().setWidth(45)),
                            child: IconButton(
                              onPressed: (){},
                                icon: Image(
                                  image: AssetImage(R.assetsImgImgRight),
                                  width: ScreenUtil.getInstance().setWidth(55),
                                  height: ScreenUtil.getInstance().setWidth(55),
                                )),
                          )
                        ],
                      ),
                    ),
                    new InkWell(
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil.getInstance().setWidth(45),
                                top: ScreenUtil.getInstance().setWidth(45),
                                bottom: ScreenUtil.getInstance().setWidth(45),
                                right: ScreenUtil.getInstance().setWidth(35)),
                            child: new Image(
                              image: AssetImage(R.assetsImgImgGithub),
                              width: ScreenUtil.getInstance().setWidth(60),
                              height: ScreenUtil.getInstance().setWidth(60),
                            ),
                          ),
                          new Expanded(
                              child: new Text(
                            "项目地址",
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(40),
                                color: Theme.of(context).primaryColor),
                          )),
                          new Padding(
                            padding: EdgeInsets.only(
                                right: ScreenUtil.getInstance().setWidth(45)),
                            child: IconButton(
                                onPressed: (){},
                                icon: Image(
                                  image: AssetImage(R.assetsImgImgRight),
                                  width: ScreenUtil.getInstance().setWidth(55),
                                  height: ScreenUtil.getInstance().setWidth(55),
                                )),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .push(new MaterialPageRoute(builder: (_) {
                          return new Browser(
                            url: "https://gitee.com/wudeh",
                            title: "wudeh的码云平台",
                            id: 9705,
                          );
                        }));
                      },
                    ),
                    
                    // 用户登录时显示退出登录
                    userEntity != null ? new InkWell(
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil.getInstance().setWidth(45),
                                top: ScreenUtil.getInstance().setWidth(45),
                                bottom: ScreenUtil.getInstance().setWidth(45),
                                right: ScreenUtil.getInstance().setWidth(35)),
                            child: new Icon(Icons.local_cafe,size: ScreenUtil().setWidth(58),color: Theme.of(context).primaryColor,)
                          ),
                          new Expanded(
                              child: new Text(
                            "退出登录",
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(40),
                                color: Theme.of(context).primaryColor),
                          )),
                          new Padding(
                            padding: EdgeInsets.only(
                                right: ScreenUtil.getInstance().setWidth(45)),
                            child: IconButton(
                                onPressed: (){},
                                icon: Image(
                                  image: AssetImage(R.assetsImgImgRight),
                                  width: ScreenUtil.getInstance().setWidth(55),
                                  height: ScreenUtil.getInstance().setWidth(55),
                                )),
                          )
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          child: DialogShow(
                            title: '确定退出？',
                            yes: clearUserInfo,
                          )
                        );
                      },
                    ) : new Container()
                  ],
                )),
          ],
        ),
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
