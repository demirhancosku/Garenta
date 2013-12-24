//
//  CarGroupFilterVC.m
//  Garenta
//
//  Created by Ata  Cengiz on 24.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupFilterVC.h"

@interface CarGroupFilterVC ()

@end

@implementation CarGroupFilterVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fillFiltersInArrays];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [tableView setRowHeight:50.0f];
    [tableView setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width * 0.15, 0, 0)];
    
    [[self view] addSubview:tableView];
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
        if ([[brandType objectAtIndex:0] isSelected])
            return [brandType count];
        else
            return 1;
    }
    
    if (section == 1)
    {
        if ([[fuelType objectAtIndex:0] isSelected])
            return [fuelType count];
        else
            return 1;
    }
    
    if (section == 2)
    {
            if ([[categoryType objectAtIndex:0] isSelected])
                return [categoryType count];
            else
                return 1;
    }
    
    if (section == 3)
    {
        if ([[bodyType objectAtIndex:0] isSelected])
            return [bodyType count];
        else
            return 1;
    }
    
    if (section == 4)
    {
        if ([[gearboxType objectAtIndex:0] isSelected])
            return [gearboxType count];
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
    
    [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]];
    
    
    FilterObject *tempFilter;
    
    if (section == 0)
        tempFilter = [brandType objectAtIndex:row];
    if (section == 1)
        tempFilter = [fuelType objectAtIndex:row];
    if (section == 2)
        tempFilter = [categoryType objectAtIndex:row];
    if (section == 3)
        tempFilter = [bodyType objectAtIndex:row];
    if (section == 4)
        tempFilter = [gearboxType objectAtIndex:row];
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    
    FilterObject *tempFilter;
    
    if (section == 0)
        tempFilter = [brandType objectAtIndex:row];
    if (section == 1)
        tempFilter = [fuelType objectAtIndex:row];
    if (section == 2)
        tempFilter = [categoryType objectAtIndex:row];
    if (section == 3)
        tempFilter = [bodyType objectAtIndex:row];
    if (section == 4)
        tempFilter = [gearboxType objectAtIndex:row];
    
        if ([tempFilter isSelected])
        {
            [tempFilter setIsSelected:NO];
            
            if (section == 0)
                [self calculateFilterResult:brandType];
            if (section == 1)
                [self calculateFilterResult:fuelType];
            if (section == 2)
                [self calculateFilterResult:categoryType];
            if (section == 3)
                [self calculateFilterResult:bodyType];
            if (section == 4)
                [self calculateFilterResult:gearboxType];

            if (row == 0)
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
            else
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];

        }
        else
        {
            [tempFilter setIsSelected:YES];
            
            if (section == 0)
                [self calculateFilterResult:brandType];
            if (section == 1)
                [self calculateFilterResult:fuelType];
            if (section == 2)
                [self calculateFilterResult:categoryType];
            if (section == 3)
                [self calculateFilterResult:bodyType];
            if (section == 4)
                [self calculateFilterResult:gearboxType];
            
            if (row == 0)
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
            else
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
}

- (void)fillFiltersInArrays
{
    //bir ömür gitti buna -ATA
    
    fuelType = [[NSMutableArray alloc] init];
    
    FilterObject *object1 = [[FilterObject alloc] init];
    [object1 setFilterDescription:@"Yakıt Tipi"];
    [object1 setFilterResult:@""];
    [object1 setIsSelected:NO];
    [fuelType addObject:object1];
    
    FilterObject *object2 = [[FilterObject alloc] init];
    [object2 setFilterCode:@"10"];
    [object2 setFilterResult:@"Benzin"];
    [object2 setIsSelected:NO];
    [fuelType addObject:object2];
    
    FilterObject *object3 = [[FilterObject alloc] init];
    [object3 setFilterCode:@"20"];
    [object3 setFilterResult:@"Dizel"];
    [object3 setIsSelected:NO];
    [fuelType addObject:object3];
    
    [self calculateFilterResult:fuelType];
    
    categoryType = [[NSMutableArray alloc] init];
    
    FilterObject *object4 = [[FilterObject alloc] init];
    [object4 setFilterDescription:@"Kategori Tipi"];
    [object4 setFilterResult:@""];
    [object4 setIsSelected:NO];
    [categoryType addObject:object4];
    
    FilterObject *object5 = [[FilterObject alloc] init];
    [object5 setFilterDescription:@""];
    [object5 setFilterResult:@"Ekonomik"];
    [object5 setFilterCode:@"30"];
    [object5 setIsSelected:NO];
    [categoryType addObject:object5];
    
    FilterObject *object6 = [[FilterObject alloc] init];
    [object6 setFilterDescription:@""];
    [object6 setFilterResult:@"Standart"];
    [object6 setFilterCode:@"40"];
    [object6 setIsSelected:NO];
    [categoryType addObject:object6];
    
    FilterObject *object7= [[FilterObject alloc] init];
    [object7 setFilterDescription:@""];
    [object7 setFilterResult:@"Konfor"];
    [object7 setFilterCode:@"50"];
    [object7 setIsSelected:NO];
    [categoryType addObject:object7];
    
    FilterObject *object8 = [[FilterObject alloc] init];
    [object8 setFilterDescription:@""];
    [object8 setFilterResult:@"Maksi"];
    [object8 setFilterCode:@"60"];
    [object8 setIsSelected:NO];
    [categoryType addObject:object8];
    
    FilterObject *object9 = [[FilterObject alloc] init];
    [object9 setFilterDescription:@""];
    [object9 setFilterResult:@"Lüks"];
    [object9 setFilterCode:@"70"];
    [object9 setIsSelected:NO];
    [categoryType addObject:object9];
    
    FilterObject *object10 = [[FilterObject alloc] init];
    [object10 setFilterDescription:@""];
    [object10 setFilterResult:@"Stil"];
    [object10 setFilterCode:@"80"];
    [object10 setIsSelected:NO];
    [categoryType addObject:object10];
    
    FilterObject *object11 = [[FilterObject alloc] init];
    [object11 setFilterDescription:@""];
    [object11 setFilterResult:@"Elit"];
    [object11 setFilterCode:@"90"];
    [object11 setIsSelected:NO];
    [categoryType addObject:object11];
    
    FilterObject *object12 = [[FilterObject alloc] init];
    [object12 setFilterDescription:@""];
    [object12 setFilterResult:@"SUV"];
    [object12 setFilterCode:@"100"];
    [object12 setIsSelected:NO];
    [categoryType addObject:object12];
    
    FilterObject *object13 = [[FilterObject alloc] init];
    [object13 setFilterDescription:@""];
    [object13 setFilterResult:@"Fonksiyonel"];
    [object13 setFilterCode:@"110"];
    [object13 setIsSelected:NO];
    [categoryType addObject:object13];
    
    [self calculateFilterResult:categoryType];
    
    bodyType = [[NSMutableArray alloc] init];
    
    FilterObject *object14 = [[FilterObject alloc] init];
    [object14 setFilterDescription:@"Kasa Tipi"];
    [object14 setFilterResult:@""];
    [object14 setFilterCode:@""];
    [object14 setIsSelected:NO];
    [bodyType addObject:object14];
    
    FilterObject *object15 = [[FilterObject alloc] init];
    [object15 setFilterDescription:@""];
    [object15 setFilterResult:@"Sedan"];
    [object15 setFilterCode:@"120"];
    [object15 setIsSelected:NO];
    [bodyType addObject:object15];
    
    FilterObject *object16 = [[FilterObject alloc] init];
    [object16 setFilterDescription:@""];
    [object16 setFilterResult:@"Hatchback"];
    [object16 setFilterCode:@"130"];
    [object16 setIsSelected:NO];
    [bodyType addObject:object16];
    
    FilterObject *object17 = [[FilterObject alloc] init];
    [object17 setFilterDescription:@""];
    [object17 setFilterResult:@"SUV"];
    [object17 setFilterCode:@"140"];
    [object17 setIsSelected:NO];
    [bodyType addObject:object17];
    
    [self calculateFilterResult:bodyType];
    
    gearboxType = [[NSMutableArray alloc] init];
    
    FilterObject *object18 = [[FilterObject alloc] init];
    [object18 setFilterDescription:@"Vites Tipi"];
    [object18 setFilterResult:@""];
    [object18 setFilterCode:@""];
    [object18 setIsSelected:NO];
    [gearboxType addObject:object18];
    
    FilterObject *object19 = [[FilterObject alloc] init];
    [object19 setFilterDescription:@""];
    [object19 setFilterResult:@"Manuel"];
    [object19 setFilterCode:@"150"];
    [object19 setIsSelected:NO];
    [gearboxType addObject:object19];
    
    FilterObject *object20 = [[FilterObject alloc] init];
    [object20 setFilterDescription:@""];
    [object20 setFilterResult:@"Triptonik"];
    [object20 setFilterCode:@"160"];
    [object20 setIsSelected:NO];
    [gearboxType addObject:object20];
    
    FilterObject *object21 = [[FilterObject alloc] init];
    [object21 setFilterDescription:@""];
    [object21 setFilterResult:@"Otomatik"];
    [object21 setFilterCode:@"170"];
    [object21 setIsSelected:NO];
    [gearboxType addObject:object21];
    
    [self calculateFilterResult:gearboxType];
    
    brandType = [[NSMutableArray alloc] init];
    
    FilterObject *object22 = [[FilterObject alloc] init];
    [object22 setFilterDescription:@"Marka"];
    [object22 setFilterResult:@""];
    [object22 setFilterCode:@""];
    [object22 setIsSelected:NO];
    [brandType addObject:object22];
    
    FilterObject *object23 = [[FilterObject alloc] init];
    [object23 setFilterDescription:@""];
    [object23 setFilterResult:@"AUDI"];
    [object23 setFilterCode:@"180"];
    [object23 setIsSelected:NO];
    [brandType addObject:object23];
    
    FilterObject *object24 = [[FilterObject alloc] init];
    [object24 setFilterDescription:@""];
    [object24 setFilterResult:@"BMW"];
    [object24 setFilterCode:@"190"];
    [object24 setIsSelected:NO];
    [brandType addObject:object24];
    
    FilterObject *object25 = [[FilterObject alloc] init];
    [object25 setFilterDescription:@""];
    [object25 setFilterResult:@"FIAT"];
    [object25 setFilterCode:@"200"];
    [object25 setIsSelected:NO];
    [brandType addObject:object25];
    
    FilterObject *object29 = [[FilterObject alloc] init];
    [object29 setFilterDescription:@""];
    [object29 setFilterResult:@"KIA"];
    [object29 setFilterCode:@"230"];
    [object29 setIsSelected:NO];
    [brandType addObject:object29];
    
    FilterObject *object28 = [[FilterObject alloc] init];
    [object28 setFilterDescription:@""];
    [object28 setFilterResult:@"MERCEDES"];
    [object28 setFilterCode:@"220"];
    [object28 setIsSelected:NO];
    [brandType addObject:object28];
    
    FilterObject *object30 = [[FilterObject alloc] init];
    [object30 setFilterDescription:@""];
    [object30 setFilterResult:@"OPEL"];
    [object30 setFilterCode:@"240"];
    [object30 setIsSelected:NO];
    [brandType addObject:object30];
    
    FilterObject *object27 = [[FilterObject alloc] init];
    [object27 setFilterDescription:@""];
    [object27 setFilterResult:@"RENAULT"];
    [object27 setFilterCode:@"210"];
    [object27 setIsSelected:NO];
    [brandType addObject:object27];
    
    [self calculateFilterResult:brandType];
}

@end
