//
//  WiFi.m
//  PlutoController
//
//  Created by Drona Aviation on 01/09/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import "Communication.h"
#import "MultiWi230.h"
#import "UIView+Toast.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <arpa/inet.h>
#include <netinet/tcp.h>

CFReadStreamRef readStream;
CFWriteStreamRef writeStream;

NSInputStream *inputStream;
NSOutputStream *outputStream;


NSString *HOST=@"192.168.4.1";
int PORT=23;
int indx=0;
unsigned int len = 0;
uint8_t checksum=0;
uint8_t command=0;
uint8_t payload_size=0;

AVSpeechSynthesizer *synthesizer;


@implementation WiFiCommunication

@synthesize connected=_connected;
@synthesize isFlashMode =_isFlashMode;
@synthesize eat = _eat;
@synthesize temp = _temp;

-(id)init {
    
    self=[super init];
    
    if(self) {
        _connected=FALSE;
        _isFlashMode = FALSE;
    }
    return self;
}

-(void) setup {
    
    synthesizer = [[AVSpeechSynthesizer alloc]init];
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)HOST, PORT, &readStream, &writeStream);
    
    if(!CFWriteStreamOpen(writeStream)) {
        NSLog(@"Error, writeStream not open");
    }
    
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanFalse);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanFalse);
    
    NSLog(@"Status of outputStream: %lu", (unsigned long)[outputStream streamStatus]);
}

-(int) connect {
    
    [self setup];
    
    NSLog(@"Opening streams.");
    
    inputStream = (__bridge NSInputStream *)(readStream);
    outputStream = (__bridge NSOutputStream *)(writeStream);
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    NSLog(@"Status of outputStream: %lu", (unsigned long)[outputStream streamStatus]);
    
    return [outputStream streamStatus];
}

-(void) disconnect {
    
    NSLog(@"Closing streams");
    
    [inputStream close];
    [outputStream close];
    
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    
    inputStream = nil;
    outputStream = nil;
    
    NSLog(@"Status of outputStream: %lu", (unsigned long)[outputStream streamStatus]);
    
    _connected=FALSE;
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Pluto Disconnected"];
    [utterance setRate:0.5f];
    [synthesizer speakUtterance:utterance];
}



- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    
    switch(event) {
        case NSStreamEventHasSpaceAvailable: {
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            if(stream == inputStream && !_isFlashMode) {
                uint8_t buf[1024];
                len = 0;
                checksum=0;
                command=0;
                payload_size=0;
                len = [inputStream read:buf maxLength:1024];
                
                if(len > 0) {
                    NSMutableData* data=[[NSMutableData alloc] initWithLength:0];
                    
                    [data appendBytes: (const void *)buf length:len];
                    
                    if(buf[0]=='$'&&buf[1]=='M'&&buf[2]=='>') {
                        payload_size=(buf[3]&0xFF);
                        command=(buf[4]&0xFF);
                        checksum^=(payload_size&0xFF);
                        checksum^=(command&0xFF);
                        indx=0;
                        
                        for(int i=5;i<len-1;i++) {
                            int8_t k=(int8_t)(buf[i]&0xFF);
                            inputBuffer[indx++]=k;
                            checksum^=(buf[i]&0xFF);
                        }
                        
                        if(checksum==buf[len-1]) {
                            bufferIndex=0;
                            if(payload_size>0)
                                [MultiWi230 evaluateCommand:command];
                        }
                        
                    }
                    
                }
                
            }  else if(stream == inputStream){
                //len = [inputStream read:buf maxLength:8];
                uint8_t buf[1];
                [inputStream read:buf maxLength:1];
                _eat++;
                if(len > 0) {
                    _temp = buf[0];
                    NSLog(@"temp: %d", _temp);
                    //_eat++;
                }
            }
            
            break;
        }
            
        case NSStreamEventOpenCompleted: {
            NSLog(@"### streams are opened");
            _connected=TRUE;
            
            if(stream == outputStream) {
                CFDataRef socketData = CFWriteStreamCopyProperty(writeStream, kCFStreamPropertySocketNativeHandle);
                if (socketData == NULL) {
                    NSLog(@"Failed to get native socket!");
                }
                CFSocketNativeHandle *sock = (CFSocketNativeHandle *)CFDataGetBytePtr(socketData);
                int result = setsockopt(*sock, IPPROTO_TCP, TCP_NODELAY, &(int){ 1 }, sizeof(int));
                NSLog(@" result = %d", result);
                result = setsockopt(*sock, SOL_SOCKET, SO_KEEPALIVE, &(int){ 1 }, sizeof(float));
                NSLog(@" result = %d", result);
                CFRelease(socketData);
            }
            if(stream == inputStream) {
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Pluto Connected"];
                [utterance setRate:0.5f];
                [synthesizer speakUtterance:utterance];
                
                CFDataRef socketData = CFReadStreamCopyProperty(readStream, kCFStreamPropertySocketNativeHandle);
                if (socketData == NULL) {
                    NSLog(@"Failed to get native socket!");
                }
                CFSocketNativeHandle *sock = (CFSocketNativeHandle *)CFDataGetBytePtr(socketData);
                int result = setsockopt(*sock, IPPROTO_TCP, TCP_NODELAY, &(int){ 1 }, sizeof(int));
                NSLog(@" result = %d", result);
                result = setsockopt(*sock, SOL_SOCKET, SO_KEEPALIVE, &(int){ 1 }, sizeof(int));
                NSLog(@" result = %d", result);
                CFRelease(socketData);
            }
            break;
        }
            
        case NSStreamEventErrorOccurred: {
            _connected = FALSE;
            break;
        }
            
        default: {
            NSLog(@"Stream is sending an Event: %i", event);
            break;
        }
    }
    
}

-(void) write:(NSMutableData *)data {
    if(![outputStream hasSpaceAvailable]){
        NSLog(@"NO Space in outputstream!!!");
    }
    
    [outputStream write:[data bytes] maxLength:[data length]];
}

@end
