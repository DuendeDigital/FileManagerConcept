import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keepit/constants/global_variables.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:keepit/common/subscriptions.dart';
import 'package:keepit/constants/navigator_key.dart';
import 'package:keepit/models/ads_model.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:keepit/common/internet_check.dart';
import 'package:path/path.dart' as p;

class ads {
  Future check_internet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        getAdsData();
      }
    } on SocketException catch (_) {
      print("You are offline");
      navigatorKey.currentState!.pushNamed('/fallback');
    }
  }

  final navigatorKey = NavigatorKey.navKey;

  List<Ads> ads_video = [];
  var shuffle_video_ads;

  Future<List> getAdsData() async {
    var response =
        await http.get(Uri.parse('$uri/api/v1/fetch_ads.php'));
    var jsonData = jsonDecode(response.body);

    if (ads_video.length > 0) {
      ads_video.clear();
      shuffle_video_ads.clear();
    }

    for (var u in jsonData) {
      Ads ad =
          Ads(u["ad_type"], u["title"], u["path"], u["link"], u["createdat"]);

      if (ad.ad_type == 'video_ad') {
        ads_video.add(ad);
      }
    }

    if (shuffle_video_ads == null) {
      shuffle_video_ads = (ads_video.toList()..shuffle());
    }

    print('Ads function was triggered again');
    print("Shuffle list ${shuffle_video_ads}");

    _take_over_ad();

    return shuffle_video_ads;
  }

  Future _take_over_ad() async {
    print('Take over ad triggered again');

    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
    navigatorKey.currentState!.pushNamed('/videoad', arguments: {
      'online_takeover_path': shuffle_video_ads[0].path,
      'online_takeover_link': shuffle_video_ads[0].link
    });
  }
}
