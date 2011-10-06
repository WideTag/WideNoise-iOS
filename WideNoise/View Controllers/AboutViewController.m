//
//  AboutViewController.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (IBAction)openURL:(id)sender
{
    NSString *url = nil;
    switch (((UIButton *)sender).tag) {
        case 1:
            url = @"http://www.widetag.com/";
            break;
        case 2:
            url = @"http://www.everyaware.eu/";
            break;
        case 3:
            url = @"http://www.isi.it";
            break;
        case 4:
            url = @"http://www.phys.uniroma1.it/DipWeb/home.html";
            break;
        case 5:
            url = @"http://www.csp.it/";
            break;
        case 6:
            url = @"http://www.makemeapp.it/";
            break;
        default:
            break;
    }
    if (url != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
