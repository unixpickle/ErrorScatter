//
//  ANKeyEvent.m
//  Pasties
//
//  Created by Alex Nichol on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANKeyEvent.h"

static OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData) {
	EventHotKeyID hkRef;
    GetEventParameter(anEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkRef),NULL,&hkRef);
	[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"KeyEVT(id=%d)", hkRef.id] object:nil];
	return noErr;
}

@interface ANKeyEvent (Private)

+ (int)keyCodeIdentifier;
+ (void)configureKeyboard;

@end

@implementation ANKeyEvent

@synthesize target;
@synthesize action;
@synthesize isRegistered;

+ (int)keyCodeIdentifier {
	static int code = 0;
	return code++;
}

+ (void)configureKeyboard {
	static BOOL hasConfigured = NO;
	if (!hasConfigured) {
		hasConfigured = YES;
		EventTypeSpec eventType;
		eventType.eventClass = kEventClassKeyboard;
		eventType.eventKind = kEventHotKeyPressed;
		InstallApplicationEventHandler(&myHotKeyHandler, 1, &eventType, NULL, NULL);
	}
}

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithKeycode:(int)code modifiers:(ANKeyEventKeyModifier)_modifiers {
	if ((self = [super init])) {
		target = nil;
		action = NULL;
		keyCode = code;
		modifiers = _modifiers;
		hkID = [[self class] keyCodeIdentifier];
		[[self class] configureKeyboard];
		hotKeyID.id = hkID;
		hotKeyID.signature = 'psts'; // PASTIES
	}
	return self;
}

- (void)triggerAction {
	[target performSelector:action withObject:self];
}

- (void)registerAction {
	if (isRegistered) return;
	int cModifiers = 0;
	if ((modifiers & ANKeyEventKeyModifierShift) != 0) cModifiers += shiftKey;
	if ((modifiers & ANKeyEventKeyModifierAlt) != 0) cModifiers += optionKey;
	if ((modifiers & ANKeyEventKeyModifierCommand) != 0) cModifiers += cmdKey;
	if ((modifiers & ANKeyEventKeyModifierControl) != 0) cModifiers += controlKey;
	
	RegisterEventHotKey(keyCode, cModifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerAction) name:[NSString stringWithFormat:@"KeyEVT(id=%d)", hkID] object:nil];
	isRegistered = YES;
}

- (void)unregisterAction {
	if (!isRegistered) return;
	UnregisterEventHotKey(hotKeyRef);
	hotKeyRef = NULL;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"KeyEVT(id=%d)", hkID] object:nil];
}

- (void)dealloc {
	[self unregisterAction];
	self.target = nil;
    [super dealloc];
}

@end
