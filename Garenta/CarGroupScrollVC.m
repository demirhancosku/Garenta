//
//  FilterSliderVC.m
//  Garenta
//
//  Created by Kerem Balaban on 22.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//
// Bu classi silmedim ki kerem baksin ve uzulsun...yaptigin hersey bosa kerem ...hersey
#import "CarGroupScrollVC.h"
#import "GTMBase64.h"
@interface CarGroupScrollVC ()

@end

@implementation CarGroupScrollVC
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
    [self connectToGateway];
}

-(void)viewWillAppear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:YES];
}

- (void)addFilterSliderToView
{
    self.imageHostScrollView = [[UIScrollView alloc] initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.4))];
    self.imageHostScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.imageHostScrollView.frame)*3, CGRectGetHeight(self.imageHostScrollView.frame));
    self.imageHostScrollView.delegate = self;
    
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
    [self.view addSubview:self.imageHostScrollView];
    
    CGRect rect = CGRectZero;
    
    rect.size = CGSizeMake(CGRectGetWidth(self.imageHostScrollView.frame), CGRectGetHeight(self.imageHostScrollView.frame)*0.5);
    
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
    [self.galleryImages insertObject:[[NSBundle mainBundle] pathForResource:@"a_grubu" ofType:@"jpg"] atIndex:0];
    [self.galleryImages insertObject:[[NSBundle mainBundle] pathForResource:@"b_grubu" ofType:@"jpg"] atIndex:1];
    [self.galleryImages insertObject:[[NSBundle mainBundle] pathForResource:@"c_grubu" ofType:@"jpg"] atIndex:2];
    [self.galleryImages insertObject:[[NSBundle mainBundle] pathForResource:@"d_grubu" ofType:@"jpg"] atIndex:3];
    
    self.currentIndex = 0;
}

- (void)addTableView
{
    filterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.imageHostScrollView.frame.size.height, self.view.frame.size.width, (self.view.frame.size.height - self.imageHostScrollView.frame.size.height)) style:UITableViewStyleGrouped];
    
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
    
    if (i == 0) {
       [[cell textLabel] setText:@"A grubu"];
    }
    else if (i == 1)
    {
        [[cell textLabel] setText:@"B grubu"];
    }
    else if (i == 2)
    {
        [[cell textLabel] setText:@"C grubu"];
    }
    else if (i == 3)
    {
        [[cell textLabel] setText:@"D grubu"];
    }
    
    i = i + 1;
    
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


//aalpk silince
- (void)connectToGateway
{
    NSString *connectionString = @"https://172.17.1.149:8000/sap/opu/odata/sap/ZGARENTA_TEST_SRV/RESIM_TEST(IPath='6')?$format=json";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"gw_admin"
                                                                    password:@"1qa2ws3ed"
                                                                 persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *err;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];

    NSDictionary *result = [jsonDict objectForKey:@"d"];
    NSString *abdullah = [NSString stringWithFormat:@"%@",[result objectForKey:@"EPicture"]];
    NSData *theData =
    [NSData dataWithData:[YAJL_GTMBase64 decodeString:abdullah]];
    UIImageView *ata = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [ata setImage:[UIImage imageWithData:theData]];
    [[self view] addSubview:ata];
    //NSDictionary *officeListDict = [result objectForKey:@"EXPT_SUBE_BILGILERISet"];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"gateway hatasi");
}

@end
