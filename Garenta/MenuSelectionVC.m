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
            
            if ([[ApplicationProperties getUser] isLoggedIn]) {
                [self getUserInfoFromSAP];
            }
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@"F" forKey:@"ACTIVEVERSION"];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bilgi" message:@"Uygulamamızın yeni versiyonunu indirmenizi rica ederiz. Teşekkürler." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"İndir",nil];
            [alert show];
        }
    }
    
}

- (void)getUserInfoFromSAP {
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZMOB_REZ_LOGIN"];
        
        [handler addImportParameter:@"IV_PASSWORD" andValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"PASSWORD"]];
        [handler addImportParameter:@"IV_FREETEXT" andValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"USERNAME"]];
        [handler addImportParameter:@"IV_LANGU" andValue:@"T"];
        
        [handler addTableForReturn:@"ET_RETURN"];
        [handler addTableForReturn:@"ET_PARTNERS"];
        [handler addTableForReturn:@"ET_CARDTYPES"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *sysubrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([sysubrc isEqualToString:@"0"]) {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                NSDictionary *allPartners = [tables objectForKey:@"ZNET_LOGIN_ALL_PARTNERS"];
                
                if (allPartners.count > 0) {
                    
                    for (NSDictionary *tempDict in allPartners) {
                        User *user = [ApplicationProperties getUser];
                        
                        [user setName:[tempDict valueForKey:@"MC_NAME2"]];
                        [user setMiddleName:[tempDict valueForKey:@"NAMEMIDDLE"]];
                        [user setSurname:[tempDict valueForKey:@"MC_NAME1"]];
                        [user setKunnr:[tempDict valueForKey:@"PARTNER"]];
                        [user setPartnerType:[tempDict valueForKey:@"MUSTERI_TIPI"]];
                        [user setCompany:[tempDict valueForKey:@"FIRMA_KODU"]];
                        [user setCompanyName:[tempDict valueForKey:@"FIRMA_NAME1"]];
                        [user setCompanyName2:[tempDict valueForKey:@"FIRMA_NAME2"]];
                        [user setMobileCountry:[tempDict valueForKey:@"MOBILE_ULKE"]];
                        [user setMobile:[tempDict valueForKey:@"MOBILE"]];
                        [user setEmail:[tempDict valueForKey:@"EMAIL"]];
                        [user setTckno:[tempDict valueForKey:@"TCKNO"]];
                        [user setGarentaTl:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"GARENTATL"]]];
                        [user setPriceCode:[tempDict valueForKey:@"FIYAT_KODU"]];
                        [user setPriceType:[tempDict valueForKey:@"FIYAT_TIPI"]];
                        
                        if ([[tempDict valueForKey:@"C_PRIORITY"] isEqualToString:@"X"]) {
                            [user setIsPriority:YES];
                        }
                        
                        if ([[user partnerType] isEqualToString:@"B"]) {
                            [user setIsLoggedIn:YES];
                            [ApplicationProperties setUser:user];
                        }
                        else {
                            // Şu an sadece bireysel kullanıcıları alıyoruz
                        }
                    }
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
                    [alert show];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
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
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newAppLink]];
    }
}



@end
