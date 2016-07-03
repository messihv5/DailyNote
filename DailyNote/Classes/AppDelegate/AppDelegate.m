//
//  AppDelegate.m
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "AppDelegate.h"

#import "WLLDailyNoteViewController.h"
#import "WLLShareViewController.h"
#import "WLLUserViewController.h"
#import "WLLLogInViewController.h"
#import "WLLLockViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

@interface AppDelegate ()<UINavigationControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //shareSDK注册
    [ShareSDK  registerApp:@"13e3f417e934c"
           activePlatforms:@[@(SSDKPlatformTypeWechat),
                             @(SSDKPlatformTypeQQ)]
                  onImport:^(SSDKPlatformType platformType) {
                      switch (platformType)
                      {
                          case SSDKPlatformTypeWechat:
                              [ShareSDKConnector connectWeChat:[WXApi class]];
                              break;
                          case SSDKPlatformTypeQQ:
                              [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                              break;
                            default:
                              break;
                      }
                  }
           onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
               switch (platformType)
               {
                    case SSDKPlatformTypeWechat:
                       [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                             appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
                       break;
                   case SSDKPlatformTypeQQ:
                       [appInfo SSDKSetupQQByAppId:@"1105401337"
                                            appKey:@"LsqWb7ULTObHWWjf"
                                          authType:SSDKAuthTypeBoth];
                       break;
                   default:
                       break;
               }
           }];
    
    //注册Leancloud
    [AVOSCloud setApplicationId:@"gQw0p6Gi1ncURhwJozkPTA7d-gzGzoHsz"
                      clientKey:@"nKPTchiJiuqVHuHVnH4DnEtJ"];
    [AVOSCloud setAllLogsEnabled:NO];

    //设置3个根视图的控制器
    WLLDailyNoteViewController *dailyController;
    dailyController = [[WLLDailyNoteViewController alloc] initWithNibName:@"WLLDailyNoteViewController"
                                                                   bundle:[NSBundle mainBundle]];
    dailyController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"日记"
                                                               image:[[UIImage imageNamed:@"dailyNote"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                       selectedImage:[[UIImage imageNamed:@"selectedDailyNote"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    WLLShareViewController *shareController;
    shareController = [[WLLShareViewController alloc] initWithNibName:@"WLLShareViewController"
                                                               bundle:[NSBundle mainBundle]];
    shareController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"分享"
                                                               image:[[UIImage imageNamed:@"share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                       selectedImage:[[UIImage imageNamed:@"selectedShare"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    WLLUserViewController *userController;
    userController = [[WLLUserViewController alloc] initWithNibName:@"WLLUserViewController"
                                                             bundle:[NSBundle mainBundle]];
    userController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                              image:[[UIImage imageNamed:@"user"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                      selectedImage:[[UIImage imageNamed:@"selectedUser"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.viewControllers = @[dailyController, shareController, userController];
    tabController.tabBar.tintColor = [UIColor orangeColor];
    
    UINavigationController *nvController = [[UINavigationController alloc] initWithRootViewController:tabController];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = nvController;
    nvController .delegate = self;
    
    //leancloud消息推送
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        UIRemoteNotificationType remoteTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:remoteTypes];
    } else {
        UIUserNotificationType userTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    return YES;
}


//用户已注册远程推送消息，得到deviceToken,可以从控制台推送消息
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
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
    //判断用户是否设置手势锁，设置了就弹出解锁界面
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *switchString = [user objectForKey:@"privateCode"];
    if ([switchString isEqualToString:@"YES"]) {
        WLLLockViewController *lockController = [[WLLLockViewController alloc] init];
        [self.window.rootViewController presentViewController:lockController animated:YES completion:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.JustThree.DailyNote" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DailyNote" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DailyNote.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
