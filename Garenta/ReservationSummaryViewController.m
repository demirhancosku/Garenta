//
//  ReservationSummaryViewController.m
//  Garenta
//
//  Created by Alp Keser on 1/1/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationSummaryViewController.h"
#import "ReservationSummaryCell.h"

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
@interface ReservationSummaryViewController ()

@end

@implementation ReservationSummaryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithReservation:(Reservation*)aReservation{
    self = [self initWithNibName:@"ReservationSummaryViewController" bundle:nil];
    reservation = aReservation;
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self prepareScreen];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tableView reloadData];
}

- (void)prepareScreen{
    
    tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [[self view] addSubview:tableView];
    
    resumeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [resumeButton setFrame:CGRectMake(0,0,100,35)];
    [resumeButton setCenter:self.view.center];
    [resumeButton setBackgroundColor:[ApplicationProperties getGreen]];
    [resumeButton setTitleColor:[ApplicationProperties getWhite] forState:UIControlStateNormal];
    [resumeButton addTarget:self action:@selector(resumeSelected) forControlEvents:UIControlEventTouchUpInside];
    [resumeButton setTitle:@"Devam" forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  - tableview delegate datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ReservationSummaryCell *myCellView = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
    }
    NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"ReservationSummaryCell" owner:nil options:nil];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"dd.MM.YYYY"];
    [timeFormatter setDateFormat:@"HH:mm"];
    switch (indexPath.row) {
        case 0:
            carGroupVC = [[CarGroupViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 221) andCarGroups:reservation.selectedCarGroup];
            [carGroupVC setRightArrowShouldHide:YES];
            [carGroupVC setLeftArrowShouldHide:YES];
            [cell addSubview:carGroupVC.view];
            break;
            case 1:
            
            
            for (id xibObject in xibArray) {
                //Loop through array, check for the object we're interested in.
                if ([xibObject isKindOfClass:[ReservationSummaryCell class]]) {
                    //Use casting to cast (id) to (MyCustomView *)
                    myCellView = (ReservationSummaryCell *)xibObject;
                    [myCellView.checkOutTimeLabel setText:[timeFormatter stringFromDate:reservation.checkOutTime ]];
                    [myCellView.checkOutDateLabel setText:[dayFormatter stringFromDate:reservation.checkOutTime ]];
                    [myCellView.checkOutOfficeLabel setText:reservation.checkOutOffice.subOfficeName];
                    [myCellView.checkOutOfficeLabel setTextAlignment:NSTextAlignmentCenter];
                    
                    [myCellView.checkInOfficeLabel setText:reservation.checkInOffice.subOfficeName];
                    [myCellView.checkInDateLabel setText:[dayFormatter stringFromDate:reservation.checkInTime]] ;
                    [myCellView.checkInTimeLabel setText:[timeFormatter stringFromDate:reservation.checkInTime]];
                    [myCellView.checkInOfficeLabel setTextAlignment:NSTextAlignmentCenter];
                    [myCellView.totalLabel setText:reservation.selectedCarGroup.payLaterPrice];
                }
            }
            
            [cell addSubview: myCellView];
            break;
        case 2:
            [resumeButton setCenter:CGPointMake(cell.center.x,[self tableView:tableView heightForRowAtIndexPath:indexPath] / 3.0f) ];
            [cell addSubview:resumeButton];
            
            break;
        default:
            break;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
              return 157;
            break;
        case 1:
            return 201;
            break;
        case 2:
            if (isiPhone5) {
                return self.view.frame.size.height- 358;
            }
            return 105.0f;
            break;
        default:
            break;
    }

    return self.view.frame.size.height /4 ;
    
}

@end
