//
//  ErrorWindowView.h
//  ErrorScatter
//
//  Created by Alex Nichol on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ErrorWindowView : NSView {
    NSImage * currentImage;
	
	NSLock * backgroundLock;
	BOOL needsErrorWindow;
	NSThread * backgroundThread;
}

- (void)setMouseMoved;
- (void)startDrawThread;
- (void)stopDrawThread;

@end
