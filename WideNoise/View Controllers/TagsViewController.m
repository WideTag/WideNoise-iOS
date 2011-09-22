//
//  TagsViewController.m
//  WideNoise
//
//  Created by Emilio Pavia on 12/09/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "TagsViewController.h"

#import "EditableTableViewCell.h"
#import "TagTableViewCell.h"

@interface TagsViewController ()

@property (nonatomic, retain) NSMutableArray *tags;

- (void)addTagWithText:(NSString *)text;

@end

@implementation TagsViewController

@synthesize delegate;
@synthesize tags;

#pragma mark IBAction methods

- (IBAction)cancel:(id)sender
{
    [self.delegate tagsViewControllerDidCancel:self];
}

- (IBAction)save:(id)sender
{
    [self.delegate tagsViewController:self didSelectTags:self.selectedTags];
}

#pragma mark - Properties

- (void)setSelectedTags:(NSSet *)selectedTags
{
    if (selectedTags != _selectedTags) {
        [_selectedTags release];
        _selectedTags = [[NSMutableSet alloc] initWithSet:selectedTags]; 
    }    
}

- (NSSet *)selectedTags
{
    return [NSSet setWithSet:_selectedTags];
}

#pragma mark - Private methods

- (void)addTagWithText:(NSString *)text
{
    if ([text length] > 0 && ![self.tags containsObject:text]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        
        [self.tags insertObject:text atIndex:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                              withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView cellForRowAtIndexPath:indexPath].highlighted = YES;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.tags forKey:@"tags"];
        [defaults synchronize];
        
        [_selectedTags addObject:text];
    } else if ([self.tags containsObject:text]) {
        NSUInteger index = [self.tags indexOfObject:text];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index+1 inSection:0]];
        cell.highlighted = YES;
        
        [_selectedTags addObject:text];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[self addTagWithText:textField.text];
    [textField setText:@""];
    [textField resignFirstResponder];
    
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{    
    return YES;
}

#pragma mark -

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        tags = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"tags"]];
        _selectedTags = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [tags release];
    [_selectedTags release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Tags";
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(save:)] autorelease];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:43.0/255.0 green:43.00/255.0 blue:40.0/255.0 alpha:1.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tags count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *EditableCellIdentifier = @"EditableCell";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        EditableTableViewCell *editableCell = (EditableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:EditableCellIdentifier];
        if (editableCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EditableTableViewCell"
                                                         owner:self
                                                       options:nil];
            for (id oneObject in nib) 
                if ([oneObject isKindOfClass:[EditableTableViewCell class]])
                    editableCell = (EditableTableViewCell *)oneObject;
            editableCell.textField.delegate = self;
        }
        
        editableCell.textField.placeholder = @"New tag";
        
        cell = editableCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[TagTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        NSString *tag = [self.tags objectAtIndex:indexPath.row-1];
        cell.textLabel.text = tag;
    }    
    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *tag = [self.tags objectAtIndex:indexPath.row-1];
    if ([_selectedTags containsObject:tag]) {
        [_selectedTags removeObject:tag];
        [selectedCell setHighlighted:NO];
    } else {
        [_selectedTags addObject:tag];
        [selectedCell setHighlighted:YES];
        
    } 
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        if (![_selectedTags containsObject:[self.tags objectAtIndex:indexPath.row-1]]) {
            [cell setHighlighted:NO];   
        } else {
            [cell setHighlighted:YES];
        }
    }    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_selectedTags removeObject:[self.tags objectAtIndex:indexPath.row-1]];
        [self.tags removeObjectAtIndex:indexPath.row-1];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.tags forKey:@"tags"];
        [defaults synchronize];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

@end
