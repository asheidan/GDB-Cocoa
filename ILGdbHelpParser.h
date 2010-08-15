//
//  ILGdbHelpParser.h
//  GDB
//
//  Created by Emil Eriksson on 2010-08-11.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ILGdbHelpParser : NSObject {

	NSMutableArray *array;
	
	NSString *helpLine;
	NSString *command;
	
}

- (NSArray *)objects;
- (int) objectCount;
- (void) clear;

- (BOOL) isHelpLine: (NSString *)aLine;
- (void) parseLine: (NSString *)aLine;
- (void) parse: (NSString *)input;
- (void) parseNotification: (NSNotification *)notification;
@end
