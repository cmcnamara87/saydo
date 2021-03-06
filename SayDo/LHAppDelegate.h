//
//  LHAppDelegate.h
//  SayDo
//
//  Created by Justin Marrington on 5/11/2013.
//  Copyright (c) 2013 LovelyHead. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LHAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSStatusItem *statusItem;

- (IBAction)saveAction:(id)sender;

@end
