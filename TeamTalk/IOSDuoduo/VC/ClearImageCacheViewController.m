//
//  ClearImageCacheViewController.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-01.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "ClearImageCacheViewController.h"
#import "PhotosCache.h"
#import "ClearImageCell.h"
@interface ClearImageCacheViewController ()
@property(strong)NSMutableArray *images;
@property(strong)NSMutableArray *selectedItems;
@property(weak)IBOutlet UIImageView *selectAll;
-(IBAction)clearSelectedImage:(id)sender;
@end

@implementation ClearImageCacheViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"清理图片缓存";
    self.selectedItems = [NSMutableArray new];
    self.images=[[PhotosCache sharedPhotoCache] getAllImageCache];
    self.tableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 320, self.view.frame.size.height-45-70)];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAllImage)];
    [self.selectAll addGestureRecognizer:tap];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(IBAction)clearSelectedImage:(id)sender
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [self.selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *path = (NSString *)obj;
         [fileManager removeItemAtPath:path error:nil];
    }];
    [self.images removeObjectsInArray:self.selectedItems];
    [self.tableView reloadData];
    if ([self.selectedItems count] == 0) {
        [self.selectAll setHighlighted:NO];
    }
}
-(void)selectAllImage
{
    if ([self.selectedItems isEqualToArray:self.images]) {
        [self.selectedItems removeAllObjects];
        [self.selectAll setHighlighted:NO];
    }else
    {
        [self.selectedItems removeAllObjects];
        [self.selectAll setHighlighted:YES];
        [self.selectedItems addObjectsFromArray:self.images];
    }
    [self.tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.images count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ClearImageCacheCellIdentifier";
    ClearImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[ClearImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClearImageCacheCellIdentifier"];
    }
    cell.image.image =[UIImage imageWithContentsOfFile:[self.images objectAtIndex:indexPath.row]];
    cell.path = [self.images objectAtIndex:indexPath.row];
    [cell.mainLabel setText:@"cecececece"];
    [cell.detailLabel setText:@"cacacacacaca"];
    if ([self.selectedItems containsObject:cell.path]) {
        [cell setCellIsToHighlight:YES];
    }else
    {
        [cell setCellIsToHighlight:NO];
    }

    return cell;
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ClearImageCell *cell = (ClearImageCell *)[tableView cellForRowAtIndexPath:indexPath];

    if ([self.selectedItems containsObject:cell.path]) {
        [self.selectedItems removeObject:cell.path];
        [cell setCellIsToHighlight:NO];
    }else
    {
        [self.selectedItems addObject:cell.path];
        [cell setCellIsToHighlight:YES];
    }
}


@end
