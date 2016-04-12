#include<iostream>
#include<vector>
#include<stdlib.h>
#include<ctime>
using namespace std;
struct time_unit
{
    int c;
    string name;
};
void display_time(int seconds)
{
    int minutes,hours,days;
    time_unit time[4];
    minutes=seconds/60;
    seconds%=60;
    hours=minutes/60;
    minutes%=60;
    days=hours/24;
    hours%=24;
    time[0].c=days;
    time[0].name="day";
    time[1].c=hours;
    time[1].name="hour";
    time[2].c=minutes;
    time[2].name="minute";
    time[3].c=seconds;
    time[3].name="second";
    bool f=0;
    int l=4;
    for (int i=3;i>=0;i--)
    {
       if (time[i].c>0)
       {
           l=i;
           break;
       }
    }
    for (int i=0;i<=3;i++)
    {
       if (time[i].c>0 || (i==3 && f==0))
       {
           if (f==1)
           {
               if (l>i) cout<<", ";
               else cout<<" and ";
           }
           else f=1;
           cout<<time[i].c<<" "<<time[i].name;
           if (time[i].c!=1) cout<<'s';
       }
    }
    cout<<" left."<<endl;
}
int main()
{
    clock_t start,current;
    int second=-1,pr_second=-1,max_seconds,cc;
    vector<string> commands;
    string c_command;
    cout<<"Enter the time in seconds: ";
    cin>>max_seconds;
    cin.ignore();
    cout<<"Enter the number of system commands: ";
    cin>>cc;
    cin.ignore();
    for (int i=0;i<cc;i++)
    {
        cout<<"Enter system command "<<i<<": ";
        getline(cin,c_command);
        commands.push_back(c_command);
    }
    system("color 0c");
    start=clock();
    while (1)
    {
        current=clock()-start;
        second=(float)current/CLOCKS_PER_SEC;
        if (second!=pr_second)
        {
            pr_second=second;
            system("cls");
            display_time(max_seconds-second);
            if (max_seconds-second==0) break;
        }
    }
    system("color 07");
    system("cls");
    for (int i=0;i<cc;i++)
    {
        system(commands[i].c_str());
    }
    return 0;
}
