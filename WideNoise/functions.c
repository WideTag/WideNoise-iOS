//
//  functions.c
//  WideNoise
//
//  Created by Emilio Pavia on 25/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#include "functions.h"

float interpolate(float x, float lookup_table[][2], int table_size)
{
    if (x <= lookup_table[0][0]) {
        return lookup_table[0][1];
    }
    
    for (int i=0; i<table_size-1; i++) {
        float x0 = lookup_table[i][0];
        float y0 = lookup_table[i][1];
        float x1 = lookup_table[i+1][0];
        float y1 = lookup_table[i+1][1];
        
        if (x <= x1) {
            // we use a linear interpolation
            float y = ((y1 - y0) / (x1 - x0)) * (x - x0) + y0;
            return y;
        }
    }
    
    return lookup_table[table_size-1][1];
}