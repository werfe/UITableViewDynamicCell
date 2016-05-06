//
//  ViewController.m
//  UITableViewDynamicCell
//
//  Created by Vũ Trường Giang on 4/23/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+DynamicCell.h"

#define DEFAULT_ROWS 15

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UITableViewDynamicDelegate>{
    int numberOfRows;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Demo";
    // Do any additional setup after loading the view, typically from a nib.
    numberOfRows = DEFAULT_ROWS;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _tableView.refreshDelegate = self;
    _tableView.enabledLoadMore = YES;
    _tableView.enabledRefresh = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return numberOfRows;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 20, 20)];
    label.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [label sizeToFit];
    [cell addSubview:label];
    [label setCenter:CGPointMake(label.center.x, cell.contentView.frame.size.height/2)];
    return cell;
}



#pragma mark - methods required
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_tableView scrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableView checkToReload];
}
-(void)refreshData:(UITableView *)tableView completion:(RefreshCompletion)completion{
    
    //TODO:do some task needs many time to finish. After finish it, call completion block
    
    //Some codes below is an example
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        numberOfRows=DEFAULT_ROWS;
        [_tableView reloadData];
        completion();
    });
}
-(void)loadMoreData:(UITableView *)tableView completion:(RefreshCompletion)completion{
    
    //TODO:do some task needs many time to finish. After finish it, call completion block
    
    //Some codes below is an example
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        numberOfRows+=5;
        [_tableView reloadData];
        completion();
    });
}


@end
