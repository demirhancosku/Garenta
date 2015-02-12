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

@property(strong,nonatomic) NSMutableArray *tempFuelFilter;
@property(strong,nonatomic) NSMutableArray *tempBodyFilter;
@property(strong,nonatomic) NSMutableArray *tempTransmissionFilter;
@property(strong,nonatomic) NSMutableArray *tempSegmentFilter;
@property(strong,nonatomic) NSMutableArray *tempBrandFilter;

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
    
    self.tempCarGroup = [self.carGroups copy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fillFiltersInArrays];
    
    self.tempFuelFilter = [fuelFilter copy];
    self.tempTransmissionFilter = [transmissionFilter copy];
    self.tempSegmentFilter = [segmentFilter copy];
    self.tempBodyFilter = [bodyFilter copy];
    self.tempBrandFilter = [brandFilter copy];
    
    
    tableVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50) style:UITableViewStylePlain];
    [tableVC setDelegate:self];
    [tableVC setDataSource:self];
    [tableVC setRowHeight:50.0f];
    [tableVC setTintColor:[ApplicationProperties getOrange]];
    
    [[self view] addSubview:tableVC];
    
    clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clearButton.frame = CGRectMake(0,tableVC.frame.size.height,self.view.frame.size.width, 40);
    clearButton.backgroundColor = [ApplicationProperties getGreen];
    [clearButton setTitle:@"Filtreyi Sıfırla" forState:UIControlStateNormal];
    [clearButton setTintColor:[UIColor whiteColor]];
    
    [self.view addSubview:clearButton];
}

- (void)findMyCar{
    
    [self filterCars];
    
    if (filteredCarGroups.count <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Aradığınız filtrelerde aracımız bulunumamıştır." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self performSegueWithIdentifier:@"toCarGroupVCSegue" sender:self];
}

- (void)calculateFilterResult:(NSMutableArray *)filterArray
{
    NSUInteger count = [filterArray count] - 1;
    int selectedCount = 0;
    NSString *resultString = @"";
    
    for (int i = 1; i < count + 1; i++)
    {
        FilterObject *filterObject = [filterArray objectAtIndex:i];
        
        if ([filterObject isSelected])
            selectedCount++;
    }
    
    if (selectedCount == count || selectedCount == 0)
        resultString = @"Hepsi";
    
    if (selectedCount > 0) {
        resultString = [NSString stringWithFormat:@"Seçilen: %i",selectedCount];
    }
    
    FilterObject *filterObject = [filterArray objectAtIndex:0];
    [filterObject setFilterResult:resultString];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        if ([[brandFilter objectAtIndex:0] isSelected])
            return [brandFilter count];
        else
            return 1;
    }
    
    if (section == 1){
        if ([[fuelFilter objectAtIndex:0] isSelected])
            return [fuelFilter count];
        else
            return 1;
    }
    
    if (section == 2){
        if ([[segmentFilter objectAtIndex:0] isSelected])
            return [segmentFilter count];
        else
            return 1;
    }
    
    if (section == 3){
        if ([[bodyFilter objectAtIndex:0] isSelected])
            return [bodyFilter count];
        else
            return 1;
    }
    
    if (section == 4){
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
    
    [[cell textLabel] setText:@""];
    [[cell detailTextLabel] setText:@""];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0]];
    [[cell detailTextLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0]];
    
    FilterObject *tempFilter = [self findFilterObjectBySection:indexPath];
    
    if (indexPath.row == 0)
    {
        [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]];
        cell.textLabel.text = tempFilter.filterDescription;
        cell.detailTextLabel.text = tempFilter.filterResult;
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    else
    {
        cell.textLabel.text = tempFilter.filterResult;
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width * 0.1, 0, 0)];
        if ([tempFilter isSelected]){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    FilterObject *tempFilter = [self findFilterObjectBySection:indexPath];
    
    // section seçildimi?
    if ([tempFilter isSelected])
    {
        [tempFilter setIsSelected:NO];
        
        [self calculateFilterResultBySection:section];
        
        if (row == 0)
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        else
        {
            if (section == 0) {
                [self dynamicFilter:brandFilter andSection:section];
            }
            if (section == 1) {
                [self dynamicFilter:fuelFilter andSection:section];
            }
            if (section == 2) {
                [self dynamicFilter:segmentFilter andSection:section];
            }
            if (section == 3) {
                [self dynamicFilter:bodyFilter andSection:section];
            }
            if (section == 4) {
                [self dynamicFilter:transmissionFilter andSection:section];
            }
            
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else
    {
        [tempFilter setIsSelected:YES];
        
        [self calculateFilterResultBySection:section];
        
        if (row == 0){
            // önce seçilen section hariç hepsinin row sayısını eski haline getiriyoruz
            [self closeSection:section];
            
            // sonra seçilen section animasyonla açılıyo
            [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,5)] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else{
            
            if (section == 0) {
                [self dynamicFilter:brandFilter andSection:section];
            }
            if (section == 1) {
                [self dynamicFilter:fuelFilter andSection:section];
            }
            if (section == 2) {
                [self dynamicFilter:segmentFilter andSection:section];
            }
            if (section == 3) {
                [self dynamicFilter:bodyFilter andSection:section];
            }
            if (section == 4) {
                [self dynamicFilter:transmissionFilter andSection:section];
            }
            
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}


- (void)dynamicFilter:(NSMutableArray *)dynamicArray andSection:(NSUInteger)section
{
    NSString *predicateFormat = @"";
    //    predicateFormat = [self prepareArray];
    
    if (section == 0) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
        NSArray *newArray = [brandFilter filteredArrayUsingPredicate:newPredicate];
        
        if (newArray.count == 1) {
            return;
        }
        
        [fuelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, fuelFilter.count - 1)]];
        [bodyFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, bodyFilter.count - 1)]];
        [segmentFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, segmentFilter.count - 1)]];
        [transmissionFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, transmissionFilter.count - 1)]];
        
        if ([predicateFormat isEqualToString:@""])
            predicateFormat = @"sampleCar.brandId==%@";
    }
    
    if (section == 1) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
        NSArray *newArray = [fuelFilter filteredArrayUsingPredicate:newPredicate];
        
        if (newArray.count == 1) {
            return;
        }
        [brandFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, brandFilter.count - 1)]];
        [bodyFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, bodyFilter.count - 1)]];
        [segmentFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, segmentFilter.count - 1)]];
        [transmissionFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, transmissionFilter.count - 1)]];
        
        if ([predicateFormat isEqualToString:@""])
            predicateFormat = @"fuelId==%@";
    }
    
    if (section == 2) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
        NSArray *newArray = [segmentFilter filteredArrayUsingPredicate:newPredicate];
        
        if (newArray.count == 1) {
            return;
        }
        
        [fuelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, fuelFilter.count - 1)]];
        [bodyFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, bodyFilter.count - 1)]];
        [brandFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, brandFilter.count - 1)]];
        [transmissionFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, transmissionFilter.count - 1)]];
        
        if ([predicateFormat isEqualToString:@""])
            predicateFormat = @"segment==%@";
    }
    
    if (section == 3) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
        NSArray *newArray = [bodyFilter filteredArrayUsingPredicate:newPredicate];
        
        if (newArray.count == 1) {
            return;
        }
        [fuelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, fuelFilter.count - 1)]];
        [brandFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, brandFilter.count - 1)]];
        [segmentFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, segmentFilter.count - 1)]];
        [transmissionFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, transmissionFilter.count - 1)]];
        
        if ([predicateFormat isEqualToString:@""])
            predicateFormat = @"bodyId==%@";
    }
    
    if (section == 4) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
        NSArray *newArray = [transmissionFilter filteredArrayUsingPredicate:newPredicate];
        
        if (newArray.count == 1) {
            return;
        }
        
        [fuelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, fuelFilter.count - 1)]];
        [bodyFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, bodyFilter.count - 1)]];
        [segmentFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, segmentFilter.count - 1)]];
        [brandFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, brandFilter.count - 1)]];
        
        if ([predicateFormat isEqualToString:@""])
            predicateFormat = @"transmissonId==%@";
    }
    
    for (FilterObject *temp in dynamicArray)
    {
        if (temp.isSelected) {
            
            NSPredicate *predicateFilter = [NSPredicate predicateWithFormat:predicateFormat,temp.filterCode];
            NSArray *filterArr = [self.carGroups filteredArrayUsingPredicate:predicateFilter];
            
            for (CarGroup *tempCarGroup in filterArr) {
                if (section == 0) {
                    [self refillFilterArray:tempCarGroup.fuelName andFilterCode:tempCarGroup.fuelId andArray:fuelFilter];
                    [self refillFilterArray:tempCarGroup.segmentName andFilterCode:tempCarGroup.segment andArray:segmentFilter];
                    [self refillFilterArray:tempCarGroup.bodyName andFilterCode:tempCarGroup.bodyId andArray:bodyFilter];
                    [self refillFilterArray:tempCarGroup.transmissonName andFilterCode:tempCarGroup.transmissonId andArray:transmissionFilter];
                }
                
                if (section == 1) {
                    [self refillFilterArray:tempCarGroup.sampleCar.brandName andFilterCode:tempCarGroup.sampleCar.brandId andArray:brandFilter];
                    [self refillFilterArray:tempCarGroup.segmentName andFilterCode:tempCarGroup.segment andArray:segmentFilter];
                    [self refillFilterArray:tempCarGroup.bodyName andFilterCode:tempCarGroup.bodyId andArray:bodyFilter];
                    [self refillFilterArray:tempCarGroup.transmissonName andFilterCode:tempCarGroup.transmissonId andArray:transmissionFilter];
                }
                
                if (section == 2) {
                    [self refillFilterArray:tempCarGroup.fuelName andFilterCode:tempCarGroup.fuelId andArray:fuelFilter];
                    [self refillFilterArray:tempCarGroup.sampleCar.brandName andFilterCode:tempCarGroup.sampleCar.brandId andArray:brandFilter];
                    [self refillFilterArray:tempCarGroup.bodyName andFilterCode:tempCarGroup.bodyId andArray:bodyFilter];
                    [self refillFilterArray:tempCarGroup.transmissonName andFilterCode:tempCarGroup.transmissonId andArray:transmissionFilter];
                }
                
                if (section == 3) {
                    [self refillFilterArray:tempCarGroup.fuelName andFilterCode:tempCarGroup.fuelId andArray:fuelFilter];
                    [self refillFilterArray:tempCarGroup.segmentName andFilterCode:tempCarGroup.segment andArray:segmentFilter];
                    [self refillFilterArray:tempCarGroup.sampleCar.brandName andFilterCode:tempCarGroup.sampleCar.brandId andArray:brandFilter];
                    [self refillFilterArray:tempCarGroup.transmissonName andFilterCode:tempCarGroup.transmissonId andArray:transmissionFilter];
                }
                
                if (section == 4) {
                    [self refillFilterArray:tempCarGroup.fuelName andFilterCode:tempCarGroup.fuelId andArray:fuelFilter];
                    [self refillFilterArray:tempCarGroup.segmentName andFilterCode:tempCarGroup.segment andArray:segmentFilter];
                    [self refillFilterArray:tempCarGroup.bodyName andFilterCode:tempCarGroup.bodyId andArray:bodyFilter];
                    [self refillFilterArray:tempCarGroup.sampleCar.brandName andFilterCode:tempCarGroup.sampleCar.brandId andArray:brandFilter];
                }
            }
        }
    }
    
//    for (FilterObject *temp in brandFilter) {
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"sampleCar.brandId==%@",temp.filterCode];
//        NSArray *arr = [tempBrand filteredArrayUsingPredicate:pred];
//        
//        if (arr.count == 0 || ![[arr objectAtIndex:0] isSelected]) {
//            [brandFilter removeObject:temp];
//        }
//    }
//    
//    for (FilterObject *temp in fuelFilter) {
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"filterCode==%@",temp.filterCode];
//        NSArray *arr = [tempFuel filteredArrayUsingPredicate:pred];
//        
//        if (arr.count == 0 || ![[arr objectAtIndex:0] isSelected]) {
//            [fuelFilter removeObject:temp];
//        }
//    }
//    
//    for (FilterObject *temp in segmentFilter) {
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"segment==%@",temp.filterCode];
//        NSArray *arr = [tempSegment filteredArrayUsingPredicate:pred];
//        
//        if (arr.count == 0 || ![[arr objectAtIndex:0] isSelected]) {
//            [segmentFilter removeObject:temp];
//        }
//    }
//    
//    for (FilterObject *temp in bodyFilter) {
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"bodyId==%@",temp.filterCode];
//        NSArray *arr = [tempBody filteredArrayUsingPredicate:pred];
//        
//        if (arr.count == 0 || ![[arr objectAtIndex:0] isSelected]) {
//            [bodyFilter removeObject:temp];
//        }
//    }
//    
//    for (FilterObject *temp in transmissionFilter) {
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"transmissionId==%@",temp.filterCode];
//        NSArray *arr = [tempTransmission filteredArrayUsingPredicate:pred];
//        
//        if (arr.count == 0 || ![[arr objectAtIndex:0] isSelected]) {
//            [transmissionFilter removeObject:temp];
//        }
//    }
}

- (void)refillFilterArray:(NSString *)filterResult andFilterCode:(NSString *)filterCode andArray:(NSMutableArray *)array
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterCode==%@",filterCode];
    NSArray *filterArr = [array filteredArrayUsingPredicate:predicate];
    
    if (filterArr.count == 0) {
        FilterObject *object1 = [FilterObject new];
        [object1 setFilterDescription:@""];
        [object1 setFilterResult:filterResult];
        [object1 setFilterCode:filterCode];
        [object1 setIsSelected:NO];
        [array addObject:object1];
    }
}

// section ve row bazında seçilen filtre objesini döndürür
- (FilterObject *)findFilterObjectBySection:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return [brandFilter objectAtIndex:indexPath.row];
    if (indexPath.section == 1)
        return [fuelFilter objectAtIndex:indexPath.row];
    if (indexPath.section == 2)
        return [segmentFilter objectAtIndex:indexPath.row];
    if (indexPath.section == 3)
        return [bodyFilter objectAtIndex:indexPath.row];
    if (indexPath.section == 4)
        return [transmissionFilter objectAtIndex:indexPath.row];
    
    return nil;
}

// Seçilen satırda hepsinin mi yoksa belli sayıdamı seçildiğini gösterir
- (void)calculateFilterResultBySection:(NSUInteger)section
{
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
}

// seçilen section dışındaki açık olan row animasyonlarını kapatır, isSelected NO yapılarak numberOfRowsInSection'da 1 dönmesi sağlanır
- (void)closeSection:(NSUInteger)section
{
    if (section != 0){
        [[brandFilter objectAtIndex:0] setIsSelected:NO];
    }
    if (section != 1){
        [[fuelFilter objectAtIndex:0] setIsSelected:NO];
    }
    if (section != 2){
        [[segmentFilter objectAtIndex:0] setIsSelected:NO];
    }
    if (section != 3){
        [[bodyFilter objectAtIndex:0] setIsSelected:NO];
    }
    if (section != 4){
        [[transmissionFilter objectAtIndex:0] setIsSelected:NO];
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
    for (CarGroup *tempCarGroup in self.carGroups) {
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
    for (CarGroup *tempCarGroup in self.carGroups) {
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
    for (CarGroup *tempCarGroup in self.carGroups) {
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
    for (CarGroup *tempCarGroup in self.carGroups) {
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
    //TODO:sonra nscopy implement et aalpk
    NSMutableArray *newTempGroupArray = [NSMutableArray new];
    
    for (FilterObject *tempObject in brandFilter) {
        if (tempObject.filterCode == nil) {
            //ilk kalemdir
            if ([tempObject.filterResult isEqualToString:@"Hepsi"]) {
                return;
            }
        }
        else
        {
            if ([tempObject isSelected])
            {
                for (CarGroup *tempGroup in filteredCarGroups)
                {
                    NSMutableArray *cars = [NSMutableArray new];
                    CarGroup *newTempGroup = [CarGroup getGroupFromList:filteredCarGroups WithCode:tempGroup.groupCode];
                    for (Car *tempCar in newTempGroup.cars) {
                        if ([tempObject.filterCode isEqualToString:tempCar.brandId]) {
                            [cars addObject:tempCar];
                        }
                    }
                    
                    if (cars.count > 0) {
                        newTempGroup.cars = [cars copy];
                        [newTempGroupArray addObject:newTempGroup];
                    }
                }
            }
        }
    }
    
    filteredCarGroups = nil;
    filteredCarGroups = [[NSMutableArray alloc] init];
    for (CarGroup *tempGroup in newTempGroupArray) {
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
