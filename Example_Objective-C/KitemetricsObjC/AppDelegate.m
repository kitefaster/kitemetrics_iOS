//
//  AppDelegate.m
//  KitemetricsObjC
//
//  Created by mcl on 3/20/17.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

#import "AppDelegate.h"
@import Kitemetrics;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[Kitemetrics shared] initSessionWithApiKey:@"API_KEY"];
    //If userIdentifier is known on startup, you can set it here
//    [[Kitemetrics shared] initSessionWithApiKey:@"API_KEY" userIdentifier:@"012345abc"];
    
//    [[Kitemetrics shared] logAddToCart:skProduct quantity:1];
//    [[Kitemetrics shared] logInAppPurchase:skProduct quantity:1];
    //If the IAP type is know you can set it with KFPurchaseTypeAppleInAppNonConsumable or KFPurchaseTypeAppleInAppConsumable, etc.
//    [[Kitemetrics shared] logInAppPurchase:skProduct quantity:1 purchaseType:KFPurchaseTypeAppleInAppNonConsumable];
    
    [[Kitemetrics shared] logError:@"Test Error"];
    [[Kitemetrics shared] logEvent:@"Test Event"];
    [[Kitemetrics shared] logInviteWithMethod:@"Test Invite" code: @"Test Code 001"];
    [[Kitemetrics shared] logRedeemInviteWithCode:@"Test Code 001"];
    [[Kitemetrics shared] logSignUpWithMethod:@"email" userIdentifier:@"012345abc"];
    return YES;
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
