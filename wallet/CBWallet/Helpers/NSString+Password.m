//
//  NSString+Password.m
//  CBWallet
//
//  Created by Zin on 16/3/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSString+Password.h"

#ifdef DEBUG
#define PSLog(...) NSLog(__VA_ARGS__)
#else
#define PSLog(...) do {} while (0)
#endif

@implementation NSString (Password)

- (double)passwordStrength {
    PSLog(@"password strength: %@", self);
    float score = 1.0;
    // 强制条件:
    // 长度 >= 8
    NSInteger length = self.length;
    if (length < 8) {
        PSLog(@"length less %ld < 8", (long)length);
        return 0;
    }
    // 含有小写字母
    NSCharacterSet *lowercaseCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
    if([self rangeOfCharacterFromSet:lowercaseCharacterSet].location == NSNotFound) {
        PSLog(@"no lowercase character");
        return 0;
    }
    // 含有大写字母
    NSCharacterSet *uppercaseCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    if([self rangeOfCharacterFromSet:uppercaseCharacterSet].location == NSNotFound) {
        PSLog(@"no upppercase character");
        return 0;
    }
    // 含有数字
    NSCharacterSet *numbricCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"012345678"];
    if([self rangeOfCharacterFromSet:numbricCharacterSet].location == NSNotFound) {
        PSLog(@"no numberic character");
        return 0;
    }
    // 含有特殊字符
    NSCharacterSet *specialCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"`,./;'[]\\-=~!@#$%^&*()_+{}|:\"<>?"];
    if([self rangeOfCharacterFromSet:specialCharacterSet].location == NSNotFound) {
        PSLog(@"no special character");
        return 0;
    }
    // 重复性，超过两个重复扣分
    for (int i = 0; i < length - 1; i++) {
        NSString *a = [self substringWithRange:NSMakeRange(i, 1)];
        NSString *b = [self substringWithRange:NSMakeRange(i+1, 1)];
        if ([a isEqualToString:b]) {
            PSLog(@"%@ == %@", a, b);
            score -= 0.2;
        }
    }
    //TODO: 是否有顺序数字
    //TODO: 是否有顺序字母
    // 是否为bad case
    NSString *badCase = @"1234 12345 123456 1234567 12345678 654321 987654 4321 2000 4128 2112 1212 121212 232323 1313 131313 696969 112233 1111 11111 111111 11111111 2222 3333 4444 7777777 777777 7777 6666 porsche firebird prince rosebud password guitar butter beach jaguar chelsea united amateur great black turtle cool pussy diamond steelers muffin cooper nascar tiffany redsox dragon jackson zxcvbn star scorpio qwerty cameron tomcat testing mountain golf shannon madison mustang computer bond007 murphy letmein amanda bear frank brazil baseball wizard tiger hannah lauren master xxxxxxxx doctor dave japan michael money gateway eagle1 naked football phoenix gators squirt shadow mickey angel mother stars monkey bailey junior nathan apple abc123 knight thx1138 raiders alexis pass iceman porno steve aaaa fuckme tigers badboy forever bonnie 6969 purple debbie angela peaches jordan andrea spider viper jasmine harley horny melissa ou812 kevin ranger dakota booger jake matt iwantu aaaaaa lovers qwertyui jennifer player flyers suckit danielle hunter sunshine fish gregory beaver fuck morgan porn buddy starwars matrix whatever test boomer teens young runner batman cowboys scooby nicholas swimming trustno1 edward jason lucky dolphin thomas charles walter helpme gordon tigger girls cumshot jackie casper robert booboo boston monica stupid access coffee braves midnight shit love xxxxxx yankee college saturn buster bulldog lover baby gemini ncc1701 barney cunt apples soccer rabbit victor brian august hockey peanut tucker mark killer john princess startrek canada george johnny mercedes sierra blazer sexy gandalf 5150 leather cumming andrew spanky doggie hunting charlie winter zzzzzz kitty superman brandy gunner beavis rainbow asshole compaq horney bigcock fuckyou carlos bubba happy arthur dallas tennis sophie cream jessica james fred ladies calvin panties mike johnson naughty shaved pepper brandon xxxxx giants surfer fender tits booty samson austin anthony member blonde kelly william blowme boobs fucked paul daniel ferrari donald golden mine golfer cookie bigdaddy king summer chicken bronco fire racing heather maverick penis sandra 5555 hammer chicago voyager pookie eagle yankees joseph rangers packers hentai joshua diablo birdie einstein newyork maggie sexsex trouble dolphins little biteme hardcore white redwings enter 666666 topgun chevy smith ashley willie bigtits winston sticky thunder welcome bitches warrior cocacola cowboy chris green sammy animal silver panther super slut broncos richard yamaha qazwsx 8675309 private fucker justin magic zxcvbnm skippy orange banana lakers nipples marvin merlin driver rachel power blondes michelle marine slayer victoria enjoy corvette angels scott asdfgh girl bigdog fishing vagina apollo cheese david asdf toyota parker matthew maddog video travis qwert hooters london hotdog time patrick wilson paris sydney martin butthead marlboro rock women freedom dennis srinivas xxxx voodoo ginger fucking internet extreme magnum blowjob captain action redskins juice nicole bigdick carter erotic abgrtyu sparky chester jasper dirty yellow smokey monster ford dreams camaro xavier teresa freddy maxwell secret steven jeremy arsenal music dick viking access14 rush2112 falcon snoopy bill wolf russia taylor blue crystal nipple scorpion eagles peter iloveyou rebecca winner pussies alex tester 123123 samantha cock florida mistress bitch house beer eric phantom hello miller rocket legend billy scooter flower theman movie please jack oliver success albert";
    NSArray *badCasesArray = [badCase componentsSeparatedByString:@" "];
    for (NSString *bad in badCasesArray) {
        if ([self rangeOfString:bad options:NSCaseInsensitiveSearch].location != NSNotFound) {
            PSLog(@"including bad case: %@", bad);
            score -= 0.3;
        }
    }
    return score * 100;
}

@end
