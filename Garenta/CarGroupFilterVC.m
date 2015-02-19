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
@property(strong,nonatomic) NSMutableArray *tempModelFilter;
@property(strong,nonatomic) NSMutableArray *tempModelYearFilter;
@property(strong,nonatomic) NSMutableArray *tempColorFilter;
@property(strong,nonatomic) NSMutableArray *tempEngineVolumeFilter;
@property(strong,nonatomic) NSMutableArray *tempHorsePowerFilter;


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
    if (fuelFilter.count == 0) {
        [self arrayInitialize];
        [self fillFiltersInArrays];
    }
    
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
    [clearButton addTarget:self action:@selector(resetAllFilters) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setTintColor:[UIColor whiteColor]];
    
    [self.view addSubview:clearButton];
}

- (void)resetAllFilters
{
    [self arrayInitialize];
    [self fillFiltersInArrays];
    
    [tableVC reloadData];
}

- (void)arrayInitialize
{
    fuelFilter = [NSMutableArray new];
    brandFilter = [NSMutableArray new];
    bodyFilter = [NSMutableArray new];
    segmentFilter = [NSMutableArray new];
    transmissionFilter = [NSMutableArray new];
    modelFilter = [NSMutableArray new];
    modelYearFilter = [NSMutableArray new];
    colorFilter = [NSMutableArray new];
    engineVolumeFilter = [NSMutableArray new];
    horsePowerFilter = [NSMutableArray new];
    
    self.tempFuelFilter = [NSMutableArray new];
    self.tempBrandFilter = [NSMutableArray new];
    self.tempBodyFilter = [NSMutableArray new];
    self.tempSegmentFilter = [NSMutableArray new];
    self.tempTransmissionFilter = [NSMutableArray new];
    self.tempModelFilter = [NSMutableArray new];
    self.tempModelYearFilter = [NSMutableArray new];
    self.tempColorFilter = [NSMutableArray new];
    self.tempEngineVolumeFilter = [NSMutableArray new];
    self.tempHorsePowerFilter = [NSMutableArray new];
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
    return 10;
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
    
    if (section == 5){
        if ([[modelFilter objectAtIndex:0] isSelected])
            return [modelFilter count];
        else
            return 1;
    }
    
    if (section == 6){
        if ([[modelYearFilter objectAtIndex:0] isSelected])
            return [modelYearFilter count];
        else
            return 1;
    }
    
    if (section == 7){
        if ([[colorFilter objectAtIndex:0] isSelected])
            return [colorFilter count];
        else
            return 1;
    }
    
    if (section == 8){
        if ([[engineVolumeFilter objectAtIndex:0] isSelected])
            return [engineVolumeFilter count];
        else
            return 1;
    }
    
    if (section == 9){
        if ([[horsePowerFilter objectAtIndex:0] isSelected])
            return [horsePowerFilter count];
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
        {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            if (section == 0) {
                [self dynamicFilter:brandFilter andSection:section];
            }
//            if (section == 1) {
//                [self dynamicFilter:fuelFilter andSection:section];
//            }
//            if (section == 2) {
//                [self dynamicFilter:segmentFilter andSection:section];
//            }
//            if (section == 3) {
//                [self dynamicFilter:bodyFilter andSection:section];
//            }
//            if (section == 4) {
//                [self dynamicFilter:transmissionFilter andSection:section];
//            }
            
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
            [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,10)] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [tableView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:YES];
        }
        else{
            
            if (section == 0) {
                [self dynamicFilter:brandFilter andSection:section];
            }
//            if (section == 1) {
//                [self dynamicFilter:fuelFilter andSection:section];
//            }
//            if (section == 2) {
//                [self dynamicFilter:segmentFilter andSection:section];
//            }
//            if (section == 3) {
//                [self dynamicFilter:bodyFilter andSection:section];
//            }
//            if (section == 4) {
//                [self dynamicFilter:transmissionFilter andSection:section];
//            }
            
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)filterTempArray:(NSMutableArray *)tempList andCurrentList:(NSMutableArray *)aList
{
    for (FilterObject *temp in tempList) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"filterCode==%@",temp.filterCode];
        NSArray *arr = [aList filteredArrayUsingPredicate:pred];
        
        if (arr.count == 0) {
            [aList addObject:temp];
        }
    }
}


- (void)dynamicFilter:(NSMutableArray *)dynamicArray andSection:(NSUInteger)section
{
    NSString *predicateFormat = @"";
    //    predicateFormat = [self prepareArray];
    
    // sadece section 0 çalışıyor şuanda, diğerlerinde dinamiklik yok
    if (section == 0) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
        NSArray *newArray = [brandFilter filteredArrayUsingPredicate:newPredicate];
        
        if (newArray.count == 1) {
            [self buildFuelFilter:self.tempFuelFilter];
            [self buildSegmentFilter:self.tempSegmentFilter];
            [self buildBodyFilter:self.tempBodyFilter];
            [self buildTransmissionFilter:self.tempTransmissionFilter];
            [self buildModelFilter:self.tempModelFilter];
            [self buildModelYearFilter:self.tempModelYearFilter];
            [self buildColorFilter:self.tempColorFilter];
            [self buildEngineVolumeFilter:self.tempEngineVolumeFilter];
            [self buildHorsePowerFilter:self.tempHorsePowerFilter];
            
            [self filterTempArray:self.tempFuelFilter andCurrentList:fuelFilter];
            [self filterTempArray:self.tempSegmentFilter andCurrentList:segmentFilter];
            [self filterTempArray:self.tempBodyFilter andCurrentList:bodyFilter];
            [self filterTempArray:self.tempTransmissionFilter andCurrentList:transmissionFilter];
            [self filterTempArray:self.tempModelFilter andCurrentList:modelFilter];
            [self filterTempArray:self.tempModelYearFilter andCurrentList:modelYearFilter];
            [self filterTempArray:self.tempEngineVolumeFilter andCurrentList:engineVolumeFilter];
            [self filterTempArray:self.tempHorsePowerFilter andCurrentList:horsePowerFilter];

            return;
        }
        
        [fuelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, fuelFilter.count - 1)]];
        [bodyFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, bodyFilter.count - 1)]];
        [segmentFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, segmentFilter.count - 1)]];
        [transmissionFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, transmissionFilter.count - 1)]];
        
        [modelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, modelFilter.count - 1)]];
        [modelYearFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, modelYearFilter.count - 1)]];
        [colorFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, colorFilter.count - 1)]];
        [engineVolumeFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, engineVolumeFilter.count - 1)]];
        [horsePowerFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, horsePowerFilter.count - 1)]];
        
        if ([predicateFormat isEqualToString:@""])
            predicateFormat = @"sampleCar.brandId==%@";
    }
    
//    if (section == 1) {
//        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
//        NSArray *newArray = [fuelFilter filteredArrayUsingPredicate:newPredicate];
//        
//        if (newArray.count == 1) {
//            [self buildSegmentFilter:self.tempSegmentFilter];
//            [self buildBrandFilter:self.tempBrandFilter];
//            [self buildBodyFilter:self.tempBodyFilter];
//            [self buildTransmissionFilter:self.tempTransmissionFilter];
//            
//            [self filterTempArray:self.tempSegmentFilter andCurrentList:segmentFilter];
//            [self filterTempArray:self.tempBrandFilter andCurrentList:brandFilter];
//            [self filterTempArray:self.tempBodyFilter andCurrentList:bodyFilter];
//            [self filterTempArray:self.tempTransmissionFilter andCurrentList:transmissionFilter];
//            
//            return;
//        }
//        
//        [brandFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, brandFilter.count - 1)]];
//        [bodyFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, bodyFilter.count - 1)]];
//        [segmentFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, segmentFilter.count - 1)]];
//        [transmissionFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, transmissionFilter.count - 1)]];
//        
//        if ([predicateFormat isEqualToString:@""])
//            predicateFormat = @"fuelId==%@";
//    }
//    
//    if (section == 2) {
//        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
//        NSArray *newArray = [segmentFilter filteredArrayUsingPredicate:newPredicate];
//        
//        if (newArray.count == 1) {
//            [self buildFuelFilter:self.tempFuelFilter];
//            [self buildBrandFilter:self.tempBrandFilter];
//            [self buildBodyFilter:self.tempBodyFilter];
//            [self buildTransmissionFilter:self.tempTransmissionFilter];
//            
//            [self filterTempArray:self.tempFuelFilter andCurrentList:fuelFilter];
//            [self filterTempArray:self.tempBrandFilter andCurrentList:brandFilter];
//            [self filterTempArray:self.tempBodyFilter andCurrentList:bodyFilter];
//            [self filterTempArray:self.tempTransmissionFilter andCurrentList:transmissionFilter];
//            
//            return;
//        }
//        
//        [fuelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, fuelFilter.count - 1)]];
//        [bodyFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, bodyFilter.count - 1)]];
//        [brandFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, brandFilter.count - 1)]];
//        [transmissionFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, transmissionFilter.count - 1)]];
//        
//        if ([predicateFormat isEqualToString:@""])
//            predicateFormat = @"segment==%@";
//    }
//    
//    if (section == 3) {
//        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
//        NSArray *newArray = [bodyFilter filteredArrayUsingPredicate:newPredicate];
//        
//        if (newArray.count == 1) {
//            [self buildSegmentFilter:self.tempSegmentFilter];
//            [self buildBrandFilter:self.tempBrandFilter];
//            [self buildFuelFilter:self.tempFuelFilter];
//            [self buildTransmissionFilter:self.tempTransmissionFilter];
//            
//            [self filterTempArray:self.tempFuelFilter andCurrentList:fuelFilter];
//            [self filterTempArray:self.tempBrandFilter andCurrentList:brandFilter];
//            [self filterTempArray:self.tempSegmentFilter andCurrentList:segmentFilter];
//            [self filterTempArray:self.tempTransmissionFilter andCurrentList:transmissionFilter];
//            
//            return;
//        }
//        
//        [fuelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, fuelFilter.count - 1)]];
//        [brandFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, brandFilter.count - 1)]];
//        [segmentFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, segmentFilter.count - 1)]];
//        [transmissionFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, transmissionFilter.count - 1)]];
//        
//        if ([predicateFormat isEqualToString:@""])
//            predicateFormat = @"bodyId==%@";
//    }
//    
//    if (section == 4) {
//        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"isSelected==%@", [NSNumber numberWithBool:YES]];
//        NSArray *newArray = [transmissionFilter filteredArrayUsingPredicate:newPredicate];
//        
//        if (newArray.count == 1) {
//            [self buildSegmentFilter:self.tempSegmentFilter];
//            [self buildBrandFilter:self.tempBrandFilter];
//            [self buildBodyFilter:self.tempBodyFilter];
//            [self buildFuelFilter:self.tempFuelFilter];
//            
//            [self filterTempArray:self.tempFuelFilter andCurrentList:fuelFilter];
//            [self filterTempArray:self.tempBrandFilter andCurrentList:brandFilter];
//            [self filterTempArray:self.tempBodyFilter andCurrentList:bodyFilter];
//            [self filterTempArray:self.tempFuelFilter andCurrentList:fuelFilter];
//            
//            return;
//        }
//        
//        [fuelFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, fuelFilter.count - 1)]];
//        [bodyFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, bodyFilter.count - 1)]];
//        [segmentFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, segmentFilter.count - 1)]];
//        [brandFilter removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, brandFilter.count - 1)]];
//        
//        if ([predicateFormat isEqualToString:@""])
//            predicateFormat = @"transmissonId==%@";
//    }
    
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
                    [self refillFilterArray:tempCarGroup.sampleCar.modelName andFilterCode:tempCarGroup.sampleCar.modelId andArray:modelFilter];
                    [self refillFilterArray:tempCarGroup.sampleCar.modelYear andFilterCode:tempCarGroup.sampleCar.modelYear andArray:modelYearFilter];
                    [self refillFilterArray:tempCarGroup.sampleCar.colorName andFilterCode:tempCarGroup.sampleCar.colorCode andArray:colorFilter];
                    [self refillFilterArray:tempCarGroup.sampleCar.engineVolumeCode andFilterCode:tempCarGroup.sampleCar.engineVolumeCode andArray:engineVolumeFilter];
                    [self refillFilterArray:tempCarGroup.sampleCar.horsePowerCode andFilterCode:tempCarGroup.sampleCar.horsePowerCode andArray:horsePowerFilter];
                }
                
//                if (section == 1) {
//                    [self refillFilterArray:tempCarGroup.sampleCar.brandName andFilterCode:tempCarGroup.sampleCar.brandId andArray:brandFilter];
//                    [self refillFilterArray:tempCarGroup.segmentName andFilterCode:tempCarGroup.segment andArray:segmentFilter];
//                    [self refillFilterArray:tempCarGroup.bodyName andFilterCode:tempCarGroup.bodyId andArray:bodyFilter];
//                    [self refillFilterArray:tempCarGroup.transmissonName andFilterCode:tempCarGroup.transmissonId andArray:transmissionFilter];
//                }
//                
//                if (section == 2) {
//                    [self refillFilterArray:tempCarGroup.fuelName andFilterCode:tempCarGroup.fuelId andArray:fuelFilter];
//                    [self refillFilterArray:tempCarGroup.sampleCar.brandName andFilterCode:tempCarGroup.sampleCar.brandId andArray:brandFilter];
//                    [self refillFilterArray:tempCarGroup.bodyName andFilterCode:tempCarGroup.bodyId andArray:bodyFilter];
//                    [self refillFilterArray:tempCarGroup.transmissonName andFilterCode:tempCarGroup.transmissonId andArray:transmissionFilter];
//                }
//                
//                if (section == 3) {
//                    [self refillFilterArray:tempCarGroup.fuelName andFilterCode:tempCarGroup.fuelId andArray:fuelFilter];
//                    [self refillFilterArray:tempCarGroup.segmentName andFilterCode:tempCarGroup.segment andArray:segmentFilter];
//                    [self refillFilterArray:tempCarGroup.sampleCar.brandName andFilterCode:tempCarGroup.sampleCar.brandId andArray:brandFilter];
//                    [self refillFilterArray:tempCarGroup.transmissonName andFilterCode:tempCarGroup.transmissonId andArray:transmissionFilter];
//                }
//                
//                if (section == 4) {
//                    [self refillFilterArray:tempCarGroup.fuelName andFilterCode:tempCarGroup.fuelId andArray:fuelFilter];
//                    [self refillFilterArray:tempCarGroup.segmentName andFilterCode:tempCarGroup.segment andArray:segmentFilter];
//                    [self refillFilterArray:tempCarGroup.bodyName andFilterCode:tempCarGroup.bodyId andArray:bodyFilter];
//                    [self refillFilterArray:tempCarGroup.sampleCar.brandName andFilterCode:tempCarGroup.sampleCar.brandId andArray:brandFilter];
//                }
            }
        }
    }
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
    if (indexPath.section == 5)
        return [modelFilter objectAtIndex:indexPath.row];
    if (indexPath.section == 6)
        return [modelYearFilter objectAtIndex:indexPath.row];
    if (indexPath.section == 7)
        return [colorFilter objectAtIndex:indexPath.row];
    if (indexPath.section == 8)
        return [engineVolumeFilter objectAtIndex:indexPath.row];
    if (indexPath.section == 9)
        return [horsePowerFilter objectAtIndex:indexPath.row];
    
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
    if (section == 5)
        [self calculateFilterResult:modelFilter];
    if (section == 6)
        [self calculateFilterResult:modelYearFilter];
    if (section == 7)
        [self calculateFilterResult:colorFilter];
    if (section == 8)
        [self calculateFilterResult:engineVolumeFilter];
    if (section == 9)
        [self calculateFilterResult:horsePowerFilter];
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
    if (section != 5){
        [[modelFilter objectAtIndex:0] setIsSelected:NO];
    }
    if (section != 6){
        [[modelYearFilter objectAtIndex:0] setIsSelected:NO];
    }
    if (section != 7){
        [[colorFilter objectAtIndex:0] setIsSelected:NO];
    }
    if (section != 8){
        [[engineVolumeFilter objectAtIndex:0] setIsSelected:NO];
    }
    if (section != 9){
        [[horsePowerFilter objectAtIndex:0] setIsSelected:NO];
    }
}


- (void)fillFiltersInArrays
{
    //bir ömür gitti buna -ATA
    //ve malesef değişecek :D :( -alp
    
    [self buildFuelFilter:fuelFilter];
    
    [self buildSegmentFilter:segmentFilter];
    
    [self buildBodyFilter:bodyFilter];
    
    [self buildTransmissionFilter:transmissionFilter];
    
    [self buildBrandFilter:brandFilter];
    
    [self buildModelFilter:modelFilter];
    
    [self buildModelYearFilter:modelYearFilter];
    
    [self buildColorFilter:colorFilter];
    
    [self buildEngineVolumeFilter:engineVolumeFilter];
    
    [self buildHorsePowerFilter:horsePowerFilter];
}

- (void)buildFuelFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object1 = [[FilterObject alloc] init];
    [object1 setFilterDescription:@"Yakıt Tipi"];
    [object1 setFilterResult:@""];
    [object1 setIsSelected:NO];
    [dynamicArray addObject:object1];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.fuelId]) {
            object1 = [[FilterObject alloc] init];
            [object1 setFilterDescription:@""];
            [object1 setFilterResult:tempCarGroup.fuelName];
            [object1 setFilterCode:tempCarGroup.fuelId];
            [object1 setIsSelected:NO];
            [dynamicArray addObject:object1];
        }
    }
    
    [self calculateFilterResult:dynamicArray];
}

- (void)buildSegmentFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object = [[FilterObject alloc] init];
    [object setFilterDescription:@"Kategori Tipi"];
    [object setFilterResult:@""];
    [object setIsSelected:NO];
    [dynamicArray addObject:object];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.segment]) {
            object = [[FilterObject alloc] init];
            [object setFilterDescription:@""];
            [object setFilterResult:tempCarGroup.segmentName];
            [object setFilterCode:tempCarGroup.segment];
            [object setIsSelected:NO];
            [dynamicArray addObject:object];
        }
        
    }
    
    
    [self calculateFilterResult:dynamicArray];
}

- (void)buildBodyFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object = [[FilterObject alloc] init];
    [object setFilterDescription:@"Kasa Tipi"];
    [object setFilterResult:@""];
    [object setIsSelected:NO];
    [dynamicArray addObject:object];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.bodyId]) {
            object = [[FilterObject alloc] init];
            [object setFilterDescription:@""];
            [object setFilterResult:tempCarGroup.bodyName];
            [object setFilterCode:tempCarGroup.bodyId];
            [object setIsSelected:NO];
            [dynamicArray addObject:object];
        }
        
    }
    
    [self calculateFilterResult:dynamicArray];
    
    
}

- (void)buildTransmissionFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object = [[FilterObject alloc] init];
    [object setFilterDescription:@"Vites Tipi"];
    [object setFilterResult:@""];
    [object setIsSelected:NO];
    [dynamicArray addObject:object];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.transmissonId]) {
            object = [[FilterObject alloc] init];
            [object setFilterDescription:@""];
            [object setFilterResult:tempCarGroup.transmissonName];
            [object setFilterCode:tempCarGroup.transmissonId];
            [object setIsSelected:NO];
            [dynamicArray addObject:object];
        }
    }
    [self calculateFilterResult:dynamicArray];
}


- (void)buildBrandFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object = [[FilterObject alloc] init];
    [object setFilterDescription:@"Marka"];
    [object setFilterResult:@""];
    [object setIsSelected:NO];
    [dynamicArray addObject:object];
    for (CarGroup *tempCarGroup in self.carGroups) {
        for(Car *tempCar in tempCarGroup.cars)
            if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCar.brandId]) {
                object = [[FilterObject alloc] init];
                [object setFilterDescription:@""];
                [object setFilterResult:tempCar.brandName];
                [object setFilterCode:tempCar.brandId];
                [object setIsSelected:NO];
                [dynamicArray addObject:object];
            }
    }
    
    [self calculateFilterResult:dynamicArray];
}

- (void)buildModelFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object1 = [[FilterObject alloc] init];
    [object1 setFilterDescription:@"Model"];
    [object1 setFilterResult:@""];
    [object1 setIsSelected:NO];
    [dynamicArray addObject:object1];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.sampleCar.modelId]) {
            object1 = [[FilterObject alloc] init];
            [object1 setFilterDescription:@""];
            [object1 setFilterResult:tempCarGroup.sampleCar.modelName];
            [object1 setFilterCode:tempCarGroup.sampleCar.modelId];
            [object1 setIsSelected:NO];
            [dynamicArray addObject:object1];
        }
    }
    
    [self calculateFilterResult:dynamicArray];
}

- (void)buildModelYearFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object1 = [[FilterObject alloc] init];
    [object1 setFilterDescription:@"Model Yılı"];
    [object1 setFilterResult:@""];
    [object1 setIsSelected:NO];
    [dynamicArray addObject:object1];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.sampleCar.modelYear]) {
            object1 = [[FilterObject alloc] init];
            [object1 setFilterDescription:@""];
            [object1 setFilterResult:tempCarGroup.sampleCar.modelYear];
            [object1 setFilterCode:tempCarGroup.sampleCar.modelYear];
            [object1 setIsSelected:NO];
            [dynamicArray addObject:object1];
        }
    }
    
    [self calculateFilterResult:dynamicArray];
}

- (void)buildColorFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object1 = [[FilterObject alloc] init];
    [object1 setFilterDescription:@"Renk"];
    [object1 setFilterResult:@""];
    [object1 setIsSelected:NO];
    [dynamicArray addObject:object1];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.sampleCar.colorCode]) {
            object1 = [[FilterObject alloc] init];
            [object1 setFilterDescription:@""];
            [object1 setFilterResult:tempCarGroup.sampleCar.colorName];
            [object1 setFilterCode:tempCarGroup.sampleCar.colorCode];
            [object1 setIsSelected:NO];
            [dynamicArray addObject:object1];
        }
    }
    
    [self calculateFilterResult:dynamicArray];
}

- (void)buildEngineVolumeFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object1 = [[FilterObject alloc] init];
    [object1 setFilterDescription:@"Motor Hacmi"];
    [object1 setFilterResult:@""];
    [object1 setIsSelected:NO];
    [dynamicArray addObject:object1];
    
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.sampleCar.engineVolumeCode]) {
            object1 = [[FilterObject alloc] init];
            [object1 setFilterDescription:@""];
            [object1 setFilterResult:tempCarGroup.sampleCar.engineVolumeCode];
            [object1 setFilterCode:tempCarGroup.sampleCar.engineVolumeCode];
            [object1 setIsSelected:NO];
            [dynamicArray addObject:object1];
        }
    }
    
    [self calculateFilterResult:dynamicArray];
}

- (void)buildHorsePowerFilter:(NSMutableArray *)dynamicArray{
    FilterObject *object1 = [[FilterObject alloc] init];
    [object1 setFilterDescription:@"Beygir Gücü"];
    [object1 setFilterResult:@""];
    [object1 setIsSelected:NO];
    [dynamicArray addObject:object1];
    for (CarGroup *tempCarGroup in self.carGroups) {
        if (![self isFilterIdFoundFromFilterList:dynamicArray withId:tempCarGroup.sampleCar.horsePowerCode]) {
            object1 = [[FilterObject alloc] init];
            [object1 setFilterDescription:@""];
            [object1 setFilterResult:tempCarGroup.sampleCar.horsePowerCode];
            [object1 setFilterCode:tempCarGroup.sampleCar.horsePowerCode];
            [object1 setIsSelected:NO];
            [dynamicArray addObject:object1];
        }
    }
    
    [self calculateFilterResult:dynamicArray];
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
    [self filterModel];
    [self filterModelYear];
    [self filterColor];
    [self filterEngineVolume];
    [self filterHorsePower];
    
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

- (void)filterModel
{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in modelFilter) {
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
                    if ([tempObject.filterCode isEqualToString:tempGroup.sampleCar.modelId]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    filteredCarGroups = newArray;
}

- (void)filterModelYear
{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in modelYearFilter) {
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
                    if ([tempObject.filterCode isEqualToString:tempGroup.sampleCar.modelYear]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    filteredCarGroups = newArray;
}

- (void)filterColor
{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in colorFilter) {
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
                    if ([tempObject.filterCode isEqualToString:tempGroup.sampleCar.colorCode]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    filteredCarGroups = newArray;
}

- (void)filterEngineVolume
{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in engineVolumeFilter) {
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
                    if ([tempObject.filterCode isEqualToString:tempGroup.sampleCar.engineVolumeCode]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    filteredCarGroups = newArray;
}

- (void)filterHorsePower
{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (FilterObject *tempObject in horsePowerFilter) {
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
                    if ([tempObject.filterCode isEqualToString:tempGroup.sampleCar.horsePowerCode]) {
                        [newArray addObject:tempGroup];
                    }
                }
            }
        }
    }
    
    filteredCarGroups = newArray;
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
