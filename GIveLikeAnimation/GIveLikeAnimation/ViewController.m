//
//  ViewController.m
//  GIveLikeAnimation
//
//  Created by 张竟巍 on 2019/2/20.
//  Copyright © 2019 张竟巍. All rights reserved.
//

#import "ViewController.h"
#import "JWLikeAnimtionView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

@interface ViewController ()
@property (nonatomic, strong) JWLikeAnimtionView * likeView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.likeView];
    
    
}


- (JWLikeAnimtionView *)likeView {
    if (!_likeView) {
        _likeView = [[JWLikeAnimtionView alloc]initWithFrame:CGRectMake(0, 0, 40, 38)];
        _likeView.center = self.view.center;
        _likeView.animationDurtion = 0.4;
        _likeView.shapeFillColor = UIColorFromRGB(0xFC3962);
        _likeView.likeBlock = ^(BOOL isLike) {
            NSLog(@"%@",isLike ? @"点赞":@"取消赞");
        };
    }
    return _likeView;
}


@end
