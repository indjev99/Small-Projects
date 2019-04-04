#include<iostream>
#include<stdlib.h>
#include<string>
using namespace std;
int main ()
{
    cout<<"Enter a verb in the first person singular present simple."<<endl<<endl;
    system ("color b5");
    string d;
    long long a;
    bool f=0;
    while (true)
    {
        getline(cin,d);
        a=d.size();
        if(d=="can" || d=="must" || d=="would" || d=="shall" || d=="may" || d=="might" || d=="could" || d=="will") cout<<"The verb in third person singular present simple is: "<<d<<endl;
        else
        {
            if (d=="am" || d=="be") cout<<"The verb in third person singular present simple is: "<<"is"<<endl;
            else if (d=="have") cout<<"The verb in third person singular present simple is: "<<"has"<<endl;
            else
            {
                if ((d[a-2]=='s')||(d[a-2]=='S'))
                {
                    if ((d[a-1]=='s')||(d[a-1]=='S')) {cout<<"The verb in third person singular present simple is: "<<d<<"es"<<endl;f=1;}
                    if ((d[a-1]=='h')||(d[a-1]=='H')) {cout<<"The verb in third person singular present simple is: "<<d<<"es"<<endl;f=1;}
                }
                if ((d[a-2]=='c')||(d[a-2]=='C'))
                {
                    if ((d[a-1]=='h')||(d[a-1]=='H')) {cout<<"The verb in third person singular present simple is: "<<d<<"es"<<endl;f=1;}
                }
                if ((d[a-1]=='x')||(d[a-1]=='o')||(d[a-1]=='X')||(d[a-1]=='O')) {cout<<"The verb in third person singular present simple is: "<<d<<"es"<<endl;f=1;}
                if ((d[a-2]!='a')&&(d[a-2]!='e')&&(d[a-2]!='i')&&(d[a-2]!='o')&&(d[a-2]!='u')&&(d[a-2]!='A')&&(d[a-2]!='E')&&(d[a-2]!='I')&&(d[a-2]!='O')&&(d[a-2]!='U')&&((d[a-1]=='y')||(d[a-1]=='Y'))) {d[a-1]='i';cout<<"The verb in third person singular present simple is:\n"<<d<<"es"<<endl;f=1;}
                if (f==0) cout<<"The verb in third person singular present simple is: "<<d<<"s"<<endl;
            }
        }
        cout<<endl;
    }
    return 0;
}

