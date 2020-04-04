import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_image/page/project/ProjectFragment.dart';
import 'package:multi_image/r.dart';
import 'package:multi_image/widget/T.dart';
import 'System/SystemFragment.dart';
import 'gongzhonghao/GongzhFragment.dart';
import 'home/HomeFragment.dart';
import 'my/MyFragment.dart';
import 'package:multi_image/widget/T.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:multi_image/r.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_image/Api.dart';
import 'package:multi_image/Config.dart';
import '../entity/login_entity.dart';
import '../http/HttpRequest.dart';
import 'dart:convert';
import './my/Drawer.dart';
//主页面
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new splashPage();
  }
}

// 倒计时启动页
class splashPage extends StatefulWidget {
  final Widget child;

  splashPage({Key key, this.child}) : super(key: key);

  _splashPageState createState() => _splashPageState();
}

class _splashPageState extends State<splashPage> with SingleTickerProviderStateMixin {

  Timer _timer;
  int totalTime = 5;

  //每秒倒计时
  void _startTimer(){
    _timer = Timer.periodic(Duration(seconds: 1), (Timer){
      if(totalTime == 0){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context)=>ApplicationPage()
        ),(route)=> route==null );
        return;   // 实际中路由还没完全跳转到主页面 数字还是会一直减少 为了避免出现减少到-1的情况 加个 return
      }
      setState(() {
       totalTime--; 
      });
    });
  }

  //取消倒计时
  void _cancelTimer(){
    _timer.cancel();
  }

  //获取本地用户信息
  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String info = prefs.getString(Config.SP_USER_INFO);
    if (null != info && info.isNotEmpty) {
      Map userMap = json.decode(info);
      LoginEntity userEntity = new LoginEntity.fromJson(userMap);
      String _name = userEntity.username;
      String _pwd = prefs.getString(Config.SP_PWD);
      if (null != _pwd && _pwd.isNotEmpty) {
        doLogin(_name, _pwd);
      }
    }
  }

//  登录
  doLogin(String _name, String _pwd) {
    var data;
    data = {'username': _name, 'password': _pwd};
    HttpRequest.getInstance().post(Api.LOGIN, data: data,
        successCallBack: (data) {
      saveInfo(data);
      // Navigator.of(context).pop();
    }, errorCallBack: (code, msg) {});
  }

//  保存用户信息
  void saveInfo(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Config.SP_USER_INFO, data);
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
         child: Container(
             child: Column(
               children: <Widget>[
                 Container(
                   height: ScreenUtil().setHeight(900),
                   decoration: BoxDecoration(
                     color: Colors.blue
                   ),
                 ),
                 Text("这是一个倒计时启动页",style: TextStyle(fontSize: 33,color: Colors.lightBlue),),
                 Container(
                   height: ScreenUtil().setHeight(750),
                   margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                   decoration: BoxDecoration(
                     color: Colors.blue
                   ),
                 ),
                 Container(
                   padding: EdgeInsets.only(left: ScreenUtil().setWidth(600)),
                   child: RaisedButton(
                     color: Colors.white,
                    child: Text('跳过${totalTime}',style: TextStyle(color: Colors.blue),),
                    onPressed: (){
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                        builder: (context)=>ApplicationPage()
                      ),(route)=> route==null );
                    },
                  ),
                 )
               ],
             )
           )
       ),
    );
  }
}


class ApplicationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ApplicationPageState();
  }
}

class _ApplicationPageState extends State<ApplicationPage> {
  int index = 0;
  var _pageController = new PageController(initialPage: 0);
  int popNum = 2;// 点击两次返回退出
  int _lastClickTime = 0;
  //网络状态描述
  String _connectStateDescription;
  var subscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //监测网络变化
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        T.showToast("当前为移动数据网络");
      } else if (result == ConnectivityResult.wifi) {
        T.showToast("当前使用wifi数据网络");
      } else {
        setState(() {
          _connectStateDescription = "无网络";
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //在页面销毁的时候一定要取消网络状态的监听
    subscription.cancle();
  }

  @override
  Widget build(BuildContext context) {
    return _connectStateDescription == "无网络" ? new Scaffold(
      appBar: AppBar(
        title: Text("无网络"),
      ),
      body: Center(
        child: Text("当前网络错误，请退出应用重试"),
      ),
    ) : new WillPopScope(
      onWillPop: _doubleExit,
      child: Scaffold(
      drawer: DrawerPage(), 
      body: new PageView.builder(
        onPageChanged: _pageChange,
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              {
                return new HomeFragment();
              }
              break;
            case 1:
              {
                return new SystemFragment();
              }
              break;
            case 2:
              {
                return new GongzhFragment();
              }
              break;
            case 3:
              {
                return new ProjectFragment();
              }
              break;
            case 4:
              {
                return new MyFragment();
              }
              break;
          }
          return null;
        },
        itemCount: 5,
      ),
      bottomNavigationBar: new BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          new BottomNavigationBarItem(
              backgroundColor: Theme.of(context).primaryColor,
              icon: index == 0
                  ? new Image(
                      image: AssetImage(R.assetsImgIcHomeSelected),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85))
                  : new Image(
                      image: AssetImage(R.assetsImgIcHomeNormal),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85)),
              title: new Text("首页",
                  style: new TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(26)))),
          new BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: index == 1
                  ? new Image(
                      image: AssetImage(R.assetsImgIcBookSelected),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85))
                  : new Image(
                      image: AssetImage(R.assetsImgIcBookNormal),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85)),
              title: new Text("体系",
                  style: new TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(26)))),
          new BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: index == 2
                  ? new Image(
                      image: AssetImage(R.assetsImgIcWechatSelected),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85))
                  : new Image(
                      image: AssetImage(R.assetsImgIcWechatNormal),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85)),
              title: new Text("公众号",
                  style: new TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(26)))),
          new BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: index == 3
                  ? new Image(
                      image: AssetImage(R.assetsImgIcProjectSelected),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85))
                  : new Image(
                      image: AssetImage(R.assetsImgIcProjectNormal),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85)),
              title: new Text("项目",
                  style: new TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(26)))),
          new BottomNavigationBarItem(
              icon: index == 4
                  ? new Image(
                      image: AssetImage(R.assetsImgIcMineSelected),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85))
                  : new Image(
                      image: AssetImage(R.assetsImgIcMineNormal),
                      width: ScreenUtil.getInstance().setWidth(85),
                      height: ScreenUtil.getInstance().setWidth(85)),
              title: new Text("我的",
                  style: new TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(26)))),
        ],
        currentIndex: index,
        onTap: onTap,
      ),
    ),
    );
  }

  // bottomnaviagtionbar 和 pageview 的联动
  void onTap(int index) {
    // 过pageview的pagecontroller的animateToPage方法可以跳转
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void _pageChange(int i) {
    setState(() {
      if (index != i) {
        index = i;
      }
    });
  }

  Future<bool> _doubleExit() {
    int nowTime = new DateTime.now().microsecondsSinceEpoch;
    if (_lastClickTime != 0 && nowTime - _lastClickTime > 1500) {
      return new Future.value(true);
    } else {
      T.showToast("双击退出应用");
      _lastClickTime = new DateTime.now().microsecondsSinceEpoch;
      new Future.delayed(const Duration(milliseconds: 1500), () {
        _lastClickTime = 0;
      });
      return new Future.value(false);
    }
  }
}
