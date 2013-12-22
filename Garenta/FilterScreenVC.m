//
//  FilterSliderVC.m
//  Garenta
//
//  Created by Kerem Balaban on 22.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "FilterScreenVC.h"

@interface FilterScreenVC ()

@end

@implementation FilterScreenVC
@synthesize galleryImages = galleryImages_;
@synthesize imageHostScrollView = imageHostScrollView_;
@synthesize currentIndex = currentIndex_;
@synthesize filterTableView;
@synthesize prevImgView;
@synthesize centerImgView;
@synthesize nextImgView;

#define safeModulo(x,y) ((y + x % y) % y)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //slider menü buraya ekleniyo
    [self addFilterSliderToView];
    [self addTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:YES];
}

- (void)addFilterSliderToView
{
    self.imageHostScrollView = [[UIScrollView alloc] initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.1))];
    self.imageHostScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.imageHostScrollView.frame)*3, CGRectGetHeight(self.imageHostScrollView.frame));
    self.imageHostScrollView.delegate = self;
    
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    [self.view addSubview:self.imageHostScrollView];
    
    CGRect rect = CGRectZero;
    
    rect.size = CGSizeMake(CGRectGetWidth(self.imageHostScrollView.frame), CGRectGetHeight(self.imageHostScrollView.frame));
    
    // add prevView as first in line
    UIImageView *prevView = [[UIImageView alloc] initWithFrame:rect];
    self.prevImgView = prevView;
    
    UIScrollView *scrView = [[UIScrollView alloc] initWithFrame:rect];
    [self.imageHostScrollView addSubview:scrView];
    
    scrView.delegate = self;
    [scrView addSubview:self.prevImgView];
    scrView.minimumZoomScale = 0.5;
    scrView.maximumZoomScale = 2.5;
    self.prevImgView.frame = scrView.bounds;
    
    // add currentView in the middle (center)
    rect.origin.x += CGRectGetWidth(self.imageHostScrollView.frame);
    UIImageView *currentView = [[UIImageView alloc] initWithFrame:rect];
    self.centerImgView = currentView;
    //    [self.imageHostScrollView addSubview:self.centerImgView];
    
    scrView = [[UIScrollView alloc] initWithFrame:rect];
    scrView.delegate = self;
    scrView.minimumZoomScale = 0.5;
    scrView.maximumZoomScale = 2.5;
    [self.imageHostScrollView addSubview:scrView];
    
    [scrView addSubview:self.centerImgView];
    self.centerImgView.frame = scrView.bounds;
    
    // add nextView as third view
    rect.origin.x += CGRectGetWidth(self.imageHostScrollView.frame);
    UIImageView *nextView = [[UIImageView alloc] initWithFrame:rect];
    self.nextImgView = nextView;
    //    [self.imageHostScrollView addSubview:self.nextImgView];
    
    scrView = [[UIScrollView alloc] initWithFrame:rect];
    [self.imageHostScrollView addSubview:scrView];
    scrView.delegate = self;
    scrView.minimumZoomScale = 0.5;
    scrView.maximumZoomScale = 2.5;
    
    [scrView addSubview:self.nextImgView];
    self.nextImgView.frame = scrView.bounds;
    
    // center the scrollview to show the middle view only
    [self.imageHostScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.imageHostScrollView.frame), 0)  animated:NO];
    self.imageHostScrollView.userInteractionEnabled=YES;
    self.imageHostScrollView.pagingEnabled = YES;
    self.imageHostScrollView.delegate = self;
    
    self.prevImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.centerImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.nextImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    //some data for testing
    self.galleryImages = [[NSMutableArray alloc] init];
//    [self.galleryImages insertObject:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"] atIndex:0];
//    [self.galleryImages insertObject:[[NSBundle mainBundle] pathForResource:@"2" ofType:@"png"] atIndex:1];
//    [self.galleryImages insertObject:[[NSBundle mainBundle] pathForResource:@"3" ofType:@"png"] atIndex:2];
//    [self.galleryImages insertObject:[[NSBundle mainBundle] pathForResource:@"4" ofType:@"png"] atIndex:3];
    
    [self.galleryImages addObject:[UIImage imageNamed:@"1.png"]];
    [self.galleryImages addObject:[UIImage imageNamed:@"2.png"]];
    [self.galleryImages addObject:[UIImage imageNamed:@"3.png"]];
    [self.galleryImages addObject:[UIImage imageNamed:@"4.png"]];
    
    self.currentIndex = 0;
}

- (void)addTableView
{
    filterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.imageHostScrollView.frame.size.height, self.view.frame.size.width, (self.view.frame.size.height - self.imageHostScrollView.frame.size.height))];
    
    [[self view] addSubview:filterTableView];
    [filterTableView setDelegate:self];
    [filterTableView setDataSource:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //    return [officeList count];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    [[cell textLabel] setText:@"İstanbul Atatürk Havalimanı"];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - color button actions-
#pragma mark -page controller action-
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;{
    CGFloat pageWidth = scrollView.frame.size.width;
    previousPage_ = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    CGFloat pageWidth = sender.frame.size.width;
    int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    //incase we are still in same page, ignore the swipe action
    if(previousPage_ == page) return;
    
    if(sender.contentOffset.x >= sender.frame.size.width) {
        //swipe left, go to next image
        [self setRelativeIndex:1];
        
        // center the scrollview to the center UIImageView
        [self.imageHostScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.imageHostScrollView.frame), 0)  animated:NO];
	}
	else if(sender.contentOffset.x < sender.frame.size.width) {
        //swipe right, go to previous image
        [self setRelativeIndex:-1];
        
        // center the scrollview to the center UIImageView
        [self.imageHostScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.imageHostScrollView.frame), 0)  animated:NO];
	}
    
    UIScrollView *scrollView = (UIScrollView *)self.centerImgView.superview;
    scrollView.zoomScale = 1.0;

}
#pragma mark - image loading-

-(UIImage *)imageAtIndex:(NSInteger)inImageIndex;{
    // limit the input to the current number of images, using modulo math
    inImageIndex = safeModulo(inImageIndex, [self totalImages]);
    
    NSString *filePath = [self.galleryImages objectAtIndex:inImageIndex];
    
	UIImage *image = nil;
    //Otherwise load from the file path
    if (nil == image)
    {
		NSString *imagePath = filePath;
		if(imagePath){
			if([imagePath isAbsolutePath]){
				image = [UIImage imageWithContentsOfFile:imagePath];
			}
			else{
				image = [UIImage imageNamed:imagePath];
			}
            
            if(nil == image){
				image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]];
				
			}
        }
    }
    
	return image;
}

#pragma mark -

- (NSInteger)totalImages {
    return [self.galleryImages count];
}
- (NSInteger)currentIndex {
    
    return safeModulo(currentIndex_, [self totalImages]);
}

- (void)setCurrentIndex:(NSInteger)inIndex {
    currentIndex_ = inIndex;

    
    [filterTableView reloadData];
    
    if([galleryImages_ count] > 0){
        self.prevImgView.image   = [self imageAtIndex:[self relativeIndex:-1]];
        self.centerImgView.image = [self imageAtIndex:[self relativeIndex: 0]];
        self.nextImgView.image   = [self imageAtIndex:[self relativeIndex: 1]];
    }
}

- (NSInteger)relativeIndex:(NSInteger)inIndex {
    return safeModulo(([self currentIndex] + inIndex), [self totalImages]);
}

- (void)setRelativeIndex:(NSInteger)inIndex {
    [self setCurrentIndex:self.currentIndex + inIndex];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
