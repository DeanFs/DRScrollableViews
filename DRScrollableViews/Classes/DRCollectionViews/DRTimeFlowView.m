//
//  DRTimeFlowView.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/18.
//

#import "DRTimeFlowView.h"
#import "DRTimeFlowLayout.h"
#import "DRSectorDeleteView.h"
#import <DRMacroDefines/DRMacroDefines.h>
#import <HexColors/HexColors.h>
#import <Masonry/Masonry.h>
#import <DRCategories/UIImage+DRExtension.h>
#import "UICollectionViewCell+TimeFlowShadowLayer.h"

@interface DRTimeFlowView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// delete
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;
@property (nonatomic, strong) NSIndexPath *longPressIndexPath;
@property (nonatomic, weak) UICollectionViewCell *dragCell; // 长按手势开始时的cell
@property (nonatomic, strong) UIImageView *dragImageView; // 拖拽的视图的截图

@property (nonatomic, assign) BOOL haveDrag; // 用于判断上拉到底部执行代理回调
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UICollectionViewCell *> *visibleCellsMap; // 缓存当前可见的cell

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

- (void)setDelegate:(id<DRTimeFlowViewDelegate>)delegate {
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(timeFlowView:beginDeleteRowAtIndex:whenComplete:)]) {
        self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGestureStateChange:)];
        [self.collectionView addGestureRecognizer:self.longGesture];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.containerView.backgroundColor = backgroundColor;
    self.collectionView.backgroundColor = backgroundColor;
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
    [self.collectionView setContentOffset:offset animated:animated];
}

- (void)reloadDataScrollToIndex:(NSInteger)index {
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    [layout reloadDataScrollToIndex:index];
    [self.collectionView reloadData];
}

- (void)reloadData {
    [self.collectionView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint offset = [self.collectionView.collectionViewLayout targetContentOffsetForProposedContentOffset:self.collectionView.contentOffset withScrollingVelocity:CGPointZero];
        [self.collectionView setContentOffset:offset animated:YES];
    });
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
    if (cell.layer.cornerRadius != self.cellCornerRadius) {
        cell.clipsToBounds = NO;
        cell.layer.cornerRadius = self.cellCornerRadius;
        cell.layer.borderColor = cell.backgroundColor.CGColor;
        cell.layer.borderWidth = 1;
    }
    if (self.cellShadowColor && !cell.shadowLayer) {
        [cell addShadowLayerWithShadowColor:self.cellShadowColor
                                     offset:self.coverOffset + self.cellShadowOffset
                               cornerRadius:self.cellCornerRadius];
    }
    [self.visibleCellsMap setObject:cell forKey:@(indexPath.row)];
    [self setupVisibleCells];
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willDisplayCell:forRowAtIndex:)]) {
        [self.delegate timeFlowView:self willDisplayCell:cell forRowAtIndex:indexPath.row];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didScrollToBottom:)] &&
        self.haveDrag) {
        if (scrollView.isDragging) {
            return;
        }
        CGFloat contentHeight = ((DRTimeFlowLayout *)self.collectionView.collectionViewLayout).cellContentHeight;
        CGFloat bottomRest = contentHeight - scrollView.contentOffset.y - CGRectGetHeight(scrollView.frame);
        if (bottomRest <= 0) {
            [self.delegate timeFlowView:self didScrollToBottom:scrollView];
            self.haveDrag = NO;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didScroll:)]) {
        [self.delegate timeFlowView:self didScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.haveDrag = YES;
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
    [self setupVisibleCells];
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didEndDecelerating:)]) {
        [self.delegate timeFlowView:self didEndDecelerating:scrollView];
    }
}

#pragma mark - private
- (void)setupVisibleCells {
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    UICollectionViewCell *lastCell;
    for (NSNumber *index in layout.visibleIndexs) {
        lastCell = self.visibleCellsMap[index];
        lastCell.shadowLayer.hidden = NO;
        [lastCell.superview bringSubviewToFront:lastCell];
    }
    lastCell.shadowLayer.hidden = YES;
}

#pragma mark - long press to delete
- (void)onLongPressGestureStateChange:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (sender.state == UIGestureRecognizerStateBegan) { // 长按手势开始
        if (indexPath) {
            [self onLongPressBeganWithSender:sender indexPath:indexPath];
        }
    } else if (sender.state == UIGestureRecognizerStateChanged){ // 手指移动
        [self onLongPressMove:sender];
    } else { // 长按结束
        [self onLongPressEnd:sender];
    }
}

- (void)onLongPressBeganWithSender:(UILongPressGestureRecognizer *)sender indexPath:(NSIndexPath *)indexPath {
    self.longPressIndexPath = indexPath;
    BOOL canDelete = YES;
    if ([self.delegate respondsToSelector:@selector(timeFlowView:shouldDeleteRowAtIndex:)]) {
        canDelete = [self.delegate timeFlowView:self shouldDeleteRowAtIndex:indexPath.row];
    }
    if (canDelete) {
        if ([self.delegate respondsToSelector:@selector(timeFlowView:willDeleteRowAtIndex:)]) {
            [self.delegate timeFlowView:self willDeleteRowAtIndex:self.longPressIndexPath.row];
        }
        
        [kDRWindow addSubview:self.deleteView];
        [self.deleteView show];
    }
    
    // 获取长按的cell
    UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:self.longPressIndexPath];
    CGAffineTransform transform = attr.transform;
    self.dragCell = [self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
    self.dragCell.shadowLayer.hidden = YES;
    if (self.longPressIndexPath.row > 0) {
        UICollectionViewCell *lastCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.longPressIndexPath.row-1 inSection:0]];
        lastCell.shadowLayer.hidden = YES;
    }
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        // 先动画让cell变回正常大小
        self.dragCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        if (sender.state != UIGestureRecognizerStateEnded &&
            sender.state != UIGestureRecognizerStateCancelled &&
            sender.state != UIGestureRecognizerStateFailed &&
            sender.state != UIGestureRecognizerStatePossible) {
            // 创建一个imageView并添加到window，imageView的image由cell截图得来
            self.dragImageView = [self createCellImageView];
            // 使用手指的中心位置设置截图中心点
            self.dragImageView.center =  [sender locationInView:kDRWindow];
            // 隐藏并恢复cell大小
            self.dragCell.hidden = YES;
            self.dragCell.transform = transform;
        }
    }];
}

- (void)onLongPressMove:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:kDRWindow];
    self.dragImageView.center = point;
    
    // 判断拖动的cell的中心是否在删除区域
    BOOL inDeleteView = CGRectContainsPoint(self.deleteView.frame, point);
    CGAffineTransform trans = CGAffineTransformIdentity;
    if(inDeleteView) {
        trans = CGAffineTransformMakeScale(0.4, 0.4);
    }
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.dragImageView.transform = trans;
    } completion:^(BOOL finished) {
        [self.deleteView backgroundAnimationWithIsZoom:inDeleteView];
    }];
}

- (void)onLongPressEnd:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:kDRWindow];
    BOOL delete = CGRectContainsPoint(self.deleteView.frame, point);
    [self.deleteView dismiss];
    
    if (delete) {
        // 移除截图视图
        [UIView animateWithDuration:kDRAnimationDuration animations:^{
            self.dragImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.dragImageView removeFromSuperview];
            self.dragImageView = nil;
        }];
        
        // 删除期间禁用滚动和长按手势
        self.collectionView.scrollEnabled = NO;
        self.longGesture.enabled = NO;
        
        kDRWeakSelf
        [self.delegate timeFlowView:self beginDeleteRowAtIndex:self.longPressIndexPath.row whenComplete:^{
            weakSelf.collectionView.scrollEnabled = YES;
            weakSelf.longGesture.enabled = YES;
            weakSelf.dragCell.hidden = NO;
            weakSelf.dragCell = nil;
            weakSelf.longPressIndexPath = nil;
            [weakSelf.collectionView reloadData];
        }];
    } else {
        [self recoverDragView];
    }
}

- (UIImageView *)createCellImageView {
    if (CGRectIsEmpty(self.dragCell.frame)) {
        return nil;
    }
    
    UIImageView *cellImageView = [[UIImageView alloc] initWithImage:[UIImage imageFromView:self.dragCell]];
    cellImageView.layer.shadowRadius = 5.0;
    cellImageView.layer.shadowOpacity = 0.4;
    cellImageView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    [kDRWindow addSubview:cellImageView];
    return cellImageView;
}

// 恢复cell显示，移除cellImageView
- (void)recoverDragView {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:cancelDeleteRowAtIndex:)]) {
        [self.delegate timeFlowView:self cancelDeleteRowAtIndex:self.longPressIndexPath.row];
    }
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.dragImageView.transform = self.dragCell.transform;
        self.dragImageView.center = [self.dragCell.superview convertPoint:self.dragCell.center
                                                                   toView:kDRWindow];
    } completion:^(BOOL finished) {
        self.dragCell.hidden = NO;
        self.dragCell = nil;
        [self.dragImageView removeFromSuperview];
        self.dragImageView = nil;
        self.longPressIndexPath = nil;
    }];
    [self setupVisibleCells];
}

#pragma mark - lazy load
// 垃圾桶视图
- (DRSectorDeleteView *)deleteView {
    static DRSectorDeleteView *deleteV = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deleteV = [DRSectorDeleteView new];
    });
    return deleteV;
}

- (NSMutableDictionary<NSNumber *, UICollectionViewCell *> *)visibleCellsMap {
    if (!_visibleCellsMap) {
        _visibleCellsMap = [NSMutableDictionary dictionary];
    }
    return _visibleCellsMap;
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
        
        self.maxItemSize = CGSizeMake(kDRScreenWidth-56, 74);
        self.decreasingStep = 4;
        self.coverOffset = 4;
        self.cellCornerRadius = 4;
        self.cellShadowColor = [UIColor hx_colorWithHexRGBAString:@"D6E7F4"];
        self.cellShadowOffset = 18;
    }
}

- (void)dealloc {
    kDR_LOG(@"%@dealloc", NSStringFromClass([self class]));
}

@end
