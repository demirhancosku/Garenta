//
//  OfficeListVC.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "OfficeListVC.h"

@interface OfficeListVC ()

@end

@implementation OfficeListVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithOfficeList:(NSMutableArray *)office andDest:(Destination *)dest
{
    self = [super init];
    
    officeList = [[NSMutableArray alloc] init];
    destination = [[Destination alloc] init];
    
    destination = dest;
    officeList = office;
    
    return self;
}

- (id)initWithOfficeList:(NSMutableArray *)office andArr:(Arrival *)arr
{
    self = [super init];
    
    officeList = [[NSMutableArray alloc] init];
    arrival = [[Arrival alloc] init];

    arrival = arr;
    officeList = office;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    officeListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    [officeListTable setDelegate:self];
    [officeListTable setDataSource:self];
    
    tempOffice = [[Office alloc] init];
    
    [[self view] addSubview:officeListTable];
    
    searchData = [[NSMutableArray alloc]init];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    
    officeListTable.tableHeaderView = searchBar;
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"subOfficeName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [officeList sortUsingDescriptors:sortDescriptors];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [searchData count];
    else
        return [officeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        tempOffice = [searchData objectAtIndex:indexPath.row];
    }
    else
    {
        tempOffice = [officeList objectAtIndex:indexPath.row];
    }
    
    [[cell textLabel] setText:[tempOffice subOfficeName]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        tempOffice = [searchData objectAtIndex:indexPath.row];
    }
    else
    {
        tempOffice = [officeList objectAtIndex:indexPath.row];
    }
    
    if (arrival == nil)
    {
        [destination setDestinationOfficeCode:[tempOffice mainOfficeCode]];
        [destination setDestinationOfficeName:[tempOffice subOfficeName]];
    }
    else
    {
        [arrival setArrivalOfficeCode:[tempOffice mainOfficeCode]];
        [arrival setArrivalOfficeName:[tempOffice subOfficeName]];
    }
    
    [[self navigationController] popViewControllerAnimated:YES];

}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    [self->searchData removeAllObjects]; // First clear the filtered array.
    
    if (![searchText isEqualToString:@""]) {
        
        for (int i = 0; i < [officeList count]; i++)
        {
            
            NSString *officeName = [[officeList objectAtIndex:i] subOfficeName];
            
            NSComparisonResult result = [officeName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            
            if (result == NSOrderedSame)
            {
                [self->searchData addObject:[officeList objectAtIndex:i]];
            }
        }
    }
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
    controller.searchResultsTableView.backgroundColor = [officeListTable backgroundColor];
    controller.searchResultsTableView.rowHeight = [officeListTable rowHeight];
    controller.searchResultsDelegate = self;
    
}


@end
