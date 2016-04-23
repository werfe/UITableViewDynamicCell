//
//  UITableView+DynamicCell.h
//  SwitchableMultipleEnvironmentsDemo
//
//  Created by Vũ Trường Giang on 4/21/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLTableHeaderLoading;

@protocol UITableViewDynamicDelegate;
typedef void(^RefreshCompletion)();

@interface UITableView (DynamicCell)

#pragma mark -
#pragma mark Propeties

@property (strong, nonatomic) CLTableHeaderLoading *headerView;


//@property (strong, nonatomic) STableFooterView *footerView;
@property (nonatomic, readwrite) BOOL isLoadingMore;

/*
 * set VLTableDelegate
 */
@property (nonatomic, assign) id <UITableViewDynamicDelegate>   refreshDelegate;

/*
 * if YES, when pull down, activityIndicator will show on header of table
 */
@property (nonatomic, readwrite) BOOL enabledRefresh;

/*
 * if YES, when pull up, activityIndicator will show on bottom of table
 */
@property (nonatomic, readwrite) BOOL enabledLoadMore;

/*
 * readonly, check table is reloading
 */
@property (nonatomic, readonly) BOOL  isLoading;



#pragma mark -
#pragma mark Public Method

/*
 * call to update content offset
 */
- (void)scrollViewDidScroll:(UIScrollView*)scrollView;
/*
 * check drag offset to determine reload
 */
- (void)checkToReload;
/*
 * Relocate pull-to-refresh view
 */
- (void)relocatePullToRefreshView;

@end

@protocol UITableViewDynamicDelegate <NSObject>

@optional
- (void)refreshData:(UITableView*)tableView completion:(RefreshCompletion)completion;

//Load more Data delegate method
-(void)willBeginLoadMoreData;
- (void)loadMoreData:(UITableView*)tableView completion:(RefreshCompletion)completion;

@end
