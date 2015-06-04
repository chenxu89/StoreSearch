//
//  DetailViewController.h
//  StoreSearch
//
//  Created by 陈旭 on 6/1/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

typedef NS_ENUM(NSUInteger, DetailViewControllerAnimationType){
    DetailViewControllerAnimationTypeSlide,
    DetailViewControllerAnimationTypeFade
};

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) SearchResult *searchResult;

- (void)presentInParentViewController:(UIViewController *)parentViewController;

- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;

@end
