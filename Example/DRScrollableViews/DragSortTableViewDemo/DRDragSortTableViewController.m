//
//  DRDragSortTableViewController.m
//  DRBasicKit_Example
//
//  Created by 冯生伟 on 2019/3/29.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import "DRDragSortTableViewController.h"
#import <DRScrollableViews/DRDragSortTableView.h>
#import <DRMacroDefines/DRMacroDefines.h>
#import <HexColors/HExColors.h>
#import <DRCategories/UITableView+DRExtension.h>
#import "DRDragSortDeleteCell.h"

@interface DRDragSortTableViewController () <DRDragSortTableViewDelegate>

@property (nonatomic, strong) NSArray *datas;

@end

@implementation DRDragSortTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DRDragSortTableView *tableView = (DRDragSortTableView *)self.tableView;
    tableView.dr_dragSortDelegate = self;
    tableView.rowHeight = 90;
    [tableView registerNib:NSStringFromClass([DRDragSortDeleteCell class])];
    tableView.backgroundColor = [UIColor grayColor];
    
    NSMutableArray *sections = [NSMutableArray array];
    for (NSInteger i=0; i<3; i++) {
        NSInteger count = rand() % 6 + 5;
        NSMutableArray *rows = [NSMutableArray array];
        [sections addObject:rows];
        for (NSInteger j=0; j<count; j++) {
            DRDragSortDeleteModel *model = [DRDragSortDeleteModel new];
            model.title = [NSString stringWithFormat:@"s%ld-r%ld", i, j];
            model.canSort = YES;
            model.canDelete = (i == j);
            [rows addObject:model];
        }
    }
    self.datas = sections;
    
    self.title = @"长按cell拖拽";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.datas[section];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DRDragSortDeleteCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DRDragSortDeleteCell class])];
    [cell setupWithModel:self.datas[indexPath.section][indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kDRScreenWidth, 30)];
    label.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"dddddd"];
    label.text = [NSString stringWithFormat:@"section-%ld", section];
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - DRDragSortTableViewDelegate
- (BOOL)dragSortTableView:(DRDragSortTableView *)tableView
       canSortAtIndexPath:(NSIndexPath *)indexPath fromIndexPath:(NSIndexPath *)fromIndexPath{
    DRDragSortDeleteModel *model = self.datas[indexPath.section][indexPath.row];
    return model.canSort;
}

- (BOOL)dragSortTableView:(DRDragSortTableView *)tableView
     canDeleteAtIndexPath:(NSIndexPath *)indexPath {
    DRDragSortDeleteModel *model = self.datas[indexPath.section][indexPath.row];
    return model.canDelete;
}

- (void)dragSortTableView:(DRDragSortTableView *)tableView deleteAtIndexPath:(NSIndexPath *)indexPath deleteDoneBlock:(dispatch_block_t)deleteDoneBlock {
    NSMutableArray *arr = self.datas[indexPath.section];
    [arr removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
    deleteDoneBlock();
}

/**
 每拖拽移动一个位置调用，两个index一定是相邻的
 
 @param tableView tableView
 @param fromIndexPath 上一次移动到的位置
 @param toIndexPath 当前移动到的位置
 @param betweenSections 跨组移动
 @param succession 两个cell是连续，即交换的两个cell之间没有他cell
 */
- (void)dragSortTableView:(DRDragSortTableView *)tableView
        exchangeIndexPath:(NSIndexPath *)fromIndexPath
              toIndexPath:(NSIndexPath *)toIndexPath
          betweenSections:(BOOL)betweenSections
               succession:(BOOL)succession {
    NSMutableArray *fromArr = self.datas[fromIndexPath.section];
    if (betweenSections) {
        DRDragSortDeleteModel *fromModel = [fromArr objectAtIndex:fromIndexPath.row];
        [fromArr removeObject:fromModel];
        
        NSMutableArray *toArr = self.datas[toIndexPath.section];
        if (!succession) {
            DRDragSortDeleteModel *toModel = [toArr objectAtIndex:toIndexPath.row];
            [fromArr insertObject:toModel atIndex:fromIndexPath.row];
            [toArr removeObject:toModel];
        }
        
        [toArr insertObject:fromModel atIndex:toIndexPath.row];
    } else {
        [fromArr exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    }
}

@end
