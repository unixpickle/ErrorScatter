//
//  PrankExportAppDelegate.m
//  PrankExport
//
//  Created by Alex Nichol on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
}

- (IBAction)setAnIcon:(NSButton *)sender {
	const NSString * imageAssociative[] = {
		@"Mail", @"mail.png",
		@"Safari", @"safari.png",
		@"Video", @"movie.png",
		@"iChat", @"ichat.png",
		@"Image", @"image.png"
	};
	NSImage * image = nil;
	for (int i = 0; i < 9; i += 2) {
		if ([imageAssociative[i] isEqualToString:[sender title]]) {
			image = [NSImage imageNamed:(NSString *)(imageAssociative[i + 1])];
			break;
		}
	}
	if (image) {
		[appIcon setImage:image];
	}
}

- (IBAction)export:(id)sender {
	NSSavePanel * spanel = [NSSavePanel savePanel];
	NSString * path = @"~/Desktop";
	[spanel setDirectory:[path stringByExpandingTildeInPath]];
	[spanel setPrompt:@"Save Executable"];
	[spanel setRequiredFileType:@"app"];
	[spanel beginSheetForDirectory:[spanel directory]
							  file:[NSString stringWithFormat:@"%@.app", [appTitle stringValue]]
					modalForWindow:window
					 modalDelegate:self
					didEndSelector:@selector(didEndSaveSheet:returnCode:conextInfo:)
					   contextInfo:NULL];
}

- (void)didEndSaveSheet:(NSSavePanel *)savePanel returnCode:(int)returnCode conextInfo:(void *)contextInfo {
	if (returnCode == NSOKButton) {
		NSString * file = [savePanel filename];
		NSString * pathToApp = [[NSBundle mainBundle] pathForResource:@"ErrorScatter" ofType:@"app"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
			[[NSFileManager defaultManager] removeItemAtPath:file error:nil];
		}
		NSURL * src = [NSURL fileURLWithPath:pathToApp];
		NSURL * dst = [NSURL fileURLWithPath:file];
		if (![[NSFileManager defaultManager] copyItemAtURL:src toURL:dst error:nil]) {
			NSRunAlertPanel(@"Error", @"Failed to export application to the selected path.", @"OK", nil, nil);
		} else {
			NSString * contentsPath = [file stringByAppendingPathComponent:@"Contents"];
			NSString * exePath = [[contentsPath stringByAppendingPathComponent:@"MacOS"] stringByAppendingPathComponent:@"ErrorScatter"];
			NSString * infoPlist = [contentsPath stringByAppendingPathComponent:@"Info.plist"];
			NSString * iconPath = [[contentsPath stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:@"icon.icns"];
			// make sure it's executable
			chmod([exePath UTF8String], 0755);
			// set the bundle display name
			NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithContentsOfFile:infoPlist];
			[dict setObject:[appTitle stringValue] forKey:@"CFBundleDisplayName"];
			if (![[NSFileManager defaultManager] removeItemAtPath:infoPlist error:nil]) {
				NSLog(@"Warning: failed to remove plist file");
			}
			if (![dict writeToFile:infoPlist atomically:YES]) {
				NSRunAlertPanel(@"Failed to set app name", @"The custom app name you provided could not be set", @"OK", nil, nil);
			}
			// set the icon
			NSImage * scaled = [self scaledAppIcon];
			@try {
				BasicICNSExport * export = [[BasicICNSExport alloc] initWithImage:scaled];
				[export writeICNSToFile:iconPath];
				[export release];
			} @catch (NSException * ex) {
				NSRunAlertPanel(@"Icon export failed", @"Failed to export the specified image to an ICNS file.  This may mean that an image is corrupted or the exported application was moved during the export process.", @"OK", nil, nil);
			}
		}
	}
}

- (NSImage *)scaledAppIcon {
	NSImage * currentIcon = [appIcon image];
	NSRect drawFrame = NSZeroRect;
	CGFloat scale = 1;
	if ([currentIcon size].width < [currentIcon size].height) {
		scale = 256.0 / [currentIcon size].height;
	} else {
		scale = 256.0 / [currentIcon size].width;
	}
	drawFrame.size = NSMakeSize([currentIcon size].width * scale, [currentIcon size].height * scale);
	drawFrame.origin.x = round((256.0 - drawFrame.size.width) / 2.0);
	drawFrame.origin.y = round((256.0 - drawFrame.size.height) / 2.0);
	NSImage * scaled = [[NSImage alloc] initWithSize:NSMakeSize(256, 256)];
	[scaled lockFocus];
	[currentIcon drawInRect:drawFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
	[scaled unlockFocus];
	return [scaled autorelease];
}

@end
