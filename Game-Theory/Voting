/*
Everybody picks thier 3 top choices.
Ended by typing -1 -1 -1.
After that the number of candidates is entered.
The program then sorts the candidates by how liked they are.
*/
#include<iostream>
#include<conio.h>
using namespace std;
struct vote
{
    int v[3];
    int c;
};
vote vs[10000];
int p[10000];
int main()
{
    int a,b,c;
    cin>>a>>b>>c;
    int i=0;
    while (a!=-1)
    {
        a--;
        b--;
        c--;
        vs[i].v[0]=a;
        vs[i].v[1]=b;
        vs[i].v[2]=c;
        vs[i].c=0;
        cin>>a>>b>>c;
        ++i;
    }
    int k;
    cin>>k;
    for (int j=0;j<k;++j)
    {
        p[j]=0;
    }
    for (int ii=0;ii<k;++ii)
    {
        for (int j=0;j<i;++j)
        {
            vs[j].c=0;
        }
        for (int j=0;j<k;++j)
        {
            if (p[j]!=-2) p[j]=0;
        }
        for (int jj=k-ii;jj>1;--jj)
        {
            for (int j=0;j<k;++j)
            {
                if (p[j]>=0) p[j]=0;
            }
            for (int j=0;j<i;++j)
            {
                while (vs[j].c<3 && p[vs[j].v[vs[j].c]]<0) vs[j].c++;
                if (vs[j].c<3) p[vs[j].v[vs[j].c]]++;
            }
            int m=-1;
            int mm;
            for (int j=0;j<k;++j)
            {
                if ((m==-1 || p[j]<m) && p[j]>=0)
                {
                    m=p[j];
                    mm=j;
                }
            }
            /*for (int j=0;j<k;++j)
            {
                cout<<j+1<<": "<<p[j]<<" ";
            }
            cout<<endl;*/
            //cout<<jj<<". Out: "<<mm+1<<" with "<<p[mm]<<" votes."<<endl;
            //getch();
            p[mm]=-1;
        }
        for (int j=0;j<k;++j)
        {
            if (p[j]>=0) p[j]=0;
        }
        for (int j=0;j<i;++j)
        {
            while (vs[j].c<3 && p[vs[j].v[vs[j].c]]<0) vs[j].c++;
            if (vs[j].c<3) p[vs[j].v[vs[j].c]]++;
        }
        for (int j=0;j<k;++j)
        {
            if (p[j]>=0)
            {
                cout<<"On "<<ii+1<<". place: "<<j+1<<" with "<<p[j]<<" votes."<<endl;
                p[j]=-2;
            }
        }
        getch();
    }
    return 0;
}
