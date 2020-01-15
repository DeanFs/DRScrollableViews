//
//  DRSandBoxManager.m
//  DRBasicKit
//
//  Created by 冯生伟 on 2019/3/7.
//

#import "DRSandBoxManager.h"

@implementation DRSandBoxManager

#pragma mark - 磁盘信息获取
/**
 获取磁盘空间信息
 
 @param block 获取结果回调
 */
+ (void)getDiskSpaceInfoWithBlock:(void(^)(NSError *error, unsigned long long freeSpace, unsigned long long totalSpace))block {
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
    
    if (!error && dictionary) {
        
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        if (block != nil) {
            block(nil, [freeFileSystemSizeInBytes longLongValue], [fileSystemSizeInBytes longLongValue]);
        }
    } else {
        if (block != nil) {
            block(error, 0, 0);
        }
    }
}

/**
 获取指定路径文件或文件夹大小
 
 @param filePath 文件或文件夹绝对路径
 @param block 获取结果回调
 */
+ (void)getFileSizeWithPath:(NSString*)filePath
                  doneBlock:(void(^)(NSError *error, unsigned long long fileSize))block {
    
    if (!filePath) {
        NSError *error = [NSError errorWithDomain:@"filePath 不可为空"
                                             code:-1
                                         userInfo:nil];
        if (block != nil) {
            block(error, 0);
        }
        return;
    }
    
    NSFileManager* manager = [NSFileManager defaultManager];
    NSError *error;
    
    if ([manager fileExistsAtPath:filePath]) {
        unsigned long long fileSize = [[manager attributesOfItemAtPath:filePath error:&error] fileSize];
        if (error) {
            if (block != nil) {
                block(error, 0);
            }
        } else {
            if (block != nil) {
                block(nil, fileSize);
            }
        }
    } else {
        error = [NSError errorWithDomain:[NSString stringWithFormat:@"不存在文件 : %@", filePath]
                                    code:-1
                                userInfo:nil];
        if (block != nil) {
            block(error, 0);
        }
    }
}


#pragma mark - 沙盒系统文件夹路径，文件管理
/**
 * 获取document目录路径
 */
+ (NSString *)getDocumentPath {
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [Paths objectAtIndex:0];
}

/**
 返回Document下的指定文件夹，不存在则自动创建文件夹，dirName
 
 @param dirName 文件夹名，可以是纯文件夹名称，如User，也可以是相对路径，如User/Audio，也可以是包含Document的绝对路径
 @param block 获取结果回调
 */
+ (void)getDirectoryInDocumentWithName:(NSString *)dirName
                             doneBlock:(void(^)(BOOL success, NSError *error, NSString *dirPath))block {
    
    if (!dirName) {
        NSError *error = [NSError errorWithDomain:@"dirName 不可为空"
                                             code:-1
                                         userInfo:nil];
        if (block != nil) {
            block(NO, error, nil);
        }
        return;
    }
    
    NSString *document = [self getDocumentPath];
    NSString *dirPath = dirName;
    NSError *error = nil;
    
    if ([dirName rangeOfString:document].length == 0) {
        dirPath = [document stringByAppendingPathComponent:dirName];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    
    if (!(isDirExist && isDir)) {
        if (![fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (block != nil) {
                block(NO, error, nil);
            }
            return;
        }
    }
    if (block != nil) {
        block(YES, nil, dirPath);
    }
}

/**
 返回Document下dirName文件夹内的fileName文件路径
 
 @param fileName 单纯的文件名，如music.wav
 @param dirName 文件夹名，可以是纯文件夹名称，如User，也可以是相对路径，如User/Audio，也可以是包含Document的绝对路径，
 为空则表示fileName是在document下
 @param block 获取结果回调
 */
+ (void)getFilePathWithName:(NSString *)fileName
                      inDir:(NSString *)dirName
                  doneBlock:(void(^)(NSError *error, NSString *filePath))block {
    [self getDirectoryInDocumentWithName:dirName doneBlock:^(BOOL success, NSError *error, NSString *dirPath) {
        if (!success) {
            if (block != nil) {
                block(error, nil);
            }
        } else {
            if (block != nil) {
                block(nil, [dirPath stringByAppendingPathComponent:fileName]);
            }
        }
    }];
}

/**
 获取文件夹下的子目录列表
 
 @param dirPath 文件夹绝对路径
 @return 子目录列表
 */
+ (NSArray *)getSubpathsAtPath:(NSString *)dirPath {
    return [[NSFileManager defaultManager] subpathsAtPath:dirPath];
}

/**
 移动文件
 
 @param path 文件原绝对路径
 @param targetPath 文件目标绝对路径
 @param block 移动完成回调
 */
+ (void)moveFileAtPath:(NSString *)path
                toPath:(NSString *)targetPath
             doneBlock:(void(^)(BOOL success, NSError *error))block {
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSError *error;
    if([fileManage moveItemAtPath:path toPath:targetPath error:&error]) {
        if (block != nil) {
            block(YES, nil);
        }
    } else {
        if (block != nil) {
            block(NO, error);
        }
    }
}

/**
 检查是否存在文件
 
 @param filePath 文件绝对路径
 @return 检查结果
 */
+ (BOOL)isExistsFileAtPath:(NSString *)filePath {
    BOOL isDir;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    return isExists && !isDir;
}

/**
 检查是否存在文件夹
 
 @param folderPath 文件夹绝对路径
 @return 检查结果
 */
+ (BOOL)isExistsFolderAtPath:(NSString *)folderPath {
    BOOL isDir;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    return isExists && isDir;
}

/**
 删除指定文件或文件夹
 
 @param filePath 文件或者文件夹绝对路径
 @param block 删除结果回调
 */
+ (void)deleteFileAtPath:(NSString *)filePath doneBlock:(void(^)(NSString *filePath, BOOL success, NSError *error))block {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([manager removeItemAtPath:filePath error:&error]) {
            if (block != nil) {
                block(filePath, YES, nil);
            }
        } else {
            if (block != nil) {
                block(filePath, NO, error);
            }
        }
    }
}


#pragma mark- 获取文件的数据
/**
 读取文件 path问该文件绝对路径
 
 @param path 文件路径
 @return 文件内容
 */
+ (NSData *)getDataForPath:(NSString *)path {
    return [[NSFileManager defaultManager] contentsAtPath:path];
}


#pragma mark - 保存图片、视频
/**
 保存指定照片到相册
 
 @param image 指定要保存的图片，UIImage，NSData，NSString(图片路径)，NSUrl(图片路径)
 @param saveDoneBlock 保存完成回调
 */
+ (void)saveToSystemAlbumWithImage:(id)image
                     saveDoneBlock:(void(^)(BOOL success, NSError *error))saveDoneBlock {
    [self saveToSystemAlbumWithObj:image
                           isVideo:NO
                     saveDoneBlock:saveDoneBlock];
}

/**
 保存指定视频到相册
 
 @param video 指定要保存的视频路径，NSSting 或者 NSUrl 均可
 @param saveDoneBlock 保存完成回调
 */
+ (void)saveToSystemAlbumWithVideo:(id)video
                     saveDoneBlock:(void(^)(BOOL success, NSError *error))saveDoneBlock {
    [self saveToSystemAlbumWithObj:video
                           isVideo:YES
                     saveDoneBlock:saveDoneBlock];
}

+ (void)saveToSystemAlbumWithObj:(id)obj
                         isVideo:(BOOL)isVideo
                   saveDoneBlock:(void(^)(BOOL success, NSError *error))saveDoneBlock {
    // 1. 获取相片库对象
    PHPhotoLibrary *lib = [PHPhotoLibrary sharedPhotoLibrary];
    // 2. 调用changeBlock
    [lib performChanges:^{
        // 2.1 创建一个相册变动请求
        PHAssetCollectionChangeRequest *collectionRequest;
        
        // 2.2 取出指定名称的相册
        PHAssetCollection *assetCollection = [self getCurrentPhotoCollectionWithTitle:@"时光序"];
        
        // 2.3 判断相册是否存在
        if (assetCollection) { // 如果存在就使用当前的相册创建相册请求
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else { // 如果不存在, 就创建一个新的相册请求
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"时光序"];
        }
        
        // 2.4 根据传入的相片, 创建相片变动请求
        PHAssetChangeRequest *assetRequest;
        if (!isVideo) {
            if ([obj isKindOfClass:[UIImage class]]) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:(UIImage *)obj];
            } else if ([obj isKindOfClass:[NSData class]]) {
                UIImage *image = [[UIImage alloc] initWithData:(NSData *)obj];
                if (image == nil) {
                    return;
                }
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } else if([obj isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL fileURLWithPath:(NSString *)obj];
                if (url == nil) {
                    return;
                }
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
            } else if([obj isKindOfClass:[NSURL class]]) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:(NSURL *)obj];
            } else {
                return;
            }
        } else {
            if ([obj isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL fileURLWithPath:(NSString *)obj];
                if (url == nil) {
                    return;
                }
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            } else if ([obj isKindOfClass:[NSURL class]]) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:(NSURL *)obj];
            } else {
                return;
            }
        }
        
        // 2.4 创建一个占位对象
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        
        // 2.5 将占位对象添加到相册请求中
        [collectionRequest addAssets:@[placeholder]];
    } completionHandler:saveDoneBlock];
}

+ (PHAssetCollection *)getCurrentPhotoCollectionWithTitle:(NSString *)collectionName {
    // 1. 创建搜索集合
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 2. 遍历搜索集合并取出对应的相册
    for (PHAssetCollection *assetCollection in result) {
        if ([assetCollection.localizedTitle containsString:collectionName]) {
            return assetCollection;
        }
    }
    return nil;
}

/**
 保存指定图片到三盒指定路径
 
 @param image 待保存图片
 @param path 图片要保存到的路径，绝对路径，或者是Document下的相对路径，如@"Test/Image/image.jpg"
 @param saveDoneBlock 保存完成回调
 */
+ (void)saveToSandboxWithImage:(UIImage *)image
                      withPath:(NSString *)path
                 saveDoneBlock:(void(^)(BOOL success, NSError *error))saveDoneBlock {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [path stringByDeletingLastPathComponent];
    [self getDirectoryInDocumentWithName:dirPath doneBlock:^(BOOL success, NSError *error, NSString *dirPath) {
        if (success) {
            NSString *filePath = [dirPath stringByAppendingPathComponent:[path lastPathComponent]];
            NSData *imageData = UIImagePNGRepresentation(image);
            BOOL isSuccess = [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
            if (isSuccess) {
                if (saveDoneBlock != nil) {
                    saveDoneBlock(YES, nil);
                }
            } else {
                if (saveDoneBlock != nil) {
                    saveDoneBlock(NO, nil);
                }
            }
        } else {
            if (saveDoneBlock != nil) {
                saveDoneBlock(NO, error);
            }
        }
    }];
}

@end
