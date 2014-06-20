//
//  CarGroupFilterVC.m
//  Garenta
//
//  Created by Ata  Cengiz on 24.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupFilterVC.h"
#import "CarGroupManagerViewController.h"
@interface CarGroupFilterVC ()

@end

@implementation CarGroupFilterVC

//kullanılmıyor
-(id)initWithReservation:(Reservation*)aReservation andCarGroup:(NSMutableArray*)aCarGroups{
    self  = [super init];
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    filteredCarGroups = [[NSMutableArray alloc] init];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Devam" style:UIBarButtonItemStyleBordered target:self action:@selector(findMyCar)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fillFiltersInArrays];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [tableView setRowHeight:50.0f];
    [tableView setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width * 0.15, 0, 0)];
    
    [[self view] addSubview:tableView];
    [tableView setTintColor:[ApplicationProperties getOrange]];
}

- (void)findMyCar{
    
    [self filterCars];
    if (filteredCarGroups.count <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Aradığınız filtrelerde aracımız bulunumamıştır." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [self performSegueWithIdentifier:@"toCarGroupVCSegue" sender:self];
//    CarGroupManagerViewController *carGroupVC = [[CarGroupManagerViewController alloc] initWithCarGroups:filteredCarGroups andReservartion:reservation];
//
//    [[self navigationController] pushViewController:carGroupVC animated:YES];
}

- (void)calculateFilterResult:(NSMutableArray *)filterArray
{
    int count = [filterArray count] - 1;
    int selectedCount = 0;
    NSString *resultString = @"";
    
    for (int i = 1; i < count + 1; i++)
    {
        FilterObject *filterObject = [filterArray objectAtIndex:i];
        
        if ([filterObject isSelected])
        {
            if ([resultString isEqualToString:@""])
                resultString = [filterObject filterResult];
            else
                resultString = [NSString stringWithFormat:@"%@, %@",resultString, [filterObject filterResult]];
            
            selectedCount++;
        }
    }
    
    if (selectedCount == count || selectedCount == 0)
        resultString = @"Hepsi";
    
    FilterObject *filterObject = [filterArray objectAtIndex:0];
    [filterObject setFilterResult:resultString];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([[brandFilter objectAtIndex:0] isSelected])
            return [brandFilter count];
        else
            return 1;
    }
    
    if (section == 1)
    {
        if ([[fuelFilter objectAtIndex:0] isSelected])
            return [fuelFilter count];
        else
            return 1;
    }
    
    if (section == 2)
    {
            if ([[segmentFilter objectAtIndex:0] isSelected])
                return [segmentFilter count];
            else
                return 1;
    }
    
    if (section == 3)
    {
        if ([[bodyFilter objectAtIndex:0] isSelected])
            return [bodyFilter count];
        else
            return 1;
    }
    
    if (section == 4)
    {
        if ([[transmissionFilter objectAtIndex:0] isSelected])
            return [transmissionFilter count];
        else
            return 1;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    int section = [indexPath section];
    int row     = [indexPath row];
    
    [[cell imageView] setImage:nil];
    [[cell textLabel] setText:@""];
    [[cell detailTextLabel] setText:@""];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setAccessoryView:nil];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0]];
    
    
    FilterObject *tempFilter;
    
    if (section == 0)
        tempFilter = [brandFilter objectAtIndex:row];
    if (section == 1)
        tempFilter = [fuelFilter objectAtIndex:row];
    if (section == 2)
        tempFilter = [segmentFilter objectAtIndex:row];
    if (section == 3)
        tempFilter = [bodyFilter objectAtIndex:row];
    if (section == 4)
        tempFilter = [transmissionFilter objectAtIndex:row];
    
    if (row == 0)
    {
        if ([tempFilter isSelected])
            [[cell imageView] setImage:[UIImage imageNamed:@"OrangeArrowDown.png"]];
        else
            [[cell imageView] setImage:[UIImage imageNamed:@"OrangeArrowUp.png"]];
    }
    else
    {
        if ([tempFilter isSelected])
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    [[cell textLabel] setText:[tempFilter filterDescription]];
    [[cell detailTextLabel] setText:[tempFilter filterResult]];
    [[cell textLabel] setCenter:cell.center];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    
    FilterObject *tempFilter;
    
    if (section == 0)
        tempFilter = [brandFilter objectAtIndex:row];
    if (section == 1)
        tempFilter = [fuelFilter objectAtIndex:row];
    if (section == 2)
        tempFilter = [segmentFilter objectAtIndex:row];
    if (section == 3)
        tempFilter = [bodyFilter objectAtIndex:row];
    if (section == 4)
        tempFilter = [transmissionFilter objectAtIndex:row];
    
        if ([tempFilter isSelected])
        {
            [tempFilter setIsSelected:NO];
            
            if (section == 0)
                [self calculateFilterResult:brandFilter];
            if (section == 1)
                [self calculateFilterResult:fuelFilter];
            if (section == 2)
                [self calculateFilterResult:segmentFilter];
            if (section == 3)
                [self calculateFilterResult:bodyFilter];
            if (section == 4)
                [self calculateFilterResult:transmissionFilter];

            if (row == 0)
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
            else
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];

        }
        else
        {
            [tempFilter setIsSelected:YES];
            
            if (section == 0)
                [self calculateFilterResult:brandFilter];
            if (section == 1)
                [self calculateFilterResult:fuelFilter];
            if (section == 2)
                [self calculateFilterResult:segmentFilter];
            if (section == 3)
                [self calculateFilterResult:bodyFilter];
            if (section == 4)
                [self calculateFilterResult:transmissionFilter];
            
            if (row == 0)
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
            else
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
}

- (void)fillFiltersInArrays
{
    //bir ömür gitti buna -ATA
    //ve malesef değişecek :D :( -alp
    [self buildFuelFilter];
    
    [self buildSegmentFilter];
    
    [self buildBodyFilter];
    
    [self buildTransmissionFilter];
    
    [self buildBrandFilter];
    
}

- (void)buildFuelFilter{
    fuelFilter = [[NSMutableArray alloc] init];
    
    FilterObject *object1 = [[FilterObject alloc] init];
    [object1 setFilterDescription:@"Yakıt Tipi"];
    [object1 setFilterResult:@""];
    [object1 setIsSelected:NO];
    [fuelFilter addObject:object1];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:fuelFilter withId:tempCarGroup.fuelId]) {
            object1 = [[FilterObject alloc] init];
            [object1 setFilterDescription:@""];
            [object1 setFilterResult:tempCarGroup.fuelName];
            [object1 setFilterCode:tempCarGroup.fuelId];
            [object1 setIsSelected:NO];
            [fuelFilter addObject:object1];
        }

    }
    [self calculateFilterResult:fuelFilter];
}


- (void)buildSegmentFilter{
    segmentFilter = [[NSMutableArray alloc] init];
    
    FilterObject *object = [[FilterObject alloc] init];
    [object setFilterDescription:@"Kategori Tipi"];
    [object setFilterResult:@""];
    [object setIsSelected:NO];
    [segmentFilter addObject:object];
    for (CarGroup *tempCarGroup in _carGroups) {
        if (![self isFilterIdFoundFromFilterList:segmentFilter withId:tempCarGroup.segment]) {
            object = [[FilterObject alloc] init];
            [object setFilterDescription:@""];
            [object setFilterResult:tempCarGroup.segmentName];
            [object setFilterCode:tempCarGroup.segment];
            [object setIsSelected:NO];
            [segmentFilter addObject:object];
        }
        
    }

    
    [self calculateFilterResult:segmentFilter];
}

- (void)buildBodyFilter{
    bodyFilter = [[NSMutableArray alloc] init];
    
    FilterObject *object = [[FilterObject alloc] init];
    [object setFilterDescription:@"Kasa Tipi"];
    [object setFilterResult:@""];
    [object setIsSelected:NO];
    [bodyFilter addObject:object];
    for (CarGroup *tempCarGroup in _carGroups) {
        if (![self isFilterIdFoundFromFilterList:bodyFilter withId:tempCarGroup.bodyId]) {
            object = [[FilterObject alloc] init];
            [object setFilterDescription:@""];
            [object setFilterResult:tempCarGroup.bodyName];
            [object setFilterCode:tempCarGroup.bodyId];
            [object setIsSelected:NO];
            [bodyFilter addObject:object];
        }
        
    }
    
    [self calculateFilterResult:bodyFilter];

    
}

- (void)buildTransmissionFilter{
    transmissionFilter = [[NSMutableArray alloc] init];
    
    FilterObject *object = [[FilterObject alloc] init];
    [object setFilterDescription:@"Vites Tipi"];
    [object setFilterResult:@""];
    [object setIsSelected:NO];
    [transmissionFilter addObject:object];
    for (CarGroup *tempCarGroup in _carGroups) {
        if (![self isFilterIdFoundFromFilterList:transmissionFilter withId:tempCarGroup.transmissonId]) {
            object = [[FilterObject alloc] init];
            [object setFilterDescription:@""];
            [object setFilterResult:tempCarGroup.transmissonName];
            [object setFilterCode:tempCarGroup.transmissonId];
            [object setIsSelected:NO];
            [transmissionFilter addObject:object];
        }
        
    }
    [self calculateFilterResult:transmissionFilter];

    
    
}


- (void)buildBrandFilter{
    brandFilter  = [[NSMutableArray alloc] init];
    
    FilterObject *object = [[FilterObject alloc] init];
    [object setFilterDescription:@"Marka"];
    [object setFilterResult:@""];
    [object setIsSelected:NO];
    [brandFilter addObject:object];
    for (CarGroup *tempCarGroup in _carGroups) {
        for(Car *tempCar in tempCarGroup.cars)
            if (![self isFilterIdFoundFromFilterList:brandFilter withId:tempCar.brandId]) {
                object = [[FilterObject alloc] init];
                [object setFilterDescription:@""];
                [object setFilterResult:tempCar.brandName];
                [object setFilterCode:tempCar.brandId];
                [object setIsSelected:NO];
                [brandFilter addObject:object];
        }
        
    }
    

    [self calculateFilterResult:brandFilter];
    
    
    
}


- (BOOL)isFilterIdFoundFromFilterList:(NSMutableArray*)aList withId:(NSString*)anId{
    for (FilterObject *tempObject in aList) {
        if ([[tempObject filterCode] isEqualToString:anId]) {
            return YES;
        }
    }
    return NO;
}

- (void)filterCars{
    [filteredCarGroups removeAllObjects];
    [filteredCarGroups addObjectsFromArray:_carGroups];
    //ve malesef değişecek :D :( -alp
  
    [self filterFuel];
    [self filterSegment];
    [self filterBody];
    [self filterTransmission];
    [self filterBrand];
    
}

- (void)filterFuel{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in fuelFilter) {
        if (tempObject.filterCode == nil) {
            //ilk kalemdir
            if ([tempObject.filterResult isEqualToString:@"Hepsi"]) {
                return;
            }
        }
        else
        {
            if ([tempObject isSelected]) {
                
                for (CarGroup *tempGroup in filteredCarGroups) {
                    if ([tempObject.filterCode isEqualToString:tempGroup.fuelId]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    filteredCarGroups = newArray;
}
- (void)filterSegment{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in segmentFilter) {
        if (tempObject.filterCode == nil) {
            //ilk kalemdir
            if ([tempObject.filterResult isEqualToString:@"Hepsi"]) {
                return;
            }
        }
        else
        {
            if ([tempObject isSelected]) {
                
                for (CarGroup *tempGroup in filteredCarGroups) {
                    if ([tempObject.filterCode isEqualToString:tempGroup.segment]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    filteredCarGroups = newArray;
}

- (void)filterBody{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in bodyFilter) {
        if (tempObject.filterCode == nil) {
            //ilk kalemdir
            if ([tempObject.filterResult isEqualToString:@"Hepsi"]) {
                return;
            }
        }
        else
        {
            if ([tempObject isSelected]) {
                
                for (CarGroup *tempGroup in filteredCarGroups) {
                    if ([tempObject.filterCode isEqualToString:tempGroup.bodyId]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    filteredCarGroups = newArray;
}

- (void)filterTransmission{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in transmissionFilter) {
        if (tempObject.filterCode == nil) {
            //ilk kalemdir
            if ([tempObject.filterResult isEqualToString:@"Hepsi"]) {
                return;
            }
        }
        else
        {
            if ([tempObject isSelected]) {
                
                for (CarGroup *tempGroup in filteredCarGroups) {
                    if ([tempObject.filterCode isEqualToString:tempGroup.transmissonId]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    filteredCarGroups = newArray;
}

///ahahahahahhaahhahahahahahahhahaha anlasana  ahahahahahhahahaah
- (void)filterBrand{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    //TODO:sonra nscopy implement et aalpk
    NSMutableArray *newTempGroupArray = [[NSMutableArray alloc] init];
    CarGroup *newCarGroup;
    for (CarGroup *temp in filteredCarGroups) {
        newCarGroup = [[CarGroup alloc] init];
        newCarGroup.cars = [[NSMutableArray alloc] init];
        [newCarGroup setGroupCode:temp.groupCode];
        [newCarGroup setGroupName:temp.groupName];
        [newCarGroup setTransmissonId:temp.transmissonId];
        [newCarGroup setTransmissonName:temp.transmissonName];
        [newCarGroup setFuelId:temp.fuelId];
        [newCarGroup setFuelName:temp.fuelName];
        [newCarGroup setBodyId:temp.bodyId];
        [newCarGroup setBodyName:temp.bodyName];
        [newCarGroup setSegment:temp.segment];
        [newCarGroup setSegmentName:temp.segmentName];
        [newCarGroup setSampleCar:temp.sampleCar];
        [newCarGroup setPayNowPrice:temp.payNowPrice];
        [newCarGroup setPayLaterPrice:temp.payLaterPrice];
        [newTempGroupArray addObject:newCarGroup];

    }

    for (FilterObject *tempObject in brandFilter) {
        if (tempObject.filterCode == nil) {
            //ilk kalemdir
            if ([tempObject.filterResult isEqualToString:@"Hepsi"]) {
                return;
            }
        }
        else
        {
            if ([tempObject isSelected]) {
                
                for (CarGroup *tempGroup in filteredCarGroups) {
                    CarGroup *newTempGroup = [CarGroup getGroupFromList:newTempGroupArray WithCode:tempGroup.groupCode];
                    for (Car *tempCar in tempGroup.cars) {
                        if ([tempObject.filterCode isEqualToString:tempCar.brandId]) {
                            [newTempGroup.cars addObject:tempCar];
                        }
                    }

                }
            }
        }
    }
    filteredCarGroups = nil;
    filteredCarGroups = [[NSMutableArray alloc] init];
    for (CarGroup*tempGroup in newTempGroupArray) {
        if (tempGroup.cars.count>0) {
            [filteredCarGroups addObject:tempGroup];
        }
    }


}

#pragma mark - navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toCarGroupVCSegue"]) {
        CarGroupFilterVC  *filterVC = (CarGroupFilterVC*)[segue destinationViewController];
        [filterVC setCarGroups:filteredCarGroups];
        [filterVC setReservation:self.reservation];
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
