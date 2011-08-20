//
//  MouseEventCapture.m
//  ErrorScatter
//
//  Created by Alex Nichol on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MouseEventCapture.h"

CGEventRef myCGEventCallback (CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
	// mouse moved
	[(MouseEventCapture *)refcon handleEvent:event];
	return event;
}

@implementation MouseEventCapture

- (id)init {
	if ((self = [super init])) {

	}
	return self;
}

- (id)initWithEventCallback:(void (^)(NSPoint mouse))eventCb {
	if ((self = [super init])) {
		eventCallback = Block_copy(eventCb);
		
		CGEventFlags emask = CGEventMaskBit(kCGEventMouseMoved);
		CFMachPortRef eventTap = CGEventTapCreate(kCGSessionEventTap, kCGTailAppendEventTap, kCGEventTapOptionListenOnly, emask, &myCGEventCallback, self);
		if (!eventTap) {
			return NO;
		}
		
		CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
		CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
		CFRelease(runLoopSource);
		CFRelease(eventTap);
	}
	return self;
}

- (void)handleEvent:(CGEventRef)event {
	CGPoint p = CGEventGetLocation(event);
	eventCallback(NSMakePoint(p.x, p.y));
}

- (void)dealloc {
	Block_release(eventCallback);
	[super dealloc];
}

@end
