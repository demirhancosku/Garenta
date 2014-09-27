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
#import "ZGARENTA_versiyon_srvServiceV0.h"
#import "ZGARENTA_versiyon_srvRequestHandler.h"

@interface MenuSelectionVC ()
- (IBAction)locationBasedSearchSelected:(id)sender;
- (IBAction)normalSearchSelected:(id)sender;
- (IBAction)advancedSearchSelected:(id)sender;

@end

@implementation MenuSelectionVC
@synthesize loaderVC;
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
    
    [self checkVersion];
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
- (void)checkVersion
{
    //maybe we will do somehing different for here..
    loaderVC = [LoaderAnimationVC uniqueInstance];
    [loaderVC playAnimation:self.view];
    
    SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_CHECK_VERSIYON"];
    
    [handler addImportParameter:@"I_APP_NAME" andValue:[ApplicationProperties getAppName]];
    [handler addImportParameter:@"I_VERS" andValue:[ApplicationProperties getAppVersion]];
    
    NSDictionary *resultDict = [handler prepCall];
    
    if (resultDict != nil) {
        NSDictionary *exportDict = [resultDict valueForKey:@"EXPORT"];
        NSString *returnValue = [exportDict valueForKey:@"E_RETURN"];
        
        if ([returnValue isEqualToString:@"T"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"T" forKey:@"ACTIVEVERSION"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@"F" forKey:@"ACTIVEVERSION"];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bilgi" message:@"Uygulamamızın yeni versiyonunu indirmenizi rica ederiz. Teşekkürler." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"İndir",nil];
            [alert show];
        }
    }
    
    [loaderVC stopAnimation];
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
    
    //
    //    NSString *barString;
    //    if ([[ApplicationProperties getUser] isLoggedIn]) {
    //        barString = @"Çıkış";
    //        [[[self tabBarController] tabBar] setHidden:NO];
    //    }else{
    //        [[[self tabBarController] tabBar] setHidden:YES];
    //        barString = NSLocalizedString(@"Login", nil);
    //    }
    //
    //    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:barString style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
    //    [[self navigationItem] setRightBarButtonItem:barButton];
    //    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
    //                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
    //                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
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

#pragma mark - Navigation methods
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toSearchVCSegue"]) {
        
    }
    if ([segue.identifier isEqualToString:@"toLoginVCSegue"]) {
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
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newAppLink]];
        
    }
}



@end
