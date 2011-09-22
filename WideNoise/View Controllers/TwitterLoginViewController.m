//
//  TwitterLoginViewController.m
//  WideNoise
//
//  Created by Emilio Pavia on 19/09/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "TwitterLoginViewController.h"

#import "EditableTableViewCell.h"

#define kUsernameTextFieldTag 1
#define kPassowrdTextFieldTag 2

@interface TwitterLoginViewController ()
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (void)textDidChange:(id)sender;

@end

@implementation TwitterLoginViewController

@synthesize delegate = _delegate;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark - Public methods

- (IBAction)cancel:(id)sender
{
    [(UIViewController *)self.delegate dismissModalViewControllerAnimated:YES];
}

- (IBAction)login:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.delegate twitterLoginViewController:self loginWithUsername:self.username password:self.password];
}

- (IBAction)showLoginError:(id)sender
{
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertViewErrorTitle", @"") 
                                 message:NSLocalizedString(@"TwitterAuthErrorMessage", @"")
                                delegate:nil 
                       cancelButtonTitle:NSLocalizedString(@"AlertViewOK", @"")                 
                       otherButtonTitles:nil]
      autorelease] show];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_username release];
    [_password release];
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
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.navigationItem.title = @"Twitter Account";
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(login:)] autorelease];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"New to Twitter? Join today!\nhttp://twitter.com";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *EditableCellIdentifier = @"EditableTableViewCell";
    
    EditableTableViewCell *cell = (EditableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:EditableCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EditableTableViewCell"
                                                     owner:self
                                                   options:nil];
        for (id oneObject in nib) 
            if ([oneObject isKindOfClass:[EditableTableViewCell class]])
                cell = (EditableTableViewCell *)oneObject;
        cell.textField.delegate = self;
    }
    
    if (indexPath.row == 0) {
        cell.textField.placeholder = @"Username";
        cell.textField.secureTextEntry = NO;
        cell.textField.tag = kUsernameTextFieldTag;
    } else if (indexPath.row == 1) {
        cell.textField.placeholder = @"Password";
        cell.textField.secureTextEntry = YES;
        cell.textField.tag = kPassowrdTextFieldTag;
    }
    
    [cell.textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - UITextField delegate

- (void)textDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    if (textField.tag == kUsernameTextFieldTag) {
        self.username = textField.text;
    } else if (textField.tag == kPassowrdTextFieldTag) {
        self.password = textField.text;
    }
    
    if (self.username.length>0 && self.password.length>0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

@end
