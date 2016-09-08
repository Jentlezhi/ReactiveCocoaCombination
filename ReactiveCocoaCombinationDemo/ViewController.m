//
//  ViewController.m
//  ReactiveCocoaCombinationDemo
//
//  Created by Jentle on 16/9/8.
//  Copyright © 2016年 Jentle. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.concat
    [self concat];
    //2.then
    [self then];
    //3.merge
    [self merge];
    //4.zipWith
    [self zipWith];
    //5.combineLatest
    [self combineLatest];

}
/**
 *  concat: 按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号。
 */
- (void)concat{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"数据A"];
        // 注意：第一个信号必须发送完成，第二个信号才会被激活。
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"数据B"];
        return nil;
    }];
    
    //创建组合信号
    RACSignal *concatSignal = [signalA concat:signalB];
    
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
/**
 *  then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号。
 */
- (void)then{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"数据A"];
        // 注意：第一个信号必须发送完成，第二个信号才会被激活。
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"数据B"];
        return nil;
    }];
    
    //创建组合信号
    // then: 忽略掉第一个信号的所有值
    RACSignal *thenSignal = [signalA then:^RACSignal *{
        return signalB;
    }];
    
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
        
    }];
    
}
/**
 *  merge:把多个信号合并为一个信号，任何一个信号有新值的时候就会调用。
 */
- (void)merge{
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    // 组合信号
    RACSignal *mergeSignal = [signalA merge:signalB];
    
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [signalA sendNext:@"数据A"];
    [signalB sendNext:@"数据B"];
}
/**
 *  zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
 */
- (void)zipWith{
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    // 当一个界面有多个请求的时候，要等所有的请求完成才能更新UI
    // 等所有的信号都发送内容的时候才会调用
    RACSignal *zipWithSignal = [signalA zipWith:signalB];
    
    [zipWithSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [signalA sendNext:@"dataA"];
    [signalB sendNext:@"dataB"];
}
/**
 *  combineLatest:将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
 */
- (void)combineLatest{
#if 1
    // 两个不同的信号聚合成一个信号
    RACSignal *combineSignal = [RACSignal combineLatest:@[_accountTF.rac_textSignal,_pwdTF.rac_textSignal] reduce:^id(NSString *account,NSString *pwd){
        return @(account.length && pwd.length);
    }];
    
    [combineSignal subscribeNext:^(NSNumber *boolNum) {
        _loginBtn.enabled = [boolNum boolValue];
    }];
#else
    // 使用宏更简洁
    RAC(_loginBtn,enabled) = [RACSignal combineLatest:@[_accountTF.rac_textSignal,_pwdTF.rac_textSignal] reduce:^id(NSString *account,NSString *pwd){
        return @(account.length && pwd.length);
    }];
#endif
    
}





@end
