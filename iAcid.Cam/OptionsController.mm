//
//  OptionsController.m
//  iAcid.Cam
//
//  Created by Jared Bruni on 6/15/13.
//  Copyright (c) 2013 Jared Bruni. All rights reserved.
//

#import "OptionsController.h"
#import "ViewController.h"
#include"ac.h"

inline BOOL Bool(bool b) { if(b) return YES; else return NO; }

@implementation OptionsController

- (void) setOptions  {
    
    ac::pass2_alpha = 1.75f;
    
    if(pass2.on == YES) {
        ac::switch_Back = true;
    
    } else ac::switch_Back = false;
    
    if(negative.on == YES)
        ac::isNegative = true;
    else
        ac::isNegative = false;

    if(reverse_c.on == YES)
        ac::iRev = true;
    else ac::iRev = false;

    if(slideshow.on == YES) {
        ac::slide_Show = true;
    } else ac::slide_Show = false;
    
    if(strobeIt.on == YES) {
        ac::strobe_It = true;
    } else {
        ac::strobe_It = false;
    }
    if(blur_Var.on == YES) {
        ac::blur_Second = true;
    } else {
        ac::blur_Second = false;
    }
}

- (id) initWithNibName:(NSString *)str bundle: (NSBundle *)b {
    
    [super initWithNibName:@"Options" bundle: nil];
    return self;
}

- (void) resetControls {
    [reverse_c setOn: Bool(ac::iRev) animated: NO];
    [negative setOn: Bool(ac::isNegative) animated:NO];
    [pass2 setOn: Bool(ac::switch_Back) animated: NO];
    [slideshow setOn: Bool(ac::slide_Show) animated: NO];
    [strobeIt setOn: Bool(ac::strobe_It) animated: NO];
    [blur_Var setOn: Bool(ac::blur_Second) animated: NO];
}
- (IBAction) goBack: (id) sender {
    [self setOptions];
    [self dismissViewControllerAnimated:NO completion: ^() {}];
}

- (IBAction) op_setPass2: (id) sender {
}
- (IBAction) op_neg: (id) sender {
}
- (IBAction) op_reverse: (id) sender {
}
- (IBAction) op_slideshow: (id) sender {
    
}
- (IBAction) op_strobeIt: (id) sender {
}
- (IBAction) op_blur: (id) sender {
}


@end
