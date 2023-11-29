import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var firestore = FirebaseFirestore.instance;
var orderCollectionName = 'cafe-order';

class CafeIncomplete extends StatefulWidget {
  const CafeIncomplete({super.key});

  @override
  State<CafeIncomplete> createState() => _CafeIncompleteState();
}

class _CafeIncompleteState extends State<CafeIncomplete> {
  bool init = true;
  List<dynamic> orderDataList = [];
  dynamic body = const Text('비어있음');
  Future<void> getOrders() async {
    firestore.collection(orderCollectionName).snapshots().listen((event) {
      if (init) {
        var orders = event.docs;
        orderDataList.insertAll(0, orders);
      } else {
        var orders = event.docChanges;
        orderDataList.insertAll(0, orders);
      }
      showOrderList();
    });
  }

  void showOrderList() {
    setState(() {
      body = ListView.separated(
        itemBuilder: (context, index) {
          var order = orderDataList[index];
          return ListTile(
            leading: Text('${order['orderNumber']}'),
            title: Text('${order['orderName']}'),
          );
        },
        separatorBuilder: (c, i) => const Divider(),
        itemCount: orderDataList.length,
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp();
  }
}
