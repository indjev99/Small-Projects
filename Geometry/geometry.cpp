#include<iostream>
#include<conio.h>
#include<stdio.h>
#include<map>
using namespace std;
double toDouble(string n)
{
    double a=0,k=1;
    int i=0,m=1;
    if (n[0]=='-') {m=-1;i++;}
    if (n[0]=='+') i++;
    while (i<n.size() && n[i]!='.')
    {
        a*=10;
        a+=(n[i]-'0')*m;
        i++;
    }
    i++;
    while (i<n.size())
    {
        k/=10;
        a+=(double)(n[i]-'0')*k*m;
        i++;
    }
    return a;
}
class point
{
    public:
    double x,y;
    void add();
};
class line
{
    public:
    double a,b;
    bool v;
    void add();
    point crossing(line other);
};
map<string,point> points;
map<string,line> lines;
point find_point();
line find_line();
void point::add()
{
    char c1;
    string c;
    cin>>c1;
    if (c1=='(')
    {
        //cout<<c1;
        getline(cin,c,';');
        x=toDouble(c);
        getline(cin,c,')');
        y=toDouble(c);
    }
    else
    {
        string c2;
        cin>>c2;
        c="";
        c+=c1;
        c+=c2;
        if (c=="from_crossing")
        {
            line l1,l2;
            l1=find_line();
            l2=find_line();
            point n=l1.crossing(l2);
            x=n.x;
            y=n.y;
        }
        else {x=points[c].x;y=points[c].y;}
    }
}
void line::add()
{
    string c;
    cin>>c;
    if (c=="from_equation")
    {
        cin>>c;
        if (c=="undefined") {a=0;v=1;}
        else
        {
            a=toDouble(c);
            v=0;
        }
        cin>>b;
    }
    else if (c=="from_points")
    {
        point p1,p2;
        p1=find_point();
        p2=find_point();
        if (p1.x==p2.x) {a=0;b=p1.x;v=1;}
        else
        {
            a=(p1.y-p2.y)/(p1.x-p2.x);
            b=p1.y-p1.x*a;
            v=0;
        }
    }
    else {a=lines[c].a;b=lines[c].b;v=lines[c].v;}
}
point line::crossing(line other)
{
    point x;
    if (a==other.a) if (b==other.b) cout<<"The lines macth."<<endl;
                    else cout<<"The lines are parallel."<<endl;
    else
    {
        if (v)
        {
            x.x=b;
            x.y=x.x*other.a+other.b;
        }
        else if (other.v)
        {
            x.x=other.b;
            x.y=x.x*a+b;
        }
        else
        {
            x.x=(b-other.b)/(other.a-a);
            x.y=x.x*a+b;
        }

    }
    return x;
}
point find_point()
{
    string c;
    cin>>c;
    if (c=="new")
    {
        cin>>c;
        points[c].add();
    }
    return points[c];
}
line find_line()
{
    string c;
    cin>>c;
    if (c=="new")
    {
        cin>>c;
        lines[c].add();
        return lines[c];
    }
    else return lines[c];
}
int main()
{
    string c;
    cin>>c;
    while (c!="exit")
    {
        if (c=="new")
        {
            cin>>c;
            if (c=="point")
            {
                cin>>c;
                points[c].add();
            }
            else if (c=="line")
            {
                cin>>c;
                lines[c].add();
            }
            else cout<<"INVALID COMMAND!!!"<<endl;
        }
        else if (c=="print")
        {
            cin>>c;
            if (c=="point")
            {
                point x=find_point();
                cout<<x.x<<" "<<x.y<<endl;
            }
            else if (c=="line")
            {
                line a=find_line();
                if (a.v==1) cout<<"undefined ";
                else cout<<a.a<<" ";
                cout<<a.b<<endl;
            }
            else cout<<"INVALID COMMAND!!!"<<endl;
        }
        else cout<<"INVALID COMMAND!!!"<<endl;
        cin>>c;
    }
    return 0;
}
