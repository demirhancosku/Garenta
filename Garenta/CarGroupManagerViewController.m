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
    [_tableViewVC setActiveCarGroup:[_carGroups objectAtIndex:0]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"campaignButtonPressed" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        //        [[self myPopoverController] dismissPopoverAnimated:YES];
        
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
        User *tempUser = [ApplicationProperties getUser];
        
        EquipmentVC *additionalEquipmentsVC = (EquipmentVC*)segue.destinationViewController;
        [additionalEquipmentsVC setIsYoungDriver:[CarGroup checkYoungDriverAddition:_tableViewVC.activeCarGroup andBirthday:tempUser.birthday andLicenseDate:tempUser.driversLicenseDate]];
        
        _reservation.selectedCar = nil;
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
    [self performSegueWithIdentifier:@"toAdditionalEquipmentSegue" sender:self];
}

- (void)showCampaignVC{
    [self performSegueWithIdentifier:@"toCampaignVCSegue" sender:self];
}

@end
