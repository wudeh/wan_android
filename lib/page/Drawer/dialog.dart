import 'package:flutter/material.dart';
import './ExpandText.dart';

class DialogShow extends StatefulWidget {
  final Widget child;

  String title; // 一级对话框标题
  String subTitle;  // 二级标题
  String smallSubTitle; // 三级标题
  String description; // 对话框说明
  Function yes; // 确定执行方法

  DialogShow({Key key, this.child,this.title,this.subTitle,this.smallSubTitle, this.description,this.yes}) : super(key: key);

  _DialogShowState createState() => _DialogShowState();
}

class _DialogShowState extends State<DialogShow> {

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)
          ),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,   // 对话框高度自适应
            children: <Widget>[
              Container(
                height: 10,
              ),
              Center(
                child: Text(widget.title,style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 27),),
              ),
              widget.subTitle != null 
                ? 
                ExpansionTile(
                title: Text(widget.subTitle),
                subtitle: Text(widget.smallSubTitle != null ? widget.smallSubTitle : ''),
                children: <Widget>[
                  Text(widget.description)
                ],
              ) : 
                ExpandableText(text: widget.description,style: TextStyle()),
              Container(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    child: Text('取消',style: TextStyle(color: Theme.of(context).primaryColor)),
                    color: Colors.white,
                    colorBrightness: Brightness.light,
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  RaisedButton(
                    child: Text('确定',style: TextStyle(color: Theme.of(context).primaryColor)),
                    color: Colors.white,
                    colorBrightness: Brightness.light,
                    onPressed: (){
                      Navigator.pop(context);
                      widget.yes();
                    },
                  ),
                  SizedBox(
                    width: 30,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}