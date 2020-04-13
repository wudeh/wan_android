import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Config.dart';
import '../../r.dart';
import 'dart:io';
import '../home/SquarePage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../provider/Color.dart';
import '../BrowserPage.dart';
import 'package:multi_image/event/LoginEvent.dart';
import '../../main.dart';
import './MieBa.dart';
import './Download.dart';
import 'package:mobsms/mobsms.dart';

class DrawerPage extends StatefulWidget {
  final Widget child;

  DrawerPage({Key key, this.child}) : super(key: key);

  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  String headPath = '';
  //获取本地用户信息
  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String info = prefs.getString(Config.SP_USER_INFO);
    
    if (prefs.containsKey(Config.SP_HEAD_PATH)) {
      String temp = prefs.getString(Config.SP_HEAD_PATH);
      setState(() {
        headPath = temp;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    eventBus.on<LoginOutEvent>().listen((event) async { // 监听退出登录事件 退出登录就重新刷新数据
        await getUserInfo();
        setState(() {
        });
    });
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: ClipOval(
              child: Image(
                image: headPath == '' ? AssetImage(R.assetsImgImgUserHead)
                            : FileImage(File(headPath)),
              )
            ),
            accountName: Text(
              '这是个没有什么用的抽屉页'
            ),
          ),
          ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context){
                  return SquarePage();
                }
              ));
            },
            leading: Icon(Icons.account_balance,color: Theme.of(context).primaryColor),
            title: Text('广场',style: TextStyle(color: Theme.of(context).primaryColor),),
            trailing: Icon(Icons.chevron_right,color: Theme.of(context).primaryColor),
          ),
          ListTile(
            onTap: (){
              Navigator.of(context)
                .push(new MaterialPageRoute(builder: (_) {
                  return new Browser(
                    url: "https://www.wanandroid.com/blog/show/2",
                    title: "感谢鸿洋大神的开放api",
                    id: 9705,
                  );
              }));
            },
            leading: Icon(Icons.airline_seat_flat_angled,color: Theme.of(context).primaryColor),
            title: Text('本应用数据来源',style: TextStyle(color: Theme.of(context).primaryColor),),
            trailing: Icon(Icons.chevron_right,color: Theme.of(context).primaryColor),
          ),
          DownloadPage(),
          ExpansionTile(
            leading: Icon(Icons.accessibility),
            title: Text('主题颜色'),
            children: <Widget>[
              Consumer<Color>(builder: (context,val,_){
                return Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: val.colorList.map((color){
                    return InkWell(
                      onTap: (){
                        val.changeColor(color);
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        width: ScreenUtil().setWidth(60),
                        height: ScreenUtil().setWidth(60),
                        color: color,
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
          // 灭霸动画效果 只需要传进去一个你想要做出灭霸效果的 widget 即可
          Sandable(
            child: ListTile(
              leading: ClipOval(child: Image(image: AssetImage('assets/img/mieba.png'),),),
              title: Text('点一下 你就是灭霸',style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
          )
        ],
      ),
    );
  }
}