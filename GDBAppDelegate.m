//
//  GDBAppDelegate.m
//  GDB
//
//  Created by Emil Eriksson on 2010-07-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GDBAppDelegate.h"

@implementation GDBAppDelegate

#pragma mark Persistance

- (NSManagedObjectContext *)managedObjectContext
{
	if(managedObjectContext) {
		return managedObjectContext;
	}
	
	NSError *error;
	NSPersistentStoreCoordinator *coordinator;
	NSPersistentStore *store;
	
	coordinator = [[NSPersistentStoreCoordinator alloc]
					initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
	store = [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
	
	if (store != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	
	[coordinator release];
	
	return managedObjectContext;
}

#pragma mark Delegate Methods

- (BOOL) control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
	NSLog(@"Got action");
	BOOL result = NO;
	NSString *message = [textView string];
	if( commandSelector == @selector(insertNewline:) ) {
		[handler sendCommand: message];
		[self appendText: message];
		[self appendText: @"\n"];
	}
	else if( commandSelector == @selector(insertTab:) ) {
		//[self appendText: @"\n"];
		//[handler sendCompletion:message];
		//[textView setSelectedRange: NSMakeRange([[textView textStorage] length] , 0)];
		[textView complete: textView];
		result = YES;
	}
	return result;
}
- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
	NSString *message = [textView string];
	NSLog(@"Completing %@...",message);
	
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSManagedObjectModel *model = [[context persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionDictionary = [NSDictionary dictionaryWithObject:message forKey:@"COMMAND"];
	NSFetchRequest *request = [model fetchRequestFromTemplateWithName:@"completions" substitutionVariables:substitutionDictionary];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"command" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error;
	//NSLog(@"Found %d matches", [context countForFetchRequest:request error:&error]);
	NSArray *result = [context executeFetchRequest:request error:&error];
	NSMutableArray *commands = [[[NSMutableArray alloc] initWithCapacity:[result count]] autorelease];
	for(NSManagedObject *o in result) {
		[commands addObject:[[o valueForKey:@"command"] substringFromIndex:charRange.location]];
	}
	
	return (NSArray *)commands;
}

#pragma mark IBActions

- (IBAction) displayOpenFileDialog: (id)sender
{
	// Create the File Open Dialog class.
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
	// Enable the selection of files in the dialog.
	[openDlg setCanChooseFiles:YES];
	[openDlg setAllowsMultipleSelection:NO];
	
	// Disable the selection of directories in the dialog.
	[openDlg setCanChooseDirectories:NO];
	
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	[openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
		if( NSOKButton == result ) {
			[openDlg orderOut:self];
			[self openFile:[openDlg filename]];
		}
	}];
}

- (void) openFile: (NSString *)fileName
{
	debuggedFile = fileName;
	[handler setFile: debuggedFile];
}

- (IBAction) openEditor: (id)sender
{
	
}

#pragma mark NotificationMethods

- (void) newLocation: (NSNotification *)notification
{
	NSDictionary *d = [notification userInfo];
	NSString *path = [d objectForKey:@"ILGdbParserFilePath"];
	NSNumber *lineNumber = [d objectForKey:@"ILGdbParserLineNumber"];
	//NSNumber *columnNumber = [d objectForKey:@"ILGdbParserColumnNumber"];
	NSString *url = [NSString stringWithFormat:@"txmt://open?url=file://%@&line=%@",path,lineNumber];
	NSAttributedString *link = 
	[[NSAttributedString alloc]
	 initWithString:@"Open in TextMate"
	 attributes:[NSDictionary dictionaryWithObject:url forKey:NSLinkAttributeName]];
	[self appendAttributedText:link];
	[link release];	
}

- (void) handlerOutput: (NSNotification *)notification
{
	[self appendAttributedText:[gdbParser parse:[[notification userInfo] objectForKey:@"ILGdbHandlerNotificationOutputItem"]]];
}

#pragma mark Application

@synthesize window;
@synthesize logView;
@synthesize inputArea;
- (NSString *) debuggedFile { return debuggedFile; }

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	NSLog(@"We're up and well, something....");
	
	debuggedFile = nil;
	
	NSFont *monaco = [NSFont fontWithName:@"Monaco" size:9.0];
	[logView setFont:monaco];
	[inputArea setFont:monaco];
	[inputArea setDelegate: self];
	
	
	handler = [[ILGdbHandler alloc] init];
	gdbParser = [[ILGdbParser alloc] init];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(newLocation:) name:@"ILGdbParserNewLocationNotification" object:gdbParser];
	
	[self populateHelp];
	
}
- (void) applicationWillTerminate:(NSNotification *)notification
{
	[handler release];
	[gdbParser release];
}

- (void) populateHelp
{
	ILGdbHelpParser *parser = [[ILGdbHelpParser alloc] init];
	if (![handler isRunning]) {
		[handler start];
	}
	[[NSNotificationCenter defaultCenter]
		addObserver:parser
		selector:@selector(parseNotification:)
		name:@"ILGdbHandlerNewOutputNotification"
		object:handler];
	[handler sendCommand:@"help\nhelp status"];
	[self performSelector:@selector(postPopulateHelp:) withObject:parser afterDelay:0.1];
}
- (void) postPopulateHelp:(ILGdbHelpParser *)parser
{
	NSArray *objects = [parser objects];
	[parser clear];

	for(NSString *topic in objects) {
		[handler sendCommand:[NSString stringWithFormat:@"help %@",topic]];
	}

	[self performSelector:@selector(populateHelpCleanup:) withObject:parser afterDelay:0.2];
}
- (void) populateHelpCleanup:(ILGdbHelpParser *)parser
{
	[[NSNotificationCenter defaultCenter] removeObserver:parser];
	NSArray *commands = [parser objects];
	NSManagedObjectContext *context = [self managedObjectContext];
	for(NSString *command in commands) {
		NSManagedObject *newCommand = [NSEntityDescription
											insertNewObjectForEntityForName:@"CommandHelp"
											inManagedObjectContext:context];
		[newCommand setValue:command forKey:@"command"];
	}
	[context save:nil];
	[parser release];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(handlerOutput:)
		name:@"ILGdbHandlerNewOutputNotification"
		object:handler];

	if(![handler isRunning]) {
		[handler start];
	}
	//NSLog(@"Commands: %@", [context registeredObjects]);
}

- (void) appendAttributedText:(NSAttributedString *)text {
	NSArray *selections = [logView selectedRanges];
	[logView setSelectedRange:NSMakeRange([[logView textStorage] length], 0)];
	[logView setEditable:YES];
	
	[logView insertText:text];
	
	[logView setSelectedRanges:selections];
	
	[logView setEditable:NO];
}

- (void) appendText:(NSString *)text
{
	NSAttributedString *atrString = [[[NSAttributedString alloc] initWithString:text] autorelease];
	[self appendAttributedText:atrString]; 
}

	 
- (void) sendHelp:(id)sender
{
	[handler sendCommand:@"help"];
}


@end
