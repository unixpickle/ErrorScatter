//
//  ANKeyEvent.h
//  Pasties
//
//  Created by Alex Nichol on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

typedef enum {
	ANKeyEventKeyModifierShift = 1,
	ANKeyEventKeyModifierCommand = 2,
	ANKeyEventKeyModifierAlt = 4,
	ANKeyEventKeyModifierControl = 8
} ANKeyEventKeyModifier;

@interface ANKeyEvent : NSObject {
	int keyCode;
	ANKeyEventKeyModifier modifiers;
	int hkID;
	
	id target;
	SEL action;
	
	BOOL isRegistered;
	EventHotKeyRef hotKeyRef;
	EventHotKeyID hotKeyID;
}

@property (nonatomic, assign) id target;
@property (readwrite) SEL action;
@property (readonly) BOOL isRegistered;

- (id)initWithKeycode:(int)code modifiers:(ANKeyEventKeyModifier)_modifiers;
- (void)triggerAction;
- (void)registerAction;
- (void)unregisterAction;

@end
