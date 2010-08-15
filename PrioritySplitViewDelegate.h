//
//  PrioritySplitViewDelegate.h
//  GDB
//
//  Created by Emil Eriksson on 2010-08-11.
//  Copyright 2010 Irksome Lines. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrioritySplitViewDelegate : NSObject {
    NSMutableDictionary *lengthsByViewIndex;
    NSMutableDictionary *viewIndicesByPriority;
}

- (void)setMinimumLength:(CGFloat)minLength
		  forViewAtIndex:(NSInteger)viewIndex;
- (void)setPriority:(NSInteger)priorityIndex
	 forViewAtIndex:(NSInteger)viewIndex;

@end
