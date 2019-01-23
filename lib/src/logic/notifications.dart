import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  Notifications._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<Notifications> _future;
  static Future<Notifications> get instance {
    if (_future != null)
      return _future;
    final Completer<Notifications> completer = Completer<Notifications>();
    _future = completer.future;
    final Notifications result = Notifications._(FlutterLocalNotificationsPlugin());
    result._plugin.initialize(
      const InitializationSettings(
        AndroidInitializationSettings('@mipmap/ic_launcher'),
        IOSInitializationSettings(),
      ),
      onSelectNotification: result._handleSelection,
    ).then((bool value) {
      if (value) {
        completer.complete(result);
      } else {
        completer.completeError(Exception('Flutter Local Notifications plugin failed to start up.'));
      }
    });
    return _future;
  }

  Future<void> _handleSelection(String payload) async {
    // TODO(ianh): Go to the thread.
    debugPrint('received notification: $payload');
  }

  void cancelAll() {
    _plugin.cancelAll();
  }

  int _notificationId(String threadId, String messageId) {
    return '$threadId:$messageId'.hashCode;
  }

  Future<void> messageUnread(String threadId, String messageId, String subject, String message) async {
    final AndroidNotificationDetails android = AndroidNotificationDetails(
      'cruisemonkey-seamail',
      'Seamail',
      'Seamail notifications',
      // icon
      importance: Importance.High,
      priority: Priority.High,
      // style
      // styleInformation
      playSound: true,
      // sound
      enableVibration: true,
      // vibrationPattern
      groupKey: threadId,
      // setAsGroupSummary
      // groupAlertBehavior
      autoCancel: true,
      // color
      // largeIcon
      // largeIconBitmapSource
      // onlyAlertOnce
      channelShowBadge: true,
    );
    final IOSNotificationDetails iOS = IOSNotificationDetails();
    await _plugin.show(
      _notificationId(threadId, messageId),
      subject,
      message,
      NotificationDetails(android, iOS),
      payload: threadId,
    );
  }

  Future<void> messageRead(String threadId, String messageId) async {
    await _plugin.cancel(_notificationId(threadId, messageId));
  }
}