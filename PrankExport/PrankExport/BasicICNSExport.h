//
//  BasicICNSExport.h
//  PoopyHead
//
//  Created by Alex Nichol on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

UInt32 flipUInt32 (UInt32 littleEndian);

@interface BasicICNSExport : NSObject {
    NSImage * theImage;
	NSData * jpeg2000Data;
}

/**
 * Create a new ICNS exporter with a given image.
 * @param anImage An NSImage with dimensions of either
 * 256x256 or 512x512.
 */
- (id)initWithImage:(NSImage *)anImage;

/**
 * @return The header data of the image.
 * @discussion You do not need to call this if you are using
 * writeICNSToFile: separately.
 */
- (NSData *)encodeHeaders;

/**
 * @return The body data of the image.
 * @discussion You do not need to call this if you are using
 * writeICNSToFile: separately.
 */
- (NSData *)encodeBody;

/**
 * Writes the ICNS stream to an icns file on disk.
 */
- (void)writeICNSToFile:(NSString *)filePath;

@end
