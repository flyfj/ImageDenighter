//
//  vsViewController.h
//  ImageDenighter
//
//  Created by jiefeng on 1/19/13.
//  Copyright (c) 2013 jiefeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/highgui/ios.h>
#include "ImgEnhancer.h"
using namespace cv;

@interface vsVideoViewController : UIViewController <CvVideoCameraDelegate, UINavigationBarDelegate, ADBannerViewDelegate>
{
     ImgEnhancer denighter;
}


@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (weak, nonatomic) IBOutlet UIImageView *captureImgViewer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSelector;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;


@end
