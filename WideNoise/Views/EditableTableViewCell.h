//
//  EditableTableViewCell.h
//  WideNoise
//
//  Created by Emilio Pavia on 14/05/10.
//  Copyright 2010 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditableTableViewCell : UITableViewCell {
	UITextField *textField;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

@end
