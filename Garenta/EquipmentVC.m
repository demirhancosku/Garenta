//
//  EquipmentVC.m
//  Garenta
//
//  Created by Kerem Balaban on 23.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "EquipmentVC.h"
#import "AdditionalEquipmentTableViewCell.h"
#import "SelectCarTableViewCell.h"
#import "ZGARENTA_EKHIZMET_SRVRequestHandler.h"
#import "ZGARENTA_EKHIZMET_SRVServiceV0.h"
#import "AdditionalEquipment.h"
#import "ReservationSummaryVC.h"
#import "UserInfoTableViewController.h"
#import "CarSelectionVC.h"
#import "AdditionalDriverVC.h"
#import "MBProgressHUD.h"

@interface EquipmentVC ()<WYPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *additionalEquipmentsTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (strong,nonatomic)NSMutableArray *additionalEquipments;
@property (strong,nonatomic)WYPopoverController *myPopoverController;
@property (strong,nonatomic)NSMutableArray *carSelectionArray;
@property (strong,nonatomic) AdditionalEquipment *tempEquipment;

- (IBAction)plusButtonPressed:(id)sender;
- (IBAction)minusButtonPressed:(id)sender;
- (IBAction)selectCarPressed:(id)sender;
- (IBAction)resumePressed:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;
@end

@implementation EquipmentVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self clearAllEquipments];
    _carSelectionArray = [NSMutableArray new];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self getAdditionalEquipmentsFromSAP];
        [self getCarSelectionPrice];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_additionalEquipmentsTableView reloadInputViews];
            [_additionalEquipmentsTableView reloadData];
        });
    });
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"carSelected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [self recalculate];
        [_additionalEquipmentsTableView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"additionalDriverAdded" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [[self myPopoverController] dismissPopoverAnimated:YES];
        [self recalculate];
        [_additionalEquipmentsTableView reloadData];
    }];
    
}

- (void)clearAllEquipments {
    [_totalPriceLabel setText:@"0"];
    _reservation.selectedCar = nil;
    _reservation.additionalDrivers = nil;
    _reservation.additionalEquipments = nil;
}

- (IBAction)infoButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"toEquipmentInfoSegue" sender:sender];
}


- (void)getCarSelectionPrice
{
    for (Car *tempCar in _reservation.selectedCarGroup.cars)
    {
        if ([_carSelectionArray count] == 0) {
            [_carSelectionArray addObject:tempCar];
        }
        else {
            BOOL isNewModelId = YES;
            
            for (int i = 0; i < [_carSelectionArray count]; i++) {
                if ([[[_carSelectionArray objectAtIndex:i] modelId] isEqualToString:tempCar.modelId]) {
                    isNewModelId = NO;
                    break;
                }
            }
            
            if (isNewModelId) {
                [_carSelectionArray addObject:tempCar];
            }
        }
    }
    
    [_additionalEquipmentsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableviews

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _additionalEquipments.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
            //aracımı seçcem!
            return [self selectCarTableView:tableView];
            break;
            
        default:
            break;
    }
    
    if (indexPath.row - 1 <_additionalEquipments.count) {
        return [self additionalEquipmentTableViewCellForIndex:indexPath.row - 1 fromTable:tableView];
    }

    return nil;
}

- (SelectCarTableViewCell*)selectCarTableView:(UITableView*)tableView {
    
    SelectCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCarCell"];
    if (!cell) {
        cell = [SelectCarTableViewCell new];
    }
    
    [cell.mainText setText: @"Aracımı Seçmek İstiyorum"];
    if (_reservation.selectedCar == nil) {
        [cell.selectButton setImage:[UIImage imageNamed:@"unticked_button.png"] forState:UIControlStateNormal];
        //hiç görünmesin daha iyi ya çirkin oldu boşu
        [cell.selectButton setHidden:YES];
        [cell.priceLabel setText:@"0.00"];
        
        if ([_carSelectionArray count] == 0)
            [[cell carLabel] setText:@""];
        else
        {
            Car *car = [_carSelectionArray objectAtIndex:0];
            [[cell carLabel] setText:[NSString stringWithFormat:@"Sadece %.02f TL ödeyerek aracınızı seçebilirsiniz.",[car.pricing.carSelectPrice floatValue]]];
        }
    }else{
        [cell.selectButton setImage:[UIImage imageNamed:@"ticked_button.png"] forState:UIControlStateNormal];
        [cell.selectButton setHidden:NO];
        [cell.priceLabel setText:[NSString stringWithFormat:@"%.02f",[_reservation.selectedCar.pricing.carSelectPrice floatValue]]];
        [[cell carLabel] setText:[NSString stringWithFormat:@"%@ %@",_reservation.selectedCar.brandName, _reservation.selectedCar.modelName]];
    }
    return cell;
}

- (AdditionalEquipmentTableViewCell*)additionalEquipmentTableViewCellForIndex:(int)index fromTable:(UITableView*)tableView{
    AdditionalEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"additionalEquipmentCell"];
    if (!cell) {
        cell = [AdditionalEquipmentTableViewCell new];
    }
    AdditionalEquipment *additionalEquipment = [_additionalEquipments objectAtIndex:index];
    
    [[cell minusButton] setTag:index];
    [[cell plusButton] setTag:index];
    [[cell infoButton] setTag:index];
    [[cell itemNameLabel] setText:additionalEquipment.materialDescription];
    [[cell itemPriceLabel] setText:[NSString stringWithFormat:@"%.02f",additionalEquipment.price.floatValue]];
    [[cell itemQuantityLabel] setText:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]];
    [[cell itemTotalPriceLabel] setText:[NSString stringWithFormat:@"%.02f",(additionalEquipment.quantity*[additionalEquipment.price floatValue])]];
    
    [[cell textLabel] setNumberOfLines:0];
    
    if ([additionalEquipment.materialInfo isEqualToString:@""] || additionalEquipment.materialInfo == nil)
        [cell.infoButton setHidden:YES];
    else
        [cell.infoButton setHidden:NO];
    
    //hide buttons wrt max min values
    if (additionalEquipment.quantity <= 0) {
        [[cell minusButton] setHidden:YES];
    }else{
        [[cell minusButton] setHidden:NO];
    }
    if ([additionalEquipment.maxQuantity intValue] != 0 && additionalEquipment.quantity == [additionalEquipment.maxQuantity intValue]) {
        [[cell plusButton] setHidden:YES];
    }else{
        [[cell plusButton] setHidden:NO];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
// aracımı seçmek istiyorum en yukarı alındı
//    if (indexPath.row == ([self dataSourceCount] - 1))
    if (indexPath.row == 0)
    {
        if (_reservation.selectedCar == nil) {
            [self performSegueWithIdentifier:@"toCarSelectionVCSegue" sender:self];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Onay" message:
                                  [NSString stringWithFormat:@"%@ %@ modeli rezervasyonunuzdan çıkarmak istediğinize emin misiniz?",_reservation.selectedCar.brandName,_reservation.selectedCar.modelName]	 delegate:self cancelButtonTitle:@"Hayır" otherButtonTitles: @"Evet",nil];
            [alert show];
        }
    }
    
}

#pragma mark - uialertview methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //NO
            break;
        case 1:
            //YES
            [_reservation setSelectedCar:nil];
            [_additionalEquipmentsTableView reloadData];
            break;
        default:
            break;
    }
}
#pragma mark - custom methods
-(void)getAdditionalEquipmentsFromSAP {
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_KDK_GET_EQUIPMENT_LIST"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"hh:mm:ss"];
        
        [handler addImportParameter:@"IMPP_MSUBE" andValue:self.reservation.checkOutOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_DSUBE" andValue:self.reservation.checkInOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_LANGU" andValue:@"T"];
        [handler addImportParameter:@"IMPP_GRPKOD" andValue:self.reservation.selectedCarGroup.groupCode];
        [handler addImportParameter:@"IMPP_BEGDA" andValue:[dateFormatter stringFromDate:self.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDDA" andValue:[dateFormatter stringFromDate:self.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_BEGUZ" andValue:[timeFormatter stringFromDate:self.reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDUZ" andValue:[timeFormatter stringFromDate:self.reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_KANAL" andValue:@"40"];
        
        [handler addTableForReturn:@"EXPT_EKPLIST"];
        [handler addTableForReturn:@"EXPT_SIGORTA"];
        [handler addTableForReturn:@"EXPT_EKSURUCU"];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil)
        {
            NSDictionary *tables = [resultDict objectForKey:@"TABLES"];
            
            _additionalEquipments = [NSMutableArray new];
            
            NSDictionary *equipmentList = [tables objectForKey:@"ZPM_S_EKIPMAN_LISTE"];
            
            for (NSDictionary *tempDict in equipmentList) {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MATNR"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MUS_TANIMI"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"NETWR"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_MIKTAR"]]];
                [tempEquip setQuantity:0];
                [tempEquip setType:standartEquipment];
                [_additionalEquipments addObject:tempEquip];
            }
            
            NSDictionary *assuranceList = [tables objectForKey:@"ZMOB_KDK_S_SIGORTA"];
            
            for (NSDictionary *tempDict in assuranceList) {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                [tempEquip setQuantity:0];
                [tempEquip setType:additionalInsurance];
                [_additionalEquipments addObject:tempEquip];
            }
            
            NSDictionary *additionalEquipmentList = [tables objectForKey:@"ZMOB_KDK_S_EKSURUCU"];
            
            for (NSDictionary *tempDict in additionalEquipmentList) {
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_ADET"]]];
                [tempEquip setQuantity:0];
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0004"])
                    [tempEquip setType:additionalDriver];
                else
                    [tempEquip setType:additionalInsurance];
                
                [_additionalEquipments addObject:tempEquip];
            }
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
}

- (IBAction)selectCarPressed:(id)sender {
}

- (IBAction)resumePressed:(id)sender {
    
    if ([(User*)[ApplicationProperties getUser] isLoggedIn]) {
        [self performSegueWithIdentifier:@"toReservationSummaryVCSegue" sender:self];
    }else{
        [self performSegueWithIdentifier:@"toUserInfoVCSegue" sender:self];
    }
}

- (void)recalculate{
    [_additionalEquipmentsTableView reloadData];
    float total = 0;
    for (AdditionalEquipment*temp in _additionalEquipments) {
        total = total + ([temp.price floatValue] * temp.quantity);
    }
    if (_reservation.selectedCar) {
        total = total + [_reservation.selectedCar.pricing.carSelectPrice floatValue];
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_totalPriceLabel setText:[NSString stringWithFormat:@"%.02f",total]];
    });
    
}


#pragma mark - IBActions
- (IBAction)plusButtonPressed:(id)sender
{
    AdditionalEquipment*additionalEquipment = [_additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
    if (additionalEquipment.type == additionalDriver) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[(UIButton*)sender tag] inSection:0];
        [self.additionalEquipmentsTableView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:NO];
        
        [self performSegueWithIdentifier:@"toAdditionalDriverVCSegue" sender:sender];
    }
    else
    {
        if ([[additionalEquipment materialNumber] isEqualToString:@"HZM0012"]) {
            
            for (AdditionalEquipment *temp in _additionalEquipments) {
                if (([[temp materialNumber] isEqualToString:@"HZM0011"] || [[temp materialNumber] isEqualToString:@"HZM0024"] || [[temp materialNumber] isEqualToString:@"HZM0009"] || [[temp materialNumber] isEqualToString:@"HZM0006"]) && [temp quantity] == 1) {
                    [temp setQuantity:0];
                }
            }
        }
        else {
            BOOL isMaximumSafetyAdded = NO;
            
            for (AdditionalEquipment *temp in _additionalEquipments) {
                if ([[temp materialNumber] isEqualToString:@"HZM0012"] && [temp quantity] == 1) {
                    isMaximumSafetyAdded = YES;
                }
            }
            
            if (isMaximumSafetyAdded) {
                if ([[additionalEquipment materialNumber] isEqualToString:@"HZM0011"] || [[additionalEquipment materialNumber] isEqualToString:@"HZM0024"] || [[additionalEquipment materialNumber] isEqualToString:@"HZM0009"] || [[additionalEquipment materialNumber] isEqualToString:@"HZM0006"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Eklemiş olduğunuz maksimum güvence bu hizmeti kapsamaktadır" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
            }
        }
        
        int newValue = [additionalEquipment quantity] + 1;
        [additionalEquipment setQuantity:newValue];
        [self recalculate];
    }
}

- (IBAction)minusButtonPressed:(id)sender {
    
    AdditionalEquipment*additionalEquipment = [_additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
    if (additionalEquipment.type ==additionalDriver) {
        
    }else{
        int newValue = [additionalEquipment quantity]-1;
        [additionalEquipment setQuantity:newValue];
        [self recalculate];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [_reservation setAdditionalEquipments:_additionalEquipments];
    if ([[segue identifier] isEqualToString:@"toReservationSummaryVCSegue"]) {
        [(ReservationSummaryVC*)[segue destinationViewController] setReservation:_reservation];
    }
    if ([[segue identifier] isEqualToString:@"toUserInfoVCSegue"]) {
        [(UserInfoTableViewController*)  [segue destinationViewController] setReservation:_reservation];
        
    }
    if ([[segue identifier] isEqualToString:@"toCarSelectionVCSegue"]) {
        [(CarSelectionVC*)  [segue destinationViewController] setReservation:_reservation];
        [(CarSelectionVC*)  [segue destinationViewController] setCarSelectionArray:_carSelectionArray];
    }
    
    if ([[segue identifier] isEqualToString:@"toAdditionalDriverVCSegue"]) {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(320, self.view.frame.size.width);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        self.myPopoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionDown animated:YES];
        self.myPopoverController.delegate = self;
        
        [(AdditionalDriverVC*)segue.destinationViewController setReservation:self.reservation];
        for (AdditionalEquipment *tempEquipment in self.additionalEquipments) {
            if (tempEquipment.type == additionalDriver) {
                [(AdditionalDriverVC*)segue.destinationViewController setMyDriver:tempEquipment];
                break;
            }
        }
    }
    
    if ([[segue identifier] isEqualToString:@"toEquipmentInfoSegue"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(280, 75);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        AdditionalEquipment *tempEquipment = [_additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
       [(AdditionalEquipmentInfoVC *)segue.destinationViewController setInfoText:tempEquipment.materialInfo];
    
        self.myPopoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        self.myPopoverController.delegate = self;
    
    }
}


@end
