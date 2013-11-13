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
      
      // Temporary goal data
      LHGoal *goal1 = [[LHGoal alloc] init];
      goal1.title = @"Buy justin a coke";
      goal1.hours = 5;
      
      LHGoal *goal2 = [[LHGoal alloc] init];
      goal2.title = @"Eat pizza";
      goal2.hours = 12;
      
      [self.goals addObjectsFromArray:@[goal1, goal2]];
    }
    return self;
}

#pragma mark - NSTableView Controller Data Source
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  
  if ([tableColumn.identifier isEqualToString:@"GoalColumn"]) {
    LHGoal *goal = [self.goals objectAtIndex:row];
    cellView.textField.stringValue = [NSString stringWithFormat:@"%@ - %ld hours per week", goal.title, goal.hours];
  }
  
  return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [self.goals count];
}
- (IBAction)addGoal:(id)sender {
  LHGoal *newGoal = [[LHGoal alloc] init];
  newGoal.title = self.goalEntry.stringValue;
  newGoal.hours = self.hoursEntry.integerValue;
  NSIndexSet *insertIndex = [NSIndexSet indexSetWithIndex:0];
  
  [self.goals insertObject:newGoal atIndex:0];
  [self.tableView insertRowsAtIndexes:insertIndex withAnimation:NSTableViewAnimationEffectGap];
  [self.tableView selectRowIndexes:insertIndex byExtendingSelection:NO];
  [self.tableView scrollRowToVisible:0];
}

@end
