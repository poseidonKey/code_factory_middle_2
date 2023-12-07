import 'package:code_factory_middle/common/const/data.dart';
import 'package:code_factory_middle/restaurant/component/restaurant_card.dart';
import 'package:code_factory_middle/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});
  Future<List> paginateRestaurant() async {
    final dio = Dio();
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final resp = await dio.get(
      'http://$ip/restaurant',
      options: Options(
        headers: {'authorization': 'Bearer $accessToken'},
      ),
    );
    return resp.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List>(
            future: paginateRestaurant(),
            builder: (context, AsyncSnapshot<List> snapshot) {
              print(snapshot.data);
              print(snapshot.error); // error 원인 파악 401 에러.
              // accessToken 유효시간 5분이기 때문.
              if (!snapshot.hasData) {
                return Container();
              }
              return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final item = snapshot.data![index];
                  final pItem = RestaurantModel.fromJson(
                      json: item); //factory constructor 이용
                  // parsed item 이라는 의미로 pItem이름을 사용
                  // final pItem = RestaurantModel(
                  //   id: item['id'],
                  //   name: item['name'],
                  //   thumbUrl: item['thumbUrl'],
                  //   tags: List<String>.from(item['tags']),
                  //   priceRange: RestaurantPriceRange.values.firstWhere(
                  //     (element) => element.name == item['priceRange'],
                  //   ),
                  //   ratings: item['ratings'],
                  //   ratingsCount: item['ratingsCount'],
                  //   deliveryTime: item['deliveryTime'],
                  //   deliveryFee: item['deliveryFee'],
                  // );
                  return RestaurantCard.fromModel(model: pItem);
                  // return RestaurantCard(
                  //   image: Image.network(
                  //     'http://$ip${pItem.thumbUrl}',
                  //     fit: BoxFit.cover,
                  //   ),
                  //   // image: Image.asset('asset/img/food/ddeok_bok_gi.jpg'),
                  //   name: pItem.name, //'불타는 떡볶이',
                  //   tags: pItem.tags, // const ['떡볶이', '치즈', '매운맛'],
                  //   ratingsCount: pItem.ratingsCount, // 100,
                  //   deliveryTime: pItem.deliveryTime, // 15,
                  //   deliveryFee: pItem.deliveryFee, // 2000,
                  //   ratings: pItem.ratings, // 4.52,
                  // );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                  height: 10,
                ),
                itemCount: snapshot.data!.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
