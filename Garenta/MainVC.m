//
//  MainVC.m
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{    
    self = [super init];
    viewFrame = frame;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationItem] setTitle:@"Kerem"];
    
    tableViewController = [[MainTableVC alloc] initWithStyle:UITableViewStyleGrouped];
    tableViewController.tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, 0, viewFrame.size.width, 350))];
    
    [self.view addSubview:tableViewController.tableView];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
