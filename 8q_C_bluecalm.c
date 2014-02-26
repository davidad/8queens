#include <stdint.h>
#include <stdio.h>

#define Qs 8

typedef struct{
    int sqrs[Qs][Qs];
    int rows[Qs];
    int cols[Qs];
    int rightdiag[Qs*2-1];
    int leftdiag[Qs*2-1];
} board;

static const board EmptyBoard;


void pprint_board(board *brd);
void print_legal_moves(board *brd);
void place_queen(board *brd, int x, int y);
void take_back(board *brd, int x, int y);
int is_legal(board *brd, int x, int y);
void solve (board *brd, int x);


int SOLUTIONS;


void place_queen(board *brd, int x, int y)
{
    brd->sqrs[x][y] = 1;
    brd->rows[y] = 1;
    brd->cols[x] = 1;
    brd->rightdiag[x+y] = 1;
    brd->leftdiag[x + (Qs-1-y)] = 1;
}


void take_back(board *brd, int x, int y)
{
    brd->sqrs[x][y] = 0;
    brd->rows[y] = 0;
    brd->cols[x] = 0;
    brd->rightdiag[x+y] = 0;
    brd->leftdiag[x + (Qs-1-y)] = 0;
}


void pprint_board(board *brd)
{
    int x, y;
    for (y = 0; y < Qs; y++){
        for(x = 0; x < Qs; x++)
            printf("%d", brd->sqrs[x][y]);
        printf("\n");
    }
}

void print_legal_moves(board *brd)
{
    int x, y;
    for (y = 0; y < Qs; y++){
        for(x = 0; x < Qs; x++)
            printf("%d", is_legal(brd, x, y));
        printf("\n");
    }
}


int is_legal(board *brd, int x, int y)
{
    if (brd->rows[y] || brd->cols[x] || brd->rightdiag[x+y]
                            || brd->leftdiag[x + (Qs-1-y)])
        return 0;
    else return 1;
}


void solve (board *brd, int x)
{
    int i;

    if (x == Qs){
        /*if (SOLUTIONS == 0){
            pprint_board(brd);
            printf("\n");
        }*/
        SOLUTIONS += 1;
    } else {
        for (i = 0; i < Qs ; i++){
            if (is_legal(brd, x, i)){
                place_queen(brd, x, i);
                solve(brd, x+1);
                take_back(brd, x, i);
            }
        }
    }
}


int main(){
    board brd;
    //LARGE_INTEGER t1, t2, freq;
    
    //QueryPerformanceFrequency(&freq);
    //QueryPerformanceCounter(&t1);
  
    int i;
    for(i=0;i<10000;i++) {
      SOLUTIONS = 0;
      brd = EmptyBoard;
      solve(&brd,0);
    }
    return SOLUTIONS;
    //printf("%d", SOLUTIONS);

    //QueryPerformanceCounter(&t2);
    
    //printf("\n");
    //printf("%fms", (t2.QuadPart - t1.QuadPart) * (double)1000.0 / freq.QuadPart);

    //return 1;
}
