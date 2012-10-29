//
//  PlanningVIewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-25.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "PlanningVIewController.h"
#import "ShowWordsViewController.h"
#import "AppDelegate.h"

@interface PlanningVIewController ()

@property (nonatomic, strong) WordList *todaysPlan;
@property (nonatomic, strong) NSDictionary *effectiveCount_deltaDay_map;

@end

@implementation PlanningVIewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wordListsArray = [[NSMutableArray alloc]init];
    
    //艾宾浩斯曲线日期递增映射
    self.effectiveCount_deltaDay_map = 
    @{
        [NSNumber numberWithInt:1]:[NSNumber numberWithInt:1],
        [NSNumber numberWithInt:2]:[NSNumber numberWithInt:2],
        [NSNumber numberWithInt:3]:[NSNumber numberWithInt:3],
        [NSNumber numberWithInt:4]:[NSNumber numberWithInt:8],
    };
    
    self.title = @"今日复习计划";
    BOOL finishTodaysLearningPlan = ((AppDelegate *)[UIApplication sharedApplication].delegate).finishTodaysLearningPlan;
    
    NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:ctx];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"addTime" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(effectiveCount==0)"];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sort]];
    [request setFetchLimit:1];
    //筛选学习计划
    if (!finishTodaysLearningPlan) {
        //pick a word list
        NSArray *result = [ctx executeFetchRequest:request error:nil];
        if (result.count > 0) {
            self.todaysPlan = [result objectAtIndex:0];
        }
    }
    //筛选复习计划
    predicate = [NSPredicate predicateWithFormat:@"(effectiveCount > 0 AND effectiveCount < 5)"];
    [request setPredicate:predicate];
    [request setFetchLimit:0];
    
    NSArray *result = [ctx executeFetchRequest:request error:nil];
    
    for (WordList *wl in result) {
        //上次复习日期+(effectiveCount对应的艾宾浩斯递增天数)>=现在日期
        NSDate *lastReviewTime = wl.lastReviewTime;
        NSNumber *effectiveCount = wl.effectiveCount;
        int deltaDay = [[self.effectiveCount_deltaDay_map objectForKey:effectiveCount]intValue];
        NSTimeInterval deltaTimeInterval = deltaDay*24*60*60;
        //计算得到的下次应该复习的时间
        NSDate *expectedNextReviewDate = [lastReviewTime dateByAddingTimeInterval:deltaTimeInterval];
        //获取当前日期，忽略具体时间
        unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:flags fromDate:[NSDate date]];
        NSDate* currDate = [calendar dateFromComponents:components];
        //比较两个时间
        if ([expectedNextReviewDate compare:currDate] == NSOrderedAscending || [expectedNextReviewDate compare:currDate] == NSOrderedSame) {
            //expected<curr 需要复习
            [self.wordListsArray addObject:wl];
        }
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.todaysPlan != nil) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.wordListsArray.count;
        case 1:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        WordList *wl = [self.wordListsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [[wl valueForKey:@"title"] description];
        NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",[[wl valueForKey:@"effectiveCount"] description]];
        cell.detailTextLabel.text = detailTxt;
    }else{
        cell.textLabel.text = self.todaysPlan.title;
        NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",self.todaysPlan.effectiveCount];
        cell.detailTextLabel.text = detailTxt;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"今日需要复习的Word list";
        case 1:
            return @"今日需要学习的Word list";
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ShowWordsViewController *subVC = [[ShowWordsViewController alloc]initWithNibName:@"ShowWordsViewController" bundle:nil];
//    if (indexPath.section == 0) {
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        subVC.wordList = (WordList *)object;
//    }else{
//        subVC.wordList = self.todaysPlan;
//    }
//    
//    [self.navigationController pushViewController:subVC animated:YES];
}


@end