/*
N people put their names in a hat. Each randomly takes a name.
What is the probability that nobody will take their own name?
*/
#include<iostream>
using namespace std;
typedef unsigned long long ull;
const int MAX_N=10000;
double p[MAX_N][2];
ull nw[MAX_N][2];
void calc_prob(int n, bool k)
{
    if (n==0)
    {
        p[0][k]=1;
        return;
    }
    double ans=0;
    if (k==1) ans+=p[n-1][0]/n;
    ans+=(n-1)*p[n-1][1]/n;
    p[n][k]=ans;
}
void calc_num_ways(int n, bool k)
{
    if (n==0)
    {
        nw[0][k]=1;
        return;
    }
    ull ans=0;
    if (k==1) ans+=nw[n-1][0];
    ans+=(n-1)*nw[n-1][1];
    nw[n][k]=ans;
}
int main()
{
    int n;
    cin>>n;
    for(int i=0;i<=n;++i)
    {
        calc_prob(i,0);
        calc_prob(i,1);
        calc_num_ways(i,0);
        calc_num_ways(i,1);
    }
    double prob=p[n][0];
    ull num_ways=nw[n][0];
    cout<<prob<<" "<<num_ways<<endl;
    return 0;
}
