//
//  SearchViewController.m
//  StoreSearch
//
//  Created by 陈旭 on 5/27/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import <AFNetworking/AFNetworking.h>
#import "DetailViewController.h"
#import "LandscapeViewController.h"
#import "Search.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation SearchViewController
{
    Search *_search;
    LandscapeViewController *_lanscapeViewController;
    UIStatusBarStyle _statusBarStyle;
    __weak DetailViewController *_detailViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Now the first row will always be visible
    self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
    
    //load the nib
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    //register this nib for a reuse identifier
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    UINib *nothingFoundCellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:nothingFoundCellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    self.tableView.rowHeight = 80;
    
    //the keyboard will be immediately visible when you start the app
    [self.searchBar becomeFirstResponder];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
    _statusBarStyle = UIStatusBarStyleDefault;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (_search == nil) {
        return 0; // Not searched yet
    }else if (_search.isLoading) {
        return 1; // Loading...
    }else if ([_search.searchResults count] == 0){
        return 1; // Nothing Found
    }else{
        return [_search.searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //show the spinner when loading
    if (_search.isLoading) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        return cell;
    }
    else if ([_search.searchResults count] == 0){
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
    }else{
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
        SearchResult *searchResult = _search.searchResults[indexPath.row];
        
        [cell configureForSearchResult:searchResult];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    //must put before the line :"controller.view.frame = self.view.frame;"
    SearchResult *searchResult = _search.searchResults[indexPath.row];
    controller.searchResult = searchResult;

    [controller presentInParentViewController:self];
    
    _detailViewController = controller;
}

//self-produced, not necessary
- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_search.searchResults count] == 0 || _search.isLoading) {
        return nil;
    }else{
        return indexPath;
    }
}


#pragma mark - UISearchBarDelegate

//This is part of the SearchBarDelegate protocol.
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearch];
}

- (void)performSearch
{
    _search = [[Search alloc] init];
    NSLog(@"allocated %@", _search);
    
    [_search performSearchForText:self.searchBar.text
                         category:self.segmentedControl.selectedSegmentIndex
                       completion:^(BOOL success) {
                           if (!success) {
                               [self showNetworkError];
                           }
                           
                           [self.tableView reloadData];
     }];
    
    //show the activity spinner
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}



- (void)showNetworkError
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Whoops..."
                              message:@"There was error reading from the iTunes store. Please try again"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    
    [alertView show];
}

- (IBAction)segmentedChanged:(UISegmentedControl *)sender
{
    if (_search != nil) {
        [self performSearch];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self hideLandscapeViewWithDuration:duration];
    }else{
        [self showLandscapeViewWithDuration:duration];
    }
}

- (void)showLandscapeViewWithDuration:(NSTimeInterval)duration
{
    if (_lanscapeViewController == nil) {
        
        _lanscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
        
        //the order matters, transform data before view
        _lanscapeViewController.search = _search;
        
        _lanscapeViewController.view.frame = self.view.bounds;
        _lanscapeViewController.view.alpha = 0.0f;
        
        [self.view addSubview:_lanscapeViewController.view];
        [self addChildViewController:_lanscapeViewController];
        
        [UIView animateWithDuration:duration animations:^{
            _lanscapeViewController.view.alpha = 1.0f;
            
            _statusBarStyle = UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
            
            [self.searchBar resignFirstResponder];
            
            [_detailViewController dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeFade];
            
        } completion:^(BOOL finished) {
            [_lanscapeViewController didMoveToParentViewController:self];
        }];
    }
}

- (void)hideLandscapeViewWithDuration:(NSTimeInterval)duration
{
    if (_lanscapeViewController != nil) {
        [_lanscapeViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:duration animations:^{
            _lanscapeViewController.view.alpha = 0.0f;
            
            _statusBarStyle = UIStatusBarStyleDefault;
            [self setNeedsStatusBarAppearanceUpdate];
            
        } completion:^(BOOL finished) {
            [_lanscapeViewController.view removeFromSuperview];
            [_lanscapeViewController removeFromParentViewController];
            _lanscapeViewController = nil;
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}

@end
