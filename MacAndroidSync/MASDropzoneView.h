//
//  MASDropzoneView.h
//  MacAndroidSync
//
//  Created by 来 诺 on 9/1/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MASDropzoneView : NSView {
    // id <CLDropzoneViewDelegate> _delegate;
}

// @property(nonatomic) id <CLDropzoneViewDelegate> delegate; // @synthesize delegate=_delegate;
- (void)mouseUp:(id)arg1;
- (void)mouseDown:(id)arg1;
- (BOOL)performDragOperation:(id)arg1;
- (void)draggingExited:(id)arg1;
- (unsigned long long)draggingEntered:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
@end
