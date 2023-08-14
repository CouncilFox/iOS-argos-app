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

int indx=0;
int len = 0;
uint8_t checksum=0;
uint8_t command=0;
uint8_t payload_size=0;

AVSpeechSynthesizer *synthesizer;

@implementation WiFiCommunication

@synthesize connected=_connected;
@synthesize flash_char = flash_char;

-(id)init {
    
    self=[super init];
    
    if(self) {
        _connected=FALSE;
        synthesizer = [[AVSpeechSynthesizer alloc]init];
    }
    return self;
}

-(int) connect: (bool) connectToCameraTCP {
    NSString *HOST = plutoHOST;
    int PORT = plutoPORT;
    
    if(connectToCameraTCP) {
        HOST = cameraHOST;
        PORT = cameraPORT;
    }
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)HOST, PORT, &readStream, &writeStream);
    
    if(!CFWriteStreamOpen(writeStream))
        NSLog(@"Error, writeStream not open");
    
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanFalse);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanFalse);
    
    NSLog(@"Opening streams.");
    
    inputStream = (__bridge NSInputStream *)(readStream);
    outputStream = (__bridge NSOutputStream *)(writeStream);
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    usleep(150000);
    
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
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Raven, Disconnected"];
    [utterance setRate:0.5f];
    [synthesizer speakUtterance:utterance];
}


- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    
    switch(event) {
        case NSStreamEventHasSpaceAvailable: {
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            if(stream == inputStream) {
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
                                [MultiWi230 evaluateCommand:command and: payload_size];
                        }
                        
                    }
                    
                }
                
            }
            
            break;
        }
            
        case NSStreamEventOpenCompleted: {
            NSLog(@"### streams are opened");
            _connected=TRUE;
            
            if(stream == inputStream) {
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Raven, Connected"];
                [utterance setRate:0.5f];
                [synthesizer speakUtterance:utterance];
            }
            break;
        }
            
        case NSStreamEventErrorOccurred: {
            _connected = FALSE;
            NSLog(@"NSStreamEventErrorOccurred");
            break;
        }
            
        default: {
            NSLog(@"Stream is sending an Event: %lu", event);
            break;
        }
    }
    
}

-(void) write:(NSMutableData *)data {
    if(![outputStream hasSpaceAvailable]){
        NSLog(@"NO Space in outputstream!!!");
        return;
    }
    
    [outputStream write:[data bytes] maxLength:[data length]];
}

-(void) read {
    
    uint8_t buf[1];
    [inputStream read:buf maxLength:1];
    if(len > 0) {
        flash_char = buf[0];
    }
}

-(void) removeInputStreamDelegate {
    if(nil != inputStream)
        [inputStream setDelegate:nil];
}

-(void) setInputStreamDelegate {
    if(nil != inputStream)
        [inputStream setDelegate:self];
}

@end
