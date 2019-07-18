//
//  DRTimeFlowView.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DRTimeFlowView;
@protocol DRTimeFlowViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInTimeFlowView:(DRTimeFlowView *)timeFlowView;
- (UICollectionViewCell *)timeFlowView:(DRTimeFlowView *)timeFlowView
                 cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol DRTimeFlowViewDelegate <NSObject>

@optional
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView
     willDisplayCell:(nonnull UICollectionViewCell *)cell
   forRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
- (BOOL)timeFlowView:(DRTimeFlowView *)timeFlowView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)timeFlowView:(DRTimeFlowView *)timeFlowView shouldDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DRTimeFlowView : UIView

@property (nonatomic, assign) IBInspectable CGSize maxItemSize; // 最大的cell的size
@property (nonatomic, assign) IBInspectable CGFloat decreasingStep; // cell高度递减的值
@property (nonatomic, assign) IBInspectable CGFloat coverOffset; // 上一个cell被遮盖的高度值

@property (nonatomic, weak) id<DRTimeFlowViewDataSource> dataSource;
@property (nonatomic, weak) id<DRTimeFlowViewDelegate> delegate;

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier
                                                             forIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
