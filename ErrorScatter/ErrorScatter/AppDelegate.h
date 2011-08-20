//
//  ErrorScatterAppDelegate.h
//  ErrorScatter
//
//  Created by Alex Nichol on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MouseEventCapture.h"
#import "ErrorWindowView.h"
#import "ANKeyEvent.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow * window;
	ErrorWindowView * errView;
	MouseEventCapture * evtCap;
	ANKeyEvent * quitEvent;
}

- (void)addNewWindow;
- (void)quitApp:(id)sender;

@end
