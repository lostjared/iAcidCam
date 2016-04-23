//
//  ViewController.m
//  iAcid.Cam
//
//  Created by Jared Bruni on 6/12/13.
//  Copyright (c) 2013 Jared Bruni. All rights reserved.
//

#import "ViewController.h"
#import "OptionsController.h"
#include "ac.h"

//cv::VideoWriter vw;


BOOL recordI;

#define MOVEMENT_X 100
#define MOVEMENT_Y 100

typedef enum { STATE_0, STATE_1 } state;

CGPoint startLocation,stopLocation;
NSTimeInterval startTime,endTime;
state stated;


void custom_filter(cv::Mat &frame) {
    
}

Mat rotateImage(const Mat& source, double angle)
{
    Point2f src_center(source.cols/2.0F, source.rows/2.0F);
    Mat rot_mat = getRotationMatrix2D(src_center, angle, 1.0);
    Mat dst;
    warpAffine(source, dst, rot_mat, source.size());
    return dst;
}


void ProcFrame(cv::Mat &frame) {
    static int offset = 0;
    if(ac::blur_First == true) {
        cv::Mat temp;
        cv::GaussianBlur(frame, temp,cv::Size(5, 5), 0, 0, 0);
        frame = temp;
    }
    
    if(ac::slide_Show == false)
        ac::draw_func[ac::draw_offset](frame);
    else {
        if(ac::slide_Rand == true) ac::draw_func[rand()%ac::draw_max](frame);
        else ac::draw_func[offset](frame);
        ++offset;
        if(offset >= 7)
            offset = 0;
    }
    if(ac::switch_Back == true) {
        ac::isNegative = !ac::isNegative;
    }
    
    if(ac::blur_Second == true) {
        cv::Mat temp;
        cv::GaussianBlur(frame, temp,cv::Size(5, 5), 0, 0, 0);
        frame = temp;
    }
    
    if(recordI == YES) {
       // vw << frame;
    }
}



@interface ViewController ()

@end

@implementation ViewController

@synthesize videoCamera;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}

- (IBAction) changeSlider: (id) sender {

    
    int pos = [slider value];
    current_res = pos;
    
    switch(pos) {
        case 1:
            [slider_label setText: @"Resoltion 352x288 (Very Fast)"];
            break;
        case 2:
            [slider_label setText: @"Resolution 640x480 (Recommended)"];
            break;
        case 3:
            [slider_label setText: @"Resolution 960x540 (Recommended)"];
            break;
        case 4:
            [slider_label setText: @"Resolution 1280x720 (Slow)"];
            break;
        case 5:
            [slider_label  setText:@"Resolution 1920x1080 (Very Slow)"];
            break;
    }
    
}

- (void) setViewOrientation {
    startOrientation = self.interfaceOrientation;
    switch (self.interfaceOrientation) {
        default:
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationPortrait:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
    }
    [self.videoCamera stop];
    [self.videoCamera start];

}
 - (void)deviceOrientationDidChange:(NSNotification *)notification {
    //Obtaining the current device orientation
    orientation = [[UIDevice currentDevice] orientation];
}
- (void)viewDidLoad
{
    ac::tr = 0.3f;
    ac::translation_variable = 0.1f;
    [super viewDidLoad];
 	// Do any additional setup after loading the view, typically from a nib.
    imageView.frame = CGRectMake(0, 0, 352, 288);
    imageView.center = imageView.superview.center;
    current_res = 1;
    [slider_label setText: @"Resolution 352x288 (Very Fast)"];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
//    [self setViewOrientation];
    self.videoCamera.defaultFPS = 24;
    self.videoCamera.grayscaleMode = NO;
    saveI = NO;
    recordI = NO;
    camera_pos = YES;
    //[self startVideo:self];
    //[self switchCamera: nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Protocol CvVideoCameraDelegate
#ifdef __cplusplus
- (void) processImage:(Mat&)image {
    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    ProcFrame(image_copy);
    /*
    if(orientation != UIDeviceOrientationPortrait) {
        //if(recordI == YES) image_copy = rotateImage(image_copy, 90);
        
    }*/
    cvtColor(image_copy, image, CV_BGR2BGRA);
    if(saveI == YES) {
        UIImage *im = [self UIImageFromMat:image];
        UIImageWriteToSavedPhotosAlbum(im, nil, nil, nil);
        saveI = NO;
    }
}
#endif

- (UIImage *)UIImageFromMat:(cv::Mat)image
{
    cvtColor(image, image, CV_BGR2RGB);
    NSData *data = [NSData dataWithBytes:image.data length:image.elemSize()*image.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);//CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,                                 //width
                                        image.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * image.elemSize(),                       //bits per pixel
                                        image.step.p[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    //[self.imgView setImage:finalImage];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger numTouch = ((NSSet*)[event allTouches]).count;
    NSInteger numTouchB = touches.count;
    
    if((stated == STATE_0) && (numTouchB == 1) && (numTouch == 1)) {
        startLocation = [[touches anyObject] locationInView:[self view]];
        stopLocation = startLocation;
        startTime = [(UITouch*)[touches anyObject] timestamp];
        stated = STATE_1;
    } else stated = STATE_0;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(stated == STATE_1 && [touches count] == 1) {
        CGPoint stopLocationX = [[[touches allObjects] objectAtIndex: 0] locationInView:[self view]];
        float abs_x = startLocation.x - stopLocationX.x, abs_y = startLocation.y - stopLocationX.y;
        if((fabs(abs_x) >= MOVEMENT_X)) {
            if(abs_x < 0) {
                [self shiftRight:self];
                startLocation = stopLocationX;
            }
            else if(abs_x > 0){
                [self shiftLeft:self];
                startLocation = stopLocationX;
            }
        }
        
        if((fabs(abs_y) >= MOVEMENT_Y)) { /*
            if(abs_y < 0) {
                [self moveDown];
                startLocation = stopLocationX;
            } else if(abs_y > 0) {
                [self moveUp];
                startLocation = stopLocationX;
            } */
        }
    }
}

- (void)touchesCancelled: (NSSet *)touches withEvent: (UIEvent*)event {
    stated = STATE_0;
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSInteger numTouchE = ((NSSet *)[event allTouches]).count;
    NSInteger noTouchEnded = touches.count;
    if((stated == STATE_1) && (numTouchE == 1 && noTouchEnded == 1)) {
        stopLocation = [(UITouch *)[touches anyObject] locationInView:[self view]];
        endTime = [(UITouch*)[touches anyObject] timestamp];
        stated = STATE_0;
    }
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Began");
    
    
    [super touchesEnded: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Moved");
    
    [super touchesEnded: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Ended");
    
    
    NSInteger numTouchE = ((NSSet *)[event allTouches]).count;
    NSInteger noTouchEnded = touches.count;
    if((stated == STATE_1) && (numTouchE == 1 && noTouchEnded == 1)) {
        stopLocation = [(UITouch *)[touches anyObject] locationInView:[self view]];
        endTime = [(UITouch*)[touches anyObject] timestamp];
        stated = STATE_0;
    }
    
    
    [super touchesEnded: touches withEvent: event];
}*/


- (IBAction) startVideo:(id) sender {
    shift_up.hidden = NO;
    shift_down.hidden = NO;
    record_V.hidden = NO;
    switch_button.hidden = NO;
    save_button.hidden = NO;
    switch(current_res) {
        case 1:
            ac::tr = 0.1f;
            self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
            break;
        case 2:
            self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
            break;
        case 3:
            switch_button.hidden = NO;
            self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetiFrame960x540;
            break;
        case 4:
            ac::tr = 0.5f;
            record_V.hidden = YES;
            switch_button.hidden = NO;
            self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
            break;
        case 5:
            ac::tr = 0.7f;
            record_V.hidden = YES;
            switch_button.hidden = YES;
            self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1920x1080;
            break;
    }
    [self.videoCamera start];
    slider_label.hidden = YES;
    slider.hidden = YES;
    start_button.hidden = YES;
    
    NSString *text = [NSString stringWithUTF8String:ac::draw_strings[ac::draw_offset].c_str() ];
    NSString *final_text = [NSString stringWithFormat:@"%@ %d", text, current_filterx];
    [filter_name setText:final_text];
}

- (IBAction) saveImage:(id) sender {
    saveI = YES;
    CFBundleRef mainBundle=CFBundleGetMainBundle();
    CFURLRef soundFileURLRef;
    soundFileURLRef =CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"beep-7", CFSTR("wav"), NULL);
    UInt32 soundID;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
    AudioServicesPlaySystemSound(soundID);
}


- (IBAction) shiftLeft: (id) sender {
    std::cout << "Draw Offset Decreased\n";
    
    if(current_filterx > 0) {
        --current_filterx;
        NSString *text = [NSString stringWithUTF8String:ac::draw_strings[ac::draw_offset].c_str() ];
        NSString *final_text = [NSString stringWithFormat:@"%@ %d", text, current_filterx];
        [filter_name setText:final_text];
        return;
    
    }
    
    if(ac::draw_offset > 0)
        --ac::draw_offset;
    
    std::cout << "Filter set to: " << ac::draw_strings[ac::draw_offset] << "\n";
    
    NSString *text = [NSString stringWithUTF8String:ac::draw_strings[ac::draw_offset].c_str() ];
    NSString *final_text = [NSString stringWithFormat:@"%@ %d", text, current_filterx];
    [filter_name setText:final_text];
                      
}

- (IBAction) shiftRight: (id) sender {

    std::cout << "Draw Offset Increased\n";
    if(ac::draw_offset < ac::draw_max-5)
        ++ac::draw_offset;
    else {
        
        if(current_filterx < 36)++current_filterx;
    }
    std::cout << "Filter set to: " << ac::draw_strings[ac::draw_offset] << "\n";
    
    NSString *text = [NSString stringWithUTF8String:ac::draw_strings[ac::draw_offset].c_str() ];
    NSString *final_text = [NSString stringWithFormat:@"%@ %d", text, current_filterx];
    
    [filter_name setText:final_text];
}

- (IBAction) showOptions: (id) sender {
    OptionsController *viewX = [[[OptionsController alloc] init] autorelease];
    [self presentViewController:viewX animated:NO completion:^() {
        [viewX resetControls];
    }];
}

- (void)               video: (NSString *) videoPath
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo {
    NSLog(@"saved from %@\n", videoPath);
}


- (IBAction) recordVideo: (id) sender {
    if(recordI == NO) {
        [videoCamera stop];
        [videoCamera setRecordVideo:YES];
        
        /*NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"testback.m4v"];
        NSLog(@"directory: %@\n", documentsDirectory);
        vw = cv::VideoWriter([documentsDirectory UTF8String], CV_FOURCC('H', 'F', 'Y', 'U'), 30, cv::Size(480, 640), true); */

        /*
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fname = [[self.videoCamera videoFileURL] path];
        [fileManager removeItemAtPath:fname error:nil]; */
        [videoCamera start];
        recordI = YES;
        [record_V setTitle:@"Stop" forState: UIControlStateNormal];
        switch_button.hidden = YES;
       
    }
    else {
            recordI = NO; /*
            vw.release();
        
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"tmp/output.mov"];
        
            UISaveVideoAtPathToSavedPhotosAlbum(documentsDirectory,nil,nil,nil);
            NSLog(@"%@\n", documentsDirectory); */
       
        
        NSString *fname = [[self.videoCamera videoFileURL] path];
        [videoCamera saveVideo];
        [videoCamera stop];

        NSLog(@"%@\n", fname);
        UISaveVideoAtPathToSavedPhotosAlbum(fname,self,@selector(video:didFinishSavingWithError:contextInfo:),nil);
        //[[NSFileManager defaultManager] removeItemAtPath:[[self.videoCamera videoFileURL] path] error:nil];
        [videoCamera setRecordVideo: NO];
        [videoCamera start];
        switch_button.hidden = NO;
        [record_V setTitle:@"Record" forState: UIControlStateNormal];
    }
}

- (IBAction) switchCamera: (id) sender {
    [videoCamera stop];
    if(camera_pos == NO) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        camera_pos = YES;
    }
    else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        camera_pos = NO;
    }
    [videoCamera start];

}

@end
