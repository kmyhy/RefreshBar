Refresh bar－a pullup-refreshing table view component for iOS
=============================================================
Features--------* prompt when pull up 

![screenshot](https://github.com/kmyhy/RefreshBar/raw/master/images/refresh_bar_01.png)* distinguish “refresh” guesture when continue to pull up 

![screenshot](https://github.com/kmyhy/RefreshBar/raw/master/images/refresh_bar_02.png)* release finger to refresh and decelerating effect will be forbid when refreshing  

![screenshot](https://github.com/kmyhy/RefreshBar/raw/master/images/refresh_bar_03.png)* point out the update date and prompt when no more data 

![screenshot](https://github.com/kmyhy/RefreshBar/raw/master/images/refresh_bar_04.png)How to use----------Copy all of files (that are located “ RefreshBar ” folder)to your project. These files include:* RefreshBar.xib* RefreshBar.m* RefreshBar.h* grayArrow.png* whiteArrow.png
Initiate and set up an instance-------------------------------    [_refreshBar setFrame:CGRectMake(0.0f,         0.0f + self.tableView.frame.size.height,         self.view.frame.size.width,         _refreshBar.frame.size.height)];    [self.tableView addSubview:_refreshBar];    _refreshBar.delegate=self;Implement protocols
-------------------you need to implement two protocols in the class which will use the RefreshBar:* RefreshBarDelegate* UIScrollViewDelegate

UIScrollViewDelegate protocol be implement simply just to like this：    - (void)scrollViewDidScroll:(UIScrollView *)scrollView{	        [_refreshBar scrollViewDidScroll:scrollView];    }    - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{        [_refreshBar scrollViewDidEndDragging:scrollView];    }RefreshBarDelegate includes four required methods：* -(void)beginDataSourceLoading:(RefreshBar*)refreshBar;* -(BOOL)hasMoreData;* -(BOOL)isDataSourceLoading;* -(void)endDataSourceLoading:(RefreshBar*)refreshBar;

You should load new tableview cell data in beginDataSourceLoading: method.If the process is time-consuming，you should set a flag to point out whether the process is over. For Example：
    -(void)beginDataSourceLoading:(RefreshBar *)refreshBar{        _loading=YES;        loadedCount++;        _loading=NO;        // call the refresh bar, data loading is end        [_refreshBar dataSourceDidLoad:self.tableView];    }The hasMoreData method will be used for that determine whether more cell data exits so that we can load them. 
    -(BOOL)hasMoreData{        return loadedCount<3;    }The isDataSourceLoading method will be used for determine whether the data loading is over.
    -(BOOL)isDataSourceLoading{        return [self hasMoreData] && _loading;    }The endDataSouceLoading method will be invoked when data loading is over. You should do something in this method such as refresh tableview’s cell.
    -(void)endDataSourceLoading:(RefreshBar *)refreshBar{        [self.tableView reloadData];    }
Demo / Example App------------------There is an example iPhone application within the project  called ProgressiveRefreshTableApp which demonstrates how to use the RefreshBar.

Contact-------Email:[kmyhy@126.com](mailto://kmyhy@126.com/ "Email")	Blog:[http://blog.csdn.net/kmyhy](http://blog.csdn.net/kmyhy "Blog") 