//
//  ILGdbParser.h
//  GDB
//
//  Created by Emil Eriksson on 2010-08-11.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ILGdbParser : NSObject {
	NSString *sourceUrl;
}

- (NSAttributedString *)parse: (NSString *)string;

@end
