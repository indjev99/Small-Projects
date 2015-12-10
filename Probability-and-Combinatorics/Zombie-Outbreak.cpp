/*
Each zombie has a 1/3 chance to infect nobody, 1/3 chance to infect one person,
and 1/3 chance to infect 2 people. Simulates a lot of outbreaks.
*/
#include<iostream>
#include<algorithm>
#include<vector>
#include<unordered_map>
#include<ctime>
#include<stdlib.h>
#include<conio.h>
using namespace std;
typedef unsigned long long ull;
ull infect()
{
    return rand()%3;
}
ull outbreak(ull start)
{
    ull total=0,alive=0,infecting=start;
    while (infecting!=0)
    {
        for (;infecting!=0;--infecting)
        {
            alive+=infect();
        }
        infecting=alive;
        total+=alive;
        alive=0;
    }
    return total;
}
vector<ull> outbreaks,modes;
int main()
{
    //Input:
    int seed,start,sims;
    cout<<"Seed: ";
    cin>>seed;
    cout<<"Number of simulations: ";
    cin>>sims;
    cout<<"Starting zombies: ";
    cin>>start;
    srand(seed);

    //Solution:
    ull infected;
    for (int i=0;i<sims;++i)
    {
        infected=outbreak(start); //Simulate one outbreak.
        outbreaks.push_back(infected); //Add the result to the outbreaks vector.
    }
    sort(outbreaks.begin(),outbreaks.end());
    ull PO=0;
    int POC=0;
    ull sum=0,modec=0,medianl,medianr,amean,amedian;
    double mean,median;

    //Output:
    for (int i=0;i<sims;i++)
    {
        if (outbreaks[i]!=PO || i==0)
        {
            if (i!=0)
            {
                cout<<PO<<": "<<POC<<"\n"; //Output the number of outbreaks (POC) that have infected PO people.
                sum+=PO*POC;
                if (POC>modec)
                {
                    modec=POC;
                    modes.resize(0);
                }
                if (POC==modec)
                {
                    modes.push_back(PO);
                }
            }
            PO=outbreaks[i];
            POC=1;
        }
        else ++POC;
    }
    cout<<"\n";
    if (modes.size()>1) cout<<"Modes: ";
    else cout<<"Mode: ";
    cout<<modes[0];
    for (int i=1;i<modes.size()-1;i++) cout<<", "<<modes[i];
    if (modes.size()>1) cout<<" and "<<modes[modes.size()-1];
    cout<<"\n";
    mean=sum/double(sims);
    amean=sum/sims;
    cout<<"Mean: "<<mean<<" or approximately "<<amean<<"\n";
    cout<<"Median: ";
    if (sims%2)
    {
        amedian=outbreaks[sims/2];
        cout<<amedian;
    }
    else
    {
        medianl=outbreaks[sims/2];
        medianr=outbreaks[sims/2+1];
        median=(medianl+medianr)/double(2);
        amedian=(medianl+medianr)/2;
        if (medianl==medianr) cout<<amedian;
        else cout<<"Mean of "<<medianl<<" and "<<medianr<<" is "<<median<<" or approximately "<<amedian;
    }
    cout<<endl;
    return 0;
}
