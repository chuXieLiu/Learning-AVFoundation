//
//  ViewController.m
//  RecorderAndPlayer
//
//  Created by c_xie on 16/3/22.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "ViewController.h"
#import "CXRecorderManager.h"
#import "CXMemo.h"
#import "CXMeterTable.h"

static NSString * const kCellID = @"cellId";

@interface ViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    CXRecorderManagerDelegate
>

@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic,strong) CXRecorderManager *recordManager;

@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) CADisplayLink *levelTimer;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *list;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
    }
    CXMemo *memo = self.list[indexPath.row];
    cell.textLabel.text = memo.title;
    cell.detailTextLabel.text = memo.formattedTime;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.recordManager playRecorderWithURL:[self.list[indexPath.row] url]];
}

#pragma mark - target event

- (IBAction)record:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        [self startMeterTimer];
        [self startTimer];
        [self.recordManager record];
    } else {
        [self stopMeterTimer];
        [self stopTimer];
        [self.recordManager pause];
    }
}


- (IBAction)save:(UIButton *)sender {
    
    [self stopMeterTimer];
    [self stopTimer];
    __weak typeof(self) weakSelf = self;
    [self.recordManager stopCompletion:^(BOOL success) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf showAlert];
        });
        
    }];
    
}

- (void)showAlert
{
    __weak typeof(self) weakSelf = self;
    self.recordButton.selected = NO;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"保存录音" message:@"请设置标题" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入标题";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *fileName = alertVC.textFields.firstObject.text;
        [weakSelf.recordManager saveRecorderWithName:@"world" completion:^(BOOL success, NSURL *fileURL) {
            if (success) {
                CXMemo *memo = [[CXMemo alloc] init];
                memo.title = fileName;
                memo.url = fileURL;
                memo.formattedTime = weakSelf.timestampLabel.text;
                [weakSelf.list addObject:memo];
                [weakSelf.tableView reloadData];
            }
        }];
        
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 时间计算

- (void)startTimer
{
    [self stopTimer];
    _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timeFire) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}



- (void)timeFire
{
    self.timestampLabel.text = self.recordManager.formattedTime;
}


#pragma mark - 平均分贝，峰值分贝计算

- (void)stopMeterTimer
{
    [_levelTimer invalidate];
    _levelTimer = nil;
}

- (void)startMeterTimer
{
    [self stopTimer];
    _levelTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
    _levelTimer.frameInterval = 5;
    [_levelTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateMeter
{
    [self.recordManager levelsBlock:^(float avgPower, float peakPower) {
        NSLog(@"分贝系数=%f",avgPower);
    }];
}



#pragma mark - CXRecorderManagerDelegate

- (void)RecorderBeginInterruption
{
    [self stopTimer];
    self.recordButton.selected = NO;
}

#pragma mark - lazy

- (CXRecorderManager *)recordManager
{
    if (_recordManager == nil) {
        _recordManager = [[CXRecorderManager alloc] init];
        _recordManager.delegate = self;
    }
    return _recordManager;
}



- (NSMutableArray *)list
{
    if (_list == nil) {
        _list = [NSMutableArray array];
    }
    return _list;
}





@end
