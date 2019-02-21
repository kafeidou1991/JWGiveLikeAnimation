# JWGiveLikeAnimation
描述：iOS 抖音点赞动画 收藏动画



### 前言

最近项目中需要模仿抖音的点赞动画来应用到项目中，所以自己撸了一个动画，给同行们分享下，不喜勿喷。欢迎随时批评指正  QQ：38251725

![点赞动画](https://upload-images.jianshu.io/upload_images/910291-23f815022eded9c4.gif?imageMogr2/auto-orient/strip)

### 实现思路

- #### **点赞动画**

  将点赞动画分解为4个部分

  1. 6个倒三角形从中心向外扩散，先缩放在放大
  2. 6个三角全部展开之后由内向外消失
  3. 心形点赞图片 从小扩大在收缩动画
  4. 波纹慢慢扩大至心型图片圆周，再慢慢消失

  #### 实现原理：

  动画1、2：使用CAShapeLayer图层，UIBezierPath曲线绘制三角形。然后使用CAAnimationGroup来实现缩放和消失组合动画。

  ```objective-c
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
  ```

  动画3： 心形图片放大缩小，使用UIView的帧动画，来设置每帧的动画。分2部分，一部分是放大一部分是恢复

  ```objective-c
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
  ```

  动画4：波纹动画使用CAShapeLayer绘制一个圆圈，CAAnimationGroup组合使用 缩小、宽度变宽，再消失。

  ```objective-c
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
  ```

- **取消点赞动画**

   取消点赞动画分解,点赞图片由外向内慢慢消失。

  ```objective-c
  [self bringSubviewToFront:_giveLikeView];
          _giveLikeView.transform = CGAffineTransformMakeScale(1.1, 1.1);
          [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
              self.giveLikeView.transform = CGAffineTransformMakeScale(0.1, 0.1);
          } completion:^(BOOL finished) {
              self.giveLikeView.hidden = YES;
              self.giveLikeView.transform = CGAffineTransformMakeScale(1, 1);
              self.userInteractionEnabled = YES;
          }];
  ```





  ## 总结

  以上就是整个动画的分解原理。主要是使用的Shaperlayer图层 贝塞尔绘制图形，使用动画组还合成动画的实现。




