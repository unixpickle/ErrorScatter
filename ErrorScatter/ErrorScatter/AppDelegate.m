//
//  ErrorScatterAppDelegate.m
//  ErrorScatter
//
//  Created by Alex Nichol on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSRect frame = [[NSScreen mainScreen] frame];
	evtCap = [[MouseEventCapture alloc] initWithEventCallback:^(NSPoint mouse) {
		[self addNewWindow];
	}];
	window = [[NSWindow alloc] initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	errView = [[ErrorWindowView alloc] initWithFrame:frame];
	[window setContentView:errView];
	[window setOpaque:NO];
	[window setBackgroundColor:[NSColor clearColor]];
	[window setIgnoresMouseEvents:YES];
	[window setLevel:CGShieldingWindowLevel()];
	[window makeKeyAndOrderFront:self];
	// 36 = enter key
	quitEvent = [[ANKeyEvent alloc] initWithKeycode:36 modifiers:(ANKeyEventKeyModifierControl | ANKeyEventKeyModifierAlt)];
	[quitEvent setTarget:self];
	[quitEvent setAction:@selector(quitApp:)];
	[quitEvent registerAction];
	[errView startDrawThread];
}

- (void)addNewWindow {
	[errView setMouseMoved];
}

- (void)quitApp:(id)sender {
	exit(0);
}

- (void)dealloc {
	[errView stopDrawThread];
	[errView release];
	[evtCap release];
	[window release];
	[quitEvent unregisterAction];
	[quitEvent release];
	[super dealloc];
}

@end
