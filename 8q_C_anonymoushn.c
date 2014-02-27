#include <stdint.h>
#include <stdio.h>

#define Qs 8

void solve0();
void solve(int x, uint8_t straight, uint8_t left, uint8_t right);

int SOLUTIONS;

void solve (int x, uint8_t straight, uint8_t left, uint8_t right)
{
    if(x == Qs) {
        SOLUTIONS += 1;
        return;
    }
    uint32_t i;
    for (i=1; i < 256 ; i<<=1){
        if(! (i & (straight | left | right))) {
            solve(x+1,straight|i,(left|i)<<1,(right|i)>>1);
        }
    }
}

void solve0()
{
    int i;
    i = 1;
    for (; i < 256 ; i<<=1){
        solve(1, i,i<<1,i>>1);
    }
}


int main(){
    int i;
    for(i=0;i<10000;i++) {
      SOLUTIONS = 0;
      solve0();
    }
    return SOLUTIONS;
}
