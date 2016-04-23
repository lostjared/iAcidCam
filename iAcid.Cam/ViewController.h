//
//  ViewController.h
//  iAcid.Cam
//
//  Created by Jared Bruni on 6/12/13.
//  Copyright (c) 2013 Jared Bruni. All rights reserved.
//
#include<opencv2/highgui/cap_ios.h>
#import <UIKit/UIKit.h>
#import "OptionsController.h"

using namespace cv;

extern cv::VideoWriter vw;
extern BOOL recordI;

@interface ViewController : UIViewController<CvVideoCameraDelegate> {
    
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *button2;
    IBOutlet UIButton *record_V;
    IBOutlet UIButton *start_button, *switch_button, *save_button, *shift_up, *shift_down;
    CvVideoCamera *videoCamera;
    CvVideoWriter *writer;
    BOOL saveI;
    BOOL camera_pos;
    UIInterfaceOrientation startOrientation;
    UIDeviceOrientation orientation;
    IBOutlet UISlider *slider;
    IBOutlet UILabel  *slider_label;
    IBOutlet UILabel *filter_name;
    int current_res;
    UITapGestureRecognizer *doubleTap;
}
@property (nonatomic, retain) CvVideoCamera* videoCamera;
- (IBAction) startVideo:(id) sender;
- (IBAction) saveImage:(id) sender;
- (IBAction) shiftLeft: (id) sender;
- (IBAction) shiftRight: (id) sender;
- (UIImage *)UIImageFromMat:(cv::Mat)image;
- (IBAction) showOptions: (id) sender;
- (IBAction) recordVideo: (id) sender;
- (IBAction) switchCamera: (id) sender;
- (void) setViewOrientation;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (IBAction) changeSlider: (id) sender;


@end

