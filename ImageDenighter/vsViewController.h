//
//  vsViewController.h
//  ImageDenighter
//
//  Created by jiefeng on 1/19/13.
//  Copyright (c) 2013 jiefeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#include "ImgEnhancer.h"
using namespace cv;

@interface vsViewController : UIViewController <CvVideoCameraDelegate, UINavigationBarDelegate>
{
     ImgEnhancer denighter;
}


@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (weak, nonatomic) IBOutlet UIImageView *captureImgViewer;
@property (weak, nonatomic) IBOutlet UISwitch *videoSwitcher;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSelector;

- (IBAction)videoSwitchChanged:(id)sender;

@end
