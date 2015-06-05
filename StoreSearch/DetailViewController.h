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
@property (nonatomic, weak) IBOutlet UIView *popupView;

- (void)presentInParentViewController:(UIViewController *)parentViewController;

- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;

- (void)bounceAnimationForView:(UIView *)view
                  withDelegate:(UIViewController *)delegate;

- (void)sendSupportEmail;

@end
