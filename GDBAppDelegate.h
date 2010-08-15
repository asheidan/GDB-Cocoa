//
//  GDBAppDelegate.h
//  GDB
//
//  Created by Emil Eriksson on 2010-07-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILGdbHandler.h"
#import "ILGdbHelpParser.h"
#import "ILGdbParser.h"

@interface GDBAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;

	NSTextView *logView;
	NSTextField *inputArea;
	
	ILGdbHandler *handler;
	ILGdbParser *gdbParser;

	NSManagedObjectContext *managedObjectContext;
	
	NSString *debuggedFile;
	NSArray *sourceFiles;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *logView;
@property (assign) IBOutlet NSTextField *inputArea;

@property (readonly) NSString *debuggedFile;

- (void) populateHelp;
- (void) postPopulateHelp:(ILGdbHelpParser *)parser;
- (void) populateHelpCleanup:(ILGdbHelpParser *)parser;

- (void) newLocation: (NSNotification *)notification;
- (void) handlerOutput: (NSNotification *)notification;
- (void) appendText: (NSString *)text;
- (void) appendAttributedText:(NSAttributedString *)text;

- (IBAction) displayOpenFileDialog: (id)sender;
- (IBAction) openEditor: (id)sender;

- (void) openFile: (NSString *)fileName;
// Delegate Methods
- (BOOL)
	control:(NSControl *)control
	textView:(NSTextView *)textView
	doCommandBySelector:(SEL)commandSelector;
- (NSArray *)
	control:(NSControl *)control
	textView:(NSTextView *)textView
	completions:(NSArray *)words
	forPartialWordRange:(NSRange)charRange
	indexOfSelectedItem:(NSInteger *)index;


@end
