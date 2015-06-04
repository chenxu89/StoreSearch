//
//  AppDelegate.m
//  StoreSearch
//
//  Created by 陈旭 on 5/27/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "DetailViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)customizeAppearance
{
    UIColor *barTintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
    //Note that this changes the appearance of all UISearchBars in the application.
    [[UISearchBar appearance] setBarTintColor:barTintColor];
    
    self.window.tintColor = [UIColor colorWithRed:10/255.0f green:80/255.0f blue:80/255.0f alpha:1.0f];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //This is boilerplate code that you’ll find in just about any app that uses nibs.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self customizeAppearance];
    
    self.searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    
    //figure out whether the app is running on the iPhone or on the iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.splitViewController = [[UISplitViewController alloc] init];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        
        self.splitViewController.delegate = detailViewController;
        
        self.splitViewController.viewControllers = @[self.searchViewController, detailNavigationController];
        
        self.window.rootViewController = self.splitViewController;
        
        //give searchViewController a point to detailViewController.
        self.searchViewController.detailViewController = detailViewController;
        
    }else{
        self.window.rootViewController = self.searchViewController;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
