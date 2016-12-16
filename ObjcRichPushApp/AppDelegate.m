//
//  AppDelegate.m
//  ObjcRichPushApp
//
//  Created by Nifty on 2016/12/16.
//  Copyright © 2016年 Nifty. All rights reserved.
//

#import "AppDelegate.h"
#import <NCMB/NCMB.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // SDKの初期化
    [NCMB setApplicationKey:@"YOUR_NCMB_APPLICATION_KEY"
                  clientKey:@"YOUR_NCMB_CLIENT_KEY"];
    
    // DeviceTokenの要求
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10, 0, 0}]){
        /** iOS10以上 **/
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                                 UNAuthorizationOptionBadge |
                                                 UNAuthorizationOptionSound)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (error) {
                                      // エラー時の処理
                                      return;
                                  }
                                  if (granted) {
                                      // 通知を許可にした場合DeviceTokenを要求する
                                      [[UIApplication sharedApplication] registerForRemoteNotifications];
                                  }
                              }];
    } else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){8, 0, 0}]){
        /** iOS8以上iOS10未満 **/
        //通知のタイプを設定したsettingを用意
        UIUserNotificationType type = UIUserNotificationTypeAlert |
        UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting;
        setting = [UIUserNotificationSettings settingsForTypes:type
                                                    categories:nil];
        //通知のタイプを設定
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        //DeviceTokenを要求
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    // MARK: アプリが起動されるときに実行される処理を追記する場所
    NSDictionary *userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (userInfo) {
        //リッチプッシュ通知を表示させる
        [NCMBPush handleRichPush:userInfo];
    }
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"Device Token = %@", deviceToken);
    
    // 端末情報を扱うNCMBInstallationのインスタンスを作成
    NCMBInstallation *installation = [NCMBInstallation currentInstallation];
    
    // Device Tokenを設定
    [installation setDeviceTokenFromData:deviceToken];
    
    // 端末情報をデータストアに登録
    [installation saveInBackgroundWithBlock:^(NSError *error) {
        // 登録後ViewControllerのtableViewを更新する
        if(!error){
            // 端末情報の登録が成功した場合の処理
        } else {
            // 端末情報の登録が失敗した場合の処理
        }
    }];
}

// MARK: アプリが起動しているときに実行される処理を追記する場所
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    if ([userInfo.allKeys containsObject:@"com.nifty.RichUrl"]){
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive){
            // リッチプッシュを表示させる処理
            [NCMBPush handleRichPush:userInfo];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
