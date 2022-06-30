#include<iostream>
#include<vector>
#include<cstdlib>
#include<ctime>
#include<conio.h>
#include<math.h>
#include<windows.h>
using namespace std;
string m[6],c[6];
string MBD;
int w;
vector<string> vars[256];
vector<int> colours,scolours;
int cnt_small=0,cnt_mid=0,cnt_big=0,cnt_mega=0,cnt_white=0,cnt_light_gray=0,cnt_dark_gray=0,cnt_black=0,cnt_pink=0,cnt_yellow=0;
bool checkForSmallB(int p)
{
    for (int i=0;i<4;i++) if (m[0][p+i]!=' ') return 0;
    for (int i=0;i<4;i++) if (m[1][p+i]!=' ') return 0;
    for (int i=0;i<4;i++) if (m[2][p+i]!=' ') return 0;
    return 1;
}
bool checkForSmallBSpecial(int p)
{
    for (int i=1;i<3;i++) if (m[0][p+i]!=' ') return 0;
    for (int i=0;i<4;i++) if (m[1][p+i]!=' ') return 0;
    for (int i=0;i<4;i++) if (m[2][p+i]!=' ') return 0;
    return 1;
}
bool checkForMidB(int p)
{
    for (int i=0;i<5;i++) if (m[0][p+i]!=' ') return 0;
    for (int i=0;i<5;i++) if (m[1][p+i]!=' ') return 0;
    for (int i=0;i<5;i++) if (m[2][p+i]!=' ') return 0;
    return 1;
}
bool checkForMidBSpecial(int p)
{
    for (int i=1;i<4;i++) if (m[0][p+i]!=' ') return 0;
    for (int i=0;i<5;i++) if (m[1][p+i]!=' ') return 0;
    for (int i=0;i<5;i++) if (m[2][p+i]!=' ') return 0;
    return 1;
}
bool checkForBigB(int p)
{
    for (int i=1;i<5;i++) if (m[0][p+i]!=' ') return 0;
    for (int i=0;i<6;i++) if (m[1][p+i]!=' ') return 0;
    for (int i=0;i<6;i++) if (m[2][p+i]!=' ') return 0;
    return 1;
}
bool checkForMegaB(int p)
{
    for (int i=0;i<2;i++) if (m[0][p+i]!=' ') return 0;
    for (int i=4;i<6;i++) if (m[0][p+i]!=' ') return 0;
    for (int i=0;i<6;i++) if (m[1][p+i]!=' ') return 0;
    for (int i=0;i<6;i++) if (m[2][p+i]!=' ') return 0;
    for (int i=0;i<6;i++) if (m[3][p+i]!=' ') return 0;
    for (int i=0;i<6;i++) if (m[4][p+i]!=' ') return 0;
    for (int i=0;i<6;i++) if (m[5][p+i]!=' ') return 0;
    return 1;
}
void createSmallB(int p, char cc)
{
    for (int i=0;i<4;i++) {m[0][p+i]=1;c[0][p+i]=cc;}
    for (int i=0;i<4;i++) {m[1][p+i]=2;c[1][p+i]=cc;}
    for (int i=0;i<4;i++) {m[2][p+i]=3;c[2][p+i]=cc;}
}
void createSmallBSpecial(int p, char cc)
{
    for (int i=1;i<3;i++) {m[0][p+i]=101;c[0][p+i]=cc;}
    for (int i=0;i<4;i++) {m[1][p+i]=2;c[1][p+i]=cc;}
    for (int i=0;i<4;i++) {m[2][p+i]=3;c[2][p+i]=cc;}
}
void createMidB(int p, char cc)
{
    for (int i=0;i<5;i++) {m[0][p+i]=4;c[0][p+i]=cc;}
    for (int i=0;i<5;i++) {m[1][p+i]=5;c[1][p+i]=cc;}
    for (int i=0;i<5;i++) {m[2][p+i]=6;c[2][p+i]=cc;}
}
void createMidBSpecial(int p, char cc)
{
    for (int i=1;i<4;i++) {m[0][p+i]=104;c[0][p+i]=cc;}
    for (int i=0;i<5;i++) {m[1][p+i]=5;c[1][p+i]=cc;}
    for (int i=0;i<5;i++) {m[2][p+i]=6;c[2][p+i]=cc;}
}
void createBigB(int p, char cc)
{
    for (int i=1;i<5;i++) {m[0][p+i]=7;c[0][p+i]=cc;}
    for (int i=0;i<6;i++) {m[1][p+i]=8;c[1][p+i]=cc;}
    for (int i=0;i<6;i++) {m[2][p+i]=9;c[2][p+i]=cc;}
}
bool createMegaB(int p,char cc)
{
    for (int i=0;i<2;i++) {m[0][p+i]=10;c[0][p+i]=cc;}
    for (int i=4;i<6;i++) {m[0][p+i]=10;c[0][p+i]=cc;}
    for (int i=0;i<6;i++) {m[1][p+i]=11;c[1][p+i]=cc;}
    for (int i=0;i<6;i++) {m[2][p+i]=12;c[2][p+i]=cc;}
    for (int i=0;i<6;i++) {m[3][p+i]=13;c[3][p+i]=cc;}
    for (int i=0;i<6;i++) {m[4][p+i]=14;c[4][p+i]=cc;}
    for (int i=0;i<6;i++) {m[5][p+i]=15;c[5][p+i]=cc;}
    return 1;
}
bool createBunny(int p)
{
    int t=rand()%300;
    if (t<297) t%=3;
    else t=3;
    int cc;
    if (rand()%1000) cc=colours[rand()%colours.size()];
    else cc=scolours[rand()%scolours.size()];
    if (t==0)
    {
        if (checkForSmallB(p)==0)
        {
            if (rand()%vars[1].size()>=vars[101].size()) return 0;
            else
            {
                if (checkForSmallBSpecial(p)==0) return 0;
                createSmallBSpecial(p,cc);
            }
        }
        else createSmallB(p,cc);
        ++cnt_small;
    }
    else if (t==1)
    {
        if (checkForMidB(p)==0)
        {
            if (rand()%vars[4].size()>=vars[104].size()) return 0;
            else
            {
                if (checkForMidBSpecial(p)==0) return 0;
                createMidBSpecial(p,cc);
            }
        }
        else createMidB(p,cc);
        ++cnt_mid;
    }
    else if (t==2)
    {
        if (checkForBigB(p)==0) return 0;
        createBigB(p,cc);
        ++cnt_big;
    }
    else if (t==3)
    {
        if (checkForMegaB(p)==0) return 0;
        createMegaB(p,cc);
        ++cnt_mega;
    }
    if (cc==15+32-128) ++cnt_white;
    if (cc==7+32-128) ++cnt_light_gray;
    if (cc==8+32-128) ++cnt_dark_gray;
    if (cc==0+32-128) ++cnt_black;
    if (cc==13+32-128) ++cnt_pink;
    if (cc==14+32-128) ++cnt_yellow;
    return 1;
}
void fillRow()
{
    string repl;
    int var;
    for (int i=1;i<w-1;i++)
    {
        if (m[0][i]==' ') continue;
        var=rand()%vars[m[0][i]].size();
        if (m[0][i]==13) var=var/2*2+MBD[i];
        repl=vars[m[0][i]][var];
        for (int j=0;j<repl.size();j++) {m[0][i+j]=repl[j];MBD[i+j]=var%2;}
        i+=repl.size()-1;
    }
}
void genVars()
{
    vars[1].push_back("(\\/)");
    vars[1].push_back("(||)");
    vars[1].push_back("()()");
    vars[1].push_back("|\\/|");
    vars[1].push_back("|__|");
    vars[1].push_back("\\__/");
    vars[1].push_back(" \\/ ");
    vars[1].push_back(" ^^ ");
    vars[101].push_back("\\/");
    vars[101].push_back("^^");

    vars[2].push_back("('')");
    vars[2].push_back("(..)");
    vars[2].push_back("(**)");
    vars[2].push_back("(^^)");
    vars[2].push_back("(--)");
    vars[2].push_back("(oo)");
    vars[2].push_back("(OO)");
    vars[2].push_back("(00)");

    vars[3].push_back("()()");
    vars[3].push_back("{}{}");

    vars[4].push_back("(\\_/)");
    vars[4].push_back("()_()");
    vars[4].push_back("(|_|)");
    vars[4].push_back("|\\_/|");
    vars[4].push_back(" |_| ");
    vars[4].push_back(" ^_^ ");
    vars[104].push_back("|_|");
    vars[104].push_back("^_^");

    vars[5].push_back("('.')");
    vars[5].push_back("('+')");
    vars[5].push_back("('-')");
    vars[5].push_back("(*.*)");
    vars[5].push_back("(*+*)");
    vars[5].push_back("(*-*)");
    vars[5].push_back("(^.^)");
    vars[5].push_back("(^+^)");
    vars[5].push_back("(^-^)");
    vars[5].push_back("(-.-)");
    vars[5].push_back("(o.o)");
    vars[5].push_back("(O.O)");
    vars[5].push_back("(0.0)");

    vars[6].push_back("()-()");
    vars[6].push_back("{}-{}");

    vars[7].push_back("(\\/)");
    vars[7].push_back("(||)");
    vars[7].push_back("(\\(\\");
    vars[7].push_back("/)/)");
    vars[7].push_back("/)(\\");
    vars[7].push_back("()()");
    vars[7].push_back("|\\/|");
    vars[7].push_back("/\\/\\");
    vars[7].push_back("/||\\");
    vars[7].push_back("|__|");
    vars[7].push_back("\\__/");
    vars[7].push_back("/__\\");
    vars[7].push_back("_\\/_");
    vars[7].push_back("^__^");

    vars[8].push_back("('.'=)");
    vars[8].push_back("(='.')");
    vars[8].push_back("('+'=)");
    vars[8].push_back("(='+')");
    vars[8].push_back("('-'=)");
    vars[8].push_back("(='-')");
    vars[8].push_back("(*.*=)");
    vars[8].push_back("(=*.*)");
    vars[8].push_back("(*+*=)");
    vars[8].push_back("(=*+*)");
    vars[8].push_back("(*-*=)");
    vars[8].push_back("(=*-*)");
    vars[8].push_back("(^.^=)");
    vars[8].push_back("(=^.^)");
    vars[8].push_back("(^+^=)");
    vars[8].push_back("(=^+^)");
    vars[8].push_back("(^-^=)");
    vars[8].push_back("(=^-^)");
    vars[8].push_back("(-.-=)");
    vars[8].push_back("(=-.-)");
    vars[8].push_back("(o.o=)");
    vars[8].push_back("(=o.o)");
    vars[8].push_back("(O.O=)");
    vars[8].push_back("(=O.O)");
    vars[8].push_back("(0.0=)");
    vars[8].push_back("(=0.0)");

    vars[9].push_back("(\")(\")");
    vars[9].push_back("{\"}{\"}");
    vars[9].push_back("(_)(_)");
    vars[9].push_back("{_}{_}");

    vars[10].push_back("/\\");

    vars[11].push_back("\\\\\\///");

    vars[12].push_back("/ . .\\");
    vars[12].push_back("/. . \\");
    vars[12].push_back("/ ' '\\");
    vars[12].push_back("/' ' \\");
    vars[12].push_back("/ * *\\");
    vars[12].push_back("/* * \\");
    vars[12].push_back("/ o o\\");
    vars[12].push_back("/o o \\");
    vars[12].push_back("/ O O\\");
    vars[12].push_back("/O O \\");
    vars[12].push_back("/ 0 0\\");
    vars[12].push_back("/0 0 \\");

    vars[13].push_back("\\  ^ /");
    vars[13].push_back("\\ ^  /");
    vars[13].push_back("\\  - /");
    vars[13].push_back("\\ -  /");

    vars[14].push_back("/\"\\/\"\\");

    vars[15].push_back("\\_/\\_/");

    colours.push_back(0+32-128);
    colours.push_back(7+32-128);
    colours.push_back(8+32-128);
    colours.push_back(15+32-128);

    scolours.push_back(13+32-128);
    scolours.push_back(14+32-128);
}
int main()
{
    HANDLE hConsole=GetStdHandle(STD_OUTPUT_HANDLE);
    int s;
    int p,p_low,p_high;
    bool inc=1;
    char ch=' ';
    bool ca=0;
    cout<<"Enter width: ";
    cin>>w;
    cout<<"Enter seed: ";
    cin>>s;
    cout<<"Enter p_low: ";
    cin>>p_low;
    cout<<"Enter p_high: ";
    cin>>p_high;
    cout<<"Enter 1 if you want colours and 0 if you don't: ";
    cin>>ca;
    p=(p_low+p_high)/2;
    cout<<endl;
    srand(s);
    //srand(time(NULL));
    w+=2;
    string emp,cemp;
    emp.resize(w);
    cemp.resize(w);
    MBD.resize(w);
    bool mc=0;
    for (int i=1;i<w;i++)
    {
        emp[i]=' ';
        cemp[i]=2+32-128;
    }
    emp[0]=0;
    emp[w-1]=0;
    cemp[0]=2+32-128;
    cemp[w-1]=2+32-128;
    for (int i=0;i<5;i++)
    {
        m[i]=emp;
        c[i]=cemp;
    }
    genVars();
    while(m[0][1]!=0)
    {
        if (rand()%int(sqrt(p_low*p_low+p_high*p_high-p*p)))
        {
            if (inc) p++;
            else p--;
            if (p==p_high || p==p_low) inc=!inc;
            if (p>p_high) p=p_high;
            if (p<p_low) p=p_low;
        }
        m[5]=emp;
        c[5]=cemp;
        if (kbhit())
        {
            ch=getch();
            if (ch=='e' || ch=='E')
            {
                for (int i=1;i<w-1;i++)
                {
                    m[5][i]=0;
                }
            }
            if (ch=='p' || ch=='P')
            {
                ch=' ';
                while (ch!='p' && ch!='P')
                {
                    ch=getch();
                }
            }
        }
        for (int i=1;i<w-1;i++)
        {
            if (mc) mc=!createBunny(i);
            else if (rand()%p==0)  mc=!createBunny(i);
        }
        fillRow();
        if(ca==0)
        {
            cout<<m[0].substr(1,w-2);
            cout<<'\n';
        }
        else
        {
            for (int i=1;i<w-1;i++)
            {
                SetConsoleTextAttribute(hConsole,c[0][i]+128);
                cout<<m[0][i];
            }
            cout<<'\n';
        }
        for (int i=0;i<5;i++)
        {
            m[i]=m[i+1];
            c[i]=c[i+1];
        }
    }
    SetConsoleTextAttribute(hConsole,15);
    getch();
    cout<<"\n\nSmall: "<<cnt_white<<"\nMid: "<<cnt_light_gray<<"\nBig: "<<cnt_dark_gray<<"\nMega: "<<cnt_mega;
    cout<<"\nWhite: "<<cnt_white<<"\nLight Gray: "<<cnt_light_gray<<"\nDark Gray: "<<cnt_dark_gray<<"\nBlack: "<<cnt_black<<"\nPink: "<<cnt_pink<<"\nYellow: "<<cnt_yellow<<'\n';
    getch();
    return 0;
}
