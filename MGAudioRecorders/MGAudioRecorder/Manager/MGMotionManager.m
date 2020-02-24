//
//  MGMotionManager.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/7.
//  Copyright © 2019 maling. All rights reserved.
//

#import "MGMotionManager.h"
#import <CoreMotion/CoreMotion.h>
#import "MGMotionTimer.h"

/**
 加速计 & 陀螺仪 的数据获取方式有两种：push和pull

 push：
 提供一个线程管理器NSOperationQueue和一个回调Block，CoreMotion自动在每一个采样数据到来的时候回调这个Block，进行处理。在这种情况下，Block中的操作会在你自己的主线程内执行。
 pull：
 你必须主动去向CMMotionManager要数据，这个数据就是最近一次的采样数据。你不去要，CMMotionManager就不会给你。
 
 */

@interface MGMotionManager ()<MGMotionTimerDelegate>

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) NSInteger swayCount;  // 晃动次数

@end

@implementation MGMotionManager


- (NSInteger)getTotalSwayCount
{
    return self.swayCount;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        // 每6分钟检查一次
        [MGMotionTimer sharedMotionTimeManager].delegate = self;
    }
    return self;
}

- (void)motionTimeDoCheckoutSwayType:(MGMotionTimeType)timeType atIndex:(NSInteger)index
{
    if (timeType == MGMotionTimeTypeDB) {
        
        [self.dbManager motionTimeDoCheckoutDBAtIndex:index];
        
    } else {
        
        NSLog(@"抖动------  第 %ld 次检查    共震动了 %ld 次", index, self.swayCount);
        
        if (self.swayCount > 50) {
            [self.dbManager motionDoUsingPhone:YES minuteIndex:index];
            
        } else {
            
            [self.dbManager motionDoUsingPhone:NO minuteIndex:index];
        }
        
        self.swayCount = 0;
    }
}


#pragma mark - 加速计 accelerometer
// push
- (void)accelerometerPush
{
    // 1.初始化运动管理对象
    self.motionManager = [[CMMotionManager alloc] init];
    // 2.判断加速计是否可用 是否开启
    if (![self.motionManager isAccelerometerAvailable] || [self.motionManager isAccelerometerActive]) {
        NSLog(@"加速计不可用");
        return;
    }
    
    // 3.设置加速计更新频率，以秒为单位
    self.motionManager.accelerometerUpdateInterval = 0.1;
   __block CGFloat lastAccelerValue = 0;
    
    __weak typeof(self)weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        //获取加速度
        CMAcceleration acceleration = accelerometerData.acceleration;
        CGFloat test = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2));
        
        if (lastAccelerValue > 0) {
            CGFloat pregress = (MAX(lastAccelerValue, test) - MIN(lastAccelerValue, test)) / MIN(lastAccelerValue, test);
            if (pregress > 0.01) {
                weakSelf.swayCount += 1;
                NSLog(@"抖动.................................................  %f   %ld 次", pregress, weakSelf.swayCount);
            }
        }
        lastAccelerValue = test;
    }];
}


// pull
- (void)accelerometerPull
{
    // 1.初始化运动管理对象
    self.motionManager = [[CMMotionManager alloc] init];
    // 2.判断加速计是否可用
    if (![self.motionManager isAccelerometerAvailable]) {
        NSLog(@"加速计不可用");
        return;
    }
    // 3.开始更新
    [self.motionManager startAccelerometerUpdates];
}

//在需要的时候获取值
- (void)getAccelerometerData
{
    CMAcceleration acceleration = self.motionManager.accelerometerData.acceleration;
    NSLog(@"加速度 == x:%f, y:%f, z:%f", acceleration.x, acceleration.y, acceleration.z);
}

// 停止获取加速计数据
- (void)stopGetAccelerometerData
{
    if ([self.motionManager isAccelerometerActive]) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

- (void)startRecord
{
    [self accelerometerPush];
    [[MGMotionTimer sharedMotionTimeManager] checkoutFixedSwayTime];
}

- (void)stopRecord
{
    [self stopGetAccelerometerData];
    
    [[MGMotionTimer sharedMotionTimeManager] timerInvalidate];
}


#pragma mark - 陀螺仪 Gyro

// push
- (void)gyroPush
{
    // 1.初始化运动管理对象
    self.motionManager = [[CMMotionManager alloc] init];
    // 2.判断陀螺仪是否可用 是否开启
    if (![self.motionManager isGyroAvailable] || [self.motionManager isGyroActive]) {
        NSLog(@"陀螺仪不可用");
        return;
    }
    // 3.设置陀螺仪更新频率，以秒为单位
    self.motionManager.gyroUpdateInterval = 0.1;
    // 4.开始实时获取
    [self.motionManager startGyroUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        //获取陀螺仪数据
        CMRotationRate rotationRate = gyroData.rotationRate;
        NSLog(@"加速度 == x:%f, y:%f, z:%f", rotationRate.x, rotationRate.y, rotationRate.z);
    }];
}

// pull
- (void)gyroPull
{
    // 1.初始化运动管理对象
    self.motionManager = [[CMMotionManager alloc] init];
    // 2.判断陀螺仪是否可用
    if (![self.motionManager isGyroAvailable]) {
        NSLog(@"陀螺仪不可用");
        return;
    }
    // 3.开始更新
    [self.motionManager startGyroUpdates];
}

//在需要的时候获取值
- (void)getGyroData
{
    CMRotationRate rotationRate = self.motionManager.gyroData.rotationRate;
    NSLog(@"加速度 == x:%f, y:%f, z:%f", rotationRate.x, rotationRate.y, rotationRate.z);
}

// 停止陀螺仪数据
- (void)stopGetGyroData
{
    [self.motionManager stopGyroUpdates];
}



// 停止获取设备motion数据
- (void)stopDeviceMotionData
{
    [self.motionManager stopDeviceMotionUpdates];
}


#pragma mark - deviceMotion 设备运动
// deviceMotion
- (void)startDeviceMotionData
{
    self.motionManager = [[CMMotionManager alloc] init];
    
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    
    
//    CMDeviceMotion *deviceMotion = [[CMDeviceMotion alloc] init];

//    CMAttitude *attitude = deviceMotion.attitude;
    

//    if (![self.motionManager isDeviceMotionActive] || ![self.motionManager isDeviceMotionAvailable]) {
//
//        NSLog(@"传感器设备不可用");
//        return;
//    }
    

    
    if ([self.motionManager isDeviceMotionAvailable] && ![self.motionManager isDeviceMotionActive]) {
        NSLog(@"可以使用");
        
            // 获取设备传感器信息
            self.motionManager.deviceMotionUpdateInterval = 0.5;
            [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                
                CGFloat magnitude = [self magnitudeFromAttitude:deviceMotion.attitude];
                
        //        NSLog(@"magnitude:: %f", magnitude);
            }];
    }
}

// 通过勾股定理获得向量的大小(欧拉角度)  (0.8 - 1)
- (CGFloat)magnitudeFromAttitude:(CMAttitude *)attitude
{
    NSLog(@"attitude.roll: %f  attitude.yaw: %f    attitude.pitch: %f", attitude.roll, attitude.yaw, attitude.pitch);
    
    return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2));
}

#pragma mark - 磁力计 magnetometer
// 磁力计
//Pull方式，获取磁力计数据
- (void)startMagnetometerUpdatePull {
    if ([self.motionManager isMagnetometerAvailable] && ![self.motionManager isMagnetometerActive]) {
        [self.motionManager startMagnetometerUpdates];
    }
    NSLog(@"\n磁力计：\nX: %f\nY: %f\nZ: %f", self.motionManager.magnetometerData.magneticField.x, self.motionManager.magnetometerData.magneticField.y, self.motionManager.magnetometerData.magneticField.z);
}

//Push方式，获取磁力计数据
- (void)startMagnetometerUpdatePush {
    if ([_motionManager isMagnetometerAvailable] && ![_motionManager isMagnetometerActive]) {
        _motionManager.magnetometerUpdateInterval = 1.0;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [_motionManager startMagnetometerUpdatesToQueue:queue withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
            if (error) {
                [self stopMagnetometerUpdate];
                NSLog(@"There is something error for magnetometer update");
            }else {
                NSLog(@"\n磁力计：\nX: %f\nY: %f\nZ: %f", magnetometerData.magneticField.x, magnetometerData.magneticField.y, magnetometerData.magneticField.z);
            }
        }];
    }
}

//停止获取磁力计数据
- (void)stopMagnetometerUpdate {
    if ([_motionManager isMagnetometerActive]) {
        [_motionManager stopMagnetometerUpdates];
    }
}


@end








/**

 
 CoreMotionManager为4类数据（传感器，加速器，陀螺仪，磁力仪）
 
 
 
 
 
 CoreMotion主要负责三种数据：
 加速度值CMAccelerometerData

 陀螺仪值CMGyroData

 设备motion值CMDeviceMotion



 实际上，这个设备motion值就是通过加速度和旋转速度进行变换算出来的
 
 CMDeviceMotion属性介绍：

 attitude：通俗来讲，就是告诉你手机在当前空间的位置和姿势
 gravity：重力信息，其本质是重力加速度矢量在当前设备的参考坐标系中的表达
 userAcceleration：加速度信息
 rotationRate：即时的旋转速率，是陀螺仪的输出
 
 
 
 CMAccelerometerData 和 CMDeviceMotion 的区别
 
 CMAccelerometerData类的实例表示加速度计事件.它是在一个时刻沿三个空间轴的加速度的量度.
 CMDeviceMotion的一个实例封装了设备的姿态,旋转速率和加速度的测量值.

 区别在于CMDeviceMotion包含陀螺仪,加速度计和罗盘数据,其中CMAccelerometerData仅包含原始加速度计数据.
 
 
 
 CMAttitude: 含有三个能代表设备朝向的值：欧拉角度，四元组，还有一个旋转矩阵。
 
 欧拉角度
 三个维度的表达中，欧拉角度是最容易懂得，因为他们简单描述了我们对每个坐标轴转动。
 pitch是X周方向的转动，增加的时候表示设备正朝你倾斜，减少的时候表示疏远；
 roll是Y轴的转向，值减少的时候表示正往左边转，增加的时候往右；
 yaw是Z轴转向，减少是时候是顺时针，增加的时候是逆时针。
 
 四元数
 空间位置的四元数（与欧拉角类似，但解决了万向结死锁问题）

 double w = motionManager.deviceMotion.attitude.quaternion.w;
 double wx = motionManager.deviceMotion.attitude.quaternion.x;
 double wy = motionManager.deviceMotion.attitude.quaternion.y;
 double wz = motionManager.deviceMotion.attitude.quaternion.z;

 
 
 */
