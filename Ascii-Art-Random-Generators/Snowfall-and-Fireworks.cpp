#include<iostream>
#include<string>
#include<cstdlib>
#include<ctime>
#include<windows.h>
#include<conio.h>
#include<vector>
#include<math.h>
#define PI 3.1415926535897932384626433832795029
using namespace std;
struct object
{
    double x,y,xs,ys;
    int c;
    int l;
};

//parameters for the simulation

int w; //width
int h; //height

double sps; //seconds per step
int cover; //do the snow and fireworks cover the ascii art 0/1
int fs; //does the snow take the whole rectangle
string snowflakes; //all possible snowflakes
int ahc; //horizontal centering
int system_background; //system background colour
int snowflake_colour; //snowflake colour
int snow_colour; //snow- colour
int art_colour; //art colour
vector<int> firework_colours; //firework colours
char es; //empty symbol
vector<string> art; //ascii art

int sa; //snow accumulation 0/1
double sfsize; //size of snowflakes
double ar; //air resistance
double g; //gravity
double wind; //wind

int s; //seed
int ps1; //probability of a snowflake appearing is ps1/ps2
int ps2;
int pf1; //probability of a firework appearing is ps1/ps2
int pf2;

//default values of the parameters

int dw=-1;
int dh=-1;

double dsps=0.15;
int dcover=1;
int dfs=0;
string dsnowflakes="*";
int dahc=1;
int dsystem_background=3;
int dsnowflake_colour=15;
int dsnow_colour=15;
int dart_colour=4;
vector<int> dfirework_colours={9,10,11,12,13,14};
char des='L';
vector<string> dart={"LLLLLLLLLLLLLLLLLLLLLLLLLL|LLLLLLLLLLLLLLLLLLLLLLLLL_...._LLLLLLLLLLLLL",
                     "LLLLLLLLLLLLLLLLLLLLLLL\\  _  /LLLLLLLLLLLLLLLLLLLL.::o:::::.LLLLLLLLLLL",
                     "LLLLLLLLLLLLLLLLLLLLLLL (\\o/) LLLLLLLLLLLLLLLLLLL.:::'''':o:.LLLLLLLLLL",
                     "LLLLLLLLLLLLLLLLLLLL---  / \\  ---LLLLLLLLLLLLLLLL:o:_    _:::LLLLLLLLLL",
                     "LLLLLLLLLLLLLLLLLLLLLLLLL>*<LLLLLLLLLLLLLLLLLLLLL`:}_>()<_{:'LLLLLLLLLL",
                     "LLLLLLLLLLLLLLLLLLLLLLLL>0<@<LLLLLLLLLLLLLLLLL@LLLL`'//\\\\'`LLLL@LLLLLLL",
                     "LLLLLLLLLLLLLLLLLLLLLLL>>>@<<*LLLLLLLLLLLLLL@L#LLLLL//  \\\\LLLLL#L@LLLLL",
                     "LLLLLLLLLLLLLLLLLLLLLL>@>*<0<<<LLLLLLLLLLL__#_#____/'____'\\____#_#__LLL",
                     "LLLLLLLLLLLLLLLLLLLLL>*>>@<<<@<<LLLLLLLLL[__________________________]LL",
                     "LLLLLLLLLLLLLLLLLLLL>@>>0<<<*<<@<LLLLLLLLL|=_- .-/\\ /\\ /\\ /\\--. =_-|LLL",
                     "LLLLLLLLLLLLLLLLLLL>*>>0<<@<<<@<<<LLLLLLLL|-_= | \\ \\\\ \\\\ \\\\ \\ |-_=-|LLL",
                     "LLLLLLLLLLLLLLLLLL>@>>*<<@<>*<<0<*<LLLLLLL|_=-=| / // // // / |_=-_|LLL",
                     "LLLL\\*/LLLLLLLLLL>0>>*<<@<>0><<*<@<<LLLLLL|=_- |`-'`-'`-'`-'  |=_=-|LLL",
                     "___\\\\U//___LLLLL>*>>@><0<<*>>@><*<0<<LLLLL| =_-| o          o |_==_|LLL",
                     "|\\\\ | | \\\\|LLLL>@>>0<*<<0>>@<<0<<<*<@<LLLL|=_- | !     (    ! |=-_=|LLL",
                     "| \\\\| | _(UU)_ >((*))_>0><*<0><@<<<0<*<LL_|-,-=| !    ).    ! |-_-=|_LL",
                     "|\\ \\| || / //||.*.*.*.|>>@<<*<<@>><0<<@</=-((=_| ! __(:')__ ! |=_==_-\\L",
                     "|\\\\_|_|&&_// ||*.*.*.*|_\\\\db//__LLLLL(\\_/)-=))-|/^\\=^=^^=^=/^\\| _=-_-_\\",
                     "\"\"\"\"|'.'.'.|~~|.*.*.*|     ____|_LLL=('.')=//LL ,------------. LLLLLLLL",
                     "jgs |'.'.'.|   ^^^^^^|____|>>>>>>|LL( ~~~ )/LLL(((((((())))))))LLLLLLLL",
                     "LLLL~~~~~~~~LLLLLLLLL'\"\"\"\"`------'LL`w---w`LLLLL`------------'LLLLLLLLL"};

int dsa=1;
double dsfsize=0.6;
double dar=0.2;
double dg=0.2;
double dwind=0.02;

int dps1=1;
int dps2=15;
int dpf1=1;
int dpf2=2;



vector<object> fws; //fireworks
vector<object> sfs; //snowflakes
double sh[1024]; //snow hight
HANDLE hConsole=GetStdHandle(STD_OUTPUT_HANDLE); //console handle
COORD CursorPosition; //cursor position
string sb_colour; //system background colour
void set_system_background(int bc)
{
    int tc=7;
    if (bc>=7) tc=0;
    string cmd="color ";
    sb_colour="";
    if (bc<10) sb_colour+=bc+'0';
    else sb_colour+=bc-10+'a';
    sb_colour+=tc+'0';
    cmd+=sb_colour;
    system(cmd.c_str());
}
void set_text_colour(int bc)
{
    int tc=7;
    if (bc>=7) tc=0;
    SetConsoleTextAttribute(hConsole,bc*16+tc);
}
void move_cursor(int line, int character)
{
    CursorPosition.X=character;
    CursorPosition.Y=line;
    SetConsoleCursorPosition(hConsole,CursorPosition);
}
void basic_settings()
{
    cout<<"Enter width (-1 for default): ";
    cin>>w;
    cout<<"Enter height (-1 for default): ";
    cin>>h;
}
void default_basic_settings()
{
    w=dw;
    h=dh;
}
void basic_graphics_settings()
{
    cout<<"Enter the number of seconds per step (double, -1 for default): ";
    cin>>sps;
    cout<<"Enter all possible snowflakes (leave empty for default): ";
    cin.ignore(1);
    getline(cin,snowflakes);
    cout<<"Enter 1 if you want the snow to cover the art and 0 if you don't (-1 for default): ";
    cin>>cover;
    cout<<"Enter 1 if you want the art horizontally centered and 0 if you don't (-1 for default): ";
    cin>>ahc;
    cout<<"Enter 1 if you want the snow to take the whole rectangle and 0 if you don't (-1 for default): ";
    cin>>fs;
}
void default_basic_graphics_settings()
{
    sps=dsps;
    snowflakes=dsnowflakes;
    cover=dcover;
    ahc=dahc;
    fs=dfs;
}
void colour_graphics_settings()
{
    int fc;
    cout<<"Enter the background colour (0-15, -1 for default): ";
    cin>>system_background;
    cout<<"Enter the snow colour (0-15, -1 for default): ";
    cin>>snowflake_colour;
    snow_colour=snowflake_colour;
    cout<<"Enter the art colour (0-15, -1 for default): ";
    cin>>art_colour;
    cout<<"Enter all firework colours (0-15, only -1 for default) ending with -1: ";
    cin>>fc;
    firework_colours.resize(0);
    while (fc!=-1)
    {
        firework_colours.push_back(fc);
        cin>>fc;
    }
}
void default_colour_graphics_settings()
{
    system_background=dsystem_background;
    snowflake_colour=dsnowflake_colour;
    snow_colour=dsnow_colour;
    art_colour=dart_colour;
    firework_colours=dfirework_colours;
}
void art_graphics_settings()
{
    string row;
    cout<<"Enter the empty symbol, this is a symbol that won't displayed and is used for alignment: ";
    cin>>es;
    cout<<"Enter the ascii art row by row ending with an empty row: \n";
    art.resize(0);
    getline(cin,row);
    getline(cin,row);
    while(row!="")
    {
        art.push_back(row);
        getline(cin,row);
    }
}
void default_art_graphics_settings()
{
    art=dart;
    es=des;
}
void graphics_settings(int f)
{
    int c;
    cout<<"Enter 1 if you want to edit the basic graphics settings and 0 if you don't: ";
    cin>>c;
    if (c) basic_graphics_settings();
    else if (f) default_basic_graphics_settings();
    cout<<"Enter 1 if you want to edit the colour settings and 0 if you don't: ";
    cin>>c;
    if (c) colour_graphics_settings();
    else if (f) default_colour_graphics_settings();
    cout<<"Enter 1 if you want to edit the ascii art and 0 if you don't: ";
    cin>>c;
    if (c) art_graphics_settings();
    else if (f) default_art_graphics_settings();
}
void default_graphics_settings()
{
    default_basic_graphics_settings();
    default_colour_graphics_settings();
    default_art_graphics_settings();
}
void physics_settings()
{
    cout<<"Enter 1 for snow accumulation and 0 for no snow accumulation (-1 for default): ";
    cin>>sa;
    cout<<"Enter the size of the snowflakes (double >=0, -1 for default): ";
    cin>>sfsize;
    cout<<"Enter the air resistance (double 0-1, -1 for default): ";
    cin>>ar;
    cout<<"Enter the gravity (double, -1 for default): ";
    cin>>g;
    cout<<"Enter the wind (double, -1 for default): ";
    cin>>wind;
}
void default_physics_settings()
{
    sa=dsa;
    sfsize=dsfsize;
    ar=dar;
    g=dg;
    wind=dwind;
}
void probability_settings(int f)
{
    if (f)
    {
        cout<<"Enter seed: ";
        cin>>s;
    }
    cout<<"Enter probability of snowflake appearing (two numbers a and b the probability is a/b, -1 -1 for default): ";
    cin>>ps1>>ps2;
    cout<<"Enter probability of firework appearing (two numbers a and b the probability is a/b, -1 -1 for default): ";
    cin>>pf1>>pf2;
}
void default_probability_settings(int f)
{
    if (f) s=time(NULL);
    ps1=dps1;
    ps2=dps2;
    pf1=dpf1;
    pf2=dpf2;
}
void undo_background_correction()
{
    int b=system_background*16;
    snowflake_colour-=b;
    if (fs) snow_colour/=17;
    else snow_colour-=b;
    art_colour-=b;
    for (int i=0;i<firework_colours.size();++i) firework_colours[i]-=b;
}
void correct_settings()
{
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE),&csbi);
    if (w==-1) w=csbi.srWindow.Right-csbi.srWindow.Left;
    if (h==-1) h=csbi.srWindow.Bottom-csbi.srWindow.Top;

    if (sps==-1) sps=dsps;
    if (snowflakes.empty()) snowflakes=dsnowflakes;
    if (cover==-1) cover=dcover;
    if (ahc==-1) ahc=dahc;
    if (dfs==-1) fs=dfs;

    if (system_background==-1) system_background=dsystem_background;
    if (snowflake_colour==-1) snowflake_colour=dsnowflake_colour;
    if (snow_colour==-1) snow_colour=dsnow_colour;
    if (art_colour==-1) art_colour=dart_colour;
    if (firework_colours.empty()) firework_colours=dfirework_colours;
    int b=system_background*16;
    snowflake_colour+=b;
    if (fs) snow_colour*=17;
    else snow_colour+=b;
    art_colour+=b;
    for (int i=0;i<firework_colours.size();++i) firework_colours[i]+=b;

    if (sa==-1) sa=dsa;
    if (sfsize==-1) sfsize=dsfsize;
    if (ar==-1) ar=dar;
    if (g==-1) g=dg;
    if (wind==-1) wind=dwind;

    if (ps1==-1) ps1=dps1;
    if (ps2==-1) ps2=dps2;
    if (pf1==-1) pf1=dpf1;
    if (pf2==-1) pf2=dpf2;
}
int minsh; //minimal snow height
void clear_snow()
{
    for (int i=0;i<3*w;++i)
    {
        sh[i]=1;
    }
}
void start(int f)
{
    int c=0;
    cout<<"Enter 1 if you want to edit the basic settings and 0 if you don't: ";
    cin>>c;
    if (c) basic_settings();
    else if (f) default_basic_settings();
    cout<<"Enter 1 if you want to edit the graphics settings and 0 if you don't: ";
    cin>>c;
    if (c) graphics_settings(f);
    else if (f) default_graphics_settings();
    else undo_background_correction();
    cout<<"Enter 1 if you want to edit the physics settings and 0 if you don't: ";
    cin>>c;
    if (c) physics_settings();
    else if (f) default_physics_settings();
    cout<<"Enter 1 if you want to edit the probability settings and 0 if you don't: ";
    cin>>c;
    if (c) probability_settings(f);
    else if (f) default_probability_settings(f);
    correct_settings();
    cout<<"Press 'p' at any time to pause the snowfall, press 'e' at any time to exit the snowfall. Press any key to continue."<<endl;
    getch();
    cout.flush();
    set_system_background(system_background);
    set_text_colour(system_background);
    system("cls");
    if (f) srand(s);
    if (f) clear_snow();
    minsh=0;
}
void generate_snowflake()
{
    double speed;
    speed=double(rand()%5+8)/10;
    object f;
    f.x=rand()%(w*3*5)*0.2-w;
    f.y=0;
    f.c=snowflakes[rand()%snowflakes.size()];
    f.xs=0;
    f.ys=speed;
    sfs.push_back(f);
}
void generate_firework()
{
    int num1,num2;
    double angl,speed;
    double xbs,ybs;
    num1=rand()%8+5;
    num2=rand()%3+1;
    speed=double(rand()%20+15)/10/num2;
    angl=double(2*PI)/num1;
    object f;
    f.x=rand()%(w*5)*0.2;
    f.y=rand()%(h*5)*0.2;
    f.c=firework_colours[rand()%firework_colours.size()];
    for (int i=0;i<num1;++i)
    {
        xbs=cos(angl*i-PI/2)*speed;
        ybs=sin(angl*i-PI/2)*speed;
        for (int j=0;j<num2;++j)
        {
            f.l=rand()%7+7;
            f.xs=xbs*(j+1);
            f.ys=ybs*(j+1);
            fws.push_back(f);
        }
    }
}
void generate_row()
{
    for (int i=0;i<w*3;++i)
    {
        if (rand()%ps2<ps1) generate_snowflake();
    }
}
void simulate_objects()
{
    object f;
    for (int i=0;i<sfs.size();++i) //simulates snowflakes
    {
        f=sfs[i];
        f.x+=f.xs;
        f.y+=f.ys;
        if (round(f.y)<-h)
        {
            sfs.erase(sfs.begin()+i);
            continue;
        }
        if (round(f.x)<-w)
        {
            f.x+=3*w;
        }
        if (round(f.x)>=w*2)
        {
            f.x-=3*w;
        }
        if (round(f.x)>=-w && round(f.x)<2*w && h-sh[(int(round(f.x))+3*w)%(3*w)]<=round(f.y))
        {
            if (sa) sh[(int(round(f.x))+3*w)%(3*w)]+=sfsize;
            sfs.erase(sfs.begin()+i);
            continue;
        }
        f.xs*=1-ar;
        f.ys*=1-ar;
        f.xs+=wind;
        f.ys+=g;
        sfs[i]=f;
    }
    for (int i=0;i<fws.size();++i) //simulates fireworks
    {
        f=fws[i];
        --f.l;
        f.x+=f.xs;
        f.y+=f.ys;
        if (round(f.x)<-w)
        {
            f.x+=3*w;
        }
        if (round(f.x)>=w*2)
        {
            f.x-=3*w;
        }
        if (f.l<=0 || (round(f.x)>=-w && round(f.x)<2*w && h-sh[(int(round(f.x))+3*w)%(3*w)]<=round(f.y)) || round(f.y)<-h)
        {
            fws.erase(fws.begin()+i);
            continue;
        }
        f.xs*=1-ar;
        f.ys*=1-ar;
        f.xs+=wind;
        f.ys+=g;
        fws[i]=f;
    }
}
string output_snowflakes[1024],output_art[1024],output_fireworks[1024],output_snow[1024],output[1024];
vector<int> output_colour[1024];
int char_for_direction(object f)
{
    if (f.xs==0) return '|';
    double angle=atan(f.ys/f.xs)+PI/2;
    while (angle<0) angle+=2*PI;
    while (angle>2*PI) angle-=2*PI;
    if (angle>=PI*1/8 && angle<PI*3/8) return '/';
    if (angle>=PI*3/8 && angle<PI*5/8) return '-';
    if (angle>=PI*5/8 && angle<PI*7/8) return '\\';
    if (angle>=PI*7/8 && angle<PI*9/8) return '|';
    if (angle>=PI*9/8 && angle<PI*11/8) return '/';
    if (angle>=PI*11/8 && angle<PI*13/8) return '-';
    if (angle>=PI*13/8 && angle<PI*15/8) return '\\';
    if (angle>=PI*15/8 || angle<PI*1/8) return '|';
    return '$';

}
void output_snowflakes_all()
{
    object f;
    for (int i=0;i<h;++i)
    {
        output_snowflakes[i].resize(w);
        for (int j=0;j<w;++j)
        {
            output_snowflakes[i][j]=0;
        }
    }
    for (int i=0;i<sfs.size();++i)
    {
        f=sfs[i];
        if (round(f.y)>=0 && round(f.y)<h && round(f.x)>=0 &&  round(f.x)<w && h-sh[int(round(f.x))]>round(f.y)) output_snowflakes[int(round(f.y))][int(round(f.x))]=f.c;
    }
}
void output_fireworks_all()
{
    object f;
    for (int i=0;i<h;++i)
    {
        output_fireworks[i].resize(w);
        output_colour[i].resize(w);
        for (int j=0;j<w;++j)
        {
            output_fireworks[i][j]=0;
            output_colour[i][j]=snowflake_colour;
        }
    }
    for (int i=0;i<fws.size();++i)
    {
        f=fws[i];
        if (round(f.y)>=0 && round(f.y)<h &&  round(f.x)>=0 && round(f.x)<w && h-sh[int(round(f.x))]>round(f.y))
        {
            output_fireworks[int(round(f.y))][int(round(f.x))]=char_for_direction(f);
            output_colour[int(round(f.y))][int(round(f.x))]=f.c;
        }
    }
}
void output_snow_row(int r)
{
    int f=1;
    string row;
    row.resize(w);
    for (int i=0;i<w;++i)
    {
        if (r>=round(h-sh[i]))
        {
            row[i]='#';
            output_colour[r][i]=snow_colour;
        }
        else
        {
            row[i]=0;
            f=0;
        }
    }
    output_snow[r]=row;
    if (f && h-r-1>minsh) minsh=h-r-1;
}
void output_art_row(int r)
{
    string row;
    row.resize(w);
    bool f=0,f2;
    int lr=h/2-art.size()/2;
    int hr=lr+art.size()-1;
    int ar=r-lr;
    int lc,hc;
    if (lr<=r && hr>=r)
    {
        if (ahc) lc=w/2-art[ar].size()/2;
        else lc=0;
        hc=lc+art[ar].size()-1;
        f=1;
    }
    for (int i=0;i<w;++i)
    {
        if (f && lc<=i && hc>=i && art[ar][i-lc]!=es)
        {
            row[i]=art[ar][i-lc];
            if (!cover || (output_colour[r][i]==snowflake_colour && output_snow[r][i]==0 && output_snowflakes[r][i]==0 && output_fireworks[r][i]==0)) output_colour[r][i]=art_colour;
        }
        else row[i]=es;
    }
    output_art[r]=row;
}
void combine_outputs(int r)
{
    string rowsf=output_snowflakes[r];
    string rows=output_snow[r];
    string rowf=output_fireworks[r];
    string rowa=output_art[r];
    string row;
    row.resize(w);
    for (int i=0;i<w;++i)
    {
        if (rowa[i]!=es && ((rows[i]==0 && rowsf[i]==0 && rowf[i]==0) || !cover)) row[i]=rowa[i];
        else if (rows[i]!=0) row[i]=rows[i];
        else if (rowf[i]!=0) row[i]=rowf[i];
        else if (rowsf[i]!=0) row[i]=rowsf[i];
        else row[i]=' ';
    }
    output[r]=row;
}
string curr; //current string for output
int prev_colour=0; //previous colour
void output_row(int r)
{
    for(int i=0;i<w;i++)
    {
        if(output_colour[r][i]!=prev_colour && (output[r][i]!=' ' || output_colour[r][i]/16!=prev_colour/16))
        {
            cout<<curr<<flush;
            SetConsoleTextAttribute(hConsole,output_colour[r][i]);
            prev_colour=output_colour[r][i];
            curr="";
        }
        curr+=output[r][i];
    }
    curr+='\n';
}
int currminsh;
void output_all()
{
    currminsh=minsh;
    move_cursor(0,0);
    curr="";
    prev_colour=snowflake_colour;
    SetConsoleTextAttribute(hConsole,snowflake_colour);
    output_fireworks_all();
    output_snowflakes_all();
    for (int i=0;i<h-currminsh && i<h;++i)
    {
        output_snow_row(i);
        output_art_row(i);
        combine_outputs(i);
        output_row(i);
    }
    cout<<curr<<flush;
}
double shs[1024];
void smooth_snow_height()
{
    int currminsh=h;
    int f=1;
    shs[0]=sh[3*w-1]*0.5+sh[0]*1+sh[1]*0.5;
    shs[3*w-1]=sh[w-1]*1.5+sh[w-2]*0.5;
    for (int i=1;i<3*w-1;++i)
    {
        shs[i]=sh[i-1]*0.5+sh[i]+sh[i+1]*0.5;
    }
    for (int i=0;i<3*w;++i)
    {
        sh[i]=shs[i]/2;
        if (round(sh[i])<currminsh) currminsh=round(sh[i]);
        if (round(sh[i])<h) f=0;
    }
    if (currminsh<minsh) minsh=currminsh;
    if (f)
    {
        sfs.resize(0);
        fws.resize(0);
        clear_snow();
        minsh=0;
    }
}
void snowfall()
{
    clock_t startT,currT;
    double seconds;
    int step=0;
    startT=clock();
    int ch;
    while(1)
    {
        if (rand()%pf2<pf1) generate_firework();
        currT=clock()-startT;
        seconds=(double)currT/CLOCKS_PER_SEC;
        while (seconds<step*sps)
        {
            currT=clock()-startT;
            seconds=(double)currT/CLOCKS_PER_SEC;
        }
        generate_row();
        output_all();
        if (sa) smooth_snow_height();
        simulate_objects();
        ++step;
        if (kbhit())
        {
            ch=getch();
            if (ch=='e' || ch=='E')
            {
                move_cursor(h,0);
                set_text_colour(system_background);
                break;
            }
            if (ch=='p' || ch=='P')
            {
                move_cursor(h,0);
                set_text_colour(system_background);
                cout<<"Press 'p' to unpause, press 's' to edit the settings."<<flush;
                ch=' ';
                while (ch!='p' && ch!='P' && ch!='s' && ch!='S')
                {
                    ch=getch();
                    if (ch=='s' || ch=='S')
                    {
                        cout<<'\r';
                        start(0);
                    }
                }
                minsh=0;
                system("cls");
                startT=clock();
                step=0;
            }
        }
    }
    set_text_colour(system_background);
    getch();
}
int main()
{
    ios::sync_with_stdio(0);
    start(1);
    snowfall();
    return 0;
}
