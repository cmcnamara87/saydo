//
//  LHGoalListViewController.m
//  SayDo
//
//  Created by Justin Marrington on 13/11/2013.
//  Copyright (c) 2013 LovelyHead. All rights reserved.
//

#import "LHGoalListViewController.h"
#import "LHGoal.h"

@interface LHGoalListViewController ()

@property (nonatomic, strong) NSMutableArray *goals;
@property (weak) IBOutlet NSTextField *goalEntry;
@property (weak) IBOutlet NSTextField *hoursEntry;
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation LHGoalListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.goals = [NSMutableArray array];
      
//        PFObject *newGoal = [PFObject objectWithClassName:@"Goal"];
//        newGoal[@"title"] = @"test";
//        newGoal[@"hours"] = @1;
//        [newGoal saveInBackground];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Goal"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                [self.goals addObjectsFromArray:objects];
                [self.tableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    
        [self watchConfigFolder];
        
//        [self watchConfigFile:@"/Users/cmcnamara87/Desktop"];
        
      // Temporary goal data
//      LHGoal *goal1 = [[LHGoal alloc] init];
//      goal1.title = @"Buy justin a coke";
//      goal1.hours = 5;
//      
//      LHGoal *goal2 = [[LHGoal alloc] init];
//      goal2.title = @"Eat pizza";
//      goal2.hours = 12;
//      
//      [self.goals addObjectsFromArray:@[goal1, goal2]];
    }
    return self;
}

#pragma mark - NSTableView Controller Data Source
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  
  if ([tableColumn.identifier isEqualToString:@"GoalColumn"]) {
    PFObject *goal = [self.goals objectAtIndex:row];
    cellView.textField.stringValue = [NSString stringWithFormat:@"%@ - %d hours per week", goal[@"title"], [goal[@"hours"] intValue]];
  }
  
  return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [self.goals count];
}
- (IBAction)addGoal:(id)sender {
    
    PFObject *newGoal = [PFObject objectWithClassName:@"Goal"];
    newGoal[@"title"] = self.goalEntry.stringValue;
    newGoal[@"hours"] = [NSNumber numberWithInteger:self.hoursEntry.integerValue];
    [newGoal saveInBackground];
    
  NSIndexSet *insertIndex = [NSIndexSet indexSetWithIndex:0];
  
  [self.goals insertObject:newGoal atIndex:0];
  [self.tableView insertRowsAtIndexes:insertIndex withAnimation:NSTableViewAnimationEffectGap];
  [self.tableView selectRowIndexes:insertIndex byExtendingSelection:NO];
  [self.tableView scrollRowToVisible:0];
}

#pragma mark - GCD File watching
/* http://www.davidhamrick.com/2011/10/13/Monitoring-Files-With-GCD-Being-Edited-With-A-Text-Editor.html */

- (void)watchConfigFolder
{
    /* Define variables and create a CFArray object containing
     CFString objects containing paths to watch.
     */
    CFStringRef mypath = CFSTR("/Users/cmcnamara87/Desktop");
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    void *callbackInfo = NULL; // could put stream-specific data here.
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 3.0; /* Latency in seconds */
    
    /* Create the stream, passing in a callback */
    stream = FSEventStreamCreate(NULL,
                                 &myCallbackFunction,
                                 callbackInfo,
                                 pathsToWatch,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagNone /* Flags explained in reference */
                                 );
     FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(),         kCFRunLoopDefaultMode);
    
    FSEventStreamStart(stream);
}

void myCallbackFunction(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[])
{
    int i;
    char **paths = eventPaths;
    
    // printf("Callback called\n");
    for (i=0; i<numEvents; i++) {
//        int count;
        /* flags are unsigned long, IDs are uint64_t */
        printf("Change %llu in %s, flags %u\n", eventIds[i], paths[i], (unsigned int)eventFlags[i]);
    }
}



#pragma mark - GCD File watching
/* http://www.davidhamrick.com/2011/10/13/Monitoring-Files-With-GCD-Being-Edited-With-A-Text-Editor.html */

- (void)watchConfigFile:(NSString*)path;
{
    
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // Open the file
	int fildes = open([path UTF8String], O_EVTONLY);
    
    // Get a pointer back to this class, so we can called it in the block
    __block typeof(self) blockSelf = self;
    // Create a new source
    //  Newly created sources are created in a suspended state. After the source has been configured by setting
    // an event handler, cancellation handler, registration handler, context, etc., the source must be
    // activated by a call to dispatch_resume() before any events will be delivered. (its at the bottom)
    // DISPATCH_SOURCE_TYPE_VNODE - monitor the virtual filesystem nodes for state changes
	__block dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fildes,
															  DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
															  queue);
    
    // Setup my event handle for all those flags i set for the mask in dispatch_source_create
	dispatch_source_set_event_handler(source, ^
                                      {
                                          unsigned long flags = dispatch_source_get_data(source);
                                          if(flags & DISPATCH_VNODE_DELETE)
                                          {
                                              dispatch_source_cancel(source);
                                              [blockSelf watchConfigFile:path];
//                                              [blockSelf watchStyleSheet:path];
                                          }
                                          // Reload config file
                                          NSLog(@"File did something from GCD");
                                      });
	dispatch_source_set_cancel_handler(source, ^(void) 
                                       {
                                           close(fildes);
                                       });
	dispatch_resume(source);
}

@end
