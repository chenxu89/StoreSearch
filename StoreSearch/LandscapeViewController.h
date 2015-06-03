//
//  LandscapeViewController.h
//  StoreSearch
//
//  Created by 陈旭 on 6/2/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Search;

@interface LandscapeViewController : UIViewController

@property (nonatomic, strong) Search *search;

- (void)searchResultsReceived;

@end
