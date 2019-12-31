package com.cnfk.push_notification_permissions;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;

import androidx.core.app.NotificationManagerCompat;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * PushNotificationPermissionsPlugin
 */
public class PushNotificationPermissionsPlugin implements MethodCallHandler {
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel =
                new MethodChannel(registrar.messenger(), "push_notification_permissions");
        channel.setMethodCallHandler(new PushNotificationPermissionsPlugin(registrar));
    }

    private static final String PERMISSION_GRANTED = "granted";
    private static final String PERMISSION_DENIED = "denied";

    private final Context context;

    private PushNotificationPermissionsPlugin(Registrar registrar) {
        this.context = registrar.activity();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if ("getNotificationPermissionStatus".equalsIgnoreCase(call.method)) {
            result.success(getNotificationPermissionStatus());
        } else if ("requestNotificationPermissions".equalsIgnoreCase(call.method)) {
            if (PERMISSION_DENIED.equalsIgnoreCase(getNotificationPermissionStatus())) {
                if (context instanceof Activity) {
                    final Uri uri = Uri.fromParts("package", context.getPackageName(), null);

                    final Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                    intent.setData(uri);

                    context.startActivity(intent);

                    result.success(null);
                } else {
                    result.error(call.method, "context is not instance of Activity", null);
                }
            } else {
                result.success(null);
            }
        } else {
            result.notImplemented();
        }
    }

    private String getNotificationPermissionStatus() {
        return (NotificationManagerCompat.from(context).areNotificationsEnabled())
                ? PERMISSION_GRANTED
                : PERMISSION_DENIED;
    }
}
