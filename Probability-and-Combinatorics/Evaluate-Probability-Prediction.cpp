#include<iostream>
#include<math.h>
using namespace std;

const int RES=1e6; //resolution
const int MAX_N=1e6;

struct PDF
{
    double vals[RES+1];
    double mean;
    double SD;
    void calcMeanAndSD()
    {
        mean=0;
        for (int i=0;i<=RES;++i)
        {
            mean+=i*1.0/RES*vals[i]/RES;
        }
        SD=0;
        for (int i=0;i<=RES;++i)
        {
            SD+=(i*1.0/RES-mean)*(i*1.0/RES-mean)*vals[i]/RES;
        }
        SD=sqrt(SD);
    }
    void setUniform()
    {
        for (int i=0;i<=RES;++i)
        {
            vals[i]=1;
        }
        calcMeanAndSD();
    }
    void setFunction(double(*f)(double))
    {
        for (int i=0;i<=RES;++i)
        {
            vals[i]=f(i*1.0/RES);
        }
        calcMeanAndSD();
    }
    void adjustPDF(PDF& newPDF, bool result) const
    {
        if (result==1)
        {
            for (int i=0;i<=RES;++i)
            {
                newPDF.vals[i]=i*vals[i]/RES/mean;
            }
        }
        else
        {
            for (int i=0;i<=RES;++i)
            {
                newPDF.vals[i]=(RES-i)*vals[i]/RES/(1-mean);
            }
        }
        newPDF.calcMeanAndSD();
    }
};

int n;
bool heads[MAX_N];
double g[MAX_N];
PDF f,h,t;
int m;
double dist;
double SD;
void input()
{
    cin>>n;
    for (int i=0;i<n;++i)
    {
        cin>>g[i]>>heads[i];
    }
}
void solve()
{
    f.setUniform();
    f.adjustPDF(h,1);
    f.adjustPDF(t,0);
    m=0;
    dist=0;
    //cerr<<g[0]<<" "<<t.mean<<endl;
    for (int i=0;i<n;++i)
    {
        if (heads[i])
        {
            ++m;
            dist+=(g[i]-h.mean)*(g[i]-h.mean);
        }
        else
        {
            dist+=(g[i]-t.mean)*(g[i]-t.mean);
        }
    }
    dist=sqrt(dist);
    SD=sqrt(m*h.SD*h.SD+(n-m)*t.SD*t.SD);
    cout<<dist<<" "<<SD<<"  "<<dist/SD<<endl;
}
int main()
{
    input();
    solve();
    return 0;
}
