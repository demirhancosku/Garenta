//
//  CarGroupManagerViewController.m
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupManagerViewController.h"
#import "CampaignVC.h"
#import "CarGroupTableVC.h"
#import "EquipmentVC.h"
#import "MBProgressHUD.h"
#import "AdditionalEquipment.h"
#import "ETExpiryObject.h"
#import "CarGroupInfoVC.h"

@interface CarGroupManagerViewController ()
@property(strong,nonatomic)IBOutlet UIView *rootView;
@property(strong,nonatomic)CarGroupTableVC *tableViewVC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerHeightConstraint;
@property(strong,nonatomic)CarGroup *selectedCarGroup;
@property (strong,nonatomic)NSMutableArray *carSelectionArray;
@end

@implementation CarGroupManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithCarGroups:(NSMutableArray*)someCarGroups andReservartion:(Reservation*)aReservation{
    self= [super init];
    self.reservation = aReservation;
    self.carGroups = someCarGroups;
    
    return self;
}

- (id)init{
    self = [super init];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self initVCsWithCars];
    CGRect aFrame = CGRectMake(0, 0, _rootView.frame.size.width, _rootView.frame.size.height);
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self.pageViewController.view setFrame:aFrame];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    [self.pageViewController setViewControllers:@[[groupVCs objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
    }];
    [self addChildViewController:self.pageViewController];
    [_rootView addSubview:_pageViewController.view];
    [_tableViewVC setActiveCarGroup:[_carGroups objectAtIndex:0]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"campaignButtonPressed" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        _reservation.selectedCarGroup = note.object;
        [self showCampaignVC];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"infoButtonPressed" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
//        _reservation.selectedCarGroup = note.object;
        [self showCarGroupInfoVC:note.object];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVCsWithCars{
    groupVCs = [[NSMutableArray alloc] init];
    CarGroupViewController *carGroupVC ;
    for (int sayac = 0; sayac<self.carGroups.count; sayac++) {
        carGroupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CarGroupView"];
        [carGroupVC setCarGroup:[self.carGroups objectAtIndex:sayac]];
        [[carGroupVC view] setFrame:CGRectMake(0, 0, _rootView.frame.size.width, _rootView.frame.size.height)];
        if (sayac == 0) {
            [carGroupVC setLeftArrowShouldHide:YES];
        }
        [carGroupVC setIndex:sayac];
        [groupVCs addObject:carGroupVC];
    }
    
    [carGroupVC setRightArrowShouldHide:YES];
}

- (void)initCarGroups{
    
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    CarGroupViewController *temp = (CarGroupViewController*)viewController;
    NSUInteger index = temp.index;
    if (index == 0 ) {
        return nil;
    }
    
    index--;
    
    return [groupVCs objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    CarGroupViewController *temp =(CarGroupViewController*)viewController;
    NSUInteger index = temp.index;
    
    if (index >= groupVCs.count -1 ) {
        return nil;
    }
    
    index++;
    
    return [groupVCs objectAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pvc didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    // If the page did not turn
    if (!completed)
    {
        return;
    }
    
    CarGroupViewController *temp =(CarGroupViewController*) [pvc.viewControllers objectAtIndex:0];
    NSUInteger index =temp.index;
    activeCarGroup = [self.carGroups objectAtIndex:index];
    [_tableViewVC setActiveCarGroup:[_carGroups objectAtIndex:index]];
    [[_tableViewVC tableView] reloadData];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"CarGroupTableVCEmbedSeugue"]){
        _tableViewVC = (CarGroupTableVC*)[segue destinationViewController];
        [_tableViewVC setDelegate:self];
        
        // AATAC aylık için
        if (_reservation.etExpiry.count > 0) {
            [_tableViewVC setIsMontlyRent:YES];
        }
    }
    
    if ([segue.identifier isEqualToString:@"toAdditionalEquipmentSegue"]) {
        EquipmentVC *additionalEquipmentsVC = (EquipmentVC*)segue.destinationViewController;
        
        _reservation.selectedCar = nil;
        [additionalEquipmentsVC setIsYoungDriver:_isYoungDriver];
        [additionalEquipmentsVC setAdditionalEquipments:_additionalEquipments];
        [additionalEquipmentsVC setAdditionalEquipmentsFullList:_additionalEquipmentsFullList];
        [additionalEquipmentsVC setCarSelectionArray:_carSelectionArray];
        [additionalEquipmentsVC setReservation:_reservation];
    }
    
    if ([[segue identifier] isEqualToString:@"toCampaignVCSegue"]) {
        [(CampaignVC*)[segue destinationViewController] setCarGroup:_reservation.selectedCarGroup];
        [(CampaignVC*)[segue destinationViewController] setReservation:_reservation];
    }
    
    if ([segue.identifier isEqualToString:@"carGroupInfoSegue"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(280, 200);
        
        [(CarGroupInfoVC *)[segue destinationViewController] setCarGroup:_tableViewVC.activeCarGroup];
        
        popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES];
        popoverController.delegate = self;
    }
}

- (void)carGroupSelected:(CarGroup*)aCarGroup withOffice:(Office*)anOffice{
    _reservation.checkOutOffice = anOffice;
    _reservation.selectedCarGroup = aCarGroup;
    _reservation.campaignObject = nil;
    _reservation.additionalEquipments = nil;
    _reservation.additionalDrivers = nil;
    
    _carSelectionArray = [NSMutableArray new];
    
    User *tempUser = [ApplicationProperties getUser];
    _isYoungDriver = [CarGroup checkYoungDriverAddition:_tableViewVC.activeCarGroup andBirthday:tempUser.birthday andLicenseDate:tempUser.driversLicenseDate];

    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self getAdditionalEquipments]; //AdditionalEquipments içinde buluyoruz ekipmanları
        [self getCarSelectionPrice];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [self showAlertForYoungDriver];
            if (_additionalEquipments.count > 0) {
                [self performSegueWithIdentifier:@"toAdditionalEquipmentSegue" sender:self];
            }
        });
    });
}

- (void)showCampaignVC{
    
    CampaignVC *temp = [[UIStoryboard storyboardWithName:@"MainStoryBoard" bundle:NULL]
     instantiateViewControllerWithIdentifier:@"campaignVC"];

    temp.reservation = _reservation;
    temp.carGroup = _reservation.selectedCarGroup;
    [[self navigationController] pushViewController:temp animated:YES];
    
//    [self performSegueWithIdentifier:@"toCampaignVCSegue" sender:self];
}

- (void)showCarGroupInfoVC:(id)sender
{
    [self performSegueWithIdentifier:@"carGroupInfoSegue" sender:sender];
}

#pragma mark - custom methods
-(void)getAdditionalEquipments {
    
    NSDictionary *temp = [AdditionalEquipment getAdditionalEquipmentsFromSAP:_reservation andIsYoungDriver:_isYoungDriver];
    _additionalEquipments = [temp valueForKey:@"currentList"];
    _additionalEquipmentsFullList = [temp valueForKey:@"fullList"];
    
    _reservation.additionalFullEquipments = _additionalEquipmentsFullList;
}

- (void)getCarSelectionPrice
{
//    [_carSelectionArray removeAllObjects];
//    for (Car *tempCar in _reservation.selectedCarGroup.cars)
//    {
//        //AKEREMB - renkleriyle beraber araçları gösterelim diye kontrolü kaldırdım
//        [_carSelectionArray addObject:tempCar];
//    }
    
    [_carSelectionArray removeAllObjects];
    for (Car *tempCar in _reservation.selectedCarGroup.cars)
    {
        //AKEREMB - renkleriyle beraber araçları gösterelim diye kontrolü kaldırdım
        //        [_carSelectionArray addObject:tempCar];
        
        if ([_carSelectionArray count] == 0) {
            [_carSelectionArray addObject:tempCar];
        }
        else
        {
            BOOL isNewModelId = YES;
            
            for (int i = 0; i < [_carSelectionArray count]; i++) {
                if ([[[_carSelectionArray objectAtIndex:i] brandId] isEqualToString:tempCar.brandId] && [[[_carSelectionArray objectAtIndex:i] modelId] isEqualToString:tempCar.modelId] && [[[_carSelectionArray objectAtIndex:i] colorCode] isEqualToString:tempCar.colorCode] && [[[_carSelectionArray objectAtIndex:i] winterTire] isEqualToString:tempCar.winterTire]) {
                    isNewModelId = NO;
                    break;
                }
            }
            
            if (isNewModelId) {
                [_carSelectionArray addObject:tempCar];
            }
        }
    }
}

- (void)showAlertForYoungDriver
{
    NSArray *filterResult;
    NSPredicate *youngDriverPredicate;
    youngDriverPredicate = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0007"];
    filterResult = [_additionalEquipments filteredArrayUsingPredicate:youngDriverPredicate];
    
    if (filterResult.count > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Genç sürücü seçtiğiniz için maksimum güvence hizmeti de eklenmiştir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

@end
