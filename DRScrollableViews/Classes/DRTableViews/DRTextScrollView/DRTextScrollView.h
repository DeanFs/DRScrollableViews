//
//  DRTextScrollView.h
//  DRCategories
//
//  Created by 冯生伟 on 2020/2/6.
//

#import <UIKit/UIKit.h>

@interface DRTextScrollView : UIScrollView

@property (strong, nonatomic) NSArray<NSString *> *textList;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) UIColor *textColor;
@property (assign, nonatomic) NSTextAlignment textAlignmant;
@property (assign, nonatomic) CGFloat animateDurtaion;
@property (assign, nonatomic) NSInteger numberOfLines;
@property (assign, nonatomic) NSLineBreakMode lineBreakMode;

- (void)startAnimation;
- (void)stopAnimation;
- (void)autoDeallocWithObj:(id)obj;

@end
