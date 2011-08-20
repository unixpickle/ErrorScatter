//
//  BasicICNSExport.m
//  PoopyHead
//
//  Created by Alex Nichol on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BasicICNSExport.h"

UInt32 flipUInt32 (UInt32 littleEndian) {
	UInt32 newNum = 0;
	char * newBuff = (char *)&newNum;
	const char * oldBuff = (const char *)&littleEndian;
	newBuff[3] = oldBuff[0];
	newBuff[2] = oldBuff[1];
	newBuff[1] = oldBuff[2];
	newBuff[0] = oldBuff[3];
	return newNum;
}

@implementation BasicICNSExport

- (id)initWithImage:(NSImage *)anImage {
	int width = round([anImage size].width);
	int height = round([anImage size].height);
	NSAssert((width == 512 && height == 512) || (width == 256 && height == 256), @"Invalid image dimensions given.");
	if ((self = [super init])) {
		NSDictionary * properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
		NSBitmapImageRep * rep = [[NSBitmapImageRep alloc] initWithData:[anImage TIFFRepresentation]];
		jpeg2000Data = [[rep representationUsingType:NSJPEG2000FileType properties:properties] retain];
		theImage = [anImage retain];
		[rep release];
	}
	return self;
}

- (NSData *)encodeHeaders {
	UInt32 fileLength = flipUInt32(16 + (UInt32)[jpeg2000Data length]);
	NSMutableData * headers = [[NSMutableData alloc] init];
	[headers appendData:[@"icns" dataUsingEncoding:NSASCIIStringEncoding]];
	[headers appendBytes:&fileLength length:4];
	NSData * immutable = [NSData dataWithData:headers];
	[headers release];
	return immutable;
}

- (NSData *)encodeBody {
	UInt32 elemLength = flipUInt32(8 + (UInt32)[jpeg2000Data length]);
	NSString * elemName = round([theImage size].width) == 256 ? @"ic08" : @"ic09";
	NSMutableData * body = [[NSMutableData alloc] init];
	[body appendData:[elemName dataUsingEncoding:NSASCIIStringEncoding]];
	[body appendBytes:&elemLength length:4];
	[body appendData:jpeg2000Data];
	NSData * immutable = [NSData dataWithData:body];
	[body release];
	return immutable;
}

- (void)writeICNSToFile:(NSString *)filePath {
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		[[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:nil];
	}
	NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
	if (!handle) {
		@throw [NSException exceptionWithName:NSDestinationInvalidException reason:@"Failed to open destination file" userInfo:nil];
	}
	[handle writeData:[self encodeHeaders]];
	[handle writeData:[self encodeBody]];
	[handle closeFile];
}

- (void)dealloc {
	[theImage release];
	[jpeg2000Data release];
    [super dealloc];
}

@end
