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
queue<tuple<int, int, int>> q2;
void is_good(int x, int y, int v, int& last, int i) {
    if (s[x][y].poss[v]==1 && s[x][y].val==-1 && last!=-1) last=-2;
    if (s[x][y].poss[v]==1 && s[x][y].val==-1 && last==-1) last=i;
}
void change(int x, int y, int v);
void update(int x, int y, int v) {
    if (s[x][y].poss[v]==1) q2.push(make_tuple(x,y,v));
    s[x][y].poss[v]=0;
    int last=-1;
    for (int j=0; j<N; ++j) is_good(x,y,j,last,j);
    if (last>=0) change(x,y,last);
}
void update2(int x, int y, int v) {
    int last=-1;
    for (int i=0; i<N; ++i) is_good(x,i,v,last,i);
    if (last>=0) change(x,last,v);
    last=-1;
    for (int i=0; i<N; ++i) is_good(i,y,v,last,i);
    if (last>=0) change(last,y,v);
    last=-1;
    for (int i=0; i<N; ++i) is_good(x/NPS*NPS+i/NPS,y/NPS*NPS+i%NPS,v,last,i);
    if (last>=0) change(x/NPS*NPS+last/NPS,y/NPS*NPS+last%NPS,v);
}
void change(int x, int y, int v) {
    s[x][y].val=v;
    q.push(make_pair(x,y));
    for (int i=0; i<N; ++i) if (i!=v) update(x,y,i);
}
int main() {
    for (int i=0; i<N*N; ++i) {
        cin>>s[i/N][i%N].val;
        --s[i/N][i%N].val;
        for (int k=0; k<N && s[i/N][i%N].val==-1; ++k) s[i/N][i%N].poss[k]=1;
        if (s[i/N][i%N].val!=-1) q.push(make_pair(i/N,i%N));
    }
    while (!q2.empty() || !q.empty()) {
        while (!q.empty()) {
            for (int i=0; i<N; ++i) if (s[i][q.front().second].val==-1) update(i,q.front().second,s[q.front().first][q.front().second].val);
            for (int i=0; i<N; ++i) if (s[q.front().first][i].val==-1) update(q.front().first,i,s[q.front().first][q.front().second].val);
            for (int i=0; i<N; ++i) if (s[q.front().first/NPS*NPS+i/NPS][q.front().second/NPS*NPS+i%NPS].val==-1) update(q.front().first/NPS*NPS+i/NPS,q.front().second/NPS*NPS+i%NPS,s[q.front().first][q.front().second].val);
            q.pop();
        }
        update2(get<0>(q2.front()),get<1>(q2.front()),get<2>(q2.front()));
        q2.pop();
    }
    for (int i=0; i<N*N; ++i) {
        if (i%NPS==0 && i%N) cout<<" ";
        cout<<s[i/N][i%N].val+1<<" ";
        if ((i+1)%N==0) cout<<endl;
        if ((i+1)%N==0 && (i+1)/N%NPS==0) cout<<endl;
    }
    return 0;
}
