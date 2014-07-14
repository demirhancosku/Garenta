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

@interface EquipmentVC ()<WYPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *additionalEquipmentsTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (strong,nonatomic)NSMutableArray *additionalEquipments;
@property (strong,nonatomic)WYPopoverController *myPopoverController;
- (IBAction)plusButtonPressed:(id)sender;
- (IBAction)minusButtonPressed:(id)sender;
- (IBAction)selectCarPressed:(id)sender;
- (IBAction)resumePressed:(id)sender;
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
    [_totalPriceLabel setText:@"0"];
    [[LoaderAnimationVC uniqueInstance] playAnimation:self.view];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        [self getAdditionalEquipmentsFromSAP];
    });
    [[NSNotificationCenter defaultCenter] addObserverForName:@"carSelected" object:nil queue:[NSOperationQueue new] usingBlock:^(NSNotification*note){
        [self recalculate];
        [_additionalEquipmentsTableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableviews

- (int)dataSourceCount{
    //son satir aracımı seçmek istiyorum.
    return _additionalEquipments.count+1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self dataSourceCount];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row <_additionalEquipments.count) {
        return [self additionalEquipmentTableViewCellForIndex:indexPath.row fromTable:tableView];
    }
    int newIndex = indexPath.row-_additionalEquipments.count;
    switch (newIndex) {
        case 0:
            //aracımı seçcem!
            return [self selectCarTableView:tableView];
            break;
            
        default:
            break;
    }
    return nil;
}

- (SelectCarTableViewCell*)selectCarTableView:(UITableView*)tableView{
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
        [[cell carLabel] setText:@""];
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
    [[cell itemNameLabel] setText:additionalEquipment.description];
    [[cell itemPriceLabel] setText:[NSString stringWithFormat:@"%@",additionalEquipment.price]];
    [[cell itemQuantityLabel] setText:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]];
    [[cell itemTotalPriceLabel] setText:[NSString stringWithFormat:@"%i",(additionalEquipment.quantity*[additionalEquipment.price intValue])]];
    
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
    if (indexPath.row == ([self dataSourceCount] - 1)) {
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
-(void)getAdditionalEquipmentsFromSAP{
    [ApplicationProperties configureAdditionalEquipmentService];
    AdditionalEquipmentServiceV0 *aService = [[AdditionalEquipmentServiceV0 alloc] init];
    NSDateFormatter *dateformater = [NSDateFormatter new];
    [dateformater setDateFormat:@"HH:mm"];
    [aService setImppBegda:_reservation.checkOutTime];
    [aService setImppBeguz:[dateformater stringFromDate:_reservation.checkOutTime]];
    [aService setImppEnduz:[dateformater stringFromDate:_reservation.checkInTime]];
    [aService setImppEndda:_reservation.checkInTime];
    [aService setImppFikod:@" "];
    [aService setImppGrpkod:_reservation.selectedCarGroup.groupCode];
    [aService setImppMsube:_reservation.checkOutOffice.mainOfficeCode];
    [aService setImppDsube:_reservation.checkInOffice.mainOfficeCode];
    [aService setImppLangu:@"T"];
    [aService setImppMarkaid:@" "];
    [aService setImppModelid:@" "];
    [aService setImppKampid:@" "];
    [aService setImppSozno:@" "];
    [aService setImppRezno:@" "];
    
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoadAdditionalEquipmentServiceCompletedNotification object:nil queue:operationQueue usingBlock:^(NSNotification *notification){
        
        AdditionalEquipmentServiceV0 *response = [notification userInfo][kResponseItem];
        [self parseEquipmentService:response];
    }];
    [[ZGARENTA_EKHIZMET_SRVRequestHandler uniqueInstance] loadAdditionalEquipmentService:aService expand:YES];
    
}
- (void)parseEquipmentService:(AdditionalEquipmentServiceV0*)service{
    _additionalEquipments = [NSMutableArray new];
    AdditionalEquipment *tempEquipment;
    for (EXPT_EKPLISTV0 *tempEkplist in service.EXPT_EKPLISTSet) {
        tempEquipment = [AdditionalEquipment new];
        [tempEquipment setMaterialNumber:tempEkplist.Matnr];
        [tempEquipment setDescription:tempEkplist.MusTanimi];
        [tempEquipment setPrice:tempEkplist.Netwr];
        [tempEquipment setMaxQuantity:tempEkplist.MaxMiktar];
        [tempEquipment setQuantity:0];
        [tempEquipment setType:standartEquipment];
        [_additionalEquipments addObject:tempEquipment];
    }
    
    for (EXPT_SIGORTAV0 *tempSigorta in service.EXPT_SIGORTASet) {
        tempEquipment = [AdditionalEquipment new];
        [tempEquipment setMaterialNumber:tempSigorta.Malzeme];
        [tempEquipment setDescription:tempSigorta.Maktx];
        [tempEquipment setPrice:tempSigorta.Tutar];
        [tempEquipment setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
        [tempEquipment setQuantity:0];
        [tempEquipment setType:additionalInsurance];
        [_additionalEquipments addObject:tempEquipment];
    }
    for (EXPT_EKSURUCUV0 *tempEkSurucu in service.EXPT_EKSURUCUSet) {
        tempEquipment = [AdditionalEquipment new];
        [tempEquipment setMaterialNumber:tempEkSurucu.Malzeme];
        [tempEquipment setDescription:tempEkSurucu.Maktx];
        [tempEquipment setPrice:tempEkSurucu.Tutar];
        [tempEquipment setMaxQuantity:[NSDecimalNumber decimalNumberWithString:tempEkSurucu.MaxAdet]];
        [tempEquipment setQuantity:0];
        [tempEquipment setType:additionalDriver];
        [_additionalEquipments addObject:tempEquipment];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_additionalEquipmentsTableView reloadData];
        [[LoaderAnimationVC uniqueInstance] stopAnimation];
    });
    
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
- (IBAction)plusButtonPressed:(id)sender {
    AdditionalEquipment*additionalEquipment = [_additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
    if (additionalEquipment.type == additionalDriver) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[(UIButton*)sender tag] inSection:0];
        [self.additionalEquipmentsTableView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:NO];
        
        [self performSegueWithIdentifier:@"toAdditionalDriverVCSegue" sender:sender];
    }else{
        int newValue = [additionalEquipment quantity]+1;
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
        
    }
    
    if ([[segue identifier] isEqualToString:@"toAdditionalDriverVCSegue"]) {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(320, self.view.frame.size.width);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        self.myPopoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionDown animated:YES];
        self.myPopoverController.delegate = self;
        
//        [(AdditionalDriverVC*)segue.destinationViewController 
    }
}


@end
