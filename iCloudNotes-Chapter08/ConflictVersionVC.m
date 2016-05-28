//
//  ConflictVersionVC.m
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ConflictVersionVC.h"
#import "NoteDocument.h"

@implementation ConflictVersionVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateString=[dateFormatter stringFromDate:[self.fileVersion modificationDate]];
    self.versionLabel.text=[self.fileVersion localizedName];
    self.versionDate.text=dateString;
    self.versionComputer.text=[self.fileVersion localizedNameOfSavingComputer];
}

-(void)selectVersionTouched:(id)sender{
    [self.delegate conflictVersionSelected:self.fileVersion];
}

@end
