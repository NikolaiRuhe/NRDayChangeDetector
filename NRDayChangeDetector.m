#import "NRDayChangeDetector.h"

#import <TargetConditionals.h>
#if ! (defined (TARGET_OS_IPHONE) && TARGET_OS_IPHONE)
#import <AppKit/AppKit.h>
#endif


NSString *NRCurrentCalendarDayDidChange = @"NRCurrentCalendarDayDidChange";

@implementation NRDayChangeDetector
{
	NSDateComponents *_currentDay;
	NSTimer *_midnightTimer;
}

+ (void)startDetectingDayChanges
{
	static NRDayChangeDetector *detector;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		detector = [[self alloc] init];
		[detector startDetectingDayChanges];
	});
}

- (void)startDetectingDayChanges
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notificationReceived:)
												 name:NSSystemTimeZoneDidChangeNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notificationReceived:)
												 name:NSSystemClockDidChangeNotification
											   object:nil];

#if ! (defined (TARGET_OS_IPHONE) && TARGET_OS_IPHONE)
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(notificationReceived:)
															   name:NSWorkspaceDidWakeNotification
															 object:nil];
#endif

	[self checkDayChange:nil];
}

- (void)notificationReceived:(NSNotification *)notification
{
	[self checkDayChange:nil];
}

- (void)checkDayChange:(NSTimer *)timer
{
	NSDate *now = [NSDate date];

	// Calculate the current day (represented as year, month, day).
	NSCalendarUnit units = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	NSDateComponents *currentDay = [[NSCalendar currentCalendar] components:units fromDate:now];

	// Compare the last known day to the newly calculated day.
	if (! [_currentDay isEqual:currentDay]) {

		if (_currentDay == nil) {

			// There is no last known day (first call only).
			_currentDay = [currentDay copy];
		} else {

			// Last known day differs: send notification.
			[[NSNotificationCenter defaultCenter] postNotificationName:NRCurrentCalendarDayDidChange
																object:self];
		}
	}

	// Stop previous timer, if set.
	if (_midnightTimer.valid)
		[_midnightTimer invalidate];

	// Calculate time till midnight and set a timer.
	currentDay.day += 1;
	NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:currentDay];

	NSTimeInterval timeTillMidnight = [midnight timeIntervalSinceDate:now];

	// Start new timer to fire at midnight
	_midnightTimer = [NSTimer scheduledTimerWithTimeInterval:timeTillMidnight + 0.1
													  target:self
													selector:@selector(checkDayChange:)
													userInfo:nil
													 repeats:NO];
}

@end
