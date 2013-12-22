//
//  FilterSliderVC.h
//  Garenta
//
//  Created by Kerem Balaban on 22.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterScreenVC : UIViewController <UIActionSheetDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
{
@private
    NSMutableArray *galleryImages_;
    NSInteger currentIndex_;
    NSInteger previousPage_;
}
@property (nonatomic, retain) UIImageView *prevImgView; //reusable Imageview  - always contains the previous image
@property (nonatomic, retain) UIImageView *centerImgView; //reusable Imageview  - always contains the currently shown image
@property (nonatomic, retain) UIImageView *nextImgView; //reusable Imageview  - always contains the next image image
@property(nonatomic, retain) NSMutableArray *galleryImages; //Array holding the image file paths
@property(nonatomic, retain) UIScrollView *imageHostScrollView; //UIScrollview to hold the images
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, retain) UITableView *filterTableView;

#pragma mark - image loading-
//Simple method to load the UIImage, which can be extensible -
-(UIImage *)imageAtIndex:(NSInteger)inImageIndex;

@end
