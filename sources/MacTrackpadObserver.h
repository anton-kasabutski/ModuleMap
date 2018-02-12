#ifndef MACTRACKPADOBSERVER_H
#define MACTRACKPADOBSERVER_H

#import <Cocoa/Cocoa.h>

@interface MacTrackpadObserver : NSView {
}
@property (nonatomic) void (^macBridge)();
@end


#endif // MACTRACKPADOBSERVER_H
