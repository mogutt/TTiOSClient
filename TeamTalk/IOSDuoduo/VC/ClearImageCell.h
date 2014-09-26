//
//  ClearImageCell.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-01.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClearImageCell : UITableViewCell
@property(strong)UIImageView *image;
@property(strong)UILabel *mainLabel;
@property(strong)UILabel *detailLabel;
@property(strong)UIImageView *selectImage;
@property(strong)NSString *path;
@property(assign)BOOL isSelect;
-(void)setCellIsToHighlight:(BOOL)isHighlight;
@end
