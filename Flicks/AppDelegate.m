//
//  AppDelegate.m
//  Flicks
//
//  Created by Yash Kshirsagar on 9/12/16.
//  Copyright © 2016 Yash Kshirsagar. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vcNowPlaying = [storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    UIViewController *vcTopRated = [storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    tabBarController.viewControllers = @[vcNowPlaying, vcTopRated];
    
    // custom styles for tab bar
    [tabBarController.tabBar setTintColor:[UIColor colorWithRed:255/255.0f green:230/255.0f blue:66/255.0f alpha:1]];
    [tabBarController.tabBar setAlpha:0.92];
    [tabBarController.tabBar setBarTintColor:[UIColor colorWithWhite:0.0 alpha:0.9]];
    UITabBarItem *nowPlaying = [tabBarController.tabBar.items objectAtIndex:0];
    UITabBarItem *topRated = [tabBarController.tabBar.items objectAtIndex:1];
    
    // adjust title position
    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -2)];
    
    // customize tab items
    [nowPlaying setTitle:@"Now Playing"];
    [nowPlaying setImage:[UIImage imageNamed:@"playing"]];
    
    [topRated setTitle:@"Top Rated"];
    [topRated setImage:[UIImage imageNamed:@"star"]];

    
    self.window.rootViewController = tabBarController;
    
    return YES;
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
