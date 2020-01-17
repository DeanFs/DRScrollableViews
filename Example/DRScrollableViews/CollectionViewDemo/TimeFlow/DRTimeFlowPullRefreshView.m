//
//  DRTimeFlowPullRefreshView.m
//  DRCategories
//
//  Created by 冯生伟 on 2020/1/17.
//

#import "DRTimeFlowPullRefreshView.h"
#import <DRCategories/UIFont+DRExtension.h>
#import <HexColors/HexColors.h>
#import <Masonry/Masonry.h>

@interface DRTimeFlowPullRefreshView ()

@property (weak, nonatomic) UIView *nomalContainerView;
@property (weak, nonatomic) UILabel *statusLabel;
@property (weak, nonatomic) UIView *leftLine;
@property (weak, nonatomic) UIView *rightLine;
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@property (assign, nonatomic) BOOL isFooter;
@property (assign, nonatomic) DRTimeFlowPullRefreshStatus currentStatus;

@end

@implementation DRTimeFlowPullRefreshView

+ (instancetype)headerView {
    DRTimeFlowPullRefreshView *refreshView = [[DRTimeFlowPullRefreshView alloc] init];
    [refreshView setupSubViews];
    return refreshView;
}

+ (instancetype)footerView {
    DRTimeFlowPullRefreshView *refreshView = [[DRTimeFlowPullRefreshView alloc] init];
    refreshView.isFooter = YES;
    [refreshView setupSubViews];
    return refreshView;
}

- (void)setupSubViews {
    self.backgroundColor = [UIColor clearColor];
    
    UIView *containerView = [[UIView alloc] init];
    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_offset(CGPointZero);
    }];
    self.nomalContainerView = containerView;
    
    UIView *leftLine = [[UIView alloc] init];
    leftLine.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#A5A5A8"];
    [containerView addSubview:leftLine];
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(0);
        make.centerY.mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(50, 0.5));
    }];
    self.leftLine = leftLine;
    
    UILabel *lable = [[UILabel alloc] init];
    lable.textColor = [UIColor hx_colorWithHexRGBAString:@"#A5A5A8"];
    lable.font = [UIFont dr_PingFangSC_RegularWithSize:12];
    lable.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:lable];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftLine.mas_right).mas_offset(10);
        make.top.bottom.mas_offset(0);
        make.height.mas_equalTo(50);
    }];
    self.statusLabel = lable;
    
    UIView *rightLine = [[UIView alloc] init];
    rightLine.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#A5A5A8"];
    [containerView addSubview:rightLine];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lable.mas_right).mas_offset(10);
        make.right.mas_offset(0);
        make.centerY.mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(50, 0.5));
    }];
    self.rightLine = rightLine;
    
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] init];
    loadingView.color = [UIColor hx_colorWithHexRGBAString:@"#A5A5A8"];
    [self addSubview:loadingView];
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_offset(CGPointZero);
    }];
    self.loadingView = loadingView;
    
    [self setStatus:DRTimeFlowPullRefreshStatusNormal];
}


- (void)setStatus:(DRTimeFlowPullRefreshStatus)status {
    if (_currentStatus == DRTimeFlowPullRefreshStatusNoMoreData &&
        _currentStatus != DRTimeFlowPullRefreshStatusRest) {
        return;
    }
    if (_currentStatus == DRTimeFlowPullRefreshStatusLoading &&
        status != DRTimeFlowPullRefreshStatusNormal &&
        status != DRTimeFlowPullRefreshStatusNoMoreData) {
        return;
    }
    _currentStatus = status;
    self.nomalContainerView.hidden = NO;
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
    switch (status) {
        case DRTimeFlowPullRefreshStatusNormal:
        case DRTimeFlowPullRefreshStatusRest: {
            if (self.isFooter) {
                self.statusLabel.text = @"上滑查看上一年";
            } else {
                self.statusLabel.text = @"下滑查看下一年";
            }
        } break;
            
        case DRTimeFlowPullRefreshStatusPrepared: {
            if (self.isFooter) {
                self.statusLabel.text = @"松手查看上一年";
            } else {
                self.statusLabel.text = @"松手查看下一年";
            }
        } break;
            
        case DRTimeFlowPullRefreshStatusLoading: {
            self.nomalContainerView.hidden = YES;
            self.loadingView.hidden = NO;
            [self.loadingView startAnimating];
        } break;
            
        case DRTimeFlowPullRefreshStatusNoMoreData: {
            self.statusLabel.text = @"无更多数据";
        } break;
            
        default:
            break;
    }
}

- (CGFloat)refreshViewHeight {
    return 40;
}

- (void)setRefreshLabelColor:(UIColor *)refreshLabelColor {
    self.statusLabel.textColor = refreshLabelColor;
    self.leftLine.backgroundColor = refreshLabelColor;
    self.rightLine.backgroundColor = refreshLabelColor;
    self.loadingView.color = refreshLabelColor;
}

@end
