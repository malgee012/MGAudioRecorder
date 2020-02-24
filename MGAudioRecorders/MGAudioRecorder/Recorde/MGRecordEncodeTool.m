//
//  MGRecordEncodeTool.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/6.
//  Copyright © 2019 maling. All rights reserved.
//

#import "MGRecordEncodeTool.h"
//#include "lame.h"

#import <lame/lame.h>
#include <stdio.h>

//编码队列
static dispatch_queue_t mp3EncodeQueue() {
    static dispatch_queue_t cmdRequestQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cmdRequestQueue = dispatch_queue_create("mp3EncodeQueue", DISPATCH_QUEUE_SERIAL);
    });
    return cmdRequestQueue;
}

@interface MGRecordEncodeTool ()

@property (nonatomic, assign) BOOL encodeEnd; //标志位，用于编录音编解码的录音结束标识符
@property (nonatomic, assign) BOOL isSleep;


@end
@implementation MGRecordEncodeTool

+ (instancetype)shareInstance
{
    static MGRecordEncodeTool *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)encodeMp3FileWithPcmFilePath:(NSString *)pcmFilePath
                 destinationFilePath:(NSString *)mp3FilePath
                          sampleRate:(int)sampleRate
                            channels:(int)channels
                             bitRate:(int)bitRate
{
    
    _encodeEnd = NO;
    
    dispatch_async(mp3EncodeQueue(), ^{
        
        FILE* pcmFile;
        FILE* mp3File = NULL ;
        lame_t lameClient = NULL;
        
        pcmFile = fopen([pcmFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
        if(pcmFile){
            mp3File = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb+");
        }
        else{
            //返回路径错误
            NSLog(@"输入pcm文件路径不正确");
        }
        
        if(mp3File){
            //初始化参数
            lameClient = lame_init();
            lame_set_in_samplerate(lameClient,sampleRate);
            lame_set_out_samplerate(lameClient, sampleRate);
            lame_set_num_channels(lameClient, channels);
            lame_set_brate(lameClient, bitRate);
            lame_set_VBR(lameClient, vbr_default);
            lame_init_params(lameClient);
        }
        else{
            //返回路径错误
            NSLog(@"目的存放路径不正确");
            
        }
        
        //开始编码  // 256 * 1024 = 2^8 * 1024   8192
        int bufferSize = pow(2, 3) * 1024;  //(2^3) * 1024;
        short int pcm_buffer[bufferSize * 2];
        unsigned char mp3_buffer[bufferSize];
        
        size_t readBufferSize = 0;
        bool isSkipPcmHeader = false;
        long curPos;
        //循环读取数据编码
        do {
            curPos = ftell(pcmFile);
            long startPos = ftell(pcmFile);
            fseek(pcmFile, 0, SEEK_END);
            long endPos = ftell(pcmFile);
            long totalDataLength = endPos - startPos;
            fseek(pcmFile, curPos, SEEK_SET);
            
            if (totalDataLength > bufferSize * 2 * sizeof(short int)) {
                if (!isSkipPcmHeader) {
                    //跳过 PCM header 否者会有一些噪音在MP3开始播放处
                    fseek(pcmFile, 4*1024,  SEEK_CUR);
                    isSkipPcmHeader = true;
                }
                
                // 将pcm源文件读进内存
                readBufferSize = fread(pcm_buffer, 2 * sizeof(short int) , bufferSize, pcmFile);
                
                // 单声道
                /* 全局上下文句柄 */
                /* 左声道的PCM数据 */
                /* 右声道的PCM数据 */
                /* 每个通道的样本数 */
                /* 指向已编码的MP3流的指针 */
                /* 此流中有效八位字节的数量， 文件流每次读取buffer数量 */
//                size_t wroteSize = lame_encode_buffer(lameClient, (short int *)leftBuffer, (short int *)rightBuffer, (int)(readBufferSize / 2), mp3_buffer, bufferSize);
                
                // 双通道
                /*
                 全局上下文句柄
                 左右的PCM数据通道，交错
                 每个通道的样本数， _not_中的样本数
                 指向已编码的MP3流的指针
                 有效字节数流
                 */
                size_t wroteSize = lame_encode_buffer_interleaved(lameClient, pcm_buffer, (int)readBufferSize, mp3_buffer, bufferSize);
                fwrite(mp3_buffer, 1, wroteSize, mp3File);  // 写入数据
            }
            sleep(0.05);
            
        } while (!self->_encodeEnd);
        
        //这里需要注意的是，一旦录音结束encodeEnd就会导致上面的函数结束，有可能出现解码慢，导致录音结束，仍然没有解码完所有数据的可能
        //循环读取剩余数据进行编码
        readBufferSize = (int)fread(pcm_buffer, 2 * sizeof(short int), bufferSize, pcmFile);
        size_t wroteSize = lame_encode_buffer_interleaved(lameClient, pcm_buffer, (int)readBufferSize, mp3_buffer, bufferSize);
        fwrite(mp3_buffer, 1, wroteSize, mp3File);  // 写入数据
        
        
        /*
         需要：
         lame_encode_flush将刷新内部PCM缓冲区，并填充0以确保最后一帧完成，然后刷新内部MP3缓冲区，因此可能会返回
         最后几个mp3帧。 “ mp3buf”的长度至少应为7200个字节
         保存所有可能的发射数据。
         还将id3v1标签（如果有）写入比特流
         返回码=输出到mp3buf的字节数。 可以为0
         
         
         
         全局上下文句柄
         指向已编码的MP3流的指针
         有效字节数流
         */
        int size = lame_encode_flush(lameClient, mp3_buffer, bufferSize);
        
        NSLog(@"read %d bytes and flush to mp3 file", size);
        
        
        //写入Mp3 VBR Tag，不是必须的步骤
        // 编码完成之后，写入Mp3的VBR tag,如果不写入的话，可能会导致某些播放器播放时获取时长出现问题，所以建议写入。
        lame_mp3_tags_fid(lameClient, mp3File);
        
        //编码完成后关闭文件流，释放资源
        fclose(pcmFile);
        fclose(mp3File);
        lame_close(lameClient);
        
    });
}


- (void)endRecord
{
    _encodeEnd = YES;
}


- (void)encodeMp3ToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback
{
    
        NSLog(@"convert begin!!");
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        weakself.encodeEnd = NO;
    
        @try {
            
            int read, write;
            
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb+");
            
            const int PCM_SIZE = 8192;  // 2^3 * 1024
            const int MP3_SIZE = 8192;  // 2^3 * 1024
            short int pcm_buffer[PCM_SIZE * 2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, sampleRate);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            long curpos;
            BOOL isSkipPCMHeader = NO;
            
            do {
                curpos = ftell(pcm);
                long startPos = ftell(pcm);
                fseek(pcm, 0, SEEK_END);
                long endPos = ftell(pcm);
                long length = endPos - startPos;
                fseek(pcm, curpos, SEEK_SET);
                
                if (length > PCM_SIZE * 2 * sizeof(short int)) {
                    
                    if (!isSkipPCMHeader) {
                        //Uump audio file header, If you do not skip file header
                        //you will heard some noise at the beginning!!!
                        fseek(pcm, 4 * 1024, SEEK_CUR);
                        isSkipPCMHeader = YES;
                        NSLog(@"skip pcm file header !!!!!!!!!!");
                    }
                    
                    read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    fwrite(mp3_buffer, write, 1, mp3);
                    NSLog(@"read %d bytes", write);
                    weakself.isSleep = NO;
                } else {
                    weakself.isSleep = YES;
                    NSLog(@"sleep");
                }
                
            } while (!weakself.encodeEnd || !weakself.isSleep);
            
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);

            NSLog(@"read %d bytes and flush to mp3 file", write);
            lame_mp3_tags_fid(lame, mp3);

            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"TTTTTTTTTTTTTTTTTTTT  %@", [exception description]);
            if (callback) {
                callback(NO);
            }
        }
        @finally {
            if (callback) {
                callback(YES);
            }
            NSLog(@"convert mp3 finish!!! %@", mp3FilePath);
        }
    });
}


// 这是录完再转码的方法, 如果录音时间比较长的话,会要等待几秒...
// Use this FUNC convent to mp3 after record

+ (void)encodeMp3ToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            int read, write;
            
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
            lame_set_in_samplerate(lame, sampleRate);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);

                } else {
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                }
                
                fwrite(mp3_buffer, write, 1, mp3);

            } while (read != 0);

            lame_mp3_tags_fid(lame, mp3);

            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
            if (callback) {
                callback(NO);
            }
        }
        @finally {
            NSLog(@"-----\n  MP3生成成功: %@   -----  \n", mp3FilePath);
            if (callback) {
                callback(YES);
            }
        }
    });
}


@end
