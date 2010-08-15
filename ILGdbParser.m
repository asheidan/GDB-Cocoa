//
//  ILGdbParser.m
//  GDB
//
//  Created by Emil Eriksson on 2010-08-11.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import "ILGdbParser.h"
#import "RegexKitLite.h"


@implementation ILGdbParser

- (id) init
{
	self = [super init];
	// Path:Line:Column?:Instruction:Address
	sourceUrl = @"^\x1a\x1a([^:]*):([0-9]*):([0-9]*):([^:]*):(.*)$";
	return self;
}

- (NSAttributedString *)parse: (NSString *)string
{
	NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] initWithString:string] autorelease];
	NSRange range = NSMakeRange(0, [string length]);
	NSRange match = [string rangeOfRegex:sourceUrl options:RKLMultiline inRange:range capture:0 error:nil];
	if (NSNotFound != match.location) {
		NSString *path = [string stringByMatching:sourceUrl options:RKLMultiline inRange:match capture:1 error:nil];
		NSInteger lineNumber = [[string stringByMatching:sourceUrl options:RKLMultiline inRange:match capture:2 error:nil] integerValue];
		NSInteger columnNumber = [[string stringByMatching:sourceUrl options:RKLMultiline inRange:match capture:3 error:nil] integerValue];
		
		NSDictionary *d = [NSDictionary
						   dictionaryWithObjectsAndKeys:
								path,@"ILGdbParserFilePath",
								[NSNumber numberWithInt:lineNumber],@"ILGdbParserLineNumber",
								[NSNumber numberWithInt:columnNumber],@"ILGdbParserColumnNumber",
						   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ILGdbParserNewLocationNotification" object:self userInfo:d];
		[result deleteCharactersInRange:match];
	}
	return result;
}

@end
