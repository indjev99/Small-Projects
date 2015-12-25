#include<iostream>
#include<stdlib.h>
#include<vector>
#include<ctime>
using namespace std;
vector<char> crash;
int main()
{
    string def="color 0a",base="color ",n,dark="color 02";
    string word[]={"MATRIX", "GROUND", "FIRE", "WATER", "RANDOM", "EXPLOSION", "AIR", "EARTH", "SUN", "MOON", "STAR", "HUMAN", "SEA",
     "OCEAN", "RIVER", "POND", "SOND", "LIGHT", "DARK", "CARD", "UNIVERSE", "GALAXY", "BAD", "GOOD", "EVIL"};
    int a,b=0,p=11,c,pp=10,p2=5000,d=0,dd=0,wp=1000,op=0,cc,s=1;
    system("color 0a");
    srand(time(NULL));
    while (1)
    {
        if (!dd) for (int i=0;i<d;i++);
        if (b>0) b--;
        if (s)
        {
            if (!(rand()%wp)) cout<<" "<<word[rand()%25]<<" ";
            cc=rand()%20;
            cc-=op;
            if (cc<0)
            {
                cout<<char(rand()%255);
            }
            else
            {
                c=rand()%20;
                c-=pp;
                if (c<0) cout<<1;
                else cout<<0;
                if (rand()%p) cout<<" ";
            }
            if (!b)
            {
                if (rand()%10) system(def.c_str());
                else system(dark.c_str());
                b--;
            }
        }
        else
        {
            cout<<'?';
            if (rand()%p) cout<<" ";
            if (!(rand()%10))
            {
                n="";
                a=rand()%16;
                if (a<10) n+='0'+a;
                else
                {
                    if (a==10) n+='a';
                    if (a==11) n+='b';
                    if (a==12) n+='c';
                    if (a==13) n+='d';
                    if (a==14) n+='e';
                    if (a==15) n+='f';
                }
                a=rand()%16;
                if (a<10) n+='0'+a;
                else
                {
                    if (a==10) n+='a';
                    if (a==11) n+='b';
                    if (a==12) n+='c';
                    if (a==13) n+='d';
                    if (a==14) n+='e';
                    if (a==15) n+='f';
                }
                system((base+n).c_str());
            }
            if (!rand()) while (1)
            {
                crash.push_back('?');
                if (!(rand()%100000000ll)) break;
            }
        }
        if (!(rand()%p2))
        {
            n="";
            a=rand()%16;
            if (a<10) n+='0'+a;
            else
            {
                if (a==10) n+='a';
                if (a==11) n+='b';
                if (a==12) n+='c';
                if (a==13) n+='d';
                if (a==14) n+='e';
                if (a==15) n+='f';
            }
            a=rand()%16;
            if (a<10) n+='0'+a;
            else
            {
                if (a==10) n+='a';
                if (a==11) n+='b';
                if (a==12) n+='c';
                if (a==13) n+='d';
                if (a==14) n+='e';
                if (a==15) n+='f';
            }
            if (rand()%7)system((base+n).c_str());
            b=10+rand()%21;
            p=1+rand()%20;
            pp=rand()%20;
            p2=2000+rand()%6000;
            dd=rand()%2;
            d=rand()%200000;
            wp=100+rand()%1900;
            op=rand()%5;
            s=rand()%50;
        }
    }
    return 0;
}
