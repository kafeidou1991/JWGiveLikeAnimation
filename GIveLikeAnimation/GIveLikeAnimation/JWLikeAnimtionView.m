//
//  JWLikeAnimtionView.m
//  GIveLikeAnimation
//
//  Created by 张竟巍 on 2019/2/20.
//  Copyright © 2019 张竟巍. All rights reserved.
//

#import "JWLikeAnimtionView.h"

typedef NS_ENUM(NSInteger, JWLikeType) {
    JWGiveLikeType,  // 点赞
    JWCancelLikeType // 取消赞
};

@interface JWLikeAnimtionView ()
/**
 点赞
 */
@property (nonatomic, strong) UIImageView * giveLikeView;

/**
 取消点赞
 */
@property (nonatomic, strong) UIImageView * cancelLikeView;

/**
 三角形半径，默认30
 */
@property (nonatomic, assign) CGFloat length;

@end


@implementation JWLikeAnimtionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup {
    self.animationDurtion = 0.5;
    self.shapeFillColor = [UIColor redColor];
    self.length = 30;
    //点赞
    [self addSubview:self.giveLikeView];
    //取消点赞
    [self addSubview:self.cancelLikeView];
}
#pragma mark - 点赞处理
- (void)likeAction:(UITapGestureRecognizer *)tapGestureRecognizer {
    self.userInteractionEnabled = NO;
    if (tapGestureRecognizer.view.tag == JWGiveLikeType) { //取消赞
        [self cancelLikeAction];
    }else { //点赞
        [self giveLikeAction];
    }
    if (_likeBlock) {
        _likeBlock(tapGestureRecognizer.view.tag == JWCancelLikeType);
    }
}
#pragma mark - 点赞
- (void)giveLikeAction {
    /* 点赞动画分解
     * 1. 6个倒三角形从中心向外扩散
     * 2. 三角全部展开之后由内向外消失
     * 3. 心形点赞图片 从小扩大在收缩动画
     * 4. 波纹慢慢扩大至心型图片圆周，再慢慢消失
     */
    //创建三角形
    [self createTrigonsAnimtion];
    //圆圈扩大消失
    [self createCircleAnimation];
    //改变状态
    [self animtionChangeLikeType:JWGiveLikeType];
}
- (void)createCircleAnimation {
    //创建背景圆环
    CAShapeLayer *circleLayer = [[CAShapeLayer alloc]init];
    circleLayer.frame = self.bounds;
    //清空填充色
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    //设置画笔颜色 即圆环背景色
    circleLayer.strokeColor =  self.shapeFillColor.CGColor;
    circleLayer.lineWidth = 1;
    //设置画笔路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:_length startAngle:- M_PI_2 endAngle:-M_PI_2 + M_PI * 2 clockwise:YES];
    //path 决定layer将被渲染成何种形状
    circleLayer.path = path.CGPath;
    [self.layer addSublayer:circleLayer];
    
    //使用动画组来解决圆圈从小到大 -->消失
    CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    NSTimeInterval groupDurtion = self.animationDurtion * 0.8;
    groupAnimation.duration = groupDurtion;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.removedOnCompletion = NO;

    CABasicAnimation * scaleAnimtion = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //放大时间占80%
    scaleAnimtion.duration = groupDurtion * 0.8;
    scaleAnimtion.fromValue = @(0);
    scaleAnimtion.toValue = @(1);


    CABasicAnimation * widthStartAnimtion = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    widthStartAnimtion.beginTime = 0;
    widthStartAnimtion.duration = groupDurtion * 0.8;
    widthStartAnimtion.fromValue = @(1);
    widthStartAnimtion.toValue = @(3);

    CABasicAnimation * widthEndAnimtion = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    widthEndAnimtion.beginTime =  groupDurtion * 0.8;
    widthEndAnimtion.duration = groupDurtion * 0.2;
    widthEndAnimtion.fromValue = @(3);
    widthEndAnimtion.toValue = @(0);

    groupAnimation.animations = @[scaleAnimtion,widthStartAnimtion,widthEndAnimtion];
    [circleLayer addAnimation:groupAnimation forKey:@"circleLayerAnimtion"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(groupDurtion * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [circleLayer removeAnimationForKey:@"circleLayerAnimtion"];
        [circleLayer removeFromSuperlayer];
    });
    
}
#pragma mark - 取消
- (void)cancelLikeAction {
    /* 取消点赞动画分解
     * 点赞图片由外向内慢慢消失
     */
    [self animtionChangeLikeType:JWCancelLikeType];
}
#pragma mark - 6个环形三角形动画
- (void)createTrigonsAnimtion {
    //三角形大小
    for (int i = 0; i < 6; i++) {
        //绘制三角形的图层
        CAShapeLayer * shapeLayer = [[CAShapeLayer alloc]init];
        shapeLayer.position = _giveLikeView.center;
        shapeLayer.fillColor = self.shapeFillColor.CGColor;
        //三角形
        UIBezierPath * startPath = [UIBezierPath bezierPath];
        [startPath moveToPoint:CGPointMake(-2, _length)];
        [startPath addLineToPoint:CGPointMake(2, _length)];
        [startPath addLineToPoint:CGPointMake(0, 0)];
        shapeLayer.path = startPath.CGPath;
        //旋转图层，形成圆形
        //因为一共是6个，均等应该是反转60度 所以是M_PI/3 ,围绕Z轴旋转
        shapeLayer.transform = CATransform3DMakeRotation(M_PI / 3 * i, 0, 0, 1);
        [self.layer addSublayer:shapeLayer];
        
        //使用动画组来解决三角形 出现跟消失】
        CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
        groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        groupAnimation.duration = self.animationDurtion;
        groupAnimation.fillMode = kCAFillModeForwards;
        groupAnimation.removedOnCompletion = NO;
        
        CABasicAnimation * scaleAnimtion = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        //缩放时间占20%
        scaleAnimtion.duration = self.animationDurtion * 0.2;
        scaleAnimtion.fromValue = @(0);
        scaleAnimtion.toValue = @(1);
        
        //绘制三角形结束  一条直线
        UIBezierPath * endPath = [UIBezierPath bezierPath];
        [endPath moveToPoint:CGPointMake(-2, _length)];
        [endPath addLineToPoint:CGPointMake(2, _length)];
        [endPath addLineToPoint:CGPointMake(0, _length)];
        
        CABasicAnimation * pathAnimtion = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimtion.beginTime = self.animationDurtion * 0.2;
        pathAnimtion.duration = self.animationDurtion * 0.8;
        pathAnimtion.fromValue = (__bridge id)startPath.CGPath;
        pathAnimtion.toValue = (__bridge id)endPath.CGPath;
        
        groupAnimation.animations = @[scaleAnimtion,pathAnimtion];
        [shapeLayer addAnimation:groupAnimation forKey:nil];
    }
}
#pragma mark - 点赞前 点赞后 心的动画
- (void)animtionChangeLikeType:(JWLikeType)type {
    if (type == JWGiveLikeType) {
        //三角形动画之后 进行缩放 抖动效果 置为点赞效果
        _cancelLikeView.hidden = YES;
        _giveLikeView.hidden = NO;
        [UIView animateKeyframesWithDuration:self.animationDurtion delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
             /*参数1:关键帧开始时间
              参数2:关键帧占用时间比例
              参数3:到达该关键帧时的属性值 */
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 * self.animationDurtion animations:^{
                self.giveLikeView.transform =  CGAffineTransformMakeScale(1.5, 1.5);;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 * self.animationDurtion relativeDuration:0.5 * self.animationDurtion animations:^{
                self.giveLikeView.transform = CGAffineTransformIdentity;
            }];
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    }else {
        //取消点赞
        _cancelLikeView.hidden = NO;
        [self bringSubviewToFront:_giveLikeView];
        _giveLikeView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.giveLikeView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished) {
            self.giveLikeView.hidden = YES;
            self.giveLikeView.transform = CGAffineTransformMakeScale(1, 1);
            self.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark - UIComponent
- (UIImageView *)giveLikeView {
    if (!_giveLikeView) {
        UIImageView * giveLikeView = [[UIImageView alloc]initWithFrame:self.bounds];
        giveLikeView.image = [UIImage imageNamed:@"give_like"];
        giveLikeView.userInteractionEnabled = YES;
        UITapGestureRecognizer * giveLikeGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(likeAction:)];
        [giveLikeView addGestureRecognizer:giveLikeGesture];
        giveLikeView.tag = JWGiveLikeType;
        //默认未点赞状态
        giveLikeView.hidden = YES;
        _giveLikeView = giveLikeView;
    }
    return _giveLikeView;
}

- (UIImageView *)cancelLikeView {
    if (!_cancelLikeView) {
        UIImageView * cancelLikeView = [[UIImageView alloc]initWithFrame:self.bounds];
        cancelLikeView.image = [UIImage imageNamed:@"cancel_like"];
        cancelLikeView.userInteractionEnabled = YES;
        UITapGestureRecognizer * cancelLikeGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(likeAction:)];
        [cancelLikeView addGestureRecognizer:cancelLikeGesture];
        cancelLikeView.tag = JWCancelLikeType;
        _cancelLikeView = cancelLikeView;
    }
    return _cancelLikeView;
}



@end
