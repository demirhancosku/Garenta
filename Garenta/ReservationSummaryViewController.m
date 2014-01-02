//
//  ReservationSummaryViewController.m
//  Garenta
//
//  Created by Alp Keser on 1/1/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationSummaryViewController.h"
#import "ReservationSummaryCell.h"
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
    tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [[self view] addSubview:tableView];

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
    [timeFormatter setDateFormat:@"hh:mm"];
    switch (indexPath.row) {
        case 0:
            carGroupVC = [[CarGroupViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 221) andCarGroups:reservation.selectedCarGroup];
            [cell addSubview:carGroupVC.view];
            break;
            case 1:
            
            
            for (id xibObject in xibArray) {
                //Loop through array, check for the object we're interested in.
                if ([xibObject isKindOfClass:[ReservationSummaryCell class]]) {
                    //Use casting to cast (id) to (MyCustomView *)
                    myCellView = (ReservationSummaryCell *)xibObject;
                    [myCellView.checkOutTimeLabel setText:[dayFormatter stringFromDate:reservation.checkOutTime ]];
                    [myCellView.checkOutDateLabel setText:[timeFormatter stringFromDate:reservation.checkOutDay ]];
                    [myCellView.checkOutOfficeLabel setText:reservation.checkOutOffice.mainOfficeName];
                }
            }
            
            [cell addSubview: myCellView];
            break;
        case 2:
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
              return 221;
            break;
        case 1:
            return 174;
            break;
        case 2:
            return self.view.frame.size.height - (221 +174);
            break;
        default:
            break;
    }

    return self.view.frame.size.height /4 ;
    
}

@end
