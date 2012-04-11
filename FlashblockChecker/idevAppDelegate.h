//
//  idevAppDelegate.h
//  FlashblockChecker
//
//  Created by janxin li on 12-4-10.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface idevAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak) IBOutlet NSTextField *textView;

- (IBAction)saveAction:(id)sender;
- (IBAction)isInfectedCheck:(NSButton *)sender;
- (IBAction)virusCleaner:(NSButton *)sender;

- (id)valueForKey:(NSString*)aKey atPath:(NSString*)aPath;
- (void)log:(NSString*)aString;

@end
