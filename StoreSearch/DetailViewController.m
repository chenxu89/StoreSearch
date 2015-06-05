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
#import "MenuViewController.h"
#import <MessageUI/MessageUI.h>

@interface DetailViewController () <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *kindLabel;
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *menuPopoverController;

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
        
        //add a button to the navigation bar so that there is something to trigger the popover from.
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(menuButtonPressed:)];
    
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view == self.view);
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
    
    [self.artworkImageView cancelImageRequestOperation];
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
        //hide the popover after the user makes a selection.
        [self.masterPopoverController dismissPopoverAnimated:YES];
        
        //make popupView bounce
        if (self.popupView.hidden) {
            [self bounceAnimationForView:self.popupView withDelegate:nil];
        }
        //In viewDidLoad you make the view invisible, now let it visable.
        self.popupView.hidden = NO;
    }
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
    //create the background view: GradientView, it and detailview
    _gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
    [parentViewController.view addSubview:_gradientView];
    
    self.view.frame = parentViewController.view.bounds;
    //That’s first two parts of the three steps of embedding one view controller into another
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
    
    //the detail view bounces.
    [self bounceAnimationForView:self.view withDelegate:self];
    
    //the GradientView fade in
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @0.0f;
    fadeAnimation.toValue = @1.0f;
    fadeAnimation.duration = 0.2;
    [_gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (IBAction)openInStore:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.searchResult.storeURL]];
}

- (IBAction)close:(id)sender
{
    [self dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeSlide];
}

- (void)menuButtonPressed:(UIBarButtonItem *)sender
{
    if ([self.menuPopoverController isPopoverVisible]) {
        [self.menuPopoverController dismissPopoverAnimated:YES];
    }else{
        [self.menuPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

//The creation of the popover object is done lazily by the self.menuPopoverController getter.
- (UIPopoverController *)menuPopoverController
{
    if (_menuPopoverController == nil) {
        MenuViewController *menuViewController = [[MenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        menuViewController.detailViewController = self;
        
        _menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:menuViewController];
    }
    return _menuPopoverController;
}

- (void)sendSupportEmail
{
    [self.menuPopoverController dismissPopoverAnimated:YES];
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];

    controller.mailComposeDelegate = self;
    
    if (controller != nil) {
        [controller setSubject:NSLocalizedString(@"Support Request", @"Email subject")];
        [controller setToRecipients:@[@"your@email-address-here.com"]];
        
        //The modalPresentationStyle property determines how a modal view controller is presented on the iPad.  You can switch it from the default page sheet to a form sheet or full screen.
        //controller.modalPresentationStyle = UIModalPresentationFormSheet;
        //controller.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Animation

//bounce animation
- (void)bounceAnimationForView:(UIView *)view
              withDelegate:(UIViewController *)delegate
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.duration = 0.4;
    //By making DetailViewController the delegate of the CAKeyframeAnimation, you will be told when the animation stopped. at that point you must call the didMoveToParentViewController: method.
    bounceAnimation.delegate = delegate;
    bounceAnimation.values = @[ @0.7, @1.2, @0.9, @1.0 ];
    bounceAnimation.keyTimes = @[ @0.0, @0.334, @0.666, @1.0 ];
    
    bounceAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
}

//CAKeyframeAnimation delegate method
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //That’s last part of the three steps of embedding one view controller into another
    [self didMoveToParentViewController:self.parentViewController];
}

//slide and fade animation
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

#pragma mark - UISplitViewControllerDelegate

//In portrait mode the master pane won’t be visible all the time, only when you tap a button. This brings up a so-called popover. The split-view controller takes care of most of this logic for you but you still need to put that button somewhere.

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

- (void)splitViewController:(UISplitViewController *)svc
          popoverController:(UIPopoverController *)pc
  willPresentViewController:(UIViewController *)aViewController
{
    //hide menu view popover
    if ([self.menuPopoverController isPopoverVisible]) {
        [self.menuPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
