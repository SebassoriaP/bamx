import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'doc_queue_service.dart';
import 'package:flutter/material.dart';

class SyncDocQueueController {
  final DocQueueService queue;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isSyncing = false;

  SyncDocQueueController(this.queue);

  Future<void> start() async {
    // Verifica conectividad inicial
    final current = await Connectivity().checkConnectivity();
    if (current.isNotEmpty && current.any((r) => r != ConnectivityResult.none)) {
      await _flushQueue();
    }

    _sub = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        _flushQueue(); 
      }
    });
  }

  Future<void> _flushQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await queue.flush();
    } catch (e) {
      debugPrint('Error parsing metadata JSON:');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
