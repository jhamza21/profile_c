import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> setup() async {
  await _initializeFirebase();
  await _initializeStripe();
  await _initializeDownloader();
}

_initializeFirebase() async {
  await Firebase.initializeApp();
}

_initializeStripe() async {
  Stripe.publishableKey =
      'pk_test_51Jjrx9IALR9H9z91H1XCfq8IiNe5vijj9okIr7VgVt5YDz1JZs7NIccdnJ2YSLoDvGLhTD3jR8oDAsgpDj7FLJmf00QyWKjSRP';
  await Stripe.instance.applySettings();
}

_initializeDownloader() async {
  await FlutterDownloader.initialize();
  FlutterDownloader.registerCallback(downloadCallback);
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send.send([id, status, progress]);
}
