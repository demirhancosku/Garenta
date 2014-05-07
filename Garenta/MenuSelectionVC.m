//
//  MenuSelectionVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "MenuSelectionVC.h"
#import "MenuTableCellView.h"
#import "MinimumInfoVC.h"
@interface MenuSelectionVC ()

@end

@implementation MenuSelectionVC
@synthesize loaderVC;
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

#pragma mark - view event methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
	// Do any additional setup after loading the view.
    [self checkVersion];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self prepareScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView datasource methods

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


#pragma mark - tableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // Silinicek
//    MinimumInfoVC *info = [[MinimumInfoVC alloc] init];
//    [[self navigationController] pushViewController:info animated:YES];
//    return;
    
    //version check
    [self checkAppVersion];
    //aalpk
    ClassicSearchVC *classicSearchVC = [[ClassicSearchVC alloc] initWithFrame:self.view.frame];
    
    switch (indexPath.row) {
        case 0:
            [ApplicationProperties setMainSelection:location_search];
            break;
        case 1:
            [ApplicationProperties setMainSelection:classic_search];

            break;
        case 2:
            [ApplicationProperties setMainSelection:advanced_search];
            break;
            
        default:
            break;
    }
            [[self navigationController] pushViewController:classicSearchVC animated:YES];    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self tabBarController]   tabBar] isHidden] ) {
            return self.view.frame.size.height / 3.0f;
    }else{
        return    (self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height) / 3.0f;
    }

}


#pragma mark - util methods
- (void)checkVersion{
    NSString *connectionString = [ApplicationProperties getVersionUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:150.0];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}

- (void)prepareScreen
{
    
    
    NSString *barString;
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        barString = @"Çıkış";
        [[[self tabBarController] tabBar] setHidden:NO];
    }else{
        [[[self tabBarController] tabBar] setHidden:YES];
        barString = NSLocalizedString(@"Login", nil);
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:barString style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
    return;
    
    
}

- (BOOL)checkAppVersion{
    return [ApplicationProperties isActiveVersion];
     
}

- (void)showVersionAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bilgi" message:@"Uygulamamızın yeni versiyonunu indirmenizi rica ederiz. Teşekkürler." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:       @"İndir",nil];
    [alert show];
}



#pragma mark - action methods

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


#pragma mark - nurlconnection delegate methods

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0)
    {
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"gw_admin" password:@"1qa2ws3ed"persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else
    {
        NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *err;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if(err!=nil){
        //hata msjı
    }
    
    NSDictionary *result = [jsonDict objectForKey:@"d"];
    

    NSString *updateLink;
    if([[result objectForKey:@"EReturn"] isEqualToString:@"T"]){
        [[NSUserDefaults standardUserDefaults]
         setObject:@"T"forKey:@"ACTIVEVERSION"];
        
    }else{
        newAppLink = [result objectForKey:@"ELink"];
        [[NSUserDefaults standardUserDefaults]
         setObject:@"F"forKey:@"ACTIVEVERSION"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bilgi" message:@"Uygulamamızın yeni versiyonunu indirmenizi rica ederiz. Teşekkürler." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:       @"İndir",nil];
        [alert show];
    }
    [loaderVC stopAnimation];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newAppLink]];
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [loaderVC stopAnimation];
}

@end
