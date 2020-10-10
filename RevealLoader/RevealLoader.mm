//
//  RevealLoader.mm
//  RevealLoader
//
//  Created by king on 2020/6/2.
//  Copyright (c) 2020 ___ORGANIZATIONNAME___. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import "CaptainHook/CaptainHook.h"
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <notify.h>  // not required; for examples only
#import <os/log.h>
#import <spawn.h>

//extern char **environ;
//static void run_cmd(char *cmd);
//static void reloadRevealLoaderSpringBoardSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);

CHConstructor  // code block that runs immediately upon load
{
	@autoreleasepool {
		//		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),  // 系统的notifycenter，固定
		//		                                NULL,
		//		                                reloadRevealLoaderSpringBoardSettings,                               // 回调函数
		//		                                CFSTR("com.0x1306a94.RevealLoader.SpringBoard-preferencesChanged"),  // 通知Key
		//		                                NULL,
		//		                                CFNotificationSuspensionBehaviorCoalesce);

		NSDictionary *lookinSettings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.0x1306a94.reveal.plist"];
		NSString *bundleID           = [[NSBundle mainBundle] bundleIdentifier];
		BOOL appEnabled              = [[lookinSettings objectForKey:[NSString stringWithFormat:@"RevealEnabled-%@", bundleID]] boolValue];

		//		NSString *bundleId  = @"com.0x1306a94.RevealLoader.SpringBoard";
		//		NSString *plistPath = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleId];
		//
		//		NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
		//		BOOL isOn              = [settings[@"RevealLoaderSpringBoard"] boolValue];

		if (appEnabled /*|| ([bundleID isEqualToString:@"com.apple.springboard"] && isOn)*/) {
			NSFileManager *fileManager = [NSFileManager defaultManager];

			NSString *libPath = @"/usr/lib/Reveal/RevealServer.framework/RevealServer";

			if ([fileManager fileExistsAtPath:libPath]) {
				void *lib = dlopen([libPath UTF8String], RTLD_NOW);
				if (lib) {
					os_log(OS_LOG_DEFAULT, "Message: %{public}s %{public}s", "[+] RevealServer loaded!", bundleID.UTF8String);
				} else {
					char *err = dlerror();
					os_log(OS_LOG_DEFAULT, "Message: [+] RevealServer load failed: %{public}s", err);
				}
			}
		}
	}
}

//static void reloadRevealLoaderSpringBoardSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
//
//	os_log(OS_LOG_DEFAULT, "Message: %{public}s", "com.0x1306a94.RevealLoader.SpringBoard-preferencesChanged notification received");
//	run_cmd("killall -9 SpringBoard");
//}
//
//static void run_cmd(char *cmd) {
//	pid_t pid;
//	char *argv[] = {
//	    "sh",
//	    "-c",
//	    cmd,
//	    NULL,
//	    NULL,
//	};
//	int status;
//
//	os_log(OS_LOG_DEFAULT, "Message: [Execute] sh -c %{public}s", cmd);
//
//	status = posix_spawn(&pid, "/bin/sh", NULL, NULL, argv, environ);
//	if (status == 0) {
//		if (waitpid(pid, &status, 0) == -1) {
//			perror("waitpid");
//		}
//	} else {
//		os_log(OS_LOG_DEFAULT, "Message: [Execute] sh -c %{public}s status %{public}d", cmd, status);
//	}
//};

