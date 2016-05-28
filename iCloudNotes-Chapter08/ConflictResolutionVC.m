//
//  ConflictResolutionVC.m
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ConflictResolutionVC.h"

@implementation ConflictResolutionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.pageVC=[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageVC.delegate=self;
    
    ConflictVersionVC *startVC=[self conflictVersionVCAtIndex:0 storyboard:self.storyboard];
    [self.pageVC setViewControllers:@[startVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageVC.dataSource=self;
    
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    
    self.pageVC.view.frame=self.view.bounds;
    
    [self.pageVC didMoveToParentViewController:self];
    
    self.view.gestureRecognizers=self.pageVC.gestureRecognizers;
}

#pragma mark - Custom Methods
-(ConflictVersionVC *)conflictVersionVCAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard{
    if ([self.versionList count] == 0 || index >= [self.versionList count]) {
        return nil;
    }
    
    ConflictVersionVC *conflictVersionVC=[storyboard instantiateViewControllerWithIdentifier:@"ConflictVersionVC"];
    conflictVersionVC.fileVersion=self.versionList[index];
    conflictVersionVC.delegate=self;
    
    return conflictVersionVC;
}

-(NSUInteger)indexOfConflictVersionVC:(ConflictVersionVC *)conflictVersionVC{
    return [self.versionList indexOfObject:conflictVersionVC.fileVersion];
}

#pragma mark - Note Conflict Delegate Method
-(void)conflictVersionSelected:(NSFileVersion *)selectedVersion{
    [self.delegate noteConflictResolved:selectedVersion forCurrentVersion:(selectedVersion == self.currentVersion)];
}

#pragma mark - UIPageViewController Delegate Methods
-(UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation{
    UIViewController *currentViewController=self.pageVC.viewControllers[0];
    [self.pageVC setViewControllers:@[currentViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    self.pageVC.doubleSided=NO;
    return UIPageViewControllerSpineLocationMin;
}

#pragma mark - UIPageViewController Data Source
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index=[self indexOfConflictVersionVC:(ConflictVersionVC *)viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    index--;
    return [self conflictVersionVCAtIndex:index storyboard:viewController.storyboard];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index=[self indexOfConflictVersionVC:(ConflictVersionVC *)viewController];
    index++;
    if (index >= [self.versionList count] || index== NSNotFound) {
        return nil;
    }
    return [self conflictVersionVCAtIndex:index storyboard:viewController.storyboard];
}
@end
