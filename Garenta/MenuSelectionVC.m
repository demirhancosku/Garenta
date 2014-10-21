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
- (IBAction)locationBasedSearchSelected:(id)sender;
- (IBAction)normalSearchSelected:(id)sender;
- (IBAction)advancedSearchSelected:(id)sender;

@end

@implementation MenuSelectionVC

static int kGarentaLogoId = 1;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - view event methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self checkVersion];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self putLogo];
    
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        [[[self navigationItem] rightBarButtonItem] setTitle:@"Çıkış"];
    }else{
        [[[self navigationItem] rightBarButtonItem] setTitle:@"Giriş"];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeLogo];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - util methods

- (void)checkVersion {
    
    SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_CHECK_VERSIYON"];
    
    [handler addImportParameter:@"I_APP_NAME" andValue:[ApplicationProperties getAppName]];
    [handler addImportParameter:@"I_VERS" andValue:[ApplicationProperties getAppVersion]];
    
    NSDictionary *resultDict = [handler prepCall];
    
    if (resultDict != nil) {
        NSDictionary *exportDict = [resultDict valueForKey:@"EXPORT"];
        NSString *returnValue = [exportDict valueForKey:@"E_RETURN"];
        
        if ([returnValue isEqualToString:@"T"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"T" forKey:@"ACTIVEVERSION"];
            
            if ([[ApplicationProperties getUser] isLoggedIn])
            {
                [ApplicationProperties loginToSap:[[NSUserDefaults standardUserDefaults] valueForKey:@"USERNAME"] andPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"PASSWORD"]];
                
            }
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@"F" forKey:@"ACTIVEVERSION"];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bilgi" message:@"Uygulamamızın yeni versiyonunu indirmenizi rica ederiz. Teşekkürler." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

//puts logo on navigation bar
- (void)putLogo{
    UINavigationController *nav = [self navigationController];
    float logoRatio = (float)57 / (float)357;
    float logoWidth = nav.navigationBar.frame.size.width * 0.5;
    float logoHeight = logoWidth * logoRatio;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(nav.navigationBar.frame.size.width * 0.25, nav.navigationBar.frame.size.height * 0.15, logoWidth, logoHeight)];
    [imageView setTag:kGarentaLogoId];
    [imageView setImage:[UIImage imageNamed:@"GarentaSmallLogo.png"]];
    [[[self navigationController] navigationBar] addSubview:imageView];
}

- (void)removeLogo{
    UINavigationController *nav = [self navigationController];
    [[[nav navigationBar] subviews] enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
        if ([(UIView*)obj isKindOfClass:[UIImageView class]] && [(UIImageView*)obj tag] == kGarentaLogoId ) {
            [(UIView*)obj removeFromSuperview];
        }
    }];
}

- (void)prepareScreen
{
    return;
}

- (BOOL)checkAppVersion {
    return [ApplicationProperties isActiveVersion];
}

- (void)showVersionAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bilgi" message:@"Uygulamamızın yeni versiyonunu indirmenizi rica ederiz. Teşekkürler." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
}

#pragma mark - action methods
- (IBAction)locationBasedSearchSelected:(id)sender{
    [ApplicationProperties setMainSelection:location_search];
    [self performSegueWithIdentifier:@"toSearchVCSegue" sender:self];
}

- (IBAction)normalSearchSelected:(id)sender{
    [ApplicationProperties setMainSelection:classic_search];
    [self performSegueWithIdentifier:@"toSearchVCSegue" sender:self];
}

- (IBAction)advancedSearchSelected:(id)sender{
    [ApplicationProperties setMainSelection:advanced_search];
    [self performSegueWithIdentifier:@"toSearchVCSegue" sender:self];
}

- (void)login:(id)sender
{
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        //then logout
        [[NSUserDefaults standardUserDefaults] setObject:@""forKey:@"KUNNR"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PASSWORD"];
        [[ApplicationProperties getUser] setPassword:@""];
        [[ApplicationProperties getUser] setUsername:@""];
        [[ApplicationProperties getUser] setIsLoggedIn:NO];
        [[[self navigationItem] rightBarButtonItem] setTitle:@"Giriş"];
        return;
    }
    
    LoginVC *login = [[LoginVC alloc] init];
    [[self navigationController] pushViewController:login animated:YES];
}

#pragma mark - Navigation methods
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toSearchVCSegue"]) {
        
    }
    if ([segue.identifier isEqualToString:@"toLoginVCSegue"]) {
        if ([[ApplicationProperties getUser] isLoggedIn]) {
            //then logout
            [[NSUserDefaults standardUserDefaults] setObject:@""forKey:@"KUNNR"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PASSWORD"];
            [ApplicationProperties setUser:nil];
            [[ApplicationProperties getUser] setPassword:@""];
            [[ApplicationProperties getUser] setUsername:@""];
            [[ApplicationProperties getUser] setIsLoggedIn:NO];

            
            [[[self navigationItem] rightBarButtonItem] setTitle:@"Giriş"];
            return;
        }
    }
}


@end
