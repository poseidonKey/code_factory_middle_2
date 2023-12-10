import 'package:code_factory_middle/common/const/data.dart';
import 'package:code_factory_middle/common/layout/default_layout.dart';
import 'package:code_factory_middle/product/component/product_card.dart';
import 'package:code_factory_middle/restaurant/component/restaurant_card.dart';
import 'package:code_factory_middle/restaurant/model/restaurant_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String id;
  const RestaurantDetailScreen({super.key, required this.id});

  Future<Map<String, dynamic>> getRestaurantDetail() async {
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final dio = Dio();
    final resp = await dio.get(
      'http://$ip/restaurant/$id',
      options: Options(
        headers: {'authorization': 'Bearer $accessToken'},
      ),
    );

    return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '불타는 떡볶이',
      child: FutureBuilder<Map<String, dynamic>>(
          future: getRestaurantDetail(),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            // print(snapshot.data);
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final item = RestaurantDetailModel.fromJson(snapshot.data!);
            // print(item.thumbUrl);
            return CustomScrollView(
              slivers: [
                renderTop(model: item),
                // renderTop(),
                renderLabel(),
                renderProducts(products: item.products),
              ],
            );
          }),
    );
  }

  SliverPadding renderLabel() {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          "메뉴",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  SliverPadding renderProducts(
      {required List<RestaurantProductModel> products}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index];
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProductCard.fromModel(
                model: model,
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  // SliverToBoxAdapter renderTop() {
  SliverToBoxAdapter renderTop({
    required RestaurantDetailModel model,
  }) {
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
      // child: RestaurantCard(
      //   image: Image.asset('asset/img/food/ddeok_bok_gi.jpg'),
      //   name: '불타는 떡볶이',
      //   tags: const ['떡볶이', '치즈', '매운맛'],
      //   ratingsCount: 100,
      //   deliveryTime: 15,
      //   deliveryFee: 2000,
      //   ratings: 4.52,
      //   isDetail: true,
      //   detail: '맛 있는 떡볶이',
      // ),
    );
  }
}
