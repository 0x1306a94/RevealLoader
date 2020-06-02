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

CHConstructor  // code block that runs immediately upon load
{
	@autoreleasepool {
		NSDictionary *lookinSettings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.0x1306a94.reveal.plist"];
		NSString *bundleID           = [[NSBundle mainBundle] bundleIdentifier];
		BOOL appEnabled              = [[lookinSettings objectForKey:[NSString stringWithFormat:@"RevealEnabled-%@", bundleID]] boolValue];
		if (appEnabled) {
			NSFileManager *fileManager = [NSFileManager defaultManager];

			NSString *libPath = @"/usr/lib/Reveal/RevealServer.framework/RevealServer";

			if ([fileManager fileExistsAtPath:libPath]) {
				void *lib = dlopen([libPath UTF8String], RTLD_NOW);
				if (lib) {
					NSLog(@"[+] RevealServer loaded!");
				} else {
					char *err = dlerror();
					NSLog(@"[+] RevealServer load failed:%s", err);
				}
			}
		}
	}
}

