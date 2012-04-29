//
//  RefreshBar.h
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
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
enum kRefreshBarStatus{
    kRefreshBarStatusPulling,       
    kRefreshBarStatusLoading,       
    kRefreshBarStatusNormal,
    kRefreshBarStatusNoData,
};
@class RefreshBar;
@protocol RefreshBarDelegate <NSObject>
@required
-(void)beginDataSourceLoading:(RefreshBar*)refreshBar;
-(BOOL)hasMoreData;
-(BOOL)isDataSourceLoading;
-(void)endDataSourceLoading:(RefreshBar*)refreshBar;
@end
@interface RefreshBar : UIView{
    enum kRefreshBarStatus _status;
}

@property(nonatomic,assign) id <RefreshBarDelegate> delegate;
@property (retain, nonatomic) IBOutlet UILabel *updateDateText;

@property(nonatomic,retain)IBOutlet UILabel* refreshText;
@property(nonatomic,retain)IBOutlet UIActivityIndicatorView* indicator; 
@property(nonatomic,retain)IBOutlet UIImageView* imageView;
@property(nonatomic)enum kRefreshBarStatus status;
@property(nonatomic,readonly,getter = maxPullUpOffsetY)float maxPullUpOffsetY;

+(RefreshBar*)instance;
-(void)updateLastDate;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)dataSourceDidLoad:(UIScrollView *)scrollView;

-(float)barOffsetY:(UIScrollView*)scrollView;

-(BOOL)isPullUpEnd:(UIScrollView*)scrollView;
-(void)setLocationY:(float)y;
-(void)updateLastDate;
@end
