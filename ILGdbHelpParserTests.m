//
//  ILGdbHelpParserTests.m
//  GDB
//
//  Created by Emil Eriksson on 2010-08-11.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import "ILGdbHelpParserTests.h"

@implementation ILGdbHelpParserTests

- (void) setUp
{
	helpParser = [[ILGdbHelpParser alloc] init];
}
- (void) tearDown
{
	[helpParser release];
}

- (void) testInitShouldNotReturnNil
{
	STAssertNotNil(helpParser,@"Init returned nil");
}
- (void) testParserShouldRecognizeHelpLine
{
	NSString *aLine = @"aliases -- Aliases of other commands";
	STAssertTrue([helpParser isHelpLine:aLine], @"Parser didn't recognize help line");
}
- (void) testParserShouldNotRecognizeOtherLine
{
	NSString *aLine = @"List of classes of commands:";
	STAssertFalse([helpParser isHelpLine:aLine], @"Parser has hybris");
}
- (void) testParserShouldAddFoundCommandToList
{
	NSString *aLine = @"aliases -- Aliases of other commands";
	[helpParser parseLine: aLine];
	NSArray *expected = [NSArray arrayWithObject:@"aliases"];
	NSArray *os = [helpParser objects];
	
	STAssertEqualObjects(expected,os,@"Arrays not equal");
}
- (void) testParserShouldHandleMultiline
{
	NSString *input = @"List of classes of commands:\n\naliases -- Aliases of other commands\nbreakpoints -- Making program stop at certain points\ndata -- Examining data\nfiles -- Specifying and examining files\ninternals -- Maintenance commands\nobscure -- Obscure features\nrunning -- Running the program\nstack -- Examining the stack\nstatus -- Status inquiries\nsupport -- Support facilities\ntracepoints -- Tracing of program execution without stopping the program\nuser-defined -- User-defined commands\n\nType \"help\" followed by a class name for a list of commands in that class.\nType \"help\" followed by command name for full documentation.\nCommand name abbreviations are allowed if unambiguous.";
	[helpParser parse:input];
	NSArray *expected = [NSArray
							arrayWithObjects:@"aliases",@"breakpoints",@"data",@"files",@"internals",@"obscure",@"running",@"stack",@"status",@"support",@"tracepoints",@"user-defined",nil];
	NSArray *objects = [helpParser objects];
	
	STAssertEqualObjects(expected, objects, @"Arrays not equal");
}

@end
