//
//  DRFoldableOptionItemView.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/9/4.
//

#import <UIKit/UIKit.h>

@class DRFoldableOptionItemView;
@protocol DRFoldableOptionItemViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInFoldableOptionItemView:(DRFoldableOptionItemView *)optionItemView;
- (UICollectionViewCell *)foldableOptionItemView:(DRFoldableOptionItemView *)foldableOptionItemView
                              cellForItemAtIndex:(NSInteger)index;

@end

@protocol DRFoldableOptionItemViewDelegate <NSObject>

@optional
- (void)foldableOptionItemView:(DRFoldableOptionItemView *)foldableOptionItemView
          didSelectItemAtIndex:(NSInteger)index;

@end

@interface DRFoldableOptionItemView : UIView

@property (nonatomic, assign) IBInspectable CGFloat itemWidth; // default 85;
@property (nonatomic, weak) id<DRFoldableOptionItemViewDataSource> dataSource;
@property (nonatomic, weak) id<DRFoldableOptionItemViewDelegate> delegate;

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier
                                                                 forIndex:(NSInteger)index;
- (void)reloadData;

/// 展开或收起时调用
- (void)expandChangeToHeight:(CGFloat)height;

@end

