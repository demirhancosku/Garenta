//
//  AppDelegate.m
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    self.globalMailComposer = [[MFMailComposeViewController alloc] init];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    timestamp = [[NSDate date] timeIntervalSince1970];
    NSLog(@"Uygulamanın aşağı atılması:%lu",(unsigned long)[ApplicationProperties getTimerObject]);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    int interval;
    interval = timestamp - [[NSDate date] timeIntervalSince1970];
    
    [ApplicationProperties setTimerObject:[ApplicationProperties getTimerObject] - interval];
    NSLog(@"Uygulamanın tekrar açılışı:%lu",(unsigned long)[ApplicationProperties getTimerObject]);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    application.applicationIconBadgeNumber = 0;
    
    NSString *reservationNumber = [userInfo valueForKey:@"ReservationId"];
    
    if (reservationNumber != nil && ![reservationNumber isEqualToString:@""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PayNowPushNotification" object:userInfo];
    }
}

- (void)updateTimerObject:(id)sender
{
    // önce 30 saniye eklenir
    [ApplicationProperties setTimerObject:[ApplicationProperties getTimerObject] + 1];
    
    //daha sonra timer objesini alıp 10 dakika geçmişmi kontrolü yaparız
    
    NSUInteger timerObj = [ApplicationProperties getTimerObject];
    
    if (timerObj >= 600) {
        NSLog(@"kapanış saati: %lu",(unsigned long)timerObj);
        [[ApplicationProperties getTimer] invalidate];
        [ApplicationProperties setTimerObject:0];
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryBoard" bundle:nil];
        UINavigationController * myStoryBoardInitialViewController = [storyboard instantiateInitialViewController];
        self.window.rootViewController = myStoryBoardInitialViewController;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"İşleminiz zaman aşımına uğramıştır, lütfen tekrar deneyin." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

@end
