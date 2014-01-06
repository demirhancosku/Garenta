//
//  CarGroupManagerViewController.m
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupManagerViewController.h"
#import "CarGroupTableCellView.h"
#import "MinimumInfoVC.h"
#import "ReservationSummaryViewController.h"
@interface CarGroupManagerViewController ()

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
    reservation = aReservation;
    carGroups = someCarGroups;
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self prepareScreen];
}

- (void)prepareScreen{

    
    UILabel *officeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [officeLabel setBackgroundColor:[ApplicationProperties getGrey]];
    [officeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f]];
    [officeLabel setText:reservation.checkOutOffice.subOfficeName];
    [officeLabel setFrame:CGRectMake(0, 0, self.view.frame.size.width, [officeLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f ]].height)];
    [officeLabel setTextAlignment:NSTextAlignmentCenter];
    [[self view] addSubview:officeLabel];
    //1- groupPageView
    groupPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [[groupPageVC view] setFrame:CGRectMake(0, officeLabel.frame.size.height, self.view.frame.size.width, self.view.frame.size.height / 2 - officeLabel.frame.size.height)];
    [groupPageVC setDelegate:self];
    [groupPageVC setDataSource:self];
    [self initVCsWithCars];
   
    [groupPageVC setViewControllers:@[[groupVCs objectAtIndex:0]] direction:(UIPageViewControllerNavigationDirectionForward|UIPageViewControllerNavigationDirectionReverse) animated:YES completion:^(BOOL completion){
        
    }];
    [[self view] addSubview:groupPageVC.view];
    //2-tableview
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height /2)-(self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height), self.view.frame.size.width, self.view.frame.size.height /2) style:UITableViewStylePlain];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    activeCarGroup = [carGroups objectAtIndex:0];
    [[self view] addSubview:tableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVCsWithCars{
    groupVCs = [[NSMutableArray alloc] init];
    CarGroupViewController *carGroupVC ;
    for (int sayac = 0; sayac<carGroups.count; sayac++) {
        carGroupVC = [[CarGroupViewController alloc] initWithFrame:groupPageVC.view.frame andCarGroups:[carGroups objectAtIndex:sayac]];
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
   
    CarGroupViewController *temp =(CarGroupViewController*)viewController;
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
    CarGroupViewController *temp =(CarGroupViewController*) [pvc.viewControllers objectAtIndex:0];//daha mal bi yontem gormedm valla mal bunu yazanlar
    NSUInteger index =temp.index;
    activeCarGroup = [carGroups objectAtIndex:index];
    [tableView reloadData];
}

#pragma mark  - tableview delegate datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [activeCarGroup getBestCarsWithFilter:@"Fiyat"].count;
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
    Car *cellCar = [[activeCarGroup getBestCarsWithFilter:@"Fiyat"] objectAtIndex:indexPath.row];
    [myCellView.officeName setText:cellCar.office.subOfficeName];
    [myCellView.payNowLabel setText:cellCar.payLaterPrice];
    
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
    [activeCarGroup setPayLaterPrice:selectedCar.payLaterPrice];
    //
    [reservation setSelectedCarGroup:activeCarGroup];
    [reservation setCheckOutOffice:selectedCar.office];
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        //ek ekipman direk ama simdilik rez summary sayfası
        ReservationSummaryViewController *summaryVC = [[ReservationSummaryViewController alloc] initWithReservation:reservation];
        [[self navigationController] pushViewController:summaryVC animated:YES];
    }else{
        //minimum bilgiler
        MinimumInfoVC * minInfoVC = [[MinimumInfoVC alloc] initWithReservation:reservation];
        [[self navigationController] pushViewController:minInfoVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}



@end
