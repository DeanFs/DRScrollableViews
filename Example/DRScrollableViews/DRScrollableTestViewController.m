//
//  DRViewController.m
//  DRScrollableViews
//
//  Created by Dean_F on 07/15/2019.
//  Copyright (c) 2019 Dean_F. All rights reserved.
//

#import "DRScrollableTestViewController.h"
#import <DRMacroDefines/DRMacroDefines.h>
#import "DRTimeFlowViewController.h"

@interface DRScrollableTestViewController ()

@end

@implementation DRScrollableTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        DRTimeFlowViewController *timeFlowVc = [[DRTimeFlowViewController alloc] init];
        timeFlowVc.title = @"Time Flow";
        [self.navigationController pushViewController:timeFlowVc animated:YES];
    }
}

@end
