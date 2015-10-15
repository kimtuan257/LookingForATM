//
//  AppDelegate.m
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/22/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    HomeVC *home = [HomeVC new];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:home];
    _window.rootViewController = navi;
    [_window makeKeyAndVisible];
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    //get current location
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self openSetting];
    }
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.distanceFilter = 10;//10 met
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;//do chinh xac gan 10 met
    [_locationManager startUpdatingLocation];
    
    return YES;
}

- (void)openSetting {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"This app does not have access to Location service"
                                                        message:@"You can enable access in Settings"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert1 show];
    } else {
        UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"This app does not have access to Location service"
                                                        message:@"You can enable access in Settings"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Settings", nil];
        alert2.tag = 121;
        [alert2 show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 121 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    _currentLocation = newLocation;
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
