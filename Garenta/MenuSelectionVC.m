//
//  MenuSelectionVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "MenuSelectionVC.h"
#import "MenuTableCellView.h"
#import "OldReservationPaymentVC.h"
#import "ChangeUserProfileVC.h"
#import "WYStoryboardPopoverSegue.h"

@interface MenuSelectionVC ()

@property (strong,nonatomic) NSArray *userList;
@property (strong,nonatomic) WYPopoverController *popOver;

- (IBAction)locationBasedSearchSelected:(id)sender;
- (IBAction)normalSearchSelected:(id)sender;
- (IBAction)advancedSearchSelected:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;

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
    
    _userList = [[ApplicationProperties getUser] userList];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PayNowPushNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *userInfo) {
        [self performSegueWithIdentifier:@"ToPayNowNotificationSegue" sender:userInfo];
    }];
    
    // profilini değiştirdikten sonra popover kapatsın diye
    [[NSNotificationCenter defaultCenter] addObserverForName:@"profileChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *userInfo) {
        [self.popOver dismissPopoverAnimated:YES];
    }];
    
    // profilini değiştirdikten sonra popover kapatsın diye
    [[NSNotificationCenter defaultCenter] addObserverForName:@"fillUserList" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *userInfo) {
        self.userList = userInfo.object;
    }];
    
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [self checkVersion];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self putLogo];
    
//    if ([[ApplicationProperties getUser] isLoggedIn]) {
//        [[[self navigationItem] rightBarButtonItem] setTitle:@"Çıkış"];
//    }else{
//        [[[self navigationItem] rightBarButtonItem] setTitle:@"Giriş"];
//    }
    
    [[[self navigationItem] rightBarButtonItem] setImage:[UIImage imageNamed:@"userLoginBarButton"]];
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
                _userList = [NSMutableArray new];
                _userList = [User loginToSap:[[NSUserDefaults standardUserDefaults] valueForKey:@"USERNAME"] andPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"PASSWORD"]];
                
                for (User *tempUser in _userList) {
                    [tempUser setUserList:_userList];
                    if ([tempUser.kunnr isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"KUNNR"]]) {
                        tempUser.isLoggedIn = YES;
                        [ApplicationProperties setUser:tempUser];
                    }
                }
            }
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@"F" forKey:@"ACTIVEVERSION"];

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bilgi" message:@"Uygulamamızın yeni versiyonunu indirmenizi rica ederiz. Teşekkürler." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [alert show];
            });
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self locationBasedSearchSelected];
            break;
        case 1:
            [self normalSearchSelected];
            break;
        case 2:
            [self advancedSearchSelected];
            break;
        default:
            break;
    }
}

#pragma mark - action methods
- (void)locationBasedSearchSelected {
    [ApplicationProperties setMainSelection:location_search];
    [self performSegueWithIdentifier:@"toSearchVCSegue" sender:self];
}

- (void)normalSearchSelected {
    [ApplicationProperties setMainSelection:classic_search];
    [self performSegueWithIdentifier:@"toSearchVCSegue" sender:self];
}

- (void)advancedSearchSelected {
    [ApplicationProperties setMainSelection:advanced_search];
    [self performSegueWithIdentifier:@"toSearchVCSegue" sender:self];
}

- (IBAction)loginButtonPressed:(id)sender
{
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        //then logout
        
        [self performSegueWithIdentifier:@"toChangeUserProfile" sender:self.navigationItem.rightBarButtonItem];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Çıkış yapmak istediğinize emin misiniz?" delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Çıkış", nil];
//        
//        alert.tag = 1;
//        [alert show];
    }
    else
        [self performSegueWithIdentifier:@"toLoginVCSegue" sender:self];
}

#pragma mark - Navigation methods
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toSearchVCSegue"]) {
        
    }
    
    if ([segue.identifier isEqualToString:@"toChangeUserProfile"]) {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(260,(self.userList.count + 1) * 44);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        [(ChangeUserProfileVC *)[segue destinationViewController] setUserList:self.userList];
        _popOver = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        _popOver.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"ToPayNowNotificationSegue"]) {
        NSDictionary *dict = [sender object];
        NSString *reservationNumber = [dict valueForKey:@"ReservationId"];
        
        OldReservationPaymentVC *paymentVC = (OldReservationPaymentVC *)[segue destinationViewController];
        paymentVC.reservationNumber = reservationNumber;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:@""forKey:@"KUNNR"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PASSWORD"];
        [ApplicationProperties setUser:nil];
        [[ApplicationProperties getUser] setPassword:@""];
        [[ApplicationProperties getUser] setUsername:@""];
        [[ApplicationProperties getUser] setIsLoggedIn:NO];
        
        
        [self performSegueWithIdentifier:@"toLoginVCSegue" sender:self];
//        [[[self navigationItem] rightBarButtonItem] setTitle:@"Giriş"];
        [[[self navigationItem] rightBarButtonItem] setImage:[UIImage imageNamed:@"userLoginBarButton"]];
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.frame.size.height / 3;
}


@end
