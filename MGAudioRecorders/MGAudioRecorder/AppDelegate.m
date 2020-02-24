//
//  AppDelegate.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/6.
//  Copyright © 2019 maling. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)didEnterBackground:(UIApplication *)application
{
    NSLog(@"进入后台执行方法，");
    
}
/** 进程杀被死时会调用这个  */
- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"应用程序被杀死");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"内存警告⚠️");
}



#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
