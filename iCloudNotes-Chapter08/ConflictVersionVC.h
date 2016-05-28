//
//  ConflictVersionVC.h
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConflictResolutionDelegate;

/**
    冲突文件版本视图控制器，负责显示冲突文件的各个版本
 */
@interface ConflictVersionVC : UIViewController
@property (nonatomic,weak) id<ConflictResolutionDelegate> delegate;
@property (nonatomic,strong) NSFileVersion *fileVersion;

@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) IBOutlet UILabel *versionDate;
@property (nonatomic, strong) IBOutlet UILabel *versionComputer;
- (IBAction)selectVersionTouched:(id)sender;

@end

@protocol ConflictResolutionDelegate <NSObject>
/**
    代理方法，将用户选中的版本传递给代理
 */
- (void)conflictVersionSelected:(NSFileVersion *)selectedVersion;
@end