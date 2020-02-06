//
//  DRTextScrollView.m
//  DRCategories
//
//  Created by 冯生伟 on 2020/2/6.
//

#import "DRTextScrollView.h"
#import <DRCategories/DRDeallocObserver.h>
#import <DRCategories/UIView+DRExtension.h>
#import <DRCategories/NSArray+DRExtension.h>
#import <DRMacroDefines/DRMacroDefines.h>

@interface DRTextScrollView ()<UIScrollViewDelegate>

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSArray<UILabel *> *labels;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) BOOL animating;
@property (assign, nonatomic) BOOL didDraw;

@end

@implementation DRTextScrollView

- (void)startAnimation {
    if (self.textList.count < 2) {
        return;
    }
    if (self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:self.animateDurtaion
                                             target:self
                                           selector:@selector(onTimerFir)
                                           userInfo:nil
                                            repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer
                                  forMode:NSRunLoopCommonModes];
    }
    self.animating = YES;
}

- (void)stopAnimation {
    [self.timer invalidate];
    self.timer = nil;
    self.animating = NO;
}

- (void)autoDeallocWithObj:(id)obj {
    [DRDeallocObserver associateParasitifer:obj target:self deallocBlock:^(id target, id parasitifer) {
        DRTextScrollView *textView = (DRTextScrollView *)target;
        [textView stopAnimation];
    }];
}

- (void)setTextList:(NSArray<NSString *> *)textList {
    [self.timer invalidate];
    self.timer = nil;
    
    _textList = textList;
    
    self.labels[0].text = [textList safeGetObjectWithIndex:0];
    self.labels[1].text = [textList safeGetObjectWithIndex:1];
    self.currentIndex = 0;
    self.contentOffset = CGPointZero;
    
    if (self.animating) {
        [self startAnimation];
    }
}

- (void)setTextFont:(UIFont *)textFont {
    for (UILabel *label in self.labels) {
        label.font = textFont;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    for (UILabel *label in self.labels) {
        label.textColor = textColor;
    }
}

- (void)setTextAlignmant:(NSTextAlignment)textAlignmant {
    for (UILabel *label in self.labels) {
        label.textAlignment = textAlignmant;
    }
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    for (UILabel *label in self.labels) {
        label.numberOfLines = numberOfLines;
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    for (UILabel *label in self.labels) {
        label.lineBreakMode = lineBreakMode;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.currentIndex ++;
    if (self.currentIndex >= self.textList.count) {
        self.currentIndex = 0;
    }
    self.labels[0].text = self.textList[self.currentIndex];
    
    NSInteger nextIndex = self.currentIndex + 1;
    if (nextIndex >= self.textList.count) {
        nextIndex = 0;
    }
    self.labels[1].text = self.textList[nextIndex];
    
    [self setContentOffset:CGPointZero];
}

#pragma mark - private
- (void)onTimerFir {
    [self setContentOffset:CGPointMake(0, self.height) animated:YES];
}

#pragma mark - setup xib
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
    self.backgroundColor = [UIColor clearColor];
    self.contentInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.clipsToBounds = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.scrollEnabled = NO;
    self.delegate = self;
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.lineBreakMode = NSLineBreakByWordWrapping;
    label1.numberOfLines = 0;
    [self addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.lineBreakMode = NSLineBreakByWordWrapping;
    label2.numberOfLines = 0;
    [self addSubview:label2];
    
    self.labels = @[label1, label2];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!self.didDraw && !CGRectIsEmpty(rect)) {
        self.didDraw = YES;
        
        for (NSInteger i=0; i<self.labels.count; i++) {
            UILabel *label = self.labels[i];
            label.frame = self.bounds;
            label.y = i * self.height;
        }
        [self setContentSize:CGSizeMake(self.width, self.height * 2)];
    }
}

- (void)dealloc {
    kDR_LOG(@"%@ dealloc", NSStringFromClass([self class]));
}

@end
