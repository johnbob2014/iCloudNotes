//
//  ConflictResolutionVC.h
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConflictVersionVC.h"

@protocol NoteConflictDelegate;

/**
    冲突文件解决中心视图控制器，负责集中管理和显示冲突文件的各个版本
 */
@interface ConflictResolutionVC : UIViewController<ConflictResolutionDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic,weak) id<NoteConflictDelegate> delegate;

@property (nonatomic,strong) UIPageViewController *pageVC;
@property (nonatomic,strong) NSArray *versionList;
@property (nonatomic,strong) NSFileVersion *currentVersion;
@property (nonatomic,strong) NSURL *conflictNoteURL;

-(ConflictVersionVC *)conflictVersionVCAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
-(NSUInteger)indexOfConflictVersionVC:(ConflictVersionVC *)conflictVersionVC;

@end

@protocol NoteConflictDelegate <NSObject>
- (void)noteConflictResolved:(NSFileVersion *)selectedVersion forCurrentVersion:(BOOL)isCurrentVersion;
@end
