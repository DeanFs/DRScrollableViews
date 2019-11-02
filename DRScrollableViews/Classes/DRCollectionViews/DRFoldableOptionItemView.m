//
//  DRFoldableOptionItemView.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/9/4.
//

#import "DRFoldableOptionItemView.h"
#import "DRFoldableOptionItemLayout.h"
#import <Masonry/Masonry.h>
#import <DRMacroDefines/DRMacroDefines.h>

@interface DRFoldableOptionItemView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) DRFoldableOptionItemLayout *layout;

@end

@implementation DRFoldableOptionItemView

#pragma mark - api
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier
                                                                 forIndex:(NSInteger)index {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                          forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)expandChangeToHeight:(CGFloat)height {
    self.layout.expandHeight = height;
    [self.collectionView reloadData];
}

- (void)setItemWidth:(CGFloat)itemWidth {
    self.layout.itemWidth = itemWidth;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInFoldableOptionItemView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource foldableOptionItemView:self cellForItemAtIndex:indexPath.row];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(foldableOptionItemView:didSelectItemAtIndex:)]) {
                [self.delegate foldableOptionItemView:self didSelectItemAtIndex:indexPath.row];
            }
        }];
    }];
}

#pragma mark - lifecycle
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (!self.collectionView) {
        DRFoldableOptionItemLayout *layout = [DRFoldableOptionItemLayout new];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        [self addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_offset(0);
        }];
        self.collectionView = collectionView;
        self.layout = layout;
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.itemWidth = 85;
        self.layout.expandHeight = 0;
    }
}

- (void)dealloc {
    kDR_LOG(@"%@dealloc", NSStringFromClass([self class]));
}

@end
