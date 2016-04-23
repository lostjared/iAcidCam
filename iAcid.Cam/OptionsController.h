//
//  OptionsController.h
//  iAcid.Cam
//
//  Created by Jared Bruni on 6/15/13.
//  Copyright (c) 2013 Jared Bruni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionsController : UIViewController {
    IBOutlet UISwitch *pass2, *negative, *reverse_c, *slideshow, *strobeIt, *blur_Var;
}

- (IBAction) goBack: (id) sender;
- (IBAction) op_setPass2: (id) sender;
- (IBAction) op_neg: (id) sender;
- (IBAction) op_reverse: (id) sender;
- (IBAction) op_slideshow: (id) sender;
- (IBAction) op_strobeIt: (id) sender;
- (IBAction) op_blur: (id) sender;
- (void) resetControls;
- (void) setOptions;

@end
