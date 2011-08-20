//
//  ErrorWindowView.m
//  ErrorScatter
//
//  Created by Alex Nichol on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ErrorWindowView.h"

@interface ErrorWindowView (Private)

- (void)backgroundMethod:(NSValue *)theFrame;
- (void)setRedraw;

@end

@implementation ErrorWindowView

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code here.
		backgroundLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)setMouseMoved {
	[backgroundLock lock];
	needsErrorWindow = YES;
	[backgroundLock unlock];
}

- (void)startDrawThread {
	if (!currentImage) {
		currentImage = [[NSImage alloc] initWithSize:[[NSScreen mainScreen] frame].size];
	}
	if (!backgroundThread) {
		NSValue * frameVal = [NSValue valueWithRect:[[NSScreen mainScreen] frame]];
		backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(backgroundMethod:) object:frameVal];
		[backgroundThread start];
	}
}

- (void)stopDrawThread {
	if (backgroundThread) {
		[backgroundThread cancel];
		[backgroundThread release];
		backgroundThread = nil;
	}
}

- (void)dealloc {
	[currentImage release];
	[backgroundLock release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	@synchronized (currentImage) {
		[currentImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
	}
}

#pragma mark Threading

- (void)backgroundMethod:(NSValue *)theFrame {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSRect frame = NSZeroRect;
	[theFrame getValue:&frame];
	NSImage * errorImage = [NSImage imageNamed:@"errorWind.png"];
	
	while (![[NSThread currentThread] isCancelled]) {
		NSDate * nextDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
		BOOL wantsRedraw = NO;
		[backgroundLock lock];
		wantsRedraw = needsErrorWindow;
		needsErrorWindow = NO;
		[backgroundLock unlock];
		if (wantsRedraw) {
			NSPoint aPoint;
			aPoint.x = (arc4random() % (int)frame.size.width) - (errorImage.size.width / 2);
			aPoint.y = (arc4random() % (int)frame.size.height) - (errorImage.size.height / 2);
			@synchronized (currentImage) {
				[currentImage lockFocus];
				[errorImage drawAtPoint:aPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
				[currentImage unlockFocus];
			}
			[self performSelectorOnMainThread:@selector(setRedraw) withObject:nil waitUntilDone:YES];
		}
		[NSThread sleepUntilDate:nextDate];
	}
	
	[pool drain];
}

- (void)setRedraw {
	[self setNeedsDisplay:YES];
}

@end
