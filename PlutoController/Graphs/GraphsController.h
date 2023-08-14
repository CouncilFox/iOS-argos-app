//
//  GraphsController.h
//  PlutoController
//
//  Created by Drona Aviation on 08/10/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiWi230.h"
#import "Config.h"


extern UIViewController * vc;
extern UIStoryboard *storyboard;
extern NSMutableArray * graphRequests;

//extern MultiWi230 *protocol;

@interface GraphsController : UIViewController  <UIAccelerometerDelegate>
{
//GraphView *graphView;
   
    NSTimer *timer;
}


@end
