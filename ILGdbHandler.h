//
//  ILGdbHandler.h
//  GDB
//
//  Created by Emil Eriksson on 2010-07-21.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ILGdbHandler : NSObject {

	NSTask *gdb;
	
	NSPipe *inPipe;
	NSPipe *outPipe;

	NSFileHandle *input;
	NSFileHandle *output;
}

- (id) initWithGDBPath: (NSString *)path;

- (bool) isRunning;
- (void) start;

- (void) sendCommand: (NSString *)command;
- (void) sendCompletion:(NSString *)command;
- (void) sendString: (NSString *)string;
- (void) sendData: (NSData *)data;

- (void) setFile:(NSString *)fileName;

// Listener
- (void) getData: (NSNotification *)aNotification;

@end
