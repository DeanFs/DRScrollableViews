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

@interface DRDragSortTableViewController () <DRDragSortTableViewDelegate>

@property (nonatomic, strong) NSArray *datas;

@end

@implementation DRDragSortTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DRDragSortTableView *tableView = (DRDragSortTableView *)self.tableView;
    tableView.dr_dragSortDelegate = self;
    tableView.rowHeight = 50;
    
    NSMutableArray *sections = [NSMutableArray array];
    for (NSInteger i=0; i<3; i++) {
        NSInteger count = rand() % 6 + 5;
        NSMutableArray *rows = [NSMutableArray array];
        [sections addObject:rows];
        for (NSInteger j=0; j<count; j++) {
            [rows addObject:[NSString stringWithFormat:@"s%ld-r%ld", i, j]];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableViewCell"];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = self.datas[indexPath.section][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
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
    NSLog(@"from:%ld, to:%ld", fromIndexPath.row, indexPath.row);
    return YES;
}

- (BOOL)dragSortTableView:(DRDragSortTableView *)tableView
     canDeleteAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)dragSortTableView:(DRDragSortTableView *)tableView deleteAtIndexPath:(NSIndexPath *)indexPath deleteDoneBlock:(dispatch_block_t)deleteDoneBlock {
    NSMutableArray *arr = self.datas[indexPath.section];
    [arr removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
    deleteDoneBlock();
}

- (void)dragSortTableView:(DRDragSortTableView *)tableView exchangeIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableArray *fromArr = self.datas[fromIndexPath.section];
    if (fromIndexPath.section == toIndexPath.section) {
        [fromArr exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    } else {
        NSString *str = [fromArr objectAtIndex:fromIndexPath.row];
        [fromArr removeObject:str];
        
        NSMutableArray *toArr = self.datas[toIndexPath.section];
        [toArr insertObject:str atIndex:toIndexPath.row];
    }
}

@end
