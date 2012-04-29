//
//  TableViewController.m
//
//  Created by kmyhy on 4/28/2012
//  Copyright 2012 kmyhy. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE

#import "TableViewController.h"

@implementation TableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        loadedCount=1;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _refreshBar=[[RefreshBar alloc]init];
    [_refreshBar setFrame:CGRectMake(0.0f, 
                                0.0f + self.tableView.frame.size.height, 
                                self.view.frame.size.width, 
                                _refreshBar.frame.size.height)];
    _refreshBar.delegate=self;
    [self.tableView addSubview:_refreshBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_refreshBar release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return loadedCount*numPerLoading;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text=[NSString stringWithFormat:@"第 %d 条记录",indexPath.row];
    
    return cell;
}
-(void)lazyLoadTask{
    loadedCount++;
     _loading=NO;
    // call the refresh bar, data loading is end
    [_refreshBar dataSourceDidLoad:self.tableView];
}
#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    [_refreshBar scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshBar scrollViewDidEndDragging:scrollView];
}
#pragma mark - RefreshBar delegate
// begin to load data
-(void)beginDataSourceLoading:(RefreshBar *)refreshBar{
    _loading=YES;
    [self performSelector:@selector(lazyLoadTask) withObject:nil afterDelay:2.7];
}
// confirm if data loading is uncomplete
-(BOOL)isDataSourceLoading{
    return [self hasMoreData] && _loading;
}
// determine if more data exists
-(BOOL)hasMoreData{
    return loadedCount<3;
}
// when data loading is complete,do something
-(void)endDataSourceLoading:(RefreshBar *)refreshBar{
    [self.tableView reloadData];
}
@end
