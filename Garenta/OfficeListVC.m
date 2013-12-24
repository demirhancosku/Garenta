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
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [searchBar setDelegate:self];
    
    officeListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    
    [officeListTable setDelegate:self];
    [officeListTable setDataSource:self];
    
    [[self view] addSubview:officeListTable];
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
    // Return the number of rows in the section.
//    return [officeList count];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    [[cell textLabel] setText:@"İstanbul Atatürk Havalimanı"];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (arrival == nil)
        [destination setDestinationOffice:@"İstanbul Atatürk Havalimanı"];
    
    else
        [arrival setArrivalOffice:@"İstanbul Sabiha Gökçen"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewDidReturn" object:nil userInfo:nil];
    }
    else
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

@end
