import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:gap/gap.dart';
import 'package:watch_connection_test/main.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class AndroidHomePage extends StatefulWidget {
  const AndroidHomePage({super.key, required this.title});

  final String title;

  @override
  State<AndroidHomePage> createState() => _AndroidHomePageState();
}

class _AndroidHomePageState extends State<AndroidHomePage> {
  final FlutterWearOsConnectivity _flutterWearOsConnectivity =
  FlutterWearOsConnectivity();
  final WatchConnectivity watchConnectivity = WatchConnectivity();
  WearOsDevice? localDevice;
  bool? isPaired;
  bool? isReachable;
  String? packageARpcString;
  String? packageAContextString;
  String? packageBRpcString;
  String? packageBContextString;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _flutterWearOsConnectivity.configureWearableAPI();
      _clientStreamSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Gap(20),
            Text(
              "$packageA에서 받은 연결 상태: (paired: $isPaired)(reachable: $isReachable)",
            ),
            const Gap(10),
            Text(
              "$packageB에서 받은 연결 상태: ${localDevice ?? "none"}",
            ),
            OutlinedButton(
                onPressed: () {
                  _renewConnectivity.call();
                },
                child: const Text("연결상태 갱신")),
            const Gap(20),
            ElevatedButton(
                onPressed: () {
                  watchConnectivity.sendMessage({"data": "watch_connectivity"});
                },
                child: const Text("$packageA로 RPC 보내기(messageClient)")),
            Text(
                "$packageA에서 받은 RPC(messageClient): ${packageARpcString ?? "none"}"),
            const Gap(10),
            ElevatedButton(
                onPressed: () async {
                  Uint8List byteData =
                  utf8.encode('{"data":"flutter_wear_os_connectivity"}');
                  _flutterWearOsConnectivity.sendMessage(byteData,
                      deviceId: localDevice!.id, path: "/watch_connectivity");
                },
                child: const Text("$packageB로 RPC 보내기(messageClient)")),
            Text(
                "$packageB에서 받은 RPC(messageClient): ${packageBRpcString ?? "none"}"),
            const Gap(20),
            ElevatedButton(
                onPressed: () {
                  watchConnectivity
                      .updateApplicationContext({"data": "watch_connectivity"});
                },
                child: const Text("$packageA로 Context 보내기(DataClient)")),
            Text(
                "$packageA에서 받은 Context(DataClient): ${packageAContextString ?? "none"}"),
            const Gap(10),
            ElevatedButton(
                onPressed: () {
                  var data = {"data": "flutter_wear_os_connectivity"};
                  _flutterWearOsConnectivity.syncData(
                      path: "/watch_connectivity", data: data, isUrgent: true);
                },
                child: const Text("$packageB로 Context 보내기(DataClient)")),
            Text(
                "$packageB에서 받은 Context(DataClient): ${packageBContextString ?? "none"}"),
          ],
        ),
      ),
    );
  }

  void _clientStreamSet() {
    watchConnectivity.messageStream.listen((data) {
      print(data);
      setState(() {
        packageARpcString = data['key'];
      });
    });
    watchConnectivity.contextStream.listen((data) {
      setState(() {
        packageAContextString = data["key"];
      });
    });
    _flutterWearOsConnectivity.messageReceived().listen((WearOSMessage data) {
      print(data.data);
      setState(() {
        packageBRpcString = utf8.decode(data.data);
      });
    });
    _flutterWearOsConnectivity.dataChanged().listen((List<DataEvent> data) {
      print(data);
      Uint8List byteData = data.last.dataItem.data;
      setState(() {
        packageBContextString = utf8.decode(byteData);
      });
    });
  }

  void _renewConnectivity() async {
    var connectedDevices =
    await _flutterWearOsConnectivity.getConnectedDevices();
    var sampleDevice = connectedDevices.last;
    print(sampleDevice.id);
    print(sampleDevice.name);
    print(sampleDevice.isNearby);
    var pairStatus = await watchConnectivity.isPaired;
    var reachableStatus = await watchConnectivity.isReachable;
    setState(() {
      localDevice = connectedDevices.last;
      isPaired = pairStatus;
      isReachable = reachableStatus;
    });
  }
}