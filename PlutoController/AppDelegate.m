//
//  AppDelegate.m
//  HelloDrona
//
//  Created by Drona Aviation on 31/08/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
@import Firebase;
//#import <Fabric/Fabric.h>
#import "Realm/Realm.h"
#import "User.h"
#import "UserSettings.h"
#import "Gaming.h"
#import "AppDelegate.h"
#import "ViewController.h"
//#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";
NSUserDefaults *preferencesDefault;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[Fabric with:@[[Crashlytics class]]];
    [FIRApp configure];
    
    if ([UNUserNotificationCenter class] != nil) {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
             // ...
         }];
    } else {
        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    [application registerForRemoteNotifications];
    
    [FIRMessaging messaging].delegate = self;
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 2;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion <= 1) {
           //update logic if any!
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    RLMResults<User *> *users = [User allObjects];
    if(users.count == 0){
        User *guestUser = [[User alloc] init];
        guestUser.userId = @"PLUTO_DEFAULT_USER";
        guestUser.userName = @"Guest User";
        guestUser.userProfilePath = nil;
        guestUser.isDeveloper = false;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:guestUser];
        [realm commitWriteTransaction];
        
        UserSettings *userSettings = [[UserSettings alloc] init];
        userSettings.themeId = @"theme_001";
        userSettings.flightSensitivity = 300;
        userSettings.flightMode = 0;
        userSettings.flightControl = 0;
        userSettings.isHeadFreeMode = NO;
        userSettings.isSwipeControl = NO;
        userSettings.isVibrate = YES;
        userSettings.isSounds = YES;
        [userSettings.user addObject:guestUser];
        
        [realm beginWriteTransaction];
        [realm addObject:userSettings];
        [realm commitWriteTransaction];
        
        Gaming *defaultGaming = [[Gaming alloc] init];
        defaultGaming.levelNo = 0;
        defaultGaming.totalFlightTime = 0;
        defaultGaming.bestTime = 0;
        defaultGaming.points = 0;
        [defaultGaming.user addObject:guestUser];
        
        [realm beginWriteTransaction];
        [realm addObject:defaultGaming];
        [realm commitWriteTransaction];
    }
    
    preferencesDefault = [NSUserDefaults standardUserDefaults];
    if([preferencesDefault boolForKey:@"isUserLoggedIn"]){
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"Main"];
        [self.window makeKeyAndVisible];

    } else{
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"LogInController"];
        [self.window makeKeyAndVisible];
    }
    //-----------------------

    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    completionHandler(UNNotificationPresentationOptionNone);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    completionHandler();
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
}

//- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage{
//    NSLog(@"Received data message: %@", remoteMessage.appData);
//}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground: Saves changes in the application's managed object context before the application terminates.
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
}

@end
