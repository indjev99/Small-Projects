#include<iostream>
#include<string>
#include<conio.h>
#include<fstream>
#include<time.h>
#include<stdlib.h>
using namespace std;
bool flag=0,fag=0,esc=0;
bool ha=0;
int col=0;
void hack ();
void demo ();
void com ();
void man ();
void exit ();
bool right(string s)
{
    int n=s.size();
    if (s!="hack")
    {
        for (int i=0; i<n; i++)
        {
            if ((s[i]<'0')||(s[i]>'9'))
            {
                if (((s[i]!='r')&&(s[i]!='m'))&&((s[i]!='-')||(i!=0))&& s[i]!='\n') return 0;
            }
        }
    }
    return 1;
}
void little();
int main()
{
    string he;
    string q;
    int i0=0;
    ifstream read("master.txt");
    if (read)
    {
        read>>q;
        if (q=="1_master_on_key_1") ha=1;
    }
    else
    {
        ofstream write("master.txt");
        write<<"0_master_off"<<endl;
    }
    int br1=0;
    srand(time(NULL));
    system ("cls");
    ifstream rea("help.txt");
    if (rea)
    {
        rea>>he;
        if (he=="Yes!1")
        {
            fag=1;
            flag=1;
            system ("color 0f");
        }
        else if (he=="Yes!2")
        {
            fag=1;
            flag=1;
            system ("color 9f");
        }
        else if (he=="Yes!3")
        {
            fag=1;
            flag=1;
            system ("color cf");
        }
        else if (he=="Yes!4")
        {
            fag=1;
            flag=1;
            system ("color e0");
        }
        else if (he=="Yes!5")
        {
            fag=1;
            flag=1;
            system ("color a0");
        }
        else if (he=="Yes!6" && ha==1)
        {
            fag=1;
            flag=1;
            system ("color f1");
        }
        else if (he=="Yes!7" && ha==1)
        {
            fag=1;
            flag=1;
            system ("color d1");
        }
        else if (he=="Yes!8")
        {
            fag=1;
            flag=1;
            system ("color f0");
        }
        else if (he[0]=='Y' && he[1]=='e' && he[2]=='s' && he[3]=='!')
        {
            fag=1;
            flag=1;
            cout<<"Nevaliden cvqt."<<endl;
        }
        ofstream writ("help.txt");
        writ<<"No!"<<endl;
    }
    else
    {
        ofstream writ("help.txt");
        writ<<"No!"<<endl;
    }
    if (fag==0)
    {
        cout<<"Napraveno ot Emil Indjev."<<endl;
        fag=1;
    }
    if (flag==0)
    {
        flag=1;
        string j;
        cout<<"Ako iskaskate fona da e cheren natisnete 1, za sin fon natisnete 2,\nza cherven fon natisnete 3, za jylt fon natisnete 4, za zelen fon natisnete 5.";
        if (ha==0)
        {
            cout<<endl;
            for (;;)
            {
                j=getch();
                if ((j!="1")&&(j!="2")&&(j!="3")&&(j!="4")&&(j!="5"))
                {
                    if (j!="") cout<<"Vyveli ste greshen simvol."<<endl;
                    else cout<<"Ne ste vyveli nishto."<<endl;
                    br1++;
                    if (br1>2000)
                    {
                        system ("color f0");
                        cout<<"BUG"<<endl;
                        col=8;
                        system ("pause");
                        return 0;
                        break;
                    }
                }
                else
                {
                    if (j=="1")
                    {
                        system ("color 0f");
                        col=1;
                        break;
                    }
                    else
                    {
                        if (j=="2")
                        {
                            system ("color 9f");
                            col=2;
                            break;
                        }
                        else
                        {
                            if (j=="3")
                            {
                                system ("color cf");
                                col=3;
                                break;
                            }
                            else
                            {
                                if (j=="4")
                                {
                                    system ("color e0");
                                    col=4;
                                    break;
                                }
                                else
                                {
                                    if (j=="5")
                                    {
                                        system ("color a0");
                                        col=5;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        else
        {
            cout<<endl<<"Ako iskaskate fona da e bql natisnete 6, za lilav fon natisnete 7"<<endl;
            {
                for (;;)
                {
                    j=getch();
                    if ((j!="1")&&(j!="2")&&(j!="3")&&(j!="4")&&(j!="5")&&(j!="6")&&(j!="7"))
                    {
                        cout<<"Vyveli ste greshen simvol."<<endl;
                        br1++;
                        if (br1>2000)
                        {
                            system ("color f0");
                            cout<<"BUG"<<endl;
                            col=8;
                            system ("pause");
                            return 0;
                        }
                    }
                    else
                    {
                        if (j=="1")
                        {
                            system ("color 0f");
                            col=1;
                            break;
                        }
                        else
                        {
                            if (j=="2")
                            {
                                system ("color 9f");
                                col=2;
                                break;
                            }
                            else
                            {
                                if (j=="3")
                                {
                                    system ("color cf");
                                    col=3;
                                    break;
                                }
                                else
                                {
                                    if (j=="4")
                                    {
                                        system ("color e0");
                                        col=4;
                                        break;
                                    }
                                    else
                                    {
                                        if (j=="5")
                                        {
                                            system ("color a0");
                                            col=5;
                                            break;
                                        }
                                        else if (j=="6")
                                        {
                                            system ("color f1");
                                            col=6;
                                            break;
                                        }
                                        else if (j=="7")
                                        {
                                            system ("color d1");
                                            col=7;
                                            break;
                                        };
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    for (;;)
    {
        system ("cls");
        string m="0";
        cout<<"Ako iskate kompiutyryt da poznava vasheto chislo natisnete 1,\na ako iskate vie da poznavate chisloto na kompiutyra natisnete 2."<<endl;
        if (ha==1) cout<<"Za malko poznavane natisnete 3"<<endl;
        cout<<"Za demonstraciq natisnete D."<<endl<<"Za smqna na cveta natisnete C."<<endl<<"Za izkliuchvane na programata natisnete 0."<<endl;
        m=getch();
        if (m=="1")
        {
            com();
        }
        else if (m=="2")
        {
            man();
        }
        else if (m=="3" && ha==1)
        {
            little();
        }
        else if (m=="D" || m=="d")
        {
            demo();
        }
        else if (m=="C" || m=="c")
        {
            flag=0;
            system ("color 07");
            main();
            break;
        }
        else if (m=="0")
        {
            exit();
            break;
        }
        else
        {
            if (m!="" )cout<<"Vyveli ste greshen simvol."<<endl;
            else cout<<"Ne ste vyveli nishto."<<endl;
            br1++;
            if (br1>2000)
            {
                system ("color f0");
                cout<<"BUG"<<endl;
                col=8;
                system ("pause");
                break;
            }
        }
    }
    return 0;
}
void com()
{
    esc=0;
    system("cls");
    int br1=0;
    int x=256,y=128,p,f=1,f2=1;
    string z;
    cout<<"Namislete si chislo ot 0 do 512.Ako e po-golqmo ot pokazanoto natisnete +,\na ako e po-malko natisnete -."<<endl<<"Ako go poznaq natisnete =."<<endl<<"Shte go poznaq ot maximum 10 pyti."<<endl<<"Za restart natisnete r."<<endl<<"Za menu natisnete m."<<endl<<endl;
    for (;;)
    {
        cout<<"Chisloto "<<x<<" li e?"<<endl;
        z=getch();
        if ((z!="+")&&(z!="-")&&(z!="=")&&(z!="r")&&(z!="m"))
        {
            cout<<"Vyveli ste greshen simvol."<<endl;
            br1++;
            if (br1>2000)
            {
                system ("color f0");
                cout<<"BUG"<<endl;
                col=8;
                esc=1;
                system ("pause");
                break;
            }
        }
        else
        {
            if (z=="=")
            {
                cout<<z<<endl;
                break;
            }
            else
            {
                if (z=="-")
                {
                    x=x-y;
                    cout<<z<<endl;
                }
                else
                {
                    if (z=="+")
                    {
                        x=x+y;
                        cout<<z<<endl;
                    }
                    else
                    {
                        if (z=="r")
                        {
                            com();
                            break;
                        }
                        else
                        {
                            if (z=="m")
                            {
                                esc=1;
                                break;
                            }
                        }
                    }
                }
            }
            y=y/2;
        }
        if ((p==x)&&(x==511)&&(z=="+")) x=512;
        if ((p==x)&&(x==1)&&(z=="-")) x=0;
        if (p==x)
        {
            cout<<"Tova e nevyzmojno."<<endl;
            f=0;
            break;
        }
        if (y==0)  p=x;
    }
    if (esc==0)
    {
        if (f==1) cout<<"Gotovo!"<<endl;
        cout<<"Ako iskate da igraete pak natisnete 1 ako ne natisnete 0."<<endl;
        string k;
        for (;;)
        {
            k=getch();
            if ((k!="1")&&(k!="0")&&(k!="5"))
            {
                if (k!="" )cout<<"Vyveli ste greshen simvol."<<endl;
                else cout<<"Ne ste vyveli nishto."<<endl;
                br1++;
                if (br1>2000)
                {
                    system ("color f0");
                    cout<<"BUG"<<endl;
                    col=8;
                    system ("pause");
                    break;
                }
            }
            if (k=="1")
            {
                com();
                break;
            }
            else if (k=="0") break;
            else if (k=="5")
            {
                k=getch();
                if (k=="1")
                {
                    k=getch();
                    if (k=="2")
                    {
                        ofstream write("master.txt");
                        ha=1;
                        write<<"1_master_on_key_1"<<endl;
                        system ("cls");
                        hack();
                        com();
                        break;
                    }
                }
            }
        }
        if (ha==1) hack();
    }
}
void man()
{
    esc=0;
    system("cls");
    int br1=0;
    cout<<"Shte si namislq chislo ot 0 do 512.Vie trqbva da se opitate da go poznaete.\nAko e po-golqmo ot tova koeto ste napisali shte napisha +,\na ako e po-malko shte napisha -."<<endl<<"Ako go poznaete shte napisha =."<<endl<<"Shte trqbva da go poznaete ot maximum 10 pyti."<<endl<<"Za restart napishete r."<<endl<<"Za menu napishete m."<<endl<<endl;
    int a;
    a=0+rand()%513;
    string s;
    getline(cin,s);
    bool f=1;
    int i=0;
    while (f==1)
    {
        if (s=="r")
        {
            man();
            break;
        }
        else
        {
            if (s=="m")
            {
                esc=1;
                break;
            }
            else
            {
                if (s=="hack")
                {
                    if (ha==1) i-=100000;
                    else cout<<"Triabva ti master control."<<endl;
                }
            }
        }
        while(!right(s) || s=="")
        {
            if (s!="" )cout<<"Vyveli ste greshen simvol."<<endl;
            else cout<<"Ne ste vyveli nishto."<<endl;
            getline(cin,s);
            br1++;
            if (br1>2000)
            {
                system ("color f0");
                cout<<"BUG"<<endl;
                col=8;
                f=0;
                esc=1;
                system ("pause");
                break;
            }
        }
        if (f==0) break;
        int ch=0;
        int n=s.size();
        for(int j=0; j<n; j++)
        {
            ch*=10;
            ch+=s[j]-'0';
        }
        if (i>9)
        {
            cout<<"Previshihte 10 opitita."<<"Chisloto mi e "<<a<<"."<<endl;
            break;
        }
        if ((s!="hack")&&((ch>512)||(ch<0)))
        {
            cout<<"Vyveli ste greshno chislo."<<endl;
            getline(cin,s);
            br1++;
            if (br1>2000)
            {
                system ("color f0");
                cout<<"BUG"<<endl;
                col=8;
                esc=1;
                system ("pause");
                break;
            }
        }
        else
        {
            if (ch<a)
            {
                cout<<"+"<<endl;
                getline(cin,s);
            }
            if (ch>a)
            {
                if (s!="hack") cout<<"-"<<endl;
                getline(cin,s);
            }
            if (ch==a)
            {
                cout<<"="<<endl;
                f=0;
            }
            i++;
        }
    }
    if (esc==0)
    {
        cout<<"Ako iskate da igraete pak natisnete 1 ako ne natisnete 0."<<endl;
        string k;
        for (;;)
        {
            k=getch();
            if ((k!="1")&&(k!="0")&&(k!="5"))
            {
                if (k!="" )cout<<"Vyveli ste greshen simvol."<<endl;
                else cout<<"Ne ste vyveli nishto."<<endl;
                br1++;
                if (br1>2000)
                {
                    system ("color f0");
                    cout<<"BUG"<<endl;
                    col=8;
                    system ("pause");
                    break;
                }
            }
            if (k=="1")
            {
                system ("cls");
                man();
            }
            if (k=="0") break;
            if (k=="5")
            {
                k=getch();
                if (k=="1")
                {
                    k=getch();
                    if (k=="2")
                    {
                        ofstream write("master.txt");
                        ha=1;
                        write<<"1_master_on_key_1"<<endl;
                        hack();
                        man();
                        break;
                    }
                }
            }
        }
        if (ha==1) hack();
    }
}
void little()
{
    esc=0;
    int br1=0;
    system ("cls");
    cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
    int s=0,c,cc,c1,c2=1,c3,p0,p,p1;
    char a;
    srand(time(NULL));
    c=1+rand()%10;
    c1=1+rand()%10;
    c3=10+rand()%10-c1;
    while (c2%c!=0)
    {
        c2=0+rand()%31;
    }
    cc=c;
    p0=0+rand()%2;
    p=0+rand()%2;
    p1=0+rand()%2;
    while (1)
    {
        if (p0)
        {
            cout<<"Namislete si chetno chislo."<<endl;
            a=getch();
            if (a=='m')
            {
                esc=1;
                break;
            }
            if (a=='r')
            {
                little();
                break;
            }
            system ("cls");
            cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
            cc*=2;
            cout<<"Pyrvo go razdelete na 2."<<endl;
            a=getch();
            if (a=='m')
            {
                esc=1;
                break;
            }
            if (a=='r')
            {
                little();
                break;
            }
            system ("cls");
            cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
        }
        else
        {
            cout<<"Namislete si chislo."<<endl;
            a=getch();
            a=getch();
            if (a=='m')
            {
                esc=1;
                break;
            }
            if (a=='r')
            {
                little();
                break;
            }
            system ("cls");
            cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
        }
        if (p)
        {
            cout<<"Pribavete mu "<<c1<<"."<<endl;
            s+=c1;
            a=getch();
            if (a=='m')
            {
                esc=1;
                break;
            }
            if (a=='r')
            {
                little();
                break;
            }
            system ("cls");
            cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
            cout<<"Sega umnojete poluchenoto po "<<cc<<"."<<endl;
        }
        else cout<<"Umnojete go po "<<cc<<"."<<endl;
        s*=cc;
        a=getch();
        if (a=='m')
        {
            esc=1;
            break;
        }
        if (a=='r')
        {
            little();
            break;
        }
        system ("cls");
        cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
        if (c2)
        {
            cout<<"Pribavete mu "<<c2<<"."<<endl;
            s+=c2;
            a=getch();
            if (a=='m')
            {
                esc=1;
                break;
            }
            if (a=='r')
            {
                little();
                break;
            }
            system ("cls");
            cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
        }
        if (c!=1)
        {
            cout<<"Sega go razdelete na "<<c<<"."<<endl;
            s/=c;
            a=getch();
            if (a=='m')
            {
                esc=1;
                break;
            }
            if (a=='r')
            {
                little();
                break;
            }
            system ("cls");
            cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
        }
        if (p1)
        {
            cout<<"Izvadete "<<c3<<"."<<endl;
            s-=c3;
            a=getch();
            if (a=='m')
            {
                esc=1;
                break;
            }
            if (a=='r')
            {
                little();
                break;
            }
            system ("cls");
            cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
        }
        cout<<"I nakraq izvadete pyrvonachalnoto chislo."<<endl;
        a=getch();
        if (a=='m')
        {
            esc=1;
            break;
        }
        if (a=='r')
        {
            little();
            break;
        }
        system ("cls");
        cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
        cout<<"Poluchihte "<<s<<"."<<endl;
    }
    if (esc=0)
    {
        cout<<"Ako iskate da igraete pak natisnete 1 ako ne natisnete 0."<<endl;
        string k;
        for (;;)
        {
            k=getch();
            if ((k!="1")&&(k!="0"))
            {
                if (k!="" )cout<<"Vyveli ste greshen simvol."<<endl;
                else cout<<"Ne ste vyveli nishto."<<endl;
                br1++;
                if (br1>2000)
                {
                    system ("color f0");
                    cout<<"BUG"<<endl;
                    col=8;
                    system ("pause");
                    break;
                }
            }
            if (k=="1")
            {
                system ("cls");
                little();
                break;
            }
            if (k=="0") break;
        }
    }
}
void demo()
{
    esc=0;
    int br1=0;
    system ("cls");
    cout<<"Za restart natisnete r.Za menu natisnete m."<<endl<<"Natiskajte kakvoto i da bilo drugo za da prodyljite."<<endl<<endl;
    int a,x=256,y=128;
    string p;
    p=getch();
    if (p=="m") esc=1;
    if (p=="r") demo();
    a=0+rand()%513;
    if (esc==0)
    {
        do
        {
            cout<<"Igrach 1: "<<x<<endl;
            p=getch();
            if (p=="m")
            {
                esc=1;
                break;
            }
            if (p=="r")
            {
                demo();
                break;
            }
            if (x>a)
            {
                cout<<"Igrach 2: "<<"-"<<endl;
                x-=y;
                y/=2;
            }
            else if (x<a)
            {
                cout<<"Igrach 2: "<<"+"<<endl;
                x+=y;
                y/=2;
            }
            if (x==a)
            {
                p=getch();
                if (p=="m")
                {
                    esc=1;
                    break;
                }
                if (p=="r")
                {
                    demo();
                    break;
                }
                cout<<"Igrach 1: "<<x<<endl;
                p=getch();
                if (p=="m")
                {
                    esc=1;
                    break;
                }
                if (p=="r")
                {
                    demo();
                    break;
                }
                cout<<"Igrach 2: "<<"="<<endl;
            }
            p=getch();
            if (p=="m")
            {
                esc=1;
                break;
            }
            if (p=="r")
            {
                demo();
                break;
            }
        }
        while (x!=a);
    }
    if (esc==0)
    {
        cout<<"Ako iskate nova demonstraciq natisnete 1 ako ne 0"<<endl;
        while (p!="0" && p!="1")
        {
            p=getch();
            if (p=="0") break;
            else
            {
                if (p=="1")
                {
                    demo();
                    break;
                }
                else
                {
                    if (p!="" )cout<<"Vyveli ste greshen simvol."<<endl;
                    else cout<<"Ne ste vyveli nishto."<<endl;
                    br1++;
                    if (br1>2000)
                    {
                        system ("color f0");
                        cout<<"BUG"<<endl;
                        col=8;
                        system ("pause");
                        break;
                    }
                }
            }
        }
    }
}
void hack ()
{
    cout<<"Master control"<<endl;
    string a;
    a=getch();
}
void exit ()
{
    system ("cls");
    int br1=0;
    cout<<"Iskash li da se zapazi cveta?"<<endl<<"1-Da."<<endl<<"0-Ne."<<endl;
    string k;
    for (;;)
    {
        k=getch();
        if ((k!="1")&&(k!="0"))
        {
            if (k!="" )cout<<"Vyveli ste greshen simvol."<<endl;
            else cout<<"Ne ste vyveli nishto."<<endl;
            br1++;
            if (br1>2000)
            {
                system ("color f0");
                cout<<"BUG"<<endl;
                col=8;
                system ("pause");
                break;
            }
        }
        if (k=="1")
        {
            ofstream writ("help.txt");
            writ<<"Yes!"<<col<<endl;
            break;
        }
        else if (k=="0") break;
    }
}
