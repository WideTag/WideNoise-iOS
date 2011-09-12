//
//  TagTableViewCell.m
//  WideNoise
//
//  Created by Emilio Pavia on 12/09/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "TagTableViewCell.h"

@implementation TagTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:1.0 green:236.0/255.0 blue:215.0/255.0 alpha:1.0];
        self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]] autorelease];
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.accessoryView = nil;
    }
}

@end
