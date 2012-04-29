//
//  RefreshBar.m
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

#import "RefreshBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation RefreshBar
@synthesize updateDateText;
@synthesize refreshText,indicator,imageView,delegate;
-(id)init{
    self=[RefreshBar instance];
    return self;
}
+(RefreshBar*)instance{
    RefreshBar* bar=nil;
    NSArray* obj=[[NSBundle mainBundle]loadNibNamed:@"RefreshBar"
                                              owner:self options:nil];
    for(id each in obj){
        if([each isKindOfClass:[RefreshBar class]]){
            bar=(RefreshBar*)each;
            break;
        }
    }
    return bar;
}
-(void)dealloc{
    refreshText=nil;
    imageView=nil;
    indicator=nil;
    updateDateText=nil;
    [updateDateText release];
    [super dealloc];
}
// turn the arrow upside down
-(void)updownArrow{
    CATransform3D transform;
    if (CATransform3DIsIdentity(imageView.layer.transform)) {
        transform=CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
    }else{
        transform=CATransform3DIdentity;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2];
    self.imageView.layer.transform = transform;
    [CATransaction commit];
}
#pragma facilitated methods
// set location of the refresh bar to relevant y coordinate
-(void)setLocationY:(float)y{
    y=MAX(y, self.frame.size.height);// 保证refresh bar的位置始终在scroll View最下方
    self.frame=CGRectOffset(self.frame, 0, y-self.frame.origin.y);
}
// compute visibile height of the refresh bar 
-(float)barOffsetY:(UIScrollView*)scrollView{
    return scrollView.frame.size.height+scrollView.contentOffset.y-scrollView.contentSize.height;
}// determine if the scroll view was pull up to the specify height
-(BOOL)isPullUpEnd:(UIScrollView*)scrollView{
    float offset_y= [self barOffsetY:scrollView];
    return (offset_y>self.maxPullUpOffsetY);
}
#pragma mark -
-(enum kRefreshBarStatus)status{
    return _status;
}
-(void)setStatus:(enum kRefreshBarStatus)status{
    switch (status) {
		case kRefreshBarStatusPulling:
			
			refreshText.text =@"Release to refresh";//@"释放可见更多...";
            [self updownArrow];
			break;
		case kRefreshBarStatusNormal:
			
			if (_status == kRefreshBarStatusPulling) {
				[self updownArrow];
			}

			refreshText.text = @"Pull up to refresh";//@"上拉刷新...";
			[indicator stopAnimating];
            // hide the arrow image
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			imageView.hidden = NO;
			imageView.layer.transform = CATransform3DIdentity;
			[CATransaction commit];

            [self updateLastDate];	
			break;
		case kRefreshBarStatusLoading:			
			refreshText.text = @"Loading";//@"正在刷新数据";
			[indicator startAnimating];
			break;
        case kRefreshBarStatusNoData:
            refreshText.text=@"No more data";//@"没有更多数据了";
            [indicator stopAnimating];
            break;
		default:
			break;
	}
    _status=status;
}
// To trigger a refreshing when pull up refresh bar to exceed the vertical dimension
-(float)maxPullUpOffsetY{
    return 90;
}
-(void)endDataSourceLoading:(RefreshBar*)refreshBar{
    if(delegate){
        [delegate endDataSourceLoading:refreshBar];
    }

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.isDragging){
        if (delegate && ![delegate hasMoreData]) {
            [self setStatus:kRefreshBarStatusNoData];

        }else{
            BOOL b;
            if (delegate) {
                b=[delegate isDataSourceLoading];
            }
            if (![self isPullUpEnd:scrollView] && !b) {
                [self setStatus:kRefreshBarStatusNormal];
            } else if (_status == kRefreshBarStatusNormal && [self isPullUpEnd:scrollView] && !b) {
                [self setStatus:kRefreshBarStatusPulling];
            }
        }
        [self setLocationY:scrollView.contentSize.height];
		// to void the refresh bar continue to be kRefreshBarStatusPulling status 
		if (scrollView.contentInset.bottom != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView{
     if (delegate && ![delegate isDataSourceLoading]
         && [self isPullUpEnd:scrollView]) {// 
         if ([delegate hasMoreData]) {
             [delegate beginDataSourceLoading:self];
             
             [self setStatus:kRefreshBarStatusLoading];
             [UIView beginAnimations:nil context:NULL];
             [UIView setAnimationDuration:0.2];
             
             scrollView.contentInset = UIEdgeInsetsMake(0, 0, 
                                                        [self barOffsetY:scrollView], 0.0f);
             [UIView commitAnimations];

         }else{
             [self setStatus:kRefreshBarStatusNoData];
         }
     }
}
- (void)dataSourceDidLoad:(UIScrollView *)scrollView {	

	// restore the decelerating effect
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.7];
    scrollView.contentInset=UIEdgeInsetsZero;
	[UIView commitAnimations];
	[self setStatus:kRefreshBarStatusNormal];
    // perform after delay 0.7 second so that decelerating animation will be done
    [self performSelector:@selector(endDataSourceLoading:) withObject:self afterDelay:0.7];

}
- (void)updateLastDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"AM"];
    [formatter setPMSymbol:@"PM"];
    [formatter setDateFormat:@"yyyy/MM/dd hh:mm:a"];
    updateDateText.text = [NSString stringWithFormat:@"Last updated:%@", [formatter stringFromDate:[NSDate date]]];
    [formatter release];
}

@end
