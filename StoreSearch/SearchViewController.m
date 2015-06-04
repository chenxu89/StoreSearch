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
    LandscapeViewController *_landscapeViewController;
    UIStatusBarStyle _statusBarStyle;
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
    
    SearchResult *searchResult = _search.searchResults[indexPath.row];
    
    //for iphone, create a new DetailViewController and bounce it up.
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        
        //don't put it in ipad situation, cause you should let the selected row keep selected status.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        
        controller.searchResult = searchResult;
        
        [controller presentInParentViewController:self];
        
        self.detailViewController = controller;
        
    //for ipad, update the old DetailViewController.
    }else{
        self.detailViewController.searchResult = searchResult;
    }
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
                           
                           [_landscapeViewController searchResultsReceived];
                           [self.tableView reloadData];
     }];
    
    //show the activity spinner
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}



- (void)showNetworkError
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Whoops...", @"Error alert: title")
                              message:NSLocalizedString(@"There was error reading from the iTunes store. Please try again", @"Error alert: message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Error alert: cancelButtonBTitle")
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
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            [self hideLandscapeViewWithDuration:duration];
        }else{
            [self showLandscapeViewWithDuration:duration];
        }
    }
}

- (void)showLandscapeViewWithDuration:(NSTimeInterval)duration
{
    if (_landscapeViewController == nil) {
        
        _landscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
        
        //the order matters, transform data before view
        _landscapeViewController.search = _search;
        
        _landscapeViewController.view.frame = self.view.bounds;
        _landscapeViewController.view.alpha = 0.0f;
        
        [self.view addSubview:_landscapeViewController.view];
        [self addChildViewController:_landscapeViewController];
        
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 1.0f;
            
            _statusBarStyle = UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
            
            [self.searchBar resignFirstResponder];
            
            [self.detailViewController dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeFade];
            
        } completion:^(BOOL finished) {
            [_landscapeViewController didMoveToParentViewController:self];
        }];
    }
}

- (void)hideLandscapeViewWithDuration:(NSTimeInterval)duration
{
    if (_landscapeViewController != nil) {
        [_landscapeViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 0.0f;
            
            _statusBarStyle = UIStatusBarStyleDefault;
            [self setNeedsStatusBarAppearanceUpdate];
            
        } completion:^(BOOL finished) {
            [_landscapeViewController.view removeFromSuperview];
            [_landscapeViewController removeFromParentViewController];
            _landscapeViewController = nil;
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}

@end
