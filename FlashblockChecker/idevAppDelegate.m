//
//  idevAppDelegate.m
//  FlashblockChecker
//
//  Created by janxin li on 12-4-10.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

#import "idevAppDelegate.h"

@implementation idevAppDelegate

@synthesize window = _window;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize textView = _textView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "SecWays.FlashblockChecker" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"SecWays.FlashblockChecker"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FlashblockChecker" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"FlashblockChecker.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = coordinator;
    
    return __persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)isInfectedCheck:(NSButton *)sender {
    [_textView setStringValue:@""];
    
    
    NSString* theSafari = @"/Applications/Safari.app/Contents/Info.plist";
    NSString* theFirefox = @"/Applications/Firefox.app/Contents/Info.plist";
    NSString* theEnvironment = @"~/.MacOSX/environment.plist";
    
    NSArray* theFiles = [NSArray arrayWithObjects:theSafari, theFirefox, theEnvironment, nil];
    BOOL theInfected = NO;
    for( NSString* theFile in theFiles )
    {   
        NSString* theKey = @"LSEnvironment";
        if( [theFile isEqualToString:theEnvironment] )
        {
            theKey = @"DYLD_INSERT_LIBRARIES";
        }
        
        id theObject = [self valueForKey:theKey atPath:theFile];
        if( theObject )
        {
            [self log:[NSString stringWithFormat:@"发现可疑项: %@", theFile]];
            [self log:[theObject description]];
            theInfected = YES;
        }
        else 
        {
            NSString* thePath = [theFile stringByExpandingTildeInPath];
            if( [[NSFileManager defaultManager] fileExistsAtPath:thePath] )
            {
                [self log:[NSString stringWithFormat:@"正常: %@", thePath]];
            }
            else
            {
                [self log:[NSString stringWithFormat:@"正常: %@", thePath]];
            }
        }
    }
    
    if( !theInfected )
    {
        [self log:@"\n未发现感染行为。"];
    }else{
        NSString* theVisit = @"\n\n请访问 F-Secure 网站获取更多信息:\nhttp://www.f-secure.com/v-descs/trojan-downloader_osx_flashback_i.shtml";
        [self log:theVisit];
    }
}

- (IBAction)virusCleaner:(NSButton *)sender {
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!__managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (id)valueForKey:(NSString*)aKey atPath:(NSString*)aPath
{
    id theReturn = nil;
    
    NSString* thePath = [aPath stringByExpandingTildeInPath];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:thePath] )
    {
        NSDictionary* theDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
        theReturn = [theDict objectForKey:aKey];
    }
    return theReturn;
}

- (void)log:(NSString*)aString
{
    NSString* theString = [_textView stringValue];
    [_textView setStringValue:[NSString stringWithFormat:@"%@%@\n", theString, aString]];
}

@end
