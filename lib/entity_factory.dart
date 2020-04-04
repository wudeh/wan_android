import 'package:multi_image/entity/banner_entity.dart';
import 'package:multi_image/entity/coin_info_entity.dart';
import 'package:multi_image/entity/collect_entity.dart';
import 'package:multi_image/entity/gongzh_entity.dart';
import 'package:multi_image/entity/home_article_entity.dart';
import 'package:multi_image/entity/hot_key_entity.dart';
import 'package:multi_image/entity/login_entity.dart';
import 'package:multi_image/entity/project_entity.dart';
import 'package:multi_image/entity/rank_entity.dart';
import 'package:multi_image/entity/system_entity.dart';
import 'package:multi_image/entity/system_navi_entity.dart';
import 'package:multi_image/http/return_body_entity.dart';

class EntityFactory {
  static T generateOBJ<T>(json) {
    if (1 == 0) {
      return null;
    } else if (T.toString() == "BannerEntity") {
      return BannerEntity.fromJson(json) as T;
    } else if (T.toString() == "CoinInfoEntity") {
      return CoinInfoEntity.fromJson(json) as T;
    } else if (T.toString() == "CollectEntity") {
      return CollectEntity.fromJson(json) as T;
    } else if (T.toString() == "GongzhEntity") {
      return GongzhEntity.fromJson(json) as T;
    } else if (T.toString() == "HomeArticleEntity") {
      return HomeArticleEntity.fromJson(json) as T;
    } else if (T.toString() == "HotKeyEntity") {
      return HotKeyEntity.fromJson(json) as T;
    } else if (T.toString() == "LoginEntity") {
      return LoginEntity.fromJson(json) as T;
    } else if (T.toString() == "ProjectEntity") {
      return ProjectEntity.fromJson(json) as T;
    } else if (T.toString() == "RankEntity") {
      return RankEntity.fromJson(json) as T;
    } else if (T.toString() == "SystemEntity") {
      return SystemEntity.fromJson(json) as T;
    } else if (T.toString() == "SystemNaviEntity") {
      return SystemNaviEntity.fromJson(json) as T;
    } else if (T.toString() == "ReturnBodyEntity") {
      return ReturnBodyEntity.fromJson(json) as T;
    } else {
      return null;
    }
  }
}