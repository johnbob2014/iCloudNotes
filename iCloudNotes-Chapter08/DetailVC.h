//
//  DetailVC.h
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteDocument.h"
#import "ConflictResolutionVC.h"

@interface DetailVC : UIViewController<NoteDocumentDelegate,NoteConflictDelegate>

@property (nonatomic,strong) NSURL *noteURL;

@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *conflictButton;

- (IBAction)resolveConflictTapped:(id)sender;

@end
