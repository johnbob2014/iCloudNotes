//
//  NoteDocument.m
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/25.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "NoteDocument.h"

@implementation NoteDocument

#pragma mark - UIDocument Methods
-(id)contentsForType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError{
    if (!self.noteText) {
        self.noteText=@"";
    }
    NSData *contents=[self.noteText dataUsingEncoding:NSUTF8StringEncoding];
    return contents;
}

-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError{
    if ([contents length] > 0) {
        self.noteText=[[NSString alloc]initWithData:(NSData *)contents encoding:NSUTF8StringEncoding];
    }else{
        self.noteText=@"";
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(noteDocumentContentsDidChange:)]) {
        [self.delegate noteDocumentContentsDidChange:self];
    }
    return YES;
}

-(void)setNoteText:(NSString *)noteText{
    NSString *oldNoteText=self.noteText;
    _noteText=[noteText copy];
    
    //实现自动保存
    [self.undoManager setActionName:@"Text Change"];
    //Records a single undo operation for a given target, so that when an undo is performed it is sent a specified selector with a given object as the sole argument.
    [self.undoManager registerUndoWithTarget:self selector:@selector(setNoteText:) object:oldNoteText];
}
@end
