import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobsms/mobsms.dart';
import 'package:multi_image/Api.dart';
import 'package:multi_image/Config.dart';
import 'package:multi_image/entity/login_entity.dart';
import 'package:multi_image/event/LoginEvent.dart';
import 'package:multi_image/http/HttpRequest.dart';
import 'package:multi_image/widget/T.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class LoginForm extends StatefulWidget {
  PageController _pageController;

  LoginForm(this._pageController);

  @override
  State<StatefulWidget> createState() {
    return new LoginFormState(_pageController);
  }
}

class LoginFormState extends State<LoginForm>
    with AutomaticKeepAliveClientMixin {
  PageController _pageController;
  LoginFormState(this._pageController);

  String _name; // 用户名
  String _pwd;  // 密码
  String _phone;  // 手机号
  String _number; // 验证码
  Timer _timer;
  int totalTime = 60; // 获取下一次验证码倒计时
  bool isGetChenckNum = false;  // 是否正在获取验证码

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
          height: ScreenUtil.getInstance().setHeight(5),
        ),
        new GestureDetector(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: true,
                child: IconButton(
                  icon: Icon(Icons.arrow_right),
                  disabledColor: Color(int.parse("0x00000000")),
                  onPressed: null,
                ),
              ),
              new Text(
                "去注册",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: ScreenUtil.getInstance().setSp(40),
                    decoration: TextDecoration.none),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                disabledColor: Colors.lightBlue,
                onPressed: null,
              ),
            ],
          ),
          onTap: () {
            _pageController.animateToPage(1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          },
        ),
        new Container(
          width: ScreenUtil.getInstance().setWidth(750),
          child: new Column(
            children: <Widget>[
              new TextField(
                decoration: InputDecoration(
                    filled: true,
                    hintText: "请输入用户名",
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(Icons.account_circle)),
                onChanged: (val) {
                  _name = val;
                },
              ),
              new TextField(
                decoration: InputDecoration(
                    filled: true,
                    hintText: "请输入密码",
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(Icons.lock_open)),
                onChanged: (val) {
                  _pwd = val;
                },
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(480),
                    height: ScreenUtil().setHeight(100),
                    child: new TextField(
                      decoration: InputDecoration(
                          filled: true,
                          hintText: "请输入手机号码",
                          fillColor: Colors.transparent,
                          prefixIcon: Icon(Icons.phone_android)),
                      onChanged: (val) {
                        _phone = val;
                      },
                    ),
                  ),
                  RaisedButton(
                    child: isGetChenckNum == false ? Text('获取验证码') : Text('验证码$totalTime'),
                    color: Theme.of(context).primaryColor,
                    onPressed: (){
                      if(isGetChenckNum == true){
                        return;
                      }
                      if(_phone == null || _phone.isEmpty){
                        T.showToast('请输入手机号码');
                        return;
                      }
                      setState(() {
                        totalTime = 60;
                        isGetChenckNum = true;
                      });
                      // 先用正则检验手机号是否正确
                      if(checkPhoneRule(_phone) == false){
                        T.showToast('请输入正确的手机号码');
                        setState(() {
                          isGetChenckNum = false;
                        });
                        return;
                      }
                      _startTimer();
                      isGetChenckNum = true;
                      // 获取验证码
                      getCheckNum();
                    },
                  )
                ],
              ),
              new TextField(
                decoration: InputDecoration(
                    filled: true,
                    hintText: "请输入验证码",
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(Icons.check_circle_outline)),
                onChanged: (val) {
                  _number = val;
                },
              ),
              new Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                      top: ScreenUtil.getInstance().setWidth(85)),
                  height: ScreenUtil.getInstance().setWidth(120),
                  child: new RaisedButton(
                      onPressed: () {
                        doLogin();
                      },
                      textColor: Colors.white,
                      child: new Text(
                        "登录",
                        style: TextStyle(
                            fontSize: ScreenUtil.getInstance().setSp(40)),
                      ),
                      color: Colors.lightBlue,
                      shape: new StadiumBorder(
                          side: new BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.transparent,
                      ))))
            ],
          ),
        ),
      ],
    );
  }

  //每秒倒计时
  void _startTimer(){
    _timer = Timer.periodic(Duration(seconds: 1), (Timer){
      //一分钟后可再次获取验证码
      if(totalTime == 0){
        print('时间到了');
        _timer.cancel();
        setState(() {
          isGetChenckNum = false;
        });
        return; 
      }
      setState(() {
       totalTime--; 
       print('时间-1');
      });
    });
  }

  // 登录请求
  void doLogin() async {
    if (null == _name || _name.isEmpty) {
      T.showToast("请输入用户名");
      return;
    }
    if (null == _pwd || _pwd.isEmpty) {
      T.showToast("请输入密码");
      return;
    }
    if (null == _number || _number.isEmpty) {
      T.showToast('请输入验证码');
      return;
    }
    // 提交验证码
    var checked = true;
    await Smssdk.commitCode(_phone, '86', _number, (dynamic ret, Map err){
      if(err!=null)
      {
        T.showToast('验证码错误');
        checked = false;
      }
    });
    if(checked == false){
      return;
    }
    print('登陆了');
    // 开始登录
    var data;
    data = {'username': _name, 'password': _pwd};
    HttpRequest.getInstance().post(Api.LOGIN, data: data,
        successCallBack: (data) {
        eventBus.fire(LoginEvent());  // 发送登录事件广播
        T.showToast("登录成功！");
        saveInfo(data);
        Navigator.of(context).pop();
    }, errorCallBack: (code, msg) {
      T.showToast(msg);
    });
  }

  // 保存用户信息到本地
  void saveInfo(data) async {
    Map userMap = json.decode(data);
    LoginEntity entity = new LoginEntity.fromJson(userMap);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Config.SP_USER_INFO, data);
    await prefs.setString(Config.SP_PWD, _pwd);
  }

  // 正则判断手机号
  bool checkPhoneRule(phoneNum){
    RegExp exp = RegExp(
          r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    bool matched = exp.hasMatch(phoneNum);
    return matched;
  }

  // 获取验证码
  void getCheckNum() async {
    Smssdk.getTextCode(_phone, '86', '', (dynamic ret, Map err){
      if(err!=null)
      {
        if(err['code'] == 462){
          T.showToast('每分钟获取验证码次数超过限制');
        }
        if(err['code'] == 476){
          T.showToast('每天验证码获取次数最多10次');
        }
        T.showToast(err['msg']);
        print(err.toString());
        setState(() {
          isGetChenckNum = false;
          _timer.cancel();
        });
      }
      else
      {
        String rst = ret.toString();
        if (rst == null || rst == "") {
          rst = '获取验证码成功!';
        }
        T.showToast('rst');
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
