//
//  TagsViewController.h
//  WideNoise
//
//  Created by Emilio Pavia on 12/09/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagsViewController;

@protocol TagsViewControllerDelegate <NSObject>
- (void)tagsViewController:(TagsViewController *)tagsViewController didSelectTags:(NSSet *)tags;
@end

@interface TagsViewController : UITableViewController <UITextFieldDelegate> {
@private
    NSMutableSet *_selectedTags;
}

@property (nonatomic, assign) id <TagsViewControllerDelegate> delegate;
@property (nonatomic, retain) NSSet *selectedTags;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
