//
//  CarGroupManagerViewController.m
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupManagerViewController.h"

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
- (id)initWithOffices:(NSMutableArray*)someOffices andReservartion:(Reservation*)aReservation{
    self= [super init];
    reservation = aReservation;
    offices = someOffices;
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self prepareScreen];
}

- (void)prepareScreen{
    [[self view] setBackgroundColor:[UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f]];
    
    UILabel *officeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [officeLabel setBackgroundColor:[UIColor clearColor]];
    [officeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f]];
    [officeLabel setText:reservation.checkOutOffice.subOfficeName];
    [officeLabel setFrame:CGRectMake(0, 0, self.view.frame.size.width, [officeLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f ]].height)];
    [officeLabel setTextAlignment:NSTextAlignmentCenter];
    [[self view] addSubview:officeLabel];
    
    groupPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [[groupPageVC view] setFrame:CGRectMake(0, officeLabel.frame.size.height, self.view.frame.size.width, self.view.frame.size.height / 2 - officeLabel.frame.size.height)];
    [groupPageVC setDelegate:self];
    [groupPageVC setDataSource:self];
    [self initVCsWithCars];
   
    [groupPageVC setViewControllers:@[[groupVCs objectAtIndex:0]] direction:(UIPageViewControllerNavigationDirectionForward|UIPageViewControllerNavigationDirectionReverse) animated:YES completion:^(BOOL completion){
        
    }];
    [[self view] addSubview:groupPageVC.view];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVCsWithCars{
    groupVCs = [[NSMutableArray alloc] init];
    CarGroupViewController *carGroupVC ;
    for (int sayac = 0; sayac<5; sayac++) {
        carGroupVC = [[CarGroupViewController alloc] initWithFrame:groupPageVC andCarGroups:nil];
        [carGroupVC setIndex:sayac];
        [groupVCs addObject:carGroupVC];
    }
}

- (void)initCarGroups{
    for (Office *tempOffice in offices) {
        
    }
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
//    return [self viewControllerAtIndex:index];
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
//    if (index == [self.pageTitles count]) {
//        return nil;
//    }
//    return [self viewControllerAtIndex:index];
    return [groupVCs objectAtIndex:index];
}

- (CarGroupViewController *)viewControllerAtIndex:(NSUInteger)index
{
//    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
//        return nil;
//    }
    
    // Create a new view controller and pass suitable data.
//    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
//    pageContentViewController.imageFile = self.pageImages[index];
//    pageContentViewController.titleText = self.pageTitles[index];
//    pageContentViewController.pageIndex = index;
    
    return [groupVCs objectAtIndex:1];
}
@end
