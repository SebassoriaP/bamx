import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum DeliveryStatus { delivered, queued }

class QueuedDocument {
  final String id;
  final String? docId;
  final DateTime createdAt;
  final String collection;
  final Map<String, dynamic> document;

  QueuedDocument({
    required this.id,
    required this.docId,
    required this.createdAt,
    required this.collection,
    required this.document,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'docId': docId,
    'createdAt': createdAt.toIso8601String(),
    'collection': collection,
    'document': document,
  };

  static QueuedDocument fromJson(Map<String, dynamic> json) => QueuedDocument(
    id: json['id'] as String,
    docId: json['docId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    collection: json['collection'] as String,
    document: (json['document'] as Map).cast<String, dynamic>(),
  );
}

class DocQueueService {
  DocQueueService();

  File? _queueFile;
  bool _flushing = false;
  Future<void> _serial = Future.value();

  /// Try to write immediately; if it fails, enqueue (preserving optional docId).
  /// - If [docId] is provided: writes to collection.doc(docId).set(..., merge:true)
  /// - If not provided: creates a new document with .add(...)
  Future<DeliveryStatus> submit(
    Map<String, dynamic> document,
    String collection, {
    String? docId,
  }) async {
    final db = FirebaseFirestore.instance;
    try {
      if (docId != null && docId.isNotEmpty) {
        await db.collection(collection).doc(docId).set({
          ...document,
          'queuedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await db.collection(collection).add({
          ...document,
          'queuedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      return DeliveryStatus.delivered;
    } catch (_) {
      await enqueue(document, collection, docId: docId);
      return DeliveryStatus.queued;
    }
  }

  /// Enqueue without attempting delivery.
  /// You may pass an optional [docId] to target a specific Firestore doc.
  Future<void> enqueue(
    Map<String, dynamic> document,
    String collection, {
    String? docId,
  }) async {
    final item = QueuedDocument(
      id: const Uuid().v4(),
      docId: (docId != null && docId.isNotEmpty) ? docId : null,
      createdAt: DateTime.now().toUtc(),
      collection: collection,
      document: document,
    );

    await _runSerial(() async {
      final items = await _readAll();
      items.add(item);
      await _writeAll(items);
    });
  }

  /// Attempts to deliver all queued items. Returns a status summary.
  Future<void> flush() async {
    if (_flushing) return;

    _flushing = true;
    final deliveredIds = <String>[];
    String? firstError;

    try {
      final firestore = FirebaseFirestore.instance;

      while (true) {
        QueuedDocument? head;

        // Snapshot the head without holding the lock during network.
        await _runSerial(() async {
          final items = await _readAll();
          head = items.isNotEmpty ? items.first : null;
        });

        if (head == null) break;

        final ok = await _uploadOne(firestore, head!);
        if (ok) {
          deliveredIds.add(head!.id);
          await _runSerial(() async {
            final items = await _readAll();
            if (items.isNotEmpty && items.first.id == head!.id) {
              items.removeAt(0);
              await _writeAll(items);
            }
          });
        } else {
          firstError ??= 'Failed to upload queued document ${head!.id}';
          break; // stop on first failure to avoid hammering
        }
      }
    } finally {
      _flushing = false;
    }
  }

  // ---------- internals ----------

  Future<bool> _uploadOne(FirebaseFirestore db, QueuedDocument q) async {
    try {
      if (q.docId != null && q.docId!.isNotEmpty) {
        await db.collection(q.collection).doc(q.docId).set({
          ...q.document,
          'queuedLocallyAt': q.createdAt,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await db.collection(q.collection).add({
          ...q.document,
          'queuedLocallyAt': q.createdAt,
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<File> _getQueueFile() async {
    if (_queueFile != null) return _queueFile!;
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/queue_documents.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(
        jsonEncode(<Map<String, dynamic>>[]),
        flush: true,
      );
    }
    _queueFile = file;
    return file;
  }

  Future<List<QueuedDocument>> _readAll() async {
    final file = await _getQueueFile();
    final txt = await file.readAsString();
    if (txt.trim().isEmpty) return <QueuedDocument>[];
    final raw = (jsonDecode(txt) as List).cast<Map<String, dynamic>>();
    return raw.map(QueuedDocument.fromJson).toList();
  }

  /// Atomic write: write to a temp file, then replace original.
  Future<void> _writeAll(List<QueuedDocument> items) async {
    final file = await _getQueueFile();
    final tmp = File('${file.path}.tmp');
    final bytes = utf8.encode(
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
    await tmp.writeAsBytes(bytes, flush: true);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
    await tmp.rename(file.path);
  }

  Future<T> _runSerial<T>(Future<T> Function() op) {
    final next = _serial.then((_) => op());
    _serial = next.then((_) {}, onError: (_) {});
    return next;
  }
}
