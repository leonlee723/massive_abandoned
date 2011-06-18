//
//  AppPrefsWindowController.h
//


#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"


@interface AppPrefsWindowController : DBPrefsWindowController {
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *advancedPreferenceView;
}


@end
