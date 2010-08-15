//
//  ILGdbHelpParser.m
//  GDB
//
//  Created by Emil Eriksson on 2010-08-11.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import "ILGdbHelpParser.h"
#import "RegexKitLite.h"


@implementation ILGdbHelpParser

- (id) init
{
	self = [super init];
	array = [[NSMutableArray alloc] init];
	
	helpLine = @"^.* -- .*$";
	command = @"^(.*) -- .*$";
	
	return self;
}

- (void) clear
{
	[array removeAllObjects];
}

- (NSArray *)objects
{
	return [NSArray arrayWithArray:array];
}
- (int) objectCount
{
	return [array count];
}

- (BOOL) isHelpLine: (NSString *)aLine
{
	NSRange match = [aLine rangeOfRegex:helpLine];
	return NSNotFound != match.location;
}

- (void) parseLine: (NSString *)aLine
{
	if([self isHelpLine:aLine]) {
		NSString *commandWord = [aLine stringByMatching:command capture:1];
		[array addObject:commandWord];
	}
}
- (void) parse: (NSString *)input
{
	NSArray *lines = [input componentsSeparatedByString:@"\n"];
	NSEnumerator *e = [lines objectEnumerator];
	NSString *aLine;
	
	while(aLine = [e nextObject]) {
		[self parseLine:aLine];
	}
	
	//[e release];
	//[lines release];
}

- (void) parseNotification: (NSNotification *)notification
{
	NSString *output = [[notification userInfo] objectForKey:@"ILGdbHandlerNotificationOutputItem"];
	[self parse:output];
	[output release];
}


- (void) dealloc
{
	[array release];
	[super dealloc];
}
@end
