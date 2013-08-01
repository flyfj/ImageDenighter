//
//  vsNavigationController.m
//  ImageDenighter
//
//  Created by jiefeng on 7/31/13.
//  Copyright (c) 2013 jiefeng. All rights reserved.
//

#import "vsNavigationController.h"

@interface vsNavigationController ()

@end

@implementation vsNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

@end
