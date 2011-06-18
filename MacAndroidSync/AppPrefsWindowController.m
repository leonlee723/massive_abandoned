//
//  AppPrefsWindowController.m
//


#import "AppPrefsWindowController.h"


@implementation AppPrefsWindowController




- (void)setupToolbar
{
	[self addView:generalPreferenceView label:@"General"];
	[self addView:advancedPreferenceView label:@"Advanced"];
	
    // Optional configuration settings.
	[self setCrossFade:[[NSUserDefaults standardUserDefaults] boolForKey:@"fade"]];
	[self setShiftSlowsAnimation:[[NSUserDefaults standardUserDefaults] boolForKey:@"shiftSlowsAnimation"]];
}




@end
