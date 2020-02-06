//
//  DRTextScrollView.h
//  DRCategories
//
//  Created by 冯生伟 on 2020/2/6.
//

#import <UIKit/UIKit.h>

@interface DRTextScrollView : UIScrollView

@property (strong, nonatomic) NSArray<NSString *> *textList;
@property (strong, nonatomic) IBInspectable UIFont *textFont;
@property (strong, nonatomic) IBInspectable UIColor *textColor;
@property (assign, nonatomic) IBInspectable NSTextAlignment textAlignmant;
@property (assign, nonatomic) IBInspectable CGFloat animateDurtaion;
@property (assign, nonatomic) IBInspectable NSInteger numberOfLines;
@property (assign, nonatomic) IBInspectable NSLineBreakMode lineBreakMode;

- (void)startAnimation;
- (void)stopAnimation;
- (void)autoDeallocWithObj:(id)obj;

@end
