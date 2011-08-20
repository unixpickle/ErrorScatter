//
//  MouseEventCapture.h
//  ErrorScatter
//
//  Created by Alex Nichol on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MouseEventCapture : NSObject {
    void (^eventCallback)(NSPoint mouse);
}

- (id)initWithEventCallback:(void (^)(NSPoint mouse))eventCb;
- (void)handleEvent:(CGEventRef)event;

@end
