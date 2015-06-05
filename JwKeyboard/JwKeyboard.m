//
//  JwKeyboard.m
//  JwKeyboard
//
//  Created by 孙敦鸣 on 15/5/27.
//  Copyright (c) 2015年 www.jw-smart.com. All rights reserved.
//

#import "JwKeyboard.h"
#import <openssl/rsa.h>
#define kLineWidth 1
#define kNumFont [UIFont boldSystemFontOfSize:27]
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define KEYLEN 2048
#define DATALEN 256
#define PADDING 512

@implementation JwKeyboard
{
    UITextField *textField;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounds = CGRectMake(0, 0, SCREENWIDTH, 216+36);
        
        [self initKeyboard];
        
    }
    return self;
}

-(void)initKeyboard{
    
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 6, SCREENWIDTH-20, 30)];
    textField.placeholder = @"请输入联机PIN";
    textField.secureTextEntry = YES;
    textField.enabled = NO;
    textField.textAlignment = NSTextAlignmentRight;
    [textField addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self addSubview:textField];
    
    
    arrLetter = [NSArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"", nil];
    
    digitalArray = [[NSMutableArray alloc]initWithCapacity:10];
    [digitalArray addObjectsFromArray:@[@0,@1,@2,@3,@4,@5,@6,@7,@8,@9]];
    digitalArray = [self paxu];
    for (int i=0; i<4; i++)
    {
        for (int j=0; j<3; j++)
        {
            UIButton *button = [self creatButtonWithX:i Y:j];
            [self addSubview:button];
        }
    }
    
    UIColor *color = [UIColor colorWithRed:69/255.0 green:69/255.0 blue:69/255.0 alpha:1];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/3, 36, kLineWidth, 216)];
    line1.backgroundColor = color;
    [self addSubview:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/3*2, 36, kLineWidth, 216)];
    line2.backgroundColor = color;
    [self addSubview:line2];
    
    for (int i=0; i<4; i++)
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54*i+36, SCREENWIDTH, kLineWidth)];
        line.backgroundColor = color;
        [self addSubview:line];
    }
}

-(UIButton *)creatButtonWithX:(NSInteger) x Y:(NSInteger) y
{
    UIButton *button;
    CGFloat frameX;
    CGFloat frameW;
    switch (y)
    {
        case 0:
            frameX = 0.0;
            frameW = SCREENWIDTH/3;
            break;
        case 1:
            frameX = SCREENWIDTH/3;
            frameW = SCREENWIDTH/3;
            break;
        case 2:
            frameX = SCREENWIDTH/3*2;
            frameW = SCREENWIDTH/3;
            break;
            
        default:
            break;
    }
    CGFloat frameY = 54*x;
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(frameX, frameY+36, frameW, 54)];
    NSInteger num = y+3*x+1;
    button.tag = num;
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *colorHightlighted = [UIColor colorWithRed:255.0/255 green:102.0/255 blue:51.0/255 alpha:1.0];
    button.backgroundColor = [UIColor clearColor];
    if (num == 10 || num == 12)
    {
        button.backgroundColor = [UIColor colorWithRed:127/255.0 green:127/255.0 blue:129/255.0 alpha:1];
    }
    
    CGSize imageSize = CGSizeMake(frameW, 54);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [colorHightlighted set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [button setImage:pressedColorImg forState:UIControlStateHighlighted];
    
    
    
    if (num<10)
    {
        UILabel *labelNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, frameW, 28)];
        labelNum.text = [NSString stringWithFormat:@"%@",[digitalArray objectAtIndex:num-1]];
        labelNum.textColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        labelNum.textAlignment = NSTextAlignmentCenter;
        labelNum.font = kNumFont;
        [button addSubview:labelNum];
        
        if (num != 1)
        {
            UILabel *labelLetter = [[UILabel alloc] initWithFrame:CGRectMake(0, 33, frameW, 16)];
            labelLetter.text = [arrLetter objectAtIndex:num-2];
            labelLetter.textColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
            labelLetter.textAlignment = NSTextAlignmentCenter;
            labelLetter.font = [UIFont boldSystemFontOfSize:20.0f];
            [button addSubview:labelLetter];
        }
    }
    else if (num == 11)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, frameW, 28)];
        label.text = [NSString stringWithFormat:@"%@",[digitalArray objectAtIndex:9]];
        label.textColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = kNumFont;
        [button addSubview:label];
    }
    else if (num == 12)
    {
        
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake( SCREENWIDTH >320 ? 50: 40, 14, 30, 30)];
        NSString *imagePath =[[NSBundle mainBundle]pathForResource:@"arrowInKeyboard" ofType:@"png"];
        arrow.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        [button addSubview:arrow];
        
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, frameW, 28)];
        label.text = @"确定";
        label.textColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:20.0f];
        [button addSubview:label];
        
    }
    
    return button;
}

-(void)clickButton:(UIButton *)sender
{
    if (sender.tag == 12)
    {
        [self.delegate numberKeyboardBackspace];
        
        if (textField.text.length != 0)
        {
            textField.text = [textField.text substringToIndex:textField.text.length -1];
        }
    }
    else if(sender.tag == 10)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *block = @"";
            block = [self calcRSA:textField.text];
            NSLog(@"确定text:%@", block);
            [[NSNotificationCenter defaultCenter]postNotificationName:PUSHPASSWORD object:block];
        
            digitalArray = [self paxu];
            [self initKeyboard];
            [self.delegate changeKeyboardType];
            [textField resignFirstResponder];
        });
        return;
    }
    else
    {
        NSInteger num = sender.tag;
        if (sender.tag == 11)
        {
            num = 10;
        }
        [self.delegate numberKeyboardInput:[[digitalArray objectAtIndex:num-1] intValue]];
        
        textField.text = [textField.text stringByAppendingString:[NSString stringWithFormat:@"%d",[[digitalArray objectAtIndex:num-1] intValue]]];
        if (textField.text.length >6) {
            textField.text = [textField.text substringToIndex:6];
        }
    }
}


-(NSMutableArray *)paxu{
    
    NSUInteger i = digitalArray.count;
    while(--i > 0) {
        int j = rand() % (i+1);
        [digitalArray exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    return digitalArray;
    
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] =
    {
        
        125 / 255.0,  125 / 255.0, 125 / 255.0, 1.00,
        78 / 255.0, 78 / 255.0, 78 / 255.0, 1.00,
        
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents
    (rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(rgb);
    CGContextDrawLinearGradient(context, gradient,CGPointMake
                                (0.0,0.0) ,CGPointMake(0.0,self.frame.size.height),
                                kCGGradientDrawsBeforeStartLocation);
}

-(void)setPan:(NSString *)pan
{
    mPan = pan;
}

-(NSString *)calcRSA:(NSString *)pin{
    
    RSA *ClientRsa = RSA_generate_key(KEYLEN, RSA_F4, NULL, NULL);
    
    unsigned char PublicKey[KEYLEN];
    unsigned char *PKey = PublicKey;
    int PublicKeyLen = i2d_RSAPublicKey(ClientRsa, &PKey);
    
    unsigned char temp[] = {0x30, 0x82, 0x01, 0x0a, 0x02, 0x82, 0x01, 0x01, 0x00, 0xB8, 0x45, 0xAC, 0x7A, 0x35, 0xE1, 0xE6, 0x84, 0xC0, 0x86, 0x10, 0x51, 0x29, 0xC3, 0x99, 0x4E, 0x13, 0xEB, 0x5B, 0x16, 0x91, 0x46, 0xD5, 0x26, 0x99, 0xE0, 0xB3, 0xD3, 0xA5, 0x47, 0xFD, 0x62, 0x8A, 0x19, 0xBB, 0x46, 0xD1, 0x08, 0xE3, 0xAA, 0xF0, 0x70, 0xB7, 0x62, 0x50, 0x53, 0xDE, 0xCD, 0x4C, 0x6C, 0xA9, 0x8C, 0xD2, 0x77, 0x89, 0x37, 0x69, 0xFD, 0x75, 0x86, 0x23, 0x3C, 0xAB, 0xFF, 0x33, 0x07, 0x9F, 0x18, 0x5D, 0x82, 0x0D, 0xA8, 0x76, 0x59, 0x6C, 0xA7, 0xD1, 0x9F, 0x9A, 0x77, 0x39, 0x13, 0x92, 0x6B, 0xCD, 0x13, 0x6E, 0x46, 0x90, 0x19, 0xC1, 0xE5, 0xD4, 0x7B, 0xF1, 0x3E, 0x4D, 0xEF, 0x5C, 0x40, 0x2F, 0x9A, 0xF8, 0xA3, 0x1B, 0x42, 0xA5, 0x24, 0x34, 0x53, 0xEB, 0xD4, 0xD0, 0xD9, 0x6C, 0x70, 0xD2, 0x02, 0x3C, 0x11, 0xCD, 0xA9, 0x07, 0xF9, 0x99, 0x0B, 0x4F, 0xFC, 0x2C, 0x8A, 0xF5, 0xE7, 0xAA, 0x66, 0xCE, 0xE4, 0x2D, 0x94, 0xBC, 0x39, 0x04, 0xA6, 0x4C, 0x05, 0x1E, 0x6F, 0x05, 0xEF, 0x42, 0x6A, 0xA1, 0x8B, 0xF0, 0xFB, 0xAC, 0xFB, 0x4A, 0xE5, 0xBB, 0xB3, 0x6D, 0x42, 0x06, 0xAD, 0xAE, 0x9A, 0x0F, 0x9F, 0x4B, 0x0A, 0xDA, 0x04, 0xD1, 0xA2, 0x32, 0x0B, 0xEE, 0xE1, 0xA2, 0x72, 0x46, 0xCD, 0x14, 0x68, 0x1A, 0xEF, 0x84, 0xF4, 0x2D, 0x8B, 0x1E, 0xFE, 0x80, 0x0E, 0x3D, 0x71, 0x46, 0xAD, 0xAF, 0xCE, 0x97, 0x88, 0x4C, 0xC3, 0x49, 0x68, 0x0B, 0xF5, 0x71, 0xC7, 0x81, 0x4C, 0x2A, 0xF0, 0x88, 0xF9, 0x06, 0x48, 0x94, 0x7E, 0x77, 0xA5, 0x14, 0x04, 0x39, 0x98, 0x46, 0x10, 0xD6, 0x78, 0x0F, 0xA9, 0x2F, 0x56, 0x4F, 0x98, 0xA3, 0xA2, 0x39, 0x31, 0xD9, 0x71, 0xE6, 0x00, 0xC9, 0xDD, 0xBB, 0x1B, 0x2A, 0x37, 0xA4, 0x72, 0x7C, 0x42, 0xC3, 0x13, 0x02, 0x03, 0x01, 0x00, 0x01};
    
    //unsigned char temp[] = {0x30, 0x81, 0x89, 0x02, 0x81, 0x81, 0x00, 0xDE, 0x01, 0x19, 0x9F, 0x15, 0x44, 0x1A, 0x29, 0x4B, 0x10, 0xBA, 0xCE, 0x53, 0x56, 0xC4, 0x27, 0x87, 0x44, 0xD9, 0x0E, 0xCA, 0xC2, 0xAE, 0x3D, 0x7B, 0x1A, 0xD0, 0x8F, 0xAB, 0xAF, 0xF3, 0x0A, 0xBE, 0x29, 0xAD, 0x14, 0x1B, 0xDB, 0xE6, 0x09, 0x08, 0x81, 0xEE, 0x16, 0x44, 0x91, 0x90, 0xB2, 0x72, 0x46, 0x97, 0x97, 0x44, 0xBE, 0xA3, 0xD5, 0x84, 0xF4, 0x65, 0x8C, 0xE8, 0x06, 0xEC, 0x24, 0x2B, 0x6E, 0x84, 0xE7, 0x2F, 0x99, 0x87, 0xD9, 0x03, 0xCD, 0xFA, 0x72, 0xE3, 0xF3, 0xFC, 0xEC, 0x52, 0x79, 0xB0, 0xEE, 0xC0, 0x24, 0xF8, 0x7C, 0xE4, 0x74, 0x05, 0x2F, 0xB4, 0x48, 0x35, 0xC5, 0x50, 0x63, 0x97, 0xA9, 0x21, 0x1A, 0xCF, 0x22, 0x51, 0x80, 0x71, 0xB0, 0xBE, 0x12, 0x85, 0x15, 0x54, 0xEE, 0xFD, 0xB3, 0x33, 0xA5, 0x95, 0xED, 0x26, 0x16, 0xDF, 0x9E, 0xAD, 0xD7, 0x2B, 0x29, 0x02, 0x03, 0x01, 0x00, 0x01};
    memcpy(PublicKey, temp, sizeof(temp));
    
    // ---------
    // 3. 跟据上面提出的公钥信息PublicKey构造一个新RSA密钥(这个密钥结构只有公钥信息)
    PKey = PublicKey;
    RSA *EncryptRsa = d2i_RSAPublicKey(NULL, (const unsigned char**)&PKey, PublicKeyLen);
    
    unsigned char OutBuff[DATALEN] = {};
    NSString * block = [self ToRSADataWithPIN:pin];
    
    unsigned char *dataExchange = NULL;
    NSMutableData *myData = [[NSMutableData alloc] initWithCapacity:DATALEN];
    dataExchange = myData.mutableBytes;
    
    Ascii2Hex(dataExchange, (unsigned char *)[[block uppercaseString] UTF8String], (int)( [block length]));
    
    RSA_public_encrypt(DATALEN, dataExchange, OutBuff, EncryptRsa, RSA_NO_PADDING); // 加密
    
    // ----------
    // 7. 谨记要释放RSA结构
    RSA_free(EncryptRsa);
    RSA_free(ClientRsa);
    
    
    return [self char2StringWithLength:OutBuff Length:DATALEN];
}

-(NSString *)ToRSADataWithPIN:(NSString *)pin{
    
    NSString *random = [NSString new];
    
    mPan = [mPan stringByReplacingOccurrencesOfString:@"F" withString:@""];
    mPan = [mPan stringByReplacingOccurrencesOfString:@"f" withString:@""];
    
    NSString *pin1 = [@"0" stringByAppendingString:[NSString stringWithFormat:@"%d",(int)pin.length]];
    while (pin.length <14) {
        pin = [pin stringByAppendingString:@"F"];
    }
    NSString *pin2 = [pin1 stringByAppendingString:pin];
    NSString *pan1 = [mPan substringToIndex:(mPan.length - 1)];
    NSString *pan2 = [pan1 substringFromIndex:(pan1.length -12)];
    NSString *pan3 = [@"0000" stringByAppendingString:pan2];
    int i1;
    int i2;
    NSString *s1;
    NSString *s2;
    NSString *XOR = @"";
    //对pin和pan进行转化
    for (int i=0; i<16; i++) {
        NSRange range = NSMakeRange(i, 1);
        s1 = [pin2 substringWithRange:range];
        s2 = [pan3 substringWithRange:range];
        i1 = [[self hexStringFromString:s1 ] intValue];
        i2 = [[self hexStringFromString:s2] intValue];
        i1 ^= i2;
        Byte src[4] = {};
        src[0] = (Byte) ((i1>>24) & 0x000000FF);
        src[1] =  (Byte) ((i1>>16) & 0x000000FF);
        src[2] =  (Byte) ((i1>>8) & 0x000000FF);
        src[3] =  (Byte) (i1 & 0x000000FF);
        Byte bs2[] = {src[3]};
        XOR = [XOR stringByAppendingString:[[NSString stringWithFormat:@"%x",(int )bs2[0]] uppercaseString]];
    }
    NSLog(@"XOR_____:%@",XOR);
    
    random = [@"00" stringByAppendingString:@"02"];
    NSString *randomSyting = [self getRandomString:(int)(PADDING - 6 - XOR.length)];
    random = [[[random stringByAppendingString:randomSyting] stringByAppendingString:@"00"] stringByAppendingString:XOR];
    
    NSLog(@"random_____:%@",random);
    
    return random;
}

#pragma 普通字符串转换为十六进制的
- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr;
        if (bytes[i]>=65) {
            newHexStr = [NSString stringWithFormat:@"%d",bytes[i]-55];///16进制数
        }else{
            newHexStr = [NSString stringWithFormat:@"%d",bytes[i]-48];///16进制数
        }
        
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

#pragma 获取随机数
-(NSString *)getRandomString:(int )rlength {
    NSString *randomString = [NSString new];
    NSString *s = [NSString new];
    //static char HEX[] = { '0', '1', '2', '3', '4', '5', '6', '7',
    //    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    static char HEX[] = {'F'};
    int r;
    char c[] = {};
    
    if(rlength<1){
        return @"";
    }
    for (int i=0; i < rlength; i++) {
        do{
            r = arc4random() % 16;
            
            //c[0] = HEX[0x0F &r];
            c[0] = HEX[0];
            s = [NSString stringWithFormat:@"%c",c[0]];
            
        }while ([s isEqualToString:@"0"] == YES);
        randomString = [randomString stringByAppendingString:s];
        
    }
    
    return randomString;
    
}

-(NSString *)char2StringWithLength:(unsigned char *)sData Length:(int) length{
    
    NSMutableString *hexString = [NSMutableString string];
    for (int i=0; i<length; i++)
    {
        [hexString appendFormat:@"%02x", sData[i]];
    }
    
    return hexString;
}

int Ascii2Hex(unsigned char *lpHex, const unsigned char *lpAscii, int nLength)
{
    int i;
    unsigned char cAscii;
    
    for ( i=0; i<nLength; i++)
    {
        if(isxdigit(lpAscii[i])==0)
            return -200;
        cAscii=(lpAscii[i]>='A')?lpAscii[i]-'A'+'9'+1:lpAscii[i];
        lpHex[i/2]=(i%2)?(lpHex[i/2]|(cAscii-'0')):((cAscii-'0')<<4);
    }
    return 0;
}

@end
