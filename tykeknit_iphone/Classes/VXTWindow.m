//
//  VXTWindow.m
//  mangoTheReader
//
//  Created by Abhinit Tiwari on 08/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VXTWindow.h"


@implementation VXTWindow


- (void)sendEvent:(UIEvent *)event {
	// At the moment, all the events are propagated (by calling the sendEvent method
	// in the parent class) except single-finger multitaps.
	
	BOOL shouldCallParent = YES;
	
	if (event.type == UIEventTypeTouches) {
        
		NSSet *touches = [event allTouches];		
        UITouch *touch = touches.anyObject;                

        if ([touch locationInView:self].y <= 52.0) {
//            NSLog(@"ON NAV BAR %@", [[self hitTest:[touch locationInView:self] withEvent:nil] superview]);
        } else {
//            NSLog(@"NOT NAV BAR %@", [[self hitTest:[touch locationInView:self] withEvent:nil] superview]);            
            if ([[self hitTest:[touch locationInView:self] withEvent:nil] isKindOfClass:[UINavigationBar class]] ||
                ([[[self hitTest:[touch locationInView:self] withEvent:nil] superview] isKindOfClass:[UINavigationBar class]]) && !([[self hitTest:[touch locationInView:self] withEvent:nil] superview].tag > 100)) {
                shouldCallParent = NO;
            }
        }

		if (touches.count == 1) {
			if (touch.phase == UITouchPhaseBegan) {
			} else if (touch.phase == UITouchPhaseMoved) {
			}
			
			if (touch.tapCount > 1) {
            }
		}
	}
	
	if (shouldCallParent) {
		[super sendEvent:event];
	}
}


- (void)dealloc {
	[super dealloc];
}

@end