//
//  CountrySelectionVC.h
//  Garenta
//
//  Created by Ata Cengiz on 08/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountrySelectionVC : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate>

@property (nonatomic, strong) NSArray *selectionArray;
@property (nonatomic, strong) NSArray *filterResultArray;
@property (nonatomic) NSInteger searchType;

@end
