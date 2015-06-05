//
//  DetailViewController.m
//  StoreSearch
//
//  Created by 陈旭 on 6/1/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GradientView.h"



@interface DetailViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *kindLabel;
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation DetailViewController
{
    GradientView *_gradientView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [[UIImage imageNamed:@"PriceButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.priceButton setBackgroundImage:image forState:UIControlStateNormal];
    self.view.tintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
    //rounded corners
    self.popupView.layer.cornerRadius = 10.0f;
    
    //ipad situation
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];

        self.popupView.hidden = (self.searchResult == nil);
        
        //the app shows its local name in the big navigation bar on top of the detail pane.
        self.title = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    //iphone situation
    }else{
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        gestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:gestureRecognizer];
        
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    if (self.searchResult != nil) {
        [self updateUI];
    }
}

- (void)setSearchResult:(SearchResult *)searchResult
{
    if (_searchResult != searchResult) {
        _searchResult = searchResult;
        
        if ([self isViewLoaded]) {
            [self updateUI];
        }
    }
}

- (void)updateUI
{
    self.nameLabel.text = self.searchResult.name;
    NSString *artistName = self.searchResult.artistName;
    if (artistName == nil) {
        artistName = NSLocalizedString(@"Unknown", @"DetailViewController: artistName") ;
    }
    self.artistNameLabel.text = artistName;
    self.kindLabel.text = [self.searchResult kindForDisplay];
    self.genreLabel.text = self.searchResult.genre;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:self.searchResult.currency];
    
    NSString *priceText;
    if ([self.searchResult.price floatValue] == 0.0f) {
        priceText = NSLocalizedString(@"Free", @"DetailViewController: priceText") ;
    }else{
        priceText = [formatter stringFromNumber:self.searchResult.price];
    }
    
    [self.priceButton setTitle:priceText forState:UIControlStateNormal];
    
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:self.searchResult.artworkURL100]];
    
    //ipad situation
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //This makes the view visible when on the iPad, cause in viewDidLoad you make the view invisible.
        self.popupView.hidden = NO;
        //hide the popover after the user makes a selection.
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view == self.view);
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
    //create the background view: GradientView
    _gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
    [parentViewController.view addSubview:_gradientView];
    
    //the pop-up view bounces into the main view.
    self.view.frame = parentViewController.view.bounds;
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.duration = 0.4;
    bounceAnimation.delegate = self;
    bounceAnimation.values = @[ @0.7, @1.2, @0.9, @1.0 ];
    bounceAnimation.keyTimes = @[ @0.0, @0.334, @0.666, @1.0 ];
    
    bounceAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    
    //the GradientView fade in
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @0.0f;
    fadeAnimation.toValue = @1.0f;
    fadeAnimation.duration = 0.2;
    [_gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self didMoveToParentViewController:self.parentViewController];
}

- (IBAction)close:(id)sender
{
    [self dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeSlide];
}

- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType
{
    [self willMoveToParentViewController:nil];
    
    //making the pop-up slide down the screen.
    [UIView animateWithDuration:0.4f animations:^{
        if (animationType == DetailViewControllerAnimationTypeSlide) {
            CGRect rect = self.view.bounds;
            rect.origin.y += rect.size.height;
            self.view.frame = rect;
        }else{
            self.view.alpha = 0.0f;
        }

        //animate the gradient view fade out.
        _gradientView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [_gradientView removeFromSuperview];
    }];
}

- (IBAction)openInStore:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.searchResult.storeURL]];
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
    
    [self.artworkImageView cancelImageRequestOperation];
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = NSLocalizedString(@"Search", @"Split-view master button");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
