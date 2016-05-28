//
//  NoteDocument.h
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/25.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteDocumentDelegate;

/**
    NoteDocument类，继承自UIDocument
 */
@interface NoteDocument : UIDocument
/**
    noteText属性，表示内容
 */
@property (nonatomic,copy) NSString *noteText;
/**
    delegate，代理类可实现 noteDocumentContentsDidChange: 方法来接收NoteDocument类内容变化的通知
 */
@property (nonatomic,weak) id<NoteDocumentDelegate> delegate;
@end

@protocol NoteDocumentDelegate <NSObject>
@optional
- (void)noteDocumentContentsDidChange:(NoteDocument *)document;
@end