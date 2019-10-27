import 'package:flutter/material.dart';
//import 'package:ge_eat/ui/colors.dart';
import 'package:dio/dio.dart';
import 'package:hm_spot_music_client/page/MapPage.dart';

import 'api/EventApi.dart';
import 'env.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  Dio _dio = Dio();

  void buildInterceptors(Dio dio) {
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      options.baseUrl = Env.API_URL;

/*      try {
        options.headers["jwt"] =
            (await SharedPreferences.getInstance()).getString("jwt");
      } catch (e) {}*/

      return options; //continue
    }, onResponse: (Response response) {
      return response; // continue
    }, onError: (DioError e) {
      return e; //continue
    }));
  }

  @override
  Widget build(BuildContext context) {
    buildInterceptors(_dio);
    EventApi eventApi = EventApi(_dio);

    var mapPage = MapPage(eventApi);
    //var loginPage = new LoginPage(AuthApi(_dio));
    return new MaterialApp(
        theme: new ThemeData(
            canvasColor: Colors.transparent
        ),
        initialRoute: '/map',
        routes: {
          //'/login': (context) => loginPage,
          '/map': (context) => mapPage
        },
        //color: GoEatColors.PRIMARY,
        title: 'Go.Eat',
        home: mapPage);
  }
}
