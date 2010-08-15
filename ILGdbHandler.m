//
//  ILGdbHandler.m
//  GDB
//
//  Created by Emil Eriksson on 2010-07-21.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import "ILGdbHandler.h"


@implementation ILGdbHandler

- (id) init {
	return [self initWithGDBPath:@"/usr/bin/gdb"];
}
- (id) initWithGDBPath: (NSString *)path
{
	self = [super init];
	NSArray *arguments = [NSArray arrayWithObjects:@"-f",@"-n",@"-q",nil];
	gdb = [[NSTask alloc] init];
	[gdb setLaunchPath:path];
	[gdb setArguments:arguments];
	
	outPipe = [NSPipe pipe];
	inPipe = [NSPipe pipe];
	
	[gdb setStandardInput:inPipe];
	[gdb setStandardOutput:outPipe];
	
	input = [inPipe fileHandleForWriting];
	output = [outPipe fileHandleForReading];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(getData:)
		name:NSFileHandleReadCompletionNotification
		object:output];
	[output readInBackgroundAndNotify];

	return self;
}

- (void) setFile: (NSString *)fileName
{
	const char *data = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:fileName];
	unsigned int i;
	for(i = 0; data[i] != 0; i++);
	NSData *path = [NSData dataWithBytes:data length:i];
	[self sendString:@"file \""];
	[self sendData:path];
	[self sendString:@"\"\n"];
}

- (void) getData: (NSNotification *)aNotification
{
	NSData *data = [[aNotification userInfo]
						objectForKey:@"NSFileHandleNotificationDataItem"];
	NSString *text = [[NSString alloc]
							initWithBytes:[data bytes]
							length:[data length]
							encoding:NSUTF8StringEncoding];
	//NSLog(@"Got notification:\n%@",text);
	
	NSDictionary *d = [NSDictionary
							dictionaryWithObject:text
							forKey:@"ILGdbHandlerNotificationOutputItem"];
	[[NSNotificationCenter defaultCenter]
		postNotificationName:@"ILGdbHandlerNewOutputNotification"
		object:self
		userInfo:d];
	[text autorelease];
	[output readInBackgroundAndNotify];
}

- (bool) isRunning
{
	return [gdb isRunning];
}

/**
 * Launch the GDB-process
 */
- (void) start
{
	if( ![self isRunning] ) {
		NSLog(@"ILGdbHandler Launching task");
		[gdb launch];
	}
}

/**
 * Sends a command line to the GDB-process
 */
- (void) sendCommand:(NSString *)command
{
	NSLog(@"Sending command...");
	NSString *withNewLine = [NSString stringWithFormat:@"%@\n", command];
	[self sendString: withNewLine];
}

- (void) sendCompletion:(NSString *)command
{
	NSLog(@"Sending completion...");
	NSString *withTab = [NSString stringWithFormat:@"%@\t\t", command];
	[self sendString: withTab];
}
- (void) sendString: (NSString *)string
{
	[self sendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}
- (void) sendData: (NSData *)data
{
	[input writeData:data];
}


- (void) dealloc
{
	NSLog(@"ILGdbHandler deallocating...");
	[input closeFile];
	if([self isRunning]) {
		[gdb terminate];
		[gdb waitUntilExit];
	}
	[gdb release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}
@end
