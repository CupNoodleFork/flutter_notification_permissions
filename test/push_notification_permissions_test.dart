import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_notification_permissions/push_notification_permissions.dart';

void main() {
  const MethodChannel channel = MethodChannel('push_notification_permissions');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return PermissionStatus.denied;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PushNotificationPermissions.getNotificationPermissionStatus(),
        PermissionStatus.denied);
  });
}
