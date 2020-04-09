//
//  DRDragSortTableView.h
//  Records
//
//  Created by 冯生伟 on 2018/9/26.
//  Copyright © 2018年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRDragSortTableView;

@protocol DRDragSortTableViewDelegate <NSObject, UITableViewDelegate, UITableViewDataSource>

@optional

/**
 可以拖动排序，不实现该方法时，所有cell均不可拖动排序
 
 @param tableView tableView
 @param indexPath 待判断cell的位置
 @return YES:可以拖动排序  NO:不可以拖动排序
 */
- (BOOL)dragSortTableView:(DRDragSortTableView *)tableView
       canSortAtIndexPath:(NSIndexPath *)indexPath
            fromIndexPath:(NSIndexPath *)fromIndexPath;

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
               succession:(BOOL)succession;

/**
 松手，停止拖拽时调用
 
 @param tableView tableView
 @param fromIndexPath 长按进入拖拽模式时的位置
 @param toIndexPath 停止拖拽时的位置
 */
- (void)dragSortTableView:(DRDragSortTableView *)tableView
      finishFromIndexPath:(NSIndexPath *)fromIndexPath
              toIndexPath:(NSIndexPath *)toIndexPath;

/**
 可以拖动删除，不实现该方法时，所有cell均不可以拖动删除
 
 @param tableView tableView
 @param indexPath 待判断cell的位置
 @return YES:可以拖动排序  NO:不可以拖动排序
 */
- (BOOL)dragSortTableView:(DRDragSortTableView *)tableView
     canDeleteAtIndexPath:(NSIndexPath *)indexPath;

/**
 cell拖动到了删除区域并松手，触发删除事件
 
 @param tableView tableView
 @param indexPath 删除位置
 @param deleteDoneBlock 删除接口调用完成时调用，不论接口调用成功或者失败，都要调用该回调
 否则可能导致一个cell一直处于被隐藏状态
 */
- (void)dragSortTableView:(DRDragSortTableView *)tableView
        deleteAtIndexPath:(NSIndexPath *)indexPath
          deleteDoneBlock:(dispatch_block_t)deleteDoneBlock;

// 拖拽手势开始结束回调
- (void)dragSortTableViewDragBegan:(DRDragSortTableView *)tableView
                         indexPath:(NSIndexPath *)indexPath
                          dragView:(UIView *)dragView;
- (void)dragSortTableViewDragEnd:(DRDragSortTableView *)tableView
                       indexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - 如果洗完拖动cell中的某个子视图，需要给cell添加DRDragSortCellDelegate协议，并实现dragView方法
@protocol DRDragSortCellDelegate <NSObject>

@optional
/**
 返回cell中需要拖拽的子视图
 
 @return 可拖拽的子视图
 */
- (UIView *)subDragViewFromCellInDragSortTableView:(DRDragSortTableView *)tableView;

/// 返回cell中可以响应长按手势的区域范围
- (CGRect)canReactLongPressSubRect;

@end


@interface DRDragSortTableView : UITableView

@property (nonatomic, weak) id<DRDragSortTableViewDelegate> dr_dragSortDelegate;

/// 当cell拖拽到tableView边缘时,tableView的滚动速度，1/60秒内移动像素(pt)位数，默认为6
@property (nonatomic, assign) IBInspectable CGFloat scrollSpeed;

/// 长按手势开始时，吸起的视图截图的缩放比例，默认1.05
@property (nonatomic, assign) IBInspectable CGFloat cellFrameScale;

/// 拖入删除区域时的缩小比例，默认0.5
@property (nonatomic, assign) IBInspectable CGFloat willDeleteCellFrameScale;

@end
