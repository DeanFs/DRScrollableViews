//
//  DRFoldableItemModel.m
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/9/4.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import "DRFoldableItemModel.h"

@implementation DRFoldableItemModel

+ (instancetype)modelWithTitle:(NSString *)title imageName:(NSString *)imageName {
    DRFoldableItemModel *model = [DRFoldableItemModel new];
    model.title = title;
    model.imageName = imageName;
    return model;
}

@end
