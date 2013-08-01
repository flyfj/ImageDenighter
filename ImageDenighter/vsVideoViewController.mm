//
//  vsViewController.m
//  ImageDenighter
//
//  Created by jiefeng on 1/19/13.
//  Copyright (c) 2013 jiefeng. All rights reserved.
//

#import "vsVideoViewController.h"

@interface vsVideoViewController () {
    int frame_count;
    bool isProcessing;
    cv::Mat cur_frame;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)cameraBtnPressed:(id)sender;
- (IBAction)saveBtnPressed:(id)sender;
- (void) updateAdBanner;

@end

@implementation vsVideoViewController


@synthesize videoCamera = _videoCamera;
@synthesize modeSelector = _modeSelector;
@synthesize captureImgViewer = _captureImgViewer;


#pragma vc functions

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        
    [self initVideoCpature];
    
    self.adBanner.hidden = YES;
    
    isProcessing = false;
}

- (void) viewDidAppear:(BOOL)animated
{
    [self updateAdBanner];
    [self startCamera];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate
{
    return NO;
}


#pragma mark Camera Control


- (void) initVideoCpature {
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.captureImgViewer];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 20;
    self.videoCamera.grayscaleMode = NO;
    
}

- (void) startCamera
{
    
    if(self.videoCamera == nil)
        [self initVideoCpature];
    
    if( ![self.videoCamera running] )
    {
        [self.videoCamera start];
    }
    
}

- (void) stopCamera
{
    
    if(self.videoCamera != nil && [self.videoCamera running])
    {
        [self.videoCamera stop];    // can't stop multiple times! BAD_ACCESS
    }
    
}


#pragma processing

// delegate processing method
- (void) processImage:(cv::Mat &)image {
    
    cv::Mat resize_img;
    resize(image, resize_img, cv::Size(image.cols/2, image.rows/2));
    //cvtColor(resize_img, resize_img, CV_BGRA2RGB);
    
    if ([self.modeSelector selectedSegmentIndex]==1) {
        if( !denighter.ifInit )
            denighter.Init(resize_img);
        else
        {
            Mat convertimg;
            cvtColor(resize_img, convertimg, CV_BGRA2BGR);
            Mat output;
            denighter.MSRCR(convertimg, output);
            cvtColor(output, resize_img, CV_BGR2BGRA);
        }
    }
    
    resize(resize_img, image, cv::Size(image.cols, image.rows));

    image.copyTo(cur_frame);
    
}


- (IBAction)cameraBtnPressed:(id)sender {
    
    if([self.videoCamera running])
    {
        // stop camera
        [self.videoCamera stop];
        
        cv::Mat rgbimg;
        cvtColor(cur_frame, rgbimg, CV_BGR2RGB);    // if not convert, will have blur image, don't know why
        self.captureImgViewer.image = MatToUIImage(rgbimg);
        
        self.saveBtn.enabled = true;
    }
    else
    {
        self.saveBtn.enabled = false;
        
        [self.videoCamera start];
    }
    
}

- (IBAction)saveBtnPressed:(id)sender {
    
    if(self.captureImgViewer.image != nil)
    {
        UIImageWriteToSavedPhotosAlbum(self.captureImgViewer.image, self, nil, nil);
        UIAlertView* promptView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Photo has been saved." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [promptView show];
    }
}


- (void) updateAdBanner
{
    self.adBanner.hidden = NO;
    //CGRect contentFrame = self.contentView.frame;
    CGRect bannerFrame = self.adBanner.frame;
    if (self.adBanner.bannerLoaded)
    {
        // show banner at the top
        bannerFrame.origin.y = 0; // onscreen
    }
    else
    {
        bannerFrame.origin.y = -bannerFrame.size.height; // offscreen
    }
    
    self.adBanner.frame = bannerFrame;
}

#pragma delegates

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self updateAdBanner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"didFailToReceiveAdWithError %@", error);
    [self updateAdBanner];
    //[self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    //[self stopTimer];
    //if([self.videoCamera running])
       // [self.videoCamera stop];
    
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}


@end
