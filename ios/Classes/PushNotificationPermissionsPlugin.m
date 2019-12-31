//
//  PushNotificationPermissionPlugin.m
//  Runner
//
//  Created by Spiker on 2019/12/30.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
#import "PushNotificationPermissionsPlugin.h"

#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
static NSString  * const permissionGranted = @"granted";
static NSString  * const permissionUnknown = @"unknown";
static NSString  * const permissionDenied = @"denied";


@implementation PushNotificationPermissionsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"push_notification_permissions"
            binaryMessenger:[registrar messenger]];

  PushNotificationPermissionsPlugin* instance = [[PushNotificationPermissionsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  if ([@"requestNotificationPermissions" isEqualToString:call.method]) {
      [self p_getCurrentNotificationStatus:^(NSString *status) {
          if ([status isEqualToString:permissionUnknown]) {
              if (@available(iOS 10.0, *)) {
                  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                  UNAuthorizationOptions options = 0;
                  if ([call.arguments isKindOfClass:[NSDictionary class]]){
                      NSDictionary *arg = (NSDictionary *)call.arguments;
                      if (arg[@"sound"]){
                          options |= UNAuthorizationOptionSound;
                      }
                      if (arg[@"alert"]){
                          options |= UNAuthorizationOptionAlert;
                      }
                      if (arg[@"badge"]){
                          options |= UNAuthorizationOptionBadge;
                      }
                  }
                  [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
                      if (error == nil) {
                          result(granted ? permissionGranted : permissionDenied);
                      } else {
                          result(error.localizedDescription);
                      }
                  }];
              } else {
                  UIUserNotificationType type = UIUserNotificationTypeNone;
                  if ([call.arguments isKindOfClass:[NSDictionary class]]){
                       NSDictionary *arg = (NSDictionary *)call.arguments;
                       if (arg[@"sound"]){
                           type |= UIUserNotificationTypeSound;
                       }
                       if (arg[@"alert"]){
                           type |= UIUserNotificationTypeAlert;
                       }
                       if (arg[@"badge"]){
                           type |= UIUserNotificationTypeBadge;
                       }
                  }
                  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
                  [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                  [self p_getCurrentNotificationStatus:^(NSString *status) {
                      result(status);
                  }];
              }
          } else if ([status isEqualToString:permissionDenied]) {
              if ([call.arguments isKindOfClass:[NSDictionary class]]){
                  NSDictionary *arg = (NSDictionary *)call.arguments;
                  if (arg[@"openSettings"] != nil && arg[@"openSettings"] == NO) {
                      result(permissionDenied);
                      return;
                  }

                  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                  if (url && [[UIApplication sharedApplication] canOpenURL:url]){
                      [[UIApplication sharedApplication] openURL:url];
                  }
                  result(nil);
              }
          } else {
              result(nil);
          }
      }];
  } else if ([call.method isEqualToString:@"getNotificationPermissionStatus"]){
      [self p_getCurrentNotificationStatus:^(NSString *status) {
          result(status);
      }];
  } else {
      result(FlutterMethodNotImplemented);
  }

}

- (void)p_getCurrentNotificationStatus:(void(^)(NSString* status))callback
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                    callback(permissionUnknown);
                    break;
                case UNAuthorizationStatusDenied:
                    callback(permissionDenied);
                    break;
                case UNAuthorizationStatusAuthorized:
                    callback(permissionGranted);
                    break;
                default:
                    break;
            }
        }];
    } else {
        if ([UIApplication sharedApplication].isRegisteredForRemoteNotifications) {
            callback(permissionGranted);
        } else {
            callback(permissionDenied);
        }
    }
}


@end


