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
    if ((index == 0) ) {
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

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self getAdditionalEquipmentsFromSAP];
        [self getCarSelectionPrice];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showAlertForYoungDriver];
            if (_additionalEquipments.count > 0) {
                [self performSegueWithIdentifier:@"toAdditionalEquipmentSegue" sender:self];
            }
        });
    });
}

- (void)showCampaignVC{
    [self performSegueWithIdentifier:@"toCampaignVCSegue" sender:self];
}

#pragma mark - custom methods
-(void)getAdditionalEquipmentsFromSAP {
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_KDK_GET_EQUIPMENT_LIST"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        [handler addImportParameter:@"IMPP_MSUBE" andValue:self.reservation.checkOutOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_DSUBE" andValue:self.reservation.checkInOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_LANGU" andValue:@"T"];
        [handler addImportParameter:@"IMPP_GRPKOD" andValue:self.reservation.selectedCarGroup.groupCode];
        [handler addImportParameter:@"IMPP_BEGDA" andValue:[dateFormatter stringFromDate:self.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDDA" andValue:[dateFormatter stringFromDate:self.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_BEGUZ" andValue:[timeFormatter stringFromDate:self.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDUZ" andValue:[timeFormatter stringFromDate:self.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_KANAL" andValue:@"40"];
        
        NSString *fikod = @"";
        NSString *kunnr = @"";
        
        if ([[ApplicationProperties getUser] isLoggedIn]) {
            fikod = [[ApplicationProperties getUser] priceCode];
            kunnr = [[ApplicationProperties getUser] kunnr];
        }
        
        [handler addImportParameter:@"IMPP_MUSNO" andValue:kunnr];
        [handler addImportParameter:@"IMPP_FIKOD" andValue:fikod];
        
        [handler addTableForReturn:@"EXPT_EKPLIST"];
        [handler addTableForReturn:@"EXPT_SIGORTA"];
        [handler addTableForReturn:@"EXPT_EKSURUCU"];
        [handler addTableForReturn:@"EXPT_EXPIRY"];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil)
        {
            NSDictionary *tables = [resultDict objectForKey:@"TABLES"];
            
            _additionalEquipments = [NSMutableArray new];
            _additionalEquipmentsFullList = [NSMutableArray new];
            
            NSDictionary *etExpiry = [tables objectForKey:@"ZSD_KDK_AYLIK_TAKSIT_ST"];
            NSMutableArray *etExpiryArray = [NSMutableArray new];
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            for (NSDictionary *tempDict in etExpiry) {
                ETExpiryObject *tempObject = [ETExpiryObject new];
                
                [tempObject setCarGroup:[tempDict valueForKey:@"ARAC_GRUBU"]];
                [tempObject setBeginDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_BASI"]]];
                [tempObject setEndDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_SONU"]]];
                [tempObject setCampaignID:[tempDict valueForKey:@"KAMPANYA_ID"]];
                [tempObject setBrandID:[tempDict valueForKey:@"MARKA_ID"]];
                [tempObject setModelID:[tempDict valueForKey:@"MODEL_ID"]];
                [tempObject setIsPaid:[tempDict valueForKey:@"ODENDI"]];
                [tempObject setCurrency:[tempDict valueForKey:@"PARA_BIRIMI"]];
                [tempObject setMaterialNo:[tempDict valueForKey:@"MALZEME"]];
                [tempObject setTotalPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                
                [_reservation.etExpiry addObject:tempObject];
            }
            
//            _reservation.etExpiry = etExpiryArray;
            
            NSDictionary *equipmentList = [tables objectForKey:@"ZPM_S_EKIPMAN_LISTE"];
            
            for (NSDictionary *tempDict in equipmentList)
            {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MATNR"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MUS_TANIMI"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"NETWR"]]];
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_MIKTAR"]]];
                
                if ([[ApplicationProperties getUser] isLoggedIn]) {
                    if ([[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                        NSString *fatTip = [tempDict valueForKey:@"FAT_TIP"];
                        
                        if (fatTip == nil || [fatTip isEqualToString:@""]) {
                            fatTip = @"P";
                        }
                        
                        [tempEquip setPaymentType:fatTip];
                    }
                }
                
                // Ata Cengiz 07.12.2014 corparate
                NSString *mandotaryEquipment = [tempDict valueForKey:@"ZORUNLU"];
                
                if ([mandotaryEquipment isEqualToString:@"X"]) {
                    [tempEquip setQuantity:1];
                    [tempEquip setIsRequired:YES];
                }
                else {
                    [tempEquip setQuantity:0];
                }
                
                [tempEquip setType:standartEquipment];
                [_additionalEquipments addObject:tempEquip];
                [_additionalEquipmentsFullList addObject:tempEquip];
            }
            
            NSDictionary *assuranceList = [tables objectForKey:@"ZMOB_KDK_S_SIGORTA"];
            
            for (NSDictionary *tempDict in assuranceList)
            {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                [tempEquip setType:additionalInsurance];
                
                // Ata Cengiz 07.12.2014 corparate
                NSString *mandotaryEquipment = [tempDict valueForKey:@"ZORUNLU"];
                
                if ([mandotaryEquipment isEqualToString:@"X"]) {
                    [tempEquip setQuantity:1];
                    [tempEquip setIsRequired:YES];
                }
                else {
                    [tempEquip setQuantity:0];
                }
                
                if ([[ApplicationProperties getUser] isLoggedIn]) {
                    if ([[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                        NSString *fatTip = [tempDict valueForKey:@"FAT_TIP"];
                        
                        if (fatTip == nil || [fatTip isEqualToString:@""]) {
                            fatTip = @"P";
                        }
                        [tempEquip setPaymentType:fatTip];
                    }
                }
                
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0020"] && tempEquip.price.floatValue > 0) //tek yön ücreti varsa hep 1 olacak
                {
                    [tempEquip setQuantity:1];
                    [tempEquip setIsRequired:YES];
                    [_additionalEquipments insertObject:tempEquip atIndex:0];
                    [_additionalEquipmentsFullList addObject:tempEquip];
                }
                
                // ARAÇ SEÇİM FARKI full list içinde var, ekrana gösterdiğimiz array de yok
                else if ([[tempEquip materialNumber] isEqualToString:@"HZM0031"])
                {
                    //eski ezervasyonlardan araç seçim farkı geliyomu kontrolü
                    NSPredicate *carSelectPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
                    NSArray *carSelectPredicateArray = [_reservation.additionalEquipments filteredArrayUsingPredicate:carSelectPredicate];
                    if (carSelectPredicateArray.count > 0)
                    {
                        [tempEquip setQuantity:1];
                        [tempEquip setIsRequired:YES];
                        [tempEquip setPrice:[[carSelectPredicateArray objectAtIndex:0] price]];
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                    else
                        [_additionalEquipmentsFullList addObject:tempEquip];
                }
                // EĞER GENÇ SÜRÜCÜ VARSA MAKSİMUM GÜVENCE EN ÜSTE EKLENİYO VE ZORUNLU OLUYO
                else if ([[tempEquip materialNumber]isEqualToString:@"HZM0012"])
                {
                    // eski ezervasyonlardan Maks.güvence geliyomu kontrolü
                    NSPredicate *maxSecurePredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0012"];
                    NSArray *maxSecurePredicateArray = [_reservation.additionalEquipments filteredArrayUsingPredicate:maxSecurePredicate];
                    
                    if (_isYoungDriver || maxSecurePredicateArray.count > 0)
                    {
                        [tempEquip setQuantity:1];
                        [tempEquip setIsRequired:YES];
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                    else
                    {
                        [_additionalEquipments addObject:tempEquip];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                }
                else
                {
                    [_additionalEquipments addObject:tempEquip];
                    [_additionalEquipmentsFullList addObject:tempEquip];
                }
            }
            
            NSDictionary *additionalEquipmentList = [tables objectForKey:@"ZMOB_KDK_S_EKSURUCU"];
            
            for (NSDictionary *tempDict in additionalEquipmentList) {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_ADET"]]];
                
                // Ata Cengiz 07.12.2014 corparate
                NSString *mandotaryEquipment = [tempDict valueForKey:@"ZORUNLU"];
                
                if ([mandotaryEquipment isEqualToString:@"X"]) {
                    [tempEquip setQuantity:1];
                    [tempEquip setIsRequired:YES];
                }
                else {
                    [tempEquip setQuantity:0];
                }
                
                if ([[ApplicationProperties getUser] isLoggedIn]) {
                    if ([[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                        NSString *fatTip = [tempDict valueForKey:@"FAT_TIP"];
                        
                        if (fatTip == nil || [fatTip isEqualToString:@""]) {
                            fatTip = @"P";
                        }
                        
                        [tempEquip setPaymentType:fatTip];
                    }
                }
                
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0004"])
                    [tempEquip setType:additionalDriver];
                else
                    [tempEquip setType:additionalInsurance];
                
                // GENÇ SÜRÜCÜ full list içinde var, ekrana gösterdiğimiz array de yok
                // GENÇ SÜRÜCÜ eklenince silinmemesi için isRequired = YES
                // GENÇ SÜRÜCÜ 1'den fazla ekleyememesi için MaxQuantity = 1
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0007"])
                {
                    // eski ezervasyonlardan genç sürücü geliyomu kontrolü
                    NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0007"];
                    NSArray *equipmentPredicateArray = [_reservation.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
                    
                    if (_isYoungDriver || equipmentPredicateArray.count > 0)
                    {
                        [tempEquip setIsRequired:YES];
                        [tempEquip setQuantity:1];
                        [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                    else
                        [_additionalEquipmentsFullList addObject:tempEquip];
                }
                else
                {
                    NSPredicate *tempPredicate = [NSPredicate predicateWithFormat:@"winterTire=%@",@"X"];
                    NSArray *tempPredicateArray = [_reservation.selectedCarGroup.cars filteredArrayUsingPredicate:tempPredicate];
                    if ([[tempEquip materialNumber] isEqualToString:@"HZM0014"] && tempPredicateArray.count == 0) {
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                    else
                    {
                        [_additionalEquipments addObject:tempEquip];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
}

- (void)getCarSelectionPrice
{
    [_carSelectionArray removeAllObjects];
    for (Car *tempCar in _reservation.selectedCarGroup.cars)
    {
        //AKEREMB - renkleriyle beraber araçları gösterelim diye kontrolü kaldırdım
        [_carSelectionArray addObject:tempCar];
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
