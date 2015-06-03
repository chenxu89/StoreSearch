//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by 陈旭 on 6/2/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "LandscapeViewController.h"
#import "SearchResult.h"
#import <AFNetworking/UIButton+AFNetworking.h>
#import "Search.h"

@interface LandscapeViewController () <UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end

@implementation LandscapeViewController
{
    BOOL _firstTime;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstTime = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
    
    self.pageControl.numberOfPages = 0;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (_firstTime) {
        _firstTime = NO;
        [self tileButtons];
    }
}

- (void)tileButtons
{
    const CGFloat buttonWidth = 70.0f;
    const CGFloat buttonHeight = 70.0f;
    const CGFloat marginWidth = 3.0f;
    const CGFloat marginHeight = 3.0f;
    const CGFloat itemWidth = buttonWidth + 2.0 * marginWidth;
    const CGFloat itemHeight = buttonHeight + 2.0 * marginHeight;
    const CGFloat pageControlHeight = 37.0f;
    const CGFloat statusBarHeight = 20.0f;
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    NSUInteger index = 0;
    NSUInteger row = 0;
    NSUInteger column = 0;
    
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
    CGFloat scrollViewHeight = self.scrollView.bounds.size.height;
    NSUInteger columnsPerPage = floorf(scrollViewWidth / itemWidth);
    NSUInteger rowsPerPage = floorf((scrollViewHeight - pageControlHeight - statusBarHeight) / itemHeight);
    CGFloat halfExtraSpaceWidth = (scrollViewWidth - columnsPerPage * itemWidth) / 2.0f;
    CGFloat halfExtraSpaceHeight = (scrollViewHeight - pageControlHeight - statusBarHeight - rowsPerPage * itemHeight) / 2.0f;

    
    for (SearchResult *searchResult in self.search.searchResults){
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setBackgroundImage:[UIImage imageNamed:@"LandscapeButton"] forState:UIControlStateNormal];
        
        button.frame = CGRectMake(x + halfExtraSpaceWidth + marginWidth,
                                  y + halfExtraSpaceHeight + marginHeight + statusBarHeight + row * itemHeight,
                                  buttonWidth, buttonHeight);
        
        [self downloadImageForSearchResult:searchResult andPlaceOnButton:button];
        
        [self.scrollView addSubview:button];
        
        index++;
        row++;
        //change to another column
        if (row == rowsPerPage) {
            row = 0;
            column++;
            x += itemWidth;
            //change to another page
            if (column == columnsPerPage) {
                column = 0;
                x += halfExtraSpaceWidth * 2.0f;
            }
        }
    }
    
    
    NSUInteger tilesPerPage = columnsPerPage * rowsPerPage;
    NSUInteger numPages = ceilf([self.search.searchResults count] / (float)tilesPerPage);
    
    self.scrollView.contentSize = CGSizeMake(numPages * scrollViewWidth, scrollViewHeight);
    NSLog(@"Number of pages: %ld", (long)numPages);
    
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = self.scrollView.bounds.size.width;
    NSInteger currentPage = (self.scrollView.contentOffset.x + width/2.0f) / width;
    self.pageControl.currentPage = currentPage;
}

- (IBAction)pageChanged:(UIPageControl *)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * sender.currentPage, 0);
    } completion:nil];
    
}

- (void)downloadImageForSearchResult:(SearchResult *)searchResult
                    andPlaceOnButton:(UIButton *)button
{
    NSURL *url = [NSURL URLWithString:searchResult.artworkURL60];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIButton *weakButton = button;
    
    [button setImageForState:UIControlStateNormal withURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        UIImage *unscaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:image.imageOrientation];
        
        UIImage *scaledImage = [self resizedImage:unscaledImage WithBounds:CGSizeMake(60.0f, 60.0f)];
        
        [weakButton setImage:scaledImage forState:UIControlStateNormal];
        
    } failure:nil];

}

//UIImage category to resize using the “Aspect Fill” rules.
- (UIImage *)resizedImage:(UIImage *)image
               WithBounds:(CGSize)bounds
{
    //This method first calculates how big the image can be in order to fit inside the bounds rectangle. It uses the “aspect fill” approach to keep the aspect ratio intact.
    CGFloat horizontalRatio = bounds.width / image.size.width;
    CGFloat verticalRatio = bounds.height / image.size.height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
    
    //Then it creates a new image context and draws the image into that.
    UIGraphicsBeginImageContextWithOptions(bounds, YES, 0);
    CGFloat x;
    CGFloat y;
    
    if (horizontalRatio <= verticalRatio) {
        x = - (image.size.width * ratio - bounds.width) / 2 ;
        y = 0;
    }else{
        x = 0;
        y = - (image.size.height *ratio - bounds.height) / 2;
    }
    [image drawInRect:CGRectMake(x, y, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
