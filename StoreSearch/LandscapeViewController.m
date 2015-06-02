//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by 陈旭 on 6/2/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "LandscapeViewController.h"
#import "SearchResult.h"

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
    NSUInteger columnsPerPage = 5;
    CGFloat itemWidth = 96.0f;
    CGFloat x = 0.0f;
    CGFloat extraSpace = 0.0f;
    
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
    
    if (scrollViewWidth > 480.0f) {
        columnsPerPage = 6;
        itemWidth = 94.0f;
        x = 2.0f;
        extraSpace = 4.0f;
    }
    
    const CGFloat itemHeight = 88.0f;
    const CGFloat buttonWidth = 82.0f;
    const CGFloat buttonHeight = 82.0f;
    const CGFloat marginHorz = (itemWidth - buttonWidth) / 2.0f;
    const CGFloat marginVert = (itemHeight - buttonHeight) / 2.0f;
    
    NSUInteger index = 0;
    NSUInteger row = 0;
    NSUInteger column = 0;
    
    for (SearchResult *searchResult in self.searchResults){
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        
        button.backgroundColor = [UIColor whiteColor];
        [button setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)index] forState:UIControlStateNormal];
        button.frame = CGRectMake(x + marginHorz, 20.0f + row*itemHeight + marginVert, buttonWidth, buttonHeight);
        
        [self.scrollView addSubview:button];
        
        index++;
        row++;
        if (row == 3) {
            row = 0;
            column++;
            x += itemWidth;
            
            if (column == columnsPerPage) {
                column = 0;
                x += extraSpace;
            }
        }
    }
    
    NSInteger tilesPerPage = columnsPerPage * 3;
    NSInteger numPages = ceilf([self.searchResults count] / (float)tilesPerPage);
    
    self.scrollView.contentSize = CGSizeMake(numPages*scrollViewWidth, self.scrollView.bounds.size.height);
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
