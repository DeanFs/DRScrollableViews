//
//  DRFoldableItemModel.h
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/9/4.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRFoldableItemModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;

+ (instancetype)modelWithTitle:(NSString *)title imageName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
