//
//  vsCore.h
//  a toolset for ios use
//  visualsearch
//
//  Created by jiefeng on 11/4/12.
//  Copyright (c) 2012 jiefeng. All rights reserved.
//

#import <Foundation/Foundation.h>

using namespace cv;


@interface vsCore : NSObject


// opencv mat <-> uiimage
+ (Mat) matFromUIImage: (UIImage*) image;
+ (Mat) grayMatFromUIImage: (UIImage*) image;
+ (UIImage*) uiimageFromMat: (Mat) image;

// scale to specific max resolution and rotate image s.t. orientation is up
+ (UIImage *)scaleAndRotateImage:(UIImage *)image toMaxResolution: (int) kMaxResolution;


@end
