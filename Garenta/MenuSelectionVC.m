//
//  MenuSelectionVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "MenuSelectionVC.h"
#import "MenuTableCellView.h"
@interface MenuSelectionVC ()

@end

@implementation MenuSelectionVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    //    self = [super init];
    

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self prepareScreen];
}

- (void)prepareScreen
{
    
    
    NSString *barString;
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        barString = @"Çıkış";
    }else{
        
                barString = @"Giriş";
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:barString style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
    return;

    
}



- (void)login:(id)sender
{
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        //then logout
        [[NSUserDefaults standardUserDefaults]
    setObject:@""forKey:@"KUNNR"];
        
        [[NSUserDefaults standardUserDefaults]
         setObject:@"" forKey:@"PASSWORD"];
        [[ApplicationProperties getUser] setPassword:@""];
        [[ApplicationProperties getUser] setUsername:@""];
        [[ApplicationProperties getUser] setIsLoggedIn:NO];
        [[[self navigationItem] rightBarButtonItem] setTitle:@"Giriş"];
        return;
    }
    LoginVC *login = [[LoginVC alloc] initWithFrame:self.view.frame andUser:nil];
    [[self navigationController] pushViewController:login animated:YES];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3.0f)];
    }
    
    ///custom init
    MenuTableCellView *menuTableCellView = [[MenuTableCellView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,[self tableView:tableView heightForRowAtIndexPath:indexPath]) andIndex:indexPath.row];
    [cell setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:72.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
    [cell addSubview:menuTableCellView];
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassicSearchVC *classicSearchVC = [[ClassicSearchVC alloc] initWithFrame:self.view.frame];
    
    switch (indexPath.row) {
        case 0:
            [ApplicationProperties setMainSelection:location_search];
            break;
        case 1:
            [ApplicationProperties setMainSelection:classic_search];

            break;
        case 3:
            [ApplicationProperties setMainSelection:advanced_search];
            break;
            
        default:
            break;
    }
            [[self navigationController] pushViewController:classicSearchVC animated:YES];    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.height / 3.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
