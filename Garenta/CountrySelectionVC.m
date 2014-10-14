//
//  CountrySelectionVC.m
//  Garenta
//
//  Created by Ata Cengiz on 08/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "CountrySelectionVC.h"

@interface CountrySelectionVC ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@end

@implementation CountrySelectionVC

- (instancetype)init {
    self = [super init];
    
    self.selectionArray = [NSArray new];
    self.filterResultArray = [NSArray new];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        return [self.selectionArray count];
    }
    else {
        return [self.filterResultArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *tempObject;
    
    if (tableView == self.tableView) {
        tempObject = [self.selectionArray objectAtIndex:[indexPath row]];
    }
    else {
        tempObject = [self.filterResultArray objectAtIndex:[indexPath row]];
    }
    
    if (self.searchType == 1) {
        [[cell textLabel] setText:[tempObject objectAtIndex:1]];
    }
    if (self.searchType == 2) {
        [[cell textLabel] setText:[tempObject objectAtIndex:2]];
    }
    if (self.searchType == 3) {
        [[cell textLabel] setText:[tempObject objectAtIndex:3]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *selectedObject;
    
    if (tableView == self.tableView) {
        selectedObject = [self.selectionArray objectAtIndex:[indexPath row]];
    }
    else {
        selectedObject = [self.filterResultArray objectAtIndex:[indexPath row]];
    }
    
    if (self.searchType == 1) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:selectedObject forKey:@"Country"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"countrySelected" object:nil userInfo:userInfo];
    }
    
    if (self.searchType == 2) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:selectedObject forKey:@"City"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"citySelected" object:nil userInfo:userInfo];
    }
    
    if (self.searchType == 3) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:selectedObject forKey:@"County"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"countySelected" object:nil userInfo:userInfo];
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    self.filterResultArray = [NSArray new];
    
    [self.searchDisplayController setActive:YES animated:YES];
    
    NSMutableArray *resultArray = [NSMutableArray new];
    
    if (![searchText isEqualToString:@""])
    {
        for (NSArray *tempObject in self.selectionArray)
        {
            NSComparisonResult result;
            
            if (self.searchType == 1) {
                result = [[tempObject objectAtIndex:1] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            }
            if (self.searchType == 2) {
                result = [[tempObject objectAtIndex:2] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            }
            
            if (self.searchType == 3) {
                result = [[tempObject objectAtIndex:3] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            }
            
            if (result == NSOrderedSame) {
                [resultArray addObject:tempObject];
            }
        }
    }
    
    self.filterResultArray = resultArray;
    
    [self.tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];

    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.backgroundColor = [[self tableView] backgroundColor];
    controller.searchResultsTableView.rowHeight = [[self tableView] rowHeight];
    controller.searchResultsDelegate = self;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.filterResultArray = [NSArray new];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
