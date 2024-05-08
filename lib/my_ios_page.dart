import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_watch_os_connectivity/flutter_watch_os_connectivity.dart';
import 'package:gap/gap.dart';
import 'package:watch_connection_test/main.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class IosHomePage extends StatefulWidget {
  const IosHomePage({super.key, required this.title});

  final String title;

  @override
  State<IosHomePage> createState() => _IosHomePageState();
}

class _IosHomePageState extends State<IosHomePage> {
  final FlutterWatchOsConnectivity _flutterWatchosConnectivity = FlutterWatchOsConnectivity();
  final WatchConnectivity watchConnectivity = WatchConnectivity();
  WatchOsPairedDeviceInfo? localDevice;
  bool? isPaired;
  bool? isReachable;
  String? packageARpcString;
  String? packageAContextString;
  String? packageBRpcString;
  String? packageBContextString;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _flutterWatchosConnectivity.configureAndActivateSession();
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
                child: const Text("$packageA로 RPC 보내기")),
            Text(
                "$packageA에서 받은 RPC: ${packageARpcString ?? "none"}"),
            const Gap(10),
            ElevatedButton(
                onPressed: () async {
                  var mapData = {"data":"flutter_watch_os_connectivity"};
                  _flutterWatchosConnectivity.sendMessage(mapData);
                },
                child: const Text("$packageB로 RPC 보내기")),
            Text(
                "$packageB에서 받은 RPC: ${packageBRpcString ?? "none"}"),
            const Gap(20),
            ElevatedButton(
                onPressed: () {
                  watchConnectivity
                      .updateApplicationContext({"data": "watch_connectivity"});
                },
                child: const Text("$packageA로 Context 보내기")),
            Text(
                "$packageA에서 받은 Context: ${packageAContextString ?? "none"}"),
            const Gap(10),
            ElevatedButton(
                onPressed: () {
                  var data = {"data": "flutter_watch_os_connectivity"};
                  _flutterWatchosConnectivity.updateApplicationContext(data);
                },
                child: const Text("$packageB로 Context 보내기")),
            Text(
                "$packageB에서 받은 Context: ${packageBContextString ?? "none"}"),
          ],
        ),
      ),
    );
  }

  void _clientStreamSet() {
    watchConnectivity.messageStream.listen((data) {
        print("packageARpc"+data["data"]);
      setState(() {
        packageARpcString = data['data'];
      });
    });
    watchConnectivity.contextStream.listen((data) {
        print("packageAContext:" + data["data"]);
      setState(() {
        packageAContextString = data["data"];
      });
    });
    _flutterWatchosConnectivity.messageReceived.listen((WatchOSMessage data) {
        print("packageBRpc"+data.data["data"]);
      setState(() {
        packageBRpcString = data.data["data"];
      });
    });
    _flutterWatchosConnectivity.applicationContextUpdated.listen((ApplicationContext data){
      String currentData = data.receivedData["data"] as String;
      print("PackageBContext: $currentData");
      setState(() {
        packageBContextString = currentData;
      });
    });
  }

  void _renewConnectivity() async {
    var connectedDevices = await _flutterWatchosConnectivity.getPairedDeviceInfo();
    var pairStatus = await watchConnectivity.isPaired;
    var reachableStatus = await watchConnectivity.isReachable;
    // print(connectedDevices.isWatchAppInstalled);
    // print(connectedDevices.isPaired);
    // print(connectedDevices.isComplicationEnabled);
    setState(() {
      localDevice = connectedDevices;
      isPaired = pairStatus;
      isReachable = reachableStatus;
    });
  }
}