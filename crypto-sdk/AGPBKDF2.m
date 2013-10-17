/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGPBKDF2.h"
#import "AGRandomGenerator.h"

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

static const NSInteger kIterations = 20000;
static const NSInteger kMinimumIterations = 10000;
static const NSInteger kDerivedKeyLength = 160;
static const NSInteger kMinimumSaltLength = 16;

@implementation AGPBKDF2 {
    NSData *_salt;
}

- (id)init {
    self = [super init];
    
    if (self) {
        // initialize
    }
    
    return self;
}

- (NSData *)encrypt:(NSString *)password {
    return [self encrypt:password salt:[AGRandomGenerator randomBytes]];
}

- (NSData *)encrypt:(NSString *)password salt:(NSData *)salt {
    return [self encrypt:password salt:salt iterations:kIterations];
}

- (NSData *)encrypt:(NSString *)password salt:(NSData *)salt iterations:(NSInteger)iterations {
    NSParameterAssert(password != nil);
    NSParameterAssert(salt != nil && [salt length] >= kMinimumSaltLength);
    NSParameterAssert(iterations >= kMinimumIterations);
    
    _salt = salt;
    
    NSMutableData *key = [NSMutableData dataWithLength:kDerivedKeyLength];
    
    int result = CCKeyDerivationPBKDF(kCCPBKDF2,
                                      [password UTF8String],
                                      [password length],
                                      [salt bytes],
                                      [salt length],
                                      kCCPRFHmacAlgSHA1,
                                      iterations,
                                      [key mutableBytes],
                                      kDerivedKeyLength);
    if (result == kCCParamError) {
        return nil;
    }
    
    return key;
}

- (BOOL)validate:(NSString *)password encryptedPassword:(NSData *)encryptedPassword salt:(NSData *)salt {
    NSData *attempt = [self encrypt:password salt:salt];
    
    return [encryptedPassword isEqual:attempt];    
}

- (NSData *)salt {
    return _salt;
}

@end
