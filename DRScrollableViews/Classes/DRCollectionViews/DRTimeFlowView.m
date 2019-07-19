//
//  DRTimeFlowView.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/18.
//

#import "DRTimeFlowView.h"
#import <DRMacroDefines/DRMacroDefines.h>
#import <HexColors/HexColors.h>
#import "DRTimeFlowLayout.h"
#import <Masonry/Masonry.h>

@interface DRTimeFlowView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@end

@implementation DRTimeFlowView

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

- (void)setMaxItemSize:(CGSize)maxItemSize {
    _maxItemSize = maxItemSize;
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    layout.maxItemSize = maxItemSize;
}

- (void)setDecreasingStep:(CGFloat)decreasingStep {
    _decreasingStep = decreasingStep;
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    layout.decreasingStep = decreasingStep;
}

- (void)setCoverOffset:(CGFloat)coverOffset {
    _coverOffset = coverOffset;
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    layout.coverOffset = coverOffset;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.containerView.backgroundColor = backgroundColor;
    self.collectionView.backgroundColor = backgroundColor;
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
    [self.collectionView setContentOffset:offset animated:animated];
}

- (void)reloadTimeFlowViewComplete:(dispatch_block_t)complete {
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfRowsInTimeFlowView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource timeFlowView:self cellForRowAtIndex:indexPath.row];
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:shouldSelectRowAtIndex:)]) {
        return [self.delegate timeFlowView:self shouldSelectRowAtIndex:indexPath.row];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didSelectRowAtIndex:)]) {
        [self.delegate timeFlowView:self didSelectRowAtIndex:indexPath.row];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:shouldDeselectRowAtIndex:)]) {
        [self.delegate timeFlowView:self shouldDeselectRowAtIndex:indexPath.row];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didDeselectRowAtIndex:)]) {
        [self.delegate timeFlowView:self didDeselectRowAtIndex:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    cell.layer.cornerRadius = 4;
    cell.layer.borderColor = cell.backgroundColor.CGColor;
    cell.layer.borderWidth = 1;
    cell.layer.shadowColor = [UIColor hx_colorWithHexRGBAString:@"#D6E7F4"].CGColor;
    CGFloat height = CGRectGetHeight(cell.bounds);
    CGFloat width = CGRectGetWidth(cell.bounds);
    CGFloat rate = (height - self.decreasingStep) / height;
    CGFloat neWidth = width * rate;
    CGRect shadowRect = CGRectInset(cell.bounds, (width-neWidth)/2, self.decreasingStep/2);
    shadowRect = CGRectOffset(shadowRect, 0, -5-self.decreasingStep/2);
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
   
    cell.layer.shadowOpacity = 0.9;
    if (indexPath.row == 0) {
        cell.layer.shadowOpacity = 0;
    }
    
    if (indexPath.row < self.lastIndexPath.row || !self.lastIndexPath) {
        [cell.superview sendSubviewToBack:cell];
    }
    self.lastIndexPath = indexPath;
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willDisplayCell:forRowAtIndex:)]) {
        [self.delegate timeFlowView:self willDisplayCell:cell forRowAtIndex:indexPath.row];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didScroll:)]) {
        [self.delegate timeFlowView:self didScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willBeginDragging:)]) {
        [self.delegate timeFlowView:self willBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate timeFlowView:self willEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self resetCellsLevel];
    }
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didEndDragging:willDecelerate:)]) {
        [self.delegate timeFlowView:self didEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willBeginDecelerating:)]) {
        [self.delegate timeFlowView:self willBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetCellsLevel];
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didEndDecelerating:)]) {
        [self.delegate timeFlowView:self didEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self resetCellsLevel];
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didEndScrollingAnimation:)]) {
        [self.delegate timeFlowView:self didEndScrollingAnimation:scrollView];
    }
}

#pragma mark - private
- (void)resetCellsLevel {
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    indexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
        return obj1.row < obj2.row;
    }];
    for (NSIndexPath *indexPath in indexPaths) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        [cell.superview sendSubviewToBack:cell];
    }
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
    if (!self.containerView) {
        self.containerView = kDR_LOAD_XIB_NAMED(NSStringFromClass([self class]));
        [self addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_offset(0);
        }];
        
        self.collectionView.backgroundColor = [UIColor grayColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
}

- (void)dealloc {
    kDR_LOG(@"%@dealloc", NSStringFromClass([self class]));
}

@end
