import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_image/page/MainPage.dart';
import 'package:provider/provider.dart';
import './page/provider/Color.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

EventBus eventBus = EventBus();

void main() async {
  // flutter_download 插件初始化
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Color(),)
      ],
      child: Consumer<Color>(builder: (context,val,_){
        return MaterialApp(
          home: SplashView(),
          theme: ThemeData(
              primaryColor: val.colorMain,
              primarySwatch: val.colorMain
          ),
        );
      })
    );
  }
}

class SplashView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SplashViewState();
  }
}

class SplashViewState extends State<SplashView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 1080, height: 1920)..init(context);
    return new MainPage();
  }
}
