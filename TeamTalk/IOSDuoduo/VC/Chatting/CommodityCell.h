//
//  DDCommodityCell.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-3.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDMessageEntity;
@interface CommodityCell : UITableViewCell
@property(nonatomic,weak)IBOutlet UILabel *priceOld;
@property(nonatomic,weak)IBOutlet UILabel *priceNew;
@property(nonatomic,weak)IBOutlet UILabel *title;
@property(nonatomic,weak)IBOutlet UIImageView *logo;
-(void)setOldPrice:(float )price;
-(void)setNewPrice:(float )price;

- (void)setMessage:(DDMessageEntity*)message;
@end
