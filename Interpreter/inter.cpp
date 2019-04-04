#include<iostream>
#include<string>
#include<queue>
#include<stack>
#include<vector>
#include<map>
#include<fstream>
#include<conio.h>
using namespace std;
long long quick_power(long long a, long long p)
{
    long long a2;
    if (p==2) return a*a;
    if (p==1) return a;
    if (p%2==0) {a2=quick_power(a,p/2);return a2*a2;}
    if (p%2==1) return a*quick_power(a,p-1);
    return 1;
}
int main()
{
    string command;
    long long number,number2,size,size2,j,o;
    int p;
    char operation,end,p_command;
    stack<long long> calc;
    queue<char> help2;
    stack<char> help;
    map<char, int> priority;
    map<string, long long> vars;
    vector<char> name2;
    char nl;
    string name,name3,program;
    priority['&']=1;
    priority['|']=1;
    priority['<']=2;
    priority['>']=2;
    priority[',']=2;
    priority['@']=2;
    priority['$']=2;
    priority['!']=2;
    priority['-']=3;
    priority['+']=3;
    priority['~']=4;
    priority['#']=4;
    priority['\'']=4;
    priority['*']=5;
    priority['/']=5;
    priority['%']=5;
    priority['^']=6;
    priority['?']=7;
    priority['(']=0;
    priority[')']=0;
    priority['[']=0;
    priority[']']=0;
    priority[';']=0;
    cout<<"Enter the name of the program."<<endl;
    getline(cin,program);
    cout<<endl;
    ifstream read(program);
    if (!read)
    {
             cout<<"This program doesn't exist."<<endl;
             cout<<"Press any key to continue"<<endl;
             end=getch();
             return 0;
    }
    while (!calc.empty()) calc.pop();
    while (!help2.empty()) help2.pop();
    while (!help.empty()) help.pop();
    while (!name2.empty()) name2.pop_back();
    getline(read,command);
    while (command!="exit;")
    {
        size=command.size();
        if (size==0) continue;
        if (size>5 && command[0]=='p' && command[1]=='a' && command[2]=='u' && command[3]=='s' && command[4]=='e' && command[5]==';')
        {
            cout<<"Press any key to continue."<<endl;
            end=getch();
        }
        else if (size>10 && command[0]=='p' && command[1]=='r' && command[2]=='i' && command[3]=='n' && command[4]=='t' && command[5]=='_' && command[6]=='v' && command[7]=='a' && command[8]=='r' && command[9]==' ')
        {
            j=10;
            while (command[j]!=';')
            {
                name2.push_back(command[j]);
                j++;
            }
            j-=10;
            name.resize(j);
            for (int i=0;i<j;i++)
            {
                name[i]=name2[i];
            }
            cout<<vars[name];
        }
        else if (size>12 && command[0]=='p' && command[1]=='r' && command[2]=='i' && command[3]=='n' && command[4]=='t' && command[5]=='_' && command[6]=='t' && command[7]=='e' && command[8]=='x' && command[9]=='t' && command[10]==' ' && command[11]=='\"')
        {
            j=12;
            long long slash=0;
            while (command[j]!='"')
            {
                if (command[j]=='\\')
                {
                    if (command[j+1]=='\"') name2.push_back('\"');
                    if (command[j+1]=='n') name2.push_back('\n');
                    j+=2;
                    slash++;
                }
                else
                {
                    name2.push_back(command[j]);
                    j++;
                }
            }
            j-=12+slash;
            name.resize(j);
            for (int i=0;i<j;i++)
            {
                name[i]=name2[i];
            }
            cout<<name;
        }
        else if (size>11 && command[0]=='p' && command[1]=='r' && command[2]=='i' && command[3]=='n' && command[4]=='t' && command[5]=='_' && command[6]=='c' && command[7]=='h' && command[8]=='a' && command[9]=='r' && command[10]==' ')
        {
            j=11;
            while (command[j]!=';')
            {
                name2.push_back(command[j]);
                j++;
            }
            j-=11;
            name.resize(j);
            for (int i=0;i<j;i++)
            {
                name[i]=name2[i];
            }
            if (vars[name]) cout<<(char)vars[name];
        }
        else if (size>10 && command[0]=='p' && command[1]=='r' && command[2]=='i' && command[3]=='n' && command[4]=='t' && command[5]=='_' && command[6]=='e' && command[7]=='n' && command[8]=='d' && command[9]=='l' && command[10]==';')
        {
            cout<<"\n";
        }
        else if (size>5 && command[0]=='s' && command[1]=='c' && command[2]=='a' && command[3]=='n' && command[4]==' ')
        {
            j=5;
            while (command[j]!=';')
            {
                name2.push_back(command[j]);
                j++;
            }
            j-=5;
            name.resize(j);
            for (int i=0;i<j;i++)
            {
                name[i]=name2[i];
            }
            cin>>number;
            vars[name]=number;
        }
        else
        {
            j=0;
            while (command[j]!='=')
            {
                name2.push_back(command[j]);
                j++;
            }
            name.resize(j);
            for (long long i=0;i<j;i++)
            {
                name[i]=name2[i];
            }
            j++;
            p_command='(';
            for (long long i=j;i<size;)
            {
                if (command[i]==' ') {i++;continue;}
                if (command[i]=='<' && command[i+1]=='=') {command[i]=',';command[i+1]=' ';}
                else if (command[i]=='>' && command[i+1]=='=') {command[i]='@';command[i+1]=' ';}
                else if (command[i]=='=' && command[i+1]=='=') {command[i]='$';command[i+1]=' ';}
                else if (command[i]=='!' && command[i+1]=='=') {command[i]='!';command[i+1]=' ';}
                else if (command[i]=='!' && command[i+1]!='=') command[i]='?';
                else if (command[i]=='&' && command[i+1]=='&') command[i]=' ';
                else if (command[i]=='|' && command[i+1]=='|') command[i]=' ';
                else if (command[i]=='[') help.push('\'');
                else if (command[i]=='-' && (i==j || p_command=='(' || p_command=='[')) command[i]='~';
                else if (command[i]=='+' && (i==j || p_command=='(' || p_command=='[')) command[i]='#';
                if (command[i]==' ') {i++;continue;}
                p_command=command[i];
                if (command[i]>='0' && command[i]<='9')
                {
                    number=0;
                    while (((command[i]>='0' && command[i]<='9') || command[i]==' ') && i<size)
                    {
                        if (command[i]!=' ')
                        {
                            number=number*10+command[i]-'0';
                        }
                        i++;
                    }
                    calc.push(number);
                }
                else
                {
                    if (command[i]!='(' && command[i]!=')' && command[i]!='[' && command[i]!=']' && (command[i]<'a' || command[i]>'z') && (command[i]<'A' || command[i]>'Z'))
                    {
                        p=priority[command[i]];
                        while (!help.empty() && priority[help.top()]>=p)
                        {
                            help2.push(help.top());
                            help.pop();
                        }
                        help.push(command[i]);
                    }
                    else if (command[i]=='(') help.push(command[i]);
                    else if (command[i]==')')
                    {
                        while (help.top()!='(')
                        {
                            help2.push(help.top());
                            help.pop();
                        }
                        help.pop();
                    }
                    else if (command[i]=='[') help.push(command[i]);
                    else if (command[i]==']')
                    {
                        while (help.top()!='[')
                        {
                            help2.push(help.top());
                            help.pop();
                        }
                        help.pop();
                    }
                    else if ((command[i]>='a' && command[i]<='z') || (command[i]>='A' && command[i]<='Z'))
                    {
                        while (!name2.empty()) name2.pop_back();
                        o=i;
                        while (o<size && ((command[o]>='a' && command[o]<='z') || (command[o]>='A' && command[o]<='Z') || (command[o]>='0' && command[o]<='9')))
                        {
                            name2.push_back(command[o]);
                            o++;
                        }
                        o=o-i;
                        name3.resize(o);
                        for (int ij=0;ij<o;ij++)
                        {
                            name3[ij]=name2[ij];
                        }
                        calc.push(vars[name3]);
                        i+=o-1;
                    }
                    while (!help2.empty() && help2.front()!=';')
                    {
                        operation=help2.front();
                        help2.pop();
                        if (operation=='&')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            if (number2*number) number2=1;
                            else number2=0;
                        }
                        if (operation=='|')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            if (number2+number) number2=1;
                            else number2=0;
                        }
                        if (operation=='<')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            if (number2<number) number2=1;
                            else number2=0;
                        }
                        if (operation=='>')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            if (number2>number) number2=1;
                            else number2=0;
                        }
                        if (operation==',')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            if (number2<=number) number2=1;
                            else number2=0;
                        }
                        if (operation=='@')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            if (number2>=number) number2=1;
                            else number2=0;
                        }
                        if (operation=='$')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            if (number2==number) number2=1;
                            else number2=0;
                        }
                        if (operation=='!')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            if (number2!=number) number2=1;
                            else number2=0;
                        }
                        if (operation=='+')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            number2+=number;
                        }
                        if (operation=='-')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            number2-=number;
                        }
                        if (operation=='~')
                        {
                            number2=calc.top();
                            calc.pop();
                            number2=-number2;
                        }
                        if (operation=='#')
                        {
                            number2=calc.top();
                            calc.pop();
                            number2=number2;
                        }
                        if (operation=='\'')
                        {
                            number2=calc.top();
                            calc.pop();
                            if (number2<0) number2=-number2;
                            else number2=number2;
                        }
                        if (operation=='*')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            number2*=number;
                        }
                        if (operation=='/')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            number2/=number;
                        }
                        if (operation=='%')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            number2%=number;
                        }
                        if (operation=='^')
                        {
                            number=calc.top();
                            calc.pop();
                            number2=calc.top();
                            calc.pop();
                            number2=quick_power(number2,number);
                        }
                        if (operation=='?')
                        {
                            number2=calc.top();
                            calc.pop();
                            if (!number2) number2=1;
                            else number2=0;
                        }
                        calc.push(number2);
                    }
                    i++;
                }
            }
            vars[name]=calc.top();
        }
        while (!calc.empty()) calc.pop();
        while (!help2.empty()) help2.pop();
        while (!help.empty()) help.pop();
        while (!name2.empty()) name2.pop_back();
        getline(read,command);
    }
    return 0;
}
