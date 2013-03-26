//
//  vsViewController.m
//  ImageDenighter
//
//  Created by jiefeng on 1/19/13.
//  Copyright (c) 2013 jiefeng. All rights reserved.
//

#import "vsViewController.h"

@interface vsViewController () {
    int frame_count;
}

@end

@implementation vsViewController


@synthesize videoCamera = _videoCamera;
@synthesize videoSwitcher = _videoSwitcher;
@synthesize modeSelector = _modeSelector;
@synthesize captureImgViewer = _captureImgViewer;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        
    [self initVideoCpature];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Camera Control


- (void) initVideoCpature {
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.captureImgViewer];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 15;
    self.videoCamera.grayscaleMode = NO;
    
}

- (void) startCamera
{
    
    if(self.videoCamera == nil)
        [self initVideoCpature];
    
    if( ![self.videoCamera running] )
        [self.videoCamera start];
    
    
    
}

- (void) stopCamera
{
    
    if([self.videoCamera running])
        [self.videoCamera stop];    // can't stop multiple times! BAD_ACCESS
    
}


// delegate processing method
- (void) processImage:(cv::Mat &)image {
    
    Mat resize_img;
    resize(image, resize_img, cv::Size(image.cols/2, image.rows/2));
    
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
    
}



- (IBAction)videoSwitchChanged:(id)sender {
    
    if(self.videoSwitcher.on == YES)
        [self startCamera];
    else
        [self stopCamera];
}
@end
