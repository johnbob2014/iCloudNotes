//
//  MasterTVC.m
//  iCloudNotes-Chapter08
//
//  Created by 张保国 on 16/5/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "MasterTVC.h"
#import "DetailVC.h"

@implementation MasterTVC{
    NSMutableArray *noteList;
    NSMetadataQuery *noteQuery;
    NSString *lastUpdatedNote;
}

- (NSString *)newNoteName{
    NSString *name;
    
    NSInteger noteCount=1;
    BOOL gotName=NO;
    while (!gotName) {
        name=[NSString stringWithFormat:@"Note %ld.note",(long)noteCount];
        BOOL noteExits=NO;
        for (NSURL *noteURL in noteList) {
            if ([noteURL.lastPathComponent isEqualToString:name]) {
                noteCount++;
                noteExits=YES;
            }
        }
        
        if (!noteExits) {
            gotName=YES;
        }
    }
    
    return name;
}

- (NSMetadataQuery *)noteListQuery{
    NSMetadataQuery *query=[[NSMetadataQuery alloc]init];
    query.searchScopes=@[NSMetadataQueryUbiquitousDocumentsScope];
    query.predicate=[NSPredicate predicateWithFormat:@"%K LIKE %@",NSMetadataItemFSNameKey,@"*.note"];
    return query;
}

- (void)processFiles:(NSNotification *)notification{
    NSMutableArray *foundFiles=[[NSMutableArray alloc]init];
    [noteQuery disableUpdates];
    
    NSArray *queryResults=[noteQuery results];
    for (NSMetadataItem *result in queryResults) {
        NSURL *fileURL=[result valueForAttribute:NSMetadataItemURLKey];
        NSNumber *isHidden = nil;
        [fileURL getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:nil];
        if (isHidden && ![isHidden boolValue]) {
            [foundFiles addObject:fileURL];
        }
    }
    
    [noteList removeAllObjects];
    [noteList addObjectsFromArray:foundFiles];
    
    [self.tableView reloadData];
    
    [noteQuery enableUpdates];
}

- (void)updateLastUpdateNote:(NSNotification *)notification{
    NSUbiquitousKeyValueStore *iCloudKeyValueStore=[NSUbiquitousKeyValueStore defaultStore];
    lastUpdatedNote=[iCloudKeyValueStore stringForKey:@"lastUpdatedNote"];
    [self.tableView reloadData];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;

    if(!noteList) noteList=[[NSMutableArray alloc]init];
    if(!noteQuery) noteQuery=[self noteListQuery];
    
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(processFiles:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    [center addObserver:self selector:@selector(processFiles:) name:NSMetadataQueryDidUpdateNotification object:nil];
    [center addObserver:self selector:@selector(updateLastUpdateNote:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    
    [noteQuery startQuery];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateLastUpdateNote:nil];
}

- (void)insertNewObject:(id)sender{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    dispatch_queue_t defaultQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSURL *newNoteURL=[fileManager URLForUbiquityContainerIdentifier:nil];
        newNoteURL=[newNoteURL URLByAppendingPathComponent:@"Documents" isDirectory:YES];
        newNoteURL=[newNoteURL URLByAppendingPathComponent:[self newNoteName]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [noteList addObject:newNoteURL];
            NSIndexPath *newIndexPath=[NSIndexPath indexPathForRow:([noteList count] - 1) inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [noteList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSURL *myNoteURL =
    [noteList objectAtIndex:[indexPath row]];
    
    NSString *noteName =
    [[myNoteURL lastPathComponent] stringByDeletingPathExtension];
    
    if ([lastUpdatedNote isEqualToString:noteName]) {
        
        NSString *lastUpdatedCellTitle =[NSString stringWithFormat:@"★ %@",noteName];
        
        [cell.textLabel setText:lastUpdatedCellTitle];
    }
    else{
        [cell.textLabel setText:noteName];
    }

    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSURL *noteURL=[noteList objectAtIndex:indexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileCoordinator *fileCoordinator=[[NSFileCoordinator alloc]initWithFilePresenter:nil];
            [fileCoordinator coordinateWritingItemAtURL:noteURL options:NSFileCoordinatorWritingForDeleting error:nil byAccessor:^(NSURL * _Nonnull newURL) {
                NSFileManager *fileManager=[NSFileManager defaultManager];
                [fileManager removeItemAtURL:newURL error:nil];
            }];
        });
        [noteList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSURL *mySelectedNote = noteList[indexPath.row];
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        DetailVC *detailVC=segue.destinationViewController;
        [detailVC setNoteURL:mySelectedNote];
        [detailVC.navigationItem setTitle:selectedCell.textLabel.text];
    }
}


@end
