//
//  CarGroupManagerViewController.m
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupManagerViewController.h"

#import "CarGroupTableVC.h"
#import "EquipmentVC.h"
@interface CarGroupManagerViewController ()
@property(strong,nonatomic)IBOutlet UIView *rootView;
@property(strong,nonatomic)CarGroupTableVC *tableViewVC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerHeightConstraint;
@property(strong,nonatomic)CarGroup *selectedCarGroup;
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
    //    _tableViewVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"CarGroupTable"];
    [_tableViewVC setActiveCarGroup:[_carGroups objectAtIndex:0]];
    //  //  [self.pageViewController didMoveToParentViewController:self];
    
    //    [[NSNotificationCenter defaultCenter] addObserverForName:@"CarGroupSelected" object:nil queue:[NSOperationQueue new] usingBlock:^(NSNotification*note){
    //        dispatch_async(dispatch_get_main_queue(), ^(void){
    //
    //        });
    
    //    }];
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

//http://www.appcoda.com/uipageviewcontroller-storyboard-tutorial/
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
        // You do nothing because whatever page you thought
        // the book was on before the gesture started is still the correct page
        return;
    }
    
    // This is where you would know the page number changed and handle it appropriately
    // [self sendPageChangeNotification:YES];
    CarGroupViewController *temp =(CarGroupViewController*) [pvc.viewControllers objectAtIndex:0];
    NSUInteger index =temp.index;
    activeCarGroup = [self.carGroups objectAtIndex:index];
    [_tableViewVC setActiveCarGroup:[_carGroups objectAtIndex:index]];
    [[_tableViewVC tableView] reloadData];
    
}

#pragma mark  - tableview delegate datasource methods
/*
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
 // Return the number of sections.
 return 1;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 //best var price methodu cagiriliyordu  -aalpk
 return [activeCarGroup cars].count;
 }
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 static NSString *CellIdentifier = @"Cell";
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3.0f)];
 }
 
 ///custom init
 //    MenuTableCellView *menuTableCellView = [[MenuTableCellView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,[self tableView:tableView heightForRowAtIndexPath:indexPath]) andIndex:indexPath.row];
 //    [cell setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:72.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
 //    [cell addSubview:menuTableCellView];
 //    //    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
 NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"CarGroupTableCellView" owner:nil options:nil];
 CarGroupTableCellView *myCellView = nil;
 for (id xibObject in xibArray) {
 //Loop through array, check for the object we're interested in.
 if ([xibObject isKindOfClass:[CarGroupTableCellView class]]) {
 //Use casting to cast (id) to (MyCustomView *)
 myCellView = (CarGroupTableCellView *)xibObject;
 }
 }
 Car *cellCar = [[activeCarGroup cars] objectAtIndex:indexPath.row];
 [myCellView.officeName setText:cellCar.office.subOfficeName];
 [myCellView.payNowLabel setText:[cellCar.pricing.payLaterPrice stringValue]];
 
 //AALPK currency gelmiyor bak
 [myCellView.currencyLabel setText:@"TL"];
 if (indexPath.row == 0) {
 [myCellView.topBoarder setHidden:NO];
 }else{
 [myCellView.topBoarder setHidden:YES];
 }
 [cell addSubview:myCellView];
 [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
 return cell;
 }
 
 
 
 
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 
 Car*selectedCar = [[activeCarGroup getBestCarsWithFilter:@"Fiyat"] objectAtIndex:indexPath.row];
 //aalpk burası duzeltilicek sonra yapıya bakmak laızm
 [activeCarGroup setPayLaterPrice:selectedCar.pricing.payLaterPrice];
 //
 [self.reservation setSelectedCarGroup:activeCarGroup];
 [self.reservation setCheckOutOffice:selectedCar.office];
 if ([[ApplicationProperties getUser] isLoggedIn]) {
 //ek ekipman direk ama simdilik rez summary sayfası
 ReservationSummaryViewController *summaryVC = [[ReservationSummaryViewController alloc] initWithReservation:self.reservation];
 [[self navigationController] pushViewController:summaryVC animated:YES];
 }else{
 //minimum bilgiler
 MinimumInfoVC * minInfoVC = [[MinimumInfoVC alloc] initWithReservation:self.reservation];
 [[self navigationController] pushViewController:minInfoVC animated:YES];
 }
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 return 70.0f;
 }
 
 */
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
        User *tempUser = [ApplicationProperties getUser];
        
        EquipmentVC *additionalEquipmentsVC = (EquipmentVC*)segue.destinationViewController;
        [additionalEquipmentsVC setIsYoungDriver:[CarGroup checkYoungDriverAddition:_tableViewVC.activeCarGroup andBirthday:tempUser.birthday andLicenseDate:tempUser.driversLicenseDate]];
        [additionalEquipmentsVC setReservation:_reservation];
    }
}

- (void)carGroupSelected:(CarGroup*)aCarGroup withOffice:(Office*)anOffice{
    _reservation.checkOutOffice = anOffice;
    _reservation.selectedCarGroup = aCarGroup;
    [self performSegueWithIdentifier:@"toAdditionalEquipmentSegue" sender:self];
}

@end
