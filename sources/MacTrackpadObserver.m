#import "MacTrackpadObserver.h"

@implementation MacTrackpadObserver

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self)
        [self setAcceptsTouchEvents:YES];
    return self;
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 0)
        _macBridge();
}

- (void)setBridge:(void (^)())bridge {
    _macBridge = bridge;
}
@end
