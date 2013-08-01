//
//  vsPhotoViewController.m
//  ImageDenighter
//
//  Created by jiefeng on 7/28/13.
//  Copyright (c) 2013 jiefeng. All rights reserved.
//

#import "vsPhotoViewController.h"

@interface vsPhotoViewController ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)processBtnPressed:(id)sender;
- (IBAction)saveBtnPressed:(id)sender;
- (void) updateAdBanner;

@end



@implementation vsPhotoViewController


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


#pragma events

- (IBAction)openBtnPressed:(id)sender {
    
    // create image picker
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    
    // check source type
    if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else{
        // error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No supported photo library"
                                                        message:@"Please choose photos instead"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    // check media type
    NSString *desired = (NSString*) kUTTypeImage;
    NSArray *medias = [UIImagePickerController availableMediaTypesForSourceType:imgPicker.sourceType];
    if([medias containsObject:desired]){
        imgPicker.mediaTypes = [NSArray arrayWithObject:desired];
    }
    else{
        // error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong media type"
                                                        message:@"No media type supported for image"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    imgPicker.editing = NO;
    
    // show camera preview to capture photo
    [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
    
}


- (IBAction)processBtnPressed:(id)sender {
    
    if (self.pickedImg == nil) {
        return;
    }
    
    UIImageOrientation old_orientation = self.pickedImg.imageOrientation;
    
    UIActivityIndicatorView* waitIndicator = [[UIActivityIndicatorView alloc] init];
    [waitIndicator performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:YES];
    
    // convert to opencv format
    cv::Mat old_img;
    UIImageToMat(self.pickedImg, old_img);
    
    // resize
    cv::resize(old_img, old_img, cv::Size(640, 480));
    // convert color
    cv::cvtColor(old_img, old_img, CV_BGRA2BGR);
    
    // process
    ImgEnhancer enhancer;
    if( !enhancer.Init(old_img) )
        return;
    
    cv::Mat res_img;
    if( !enhancer.MSRCR(old_img, res_img))
        return;
    
    // convert back to uiimage and show
    self.pickedImg = MatToUIImage(res_img);
    // rotate to correct orientation
    if (self.pickedImg.imageOrientation != old_orientation) {
        self.pickedImg = [[UIImage alloc] initWithCGImage: self.pickedImg.CGImage
                                                    scale: 1.0
                                              orientation: old_orientation];
    }
    self.photoView.image = self.pickedImg;
    
    [waitIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    
    self.saveBtn.enabled = YES;
    
}

- (IBAction)saveBtnPressed:(id)sender {
    
    if(self.pickedImg != nil)
    {
        UIImageWriteToSavedPhotosAlbum(self.pickedImg, self, nil, nil);
        UIAlertView* promptView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Photo has been saved." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [promptView show];
    }
    
}


- (void) updateAdBanner
{
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
}



#pragma delegate methods

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.pickedImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // show picked image
    self.photoView.image = self.pickedImg;
    
    self.processBtn.enabled = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:nil];
}



@end
