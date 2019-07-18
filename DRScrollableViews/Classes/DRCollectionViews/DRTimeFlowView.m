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

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier
                                                             forIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                          forIndexPath:indexPath];
}

- (void)setMaxItemSize:(CGSize)maxItemSize {
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    layout.maxItemSize = maxItemSize;
}

- (void)setDecreasingStep:(CGFloat)decreasingStep {
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    layout.decreasingStep = decreasingStep;
}

- (void)setCoverOffset:(CGFloat)coverOffset {
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    layout.coverOffset = coverOffset;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.containerView.backgroundColor = backgroundColor;
    self.collectionView.backgroundColor = backgroundColor;
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfRowsInTimeFlowView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource timeFlowView:self cellForRowAtIndexPath:indexPath];
}

#pragma mark <UICollectionViewDelegate>
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:shouldSelectRowAtIndexPath:)]) {
        return [self.delegate timeFlowView:self shouldSelectRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didSelectRowAtIndexPath:)]) {
        [self.delegate timeFlowView:self didSelectRowAtIndexPath:indexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:shouldDeselectRowAtIndexPath:)]) {
        [self.delegate timeFlowView:self shouldDeselectRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didDeselectRowAtIndexPath:)]) {
        [self.delegate timeFlowView:self didDeselectRowAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    cell.layer.shadowColor = [UIColor hx_colorWithHexRGBAString:@"#D6E7F4"].CGColor;
    CGFloat height = CGRectGetHeight(cell.bounds);
    CGFloat width = CGRectGetWidth(cell.bounds);
    CGFloat rate = (height - self.decreasingStep) / height;
    CGFloat neWidth = width * rate;
    CGRect shadowRect = CGRectInset(cell.bounds, (width-neWidth)/2, 4);
    shadowRect = CGRectOffset(shadowRect, 0, -5);
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
   
    cell.layer.shadowOpacity = 0.9;
    if (indexPath.row == 0) {
        cell.layer.shadowOpacity = 0;
    }
    
    if (indexPath.row < self.lastIndexPath.row || !self.lastIndexPath) {
        [cell.superview sendSubviewToBack:cell];
    }
    self.lastIndexPath = indexPath;
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.delegate timeFlowView:self willDisplayCell:cell forRowAtIndexPath:indexPath];
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
