/*
 *  CMCodeIndex.m                           Colin MacCreery
 *
 *  Implementation for the Code Index.
 *
 ************************************************************/


#import "CMCodeIndex.h"

@implementation CMCodeIndex
@synthesize type = _type;
@synthesize next = _next;
@synthesize codes = _codes;
@synthesize pointers = _pointers;

// ----- PUBLIC ---------------------------------------------/
-(id)initWithFile:(NSString*)f {
    self = [super init];
    
    binHandle = [NSFileHandle fileHandleForReadingAtPath:f];
        
    header *head=(header*)malloc(sizeof(header));
    head->m = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->r = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->e = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->f = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->k = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    h = head;
    
    recSize = 1 + 2 + (h->m * 3) + (h->m * 2);
    headSize = sizeof(header);
    
    return self;
}

-(NSDictionary*)query:(NSString*)c {
    nodesRead = 0;
    comparisons = 0;
    NSNumber* ans = [self query:c atNode:h->r];
    NSNumber* nR = [NSNumber numberWithInt:nodesRead];
    NSNumber* comp = [NSNumber numberWithInt:comparisons];

    NSDictionary* result;
    if([ans isNotEqualTo:nil]) {
        result = [NSDictionary dictionaryWithObjects:@[ans, nR, comp] forKeys:@[@"pointer", @"nodes", @"comparisons"]];
    } else {
        result = [NSDictionary dictionaryWithObjects:@[nR, comp] forKeys:@[@"nodes", @"comparisons"]];
    }
    return result;
}

-(NSString*)list {
    NSMutableString* listing = [NSMutableString stringWithString:@""];
    
    [self readNode:h->f];
    while(_next != 0) {
        for(int i = 0; i < [_codes count]; i++) {
            if([[_codes objectAtIndex:i] isEqualToString:@"^^^"]) break;
            [listing appendFormat:@"%@ %3d\n", [_codes objectAtIndex:i], [[_pointers objectAtIndex:i] intValue]];
        }
        [self readNode:_next];
    }
    
    [listing appendFormat:@"+++++ END OF DATA +++++ (%d countries)\n\n", h->k];
    
    return listing;
}

-(void)close {
    [binHandle closeFile];
}

// ----- PRIVATE --------------------------------------------/
-(NSNumber*)query:(NSString*)c atNode:(int)n {
    nodesRead++;
    [self readNode:n];
    
    if(_type != 'L') {
        for(int i = 0; i < [_codes count]; i++) {
            comparisons++;
            if([[_codes objectAtIndex:i] isEqualToString:@"^^^"]) return nil;
            if([c isLessThanOrEqualTo:[_codes objectAtIndex:i]]) return [self query:c atNode:[[_pointers objectAtIndex:i] intValue]];
        }
    } else {
        for(int i = 0; i < [_codes count]; i++) {
            comparisons++;
            if([[_codes objectAtIndex:i] isEqualToString:@"^^^"]) return nil;
            if([c isEqualTo:[_codes objectAtIndex:i]]) return [_pointers objectAtIndex:i];
        }
    }
    return nil;
}

-(void)readNode:(int)record {
    [binHandle seekToFileOffset:(headSize + (record - 1) * recSize)];
    _type = *(char*)[[binHandle readDataOfLength:1] bytes];
    _next = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    
    _codes = [[NSMutableArray alloc] initWithCapacity:h->m];
    for (int i = 0; i < h->m; i++) {
        [_codes addObject: [
            [NSString alloc]
            initWithBytes:[[binHandle readDataOfLength:3] bytes]
            length:3 encoding:NSASCIIStringEncoding]
        ];
    }
    
    _pointers = [[NSMutableArray alloc] initWithCapacity:h->m];
    for (int i = 0; i < h->m; i++) {
        [_pointers addObject: [
            NSNumber numberWithShort:
            CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] )]
        ];
    }
}

@end
