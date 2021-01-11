#import <UIKit/UIKit.h>
#include "NSString.h"
#include "QQLingHook.h"

static void PostData (NSDictionary * dict) {
	// 没启用就停止
	if (!http_enable)
		return;
	// 字典转JSON文本
	NSError * error;
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
	NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

	// 异步
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
		// 创建请求对象
        NSMutableURLRequest * resuest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_url]];
		// 设置请求方式
        [resuest setHTTPMethod:@"post"];
		// 设置数据格式
		[resuest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		// 设置请求数据
        [resuest setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
		// 发送请求
		NSError * error;
        NSURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:resuest returningResponse:&response error:&error];
    });
}

%hook WtloginPlatformInfo

- (void)setECDHShareKey:(unsigned char *)arg2 andPubKey:(unsigned char *)arg3 andPubKeyLen:(int)arg4 wKeyVer:(short)arg5 {
	NSMutableDictionary *mDic1 = [[NSMutableDictionary alloc] init];
	
	NSString * pubkey = [NSString hexStringWithBuffer: arg3 ofLength: arg4];
	NSString * shakey = [NSString hexStringWithBuffer: arg2 ofLength: 0x10];
	NSString * ver = [[NSString alloc] initWithFormat:@"%d", arg5];

	[mDic1 setObject: @"ecdh" forKey:@"action"];
	[mDic1 setObject: pubkey forKey:@"pub_key"];
	[mDic1 setObject: shakey forKey:@"sha_key"];
	[mDic1 setObject: ver forKey:@"wKeyVer"];

	PostData(mDic1);
	%orig;
}
- (void)setECDHPrivateKey:(unsigned char *)arg2 andPrivKeyLen:(int)arg3 {
	NSMutableDictionary *mDic1 = [[NSMutableDictionary alloc] init];
	
	NSString * prikey = [NSString hexStringWithBuffer: arg2 ofLength: arg3];

	[mDic1 setObject: @"ecdh" forKey:@"action"];
	[mDic1 setObject: prikey forKey:@"pri_key"];

	PostData(mDic1);
	%orig;
}

%end


/**
 * 加载插件设置
 */
static void loadPrefs() {
    NSMutableDictionary * settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/cc.lingc.hook.qq.plist"];
    enabled = [settings objectForKey:@"enabled"] ? [[settings objectForKey:@"enabled"] boolValue] : NO;
	http_enable = [settings objectForKey:@"http_enable"] ? [[settings objectForKey:@"http_enable"] boolValue] : NO;
	http_url = [[settings objectForKey:@"http_url"] stringValue];
}

%ctor {
    loadPrefs();
    if (enabled)
    {
		PostData([[NSDictionary alloc] initWithObjectsAndKeys: @"init", @"action", nil]);
        %init(_ungrouped);
    }
    
}