//
//  DetailVC.m
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "DetailVC.h"


@implementation DetailVC{
    NoteDocument *noteDocument;
}

#pragma mark - Managing Detail Item
- (void)configureView{
    self.noteTextView.text=@"";
    noteDocument=[[NoteDocument alloc]initWithFileURL:self.noteURL];
    noteDocument.delegate=self;
    
    NSFileManager *fm=[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.noteURL.path]) {
        [noteDocument openWithCompletionHandler:^(BOOL success) {
            self.noteTextView.text=noteDocument.noteText;
            if (noteDocument.documentState == UIDocumentStateNormal) {
                [self.noteTextView becomeFirstResponder];
            }
        }];
    }else{
        [noteDocument saveToURL:self.noteURL forSaveOperation:UIDocumentSaveForCreating completionHandler:nil];
        [self.noteTextView becomeFirstResponder];
    }
    
    NSUbiquitousKeyValueStore *iCloudKeyValueStore=[NSUbiquitousKeyValueStore defaultStore];
    NSString *noteName=[[self.noteURL lastPathComponent] stringByDeletingPathExtension];
    [iCloudKeyValueStore setString:noteName forKey:@"kICFLastUpdatedNoteKey"];
    [iCloudKeyValueStore synchronize];
}

#pragma mark - Note Document Delegate
-(void)noteDocumentContentsDidChange:(NoteDocument *)document{
    //接收到NoteDocument内容变化通知时，更新视图
    dispatch_async(dispatch_get_main_queue(), ^{
        self.noteTextView.text=document.noteText;
    });
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentStateChanged)
                                                 name:UIDocumentStateChangedNotification object:noteDocument];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    noteDocument.noteText=self.noteTextView.text;
    [noteDocument closeWithCompletionHandler:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDocumentStateChangedNotification
                                                  object:noteDocument];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)resolveConflictTapped:(id)sender{
    NSArray *versionArray=[NSFileVersion unresolvedConflictVersionsOfItemAtURL:self.noteURL];
    NSFileVersion *currentVersion=[NSFileVersion currentVersionOfItemAtURL:self.noteURL];
    NSMutableArray <NSFileVersion *> *conflictVersionMA=[NSMutableArray arrayWithArray:versionArray];
    [conflictVersionMA addObject:currentVersion];
    
    ConflictResolutionVC *crVC=[self.storyboard instantiateViewControllerWithIdentifier:@"ConflictResolutionVC"];
    crVC.versionList=conflictVersionMA;
    crVC.currentVersion=currentVersion;
    crVC.conflictNoteURL=self.noteURL;
    crVC.delegate=self;
    
    [self presentViewController:crVC animated:YES completion:nil];
}

#pragma mark - UIDocument Notification Handler
-(void)documentStateChanged{
    if (noteDocument.documentState & UIDocumentStateEditingDisabled) {
        [self.noteTextView resignFirstResponder];
        return;
    }
    
    if (noteDocument.documentState & UIDocumentStateInConflict) {
        self.conflictButton.hidden=NO;
        [self.noteTextView resignFirstResponder];
        return;
    }else{
        self.conflictButton.hidden=YES;
    }
}

#pragma mark - Keyboard Methods
-(void)keyboardWillShow:(NSNotification *)noti{
    NSDictionary *info=noti.userInfo;
    CGRect kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration=[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIEdgeInsets insets=self.noteTextView.contentInset;
    insets.bottom += kbSize.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        self.noteTextView.contentInset=insets;
    }];
}

-(void)keyboardWillHide:(NSNotification *)noti{
    NSDictionary *info=noti.userInfo;
    double duration=[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIEdgeInsets insets=self.noteTextView.contentInset;
    insets.bottom=0;
    
    [UIView animateWithDuration:duration animations:^{
        self.noteTextView.contentInset=insets;
    }];
}

#pragma mark - NoteConflictDelegate
-(void)noteConflictResolved:(NSFileVersion *)selectedVersion forCurrentVersion:(BOOL)isCurrentVersion{
    if (!isCurrentVersion) {
        //如果用户选择的不是当前版本，用选择的版本替代当前版本
        [selectedVersion replaceItemAtURL:noteDocument.fileURL options:0 error:nil];
    }
    
    [NSFileVersion removeOtherVersionsOfItemAtURL:noteDocument.fileURL error:nil];
    NSArray *conflictVersions=[NSFileVersion unresolvedConflictVersionsOfItemAtURL:noteDocument.fileURL];
    for (NSFileVersion *fileVersion in conflictVersions) {
        fileVersion.resolved=YES;
    }
    
    [self configureView];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
