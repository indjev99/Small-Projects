#include<iostream>
#include<queue>
#include<tuple>
using namespace std;
const int NPS=3;
const int N=NPS*NPS;
struct square {
    bool poss[N];
    int val;
};
square s[N][N];
queue<pair<int, int>> q;
void update(int x, int y, int v) {
    s[x][y].poss[v]=0;
    int last=-1;
    for (int j=0; j<N; ++j) {
        if (s[x][y].poss[j]==1 && s[x][y].val==-1 && last!=-1) last=-2;
        if (s[x][y].poss[j]==1 && s[x][y].val==-1 && last==-1) last=j;
    }
    if (last>=0) {
        s[x][y].val=last;
        q.push(make_pair(x,y));
    }
}
int main() {
    for (int i=0; i<N*N; ++i) {
        cin>>s[i/N][i%N].val;
        --s[i/N][i%N].val;
        for (int k=0; k<N && s[i/N][i%N].val==-1; ++k) s[i/N][i%N].poss[k]=1;
        if (s[i/N][i%N].val!=-1) q.push(make_pair(i/N,i%N));
    }
    while (!q.empty()) {
        for (int i=0; i<N; ++i) if (s[i][q.front().second].val==-1) update(i,q.front().second,s[q.front().first][q.front().second].val);
        for (int i=0; i<N; ++i) if (s[q.front().first][i].val==-1) update(q.front().first,i,s[q.front().first][q.front().second].val);
        for (int i=0; i<N; ++i) if (s[q.front().first/NPS*NPS+i/NPS][q.front().second/NPS*NPS+i%NPS].val==-1) update(q.front().first/NPS*NPS+i/NPS,q.front().second/NPS*NPS+i%NPS,s[q.front().first][q.front().second].val);
        q.pop();
    }
    for (int i=0; i<N*N; ++i) {
        if (i%NPS==0 && i%N) cout<<" ";
        cout<<s[i/N][i%N].val+1<<" ";
        if ((i+1)%N==0) cout<<endl;
        if ((i+1)%N==0 && (i+1)/N%NPS==0) cout<<endl;
    }
    return 0;
}
