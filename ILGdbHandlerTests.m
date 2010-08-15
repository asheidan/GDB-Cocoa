//
//  ILGdbHandlerTests.m
//  GDB
//
//  Created by Emil Eriksson on 2010-07-21.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import "ILGdbHandlerTests.h"

@implementation ILGdbHandlerTests

- (void) setUp
{
	handler = [[ILGdbHandler alloc] init];
}
- (void) tearDown
{
	[handler release];
}

- (void) testInitShouldNotReturnNil
{
	STAssertNotNil(handler, @"Init returned nil");
}

- (void) testNewlyStartedHandlerShouldHaveGdbRunning
{
	[handler start];
	STAssertTrue([handler isRunning], @"GDB isn't running");
}

@end
