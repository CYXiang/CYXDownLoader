//
//  CYXMainController.m
//  CYXDownLoader
//
//  Created by 陈燕翔 on 2017/9/21.
//  Copyright © 2017年 陈燕翔. All rights reserved.
//

#import "CYXMainController.h"

@interface CYXMainController ()

@end

@implementation CYXMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.clearsSelectionOnViewWillAppear = NO;

     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


@end
