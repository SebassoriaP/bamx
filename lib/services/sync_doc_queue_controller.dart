import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'doc_queue_service.dart';

class SyncDocQueueController {
  final DocQueueService queue;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  SyncDocQueueController(this.queue);

  Future<void> start() async {
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        unawaited(queue.flush());
      }
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
