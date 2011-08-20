//
//  PrankExportAppDelegate.h
//  PrankExport
//
//  Created by Alex Nichol on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BasicICNSExport.h"
#include <sys/stat.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow * window;
	IBOutlet NSTextField * appTitle;
	IBOutlet NSImageView * appIcon;
}

@property (assign) IBOutlet NSWindow * window;

- (IBAction)setAnIcon:(NSButton *)sender;
- (IBAction)export:(id)sender;
- (NSImage *)scaledAppIcon;

@end
