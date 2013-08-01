//
//  vsPhotoViewController.h
//  ImageDenighter
//
//  Created by jiefeng on 7/28/13.
//  Copyright (c) 2013 jiefeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#include <opencv2/highgui/ios.h>
#include "ImgEnhancer.h"




@interface vsPhotoViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, ADBannerViewDelegate>



@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *processBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;

@property (strong, nonatomic) UIImage* pickedImg;

@end
