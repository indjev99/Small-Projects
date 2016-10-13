#include<iostream>
#include<algorithm>
#include<cstring>
#include<string>
#include<cstdlib>
#include<ctime>
#include<vector>
#include<fstream>
#include<conio.h>
using namespace std;
vector<string> words;
vector<string> teams;
vector<int> score;
vector<int> sortteams;
vector<int> wins;
int teamcount;
int usedwords=0;
int maxseconds;
int rotationsinround;
bool usedword;
int currentteam;
bool cmp_by_score(int t1,int t2)
{
    return score[t1]>score[t2];
}
bool cmp_by_wins(int t1,int t2)
{
    return wins[t1]>wins[t2];
}
void press_space_to_continue()
{
    char ch;
    cout<<"Press space to continue."<<endl;
    ch=getch();
    while(ch!=' ')
    {
        ch=getch();
    }
}
void new_file()
{
    string word;
    string name;
    system("cls");
    cout<<"Enter the name of the file.\n";
    cin>>name;
    ofstream newfile(name.c_str());
    system("cls");
    cout<<"Enter your words and then enter 'end' to stop.\n";
    int localcounter=1;
    cout<<localcounter<<". ";
    localcounter++;
    cin>>word;
    newfile<<word<<'\n';
    while (word!="end")
    {
        words.push_back(word);
        cout<<localcounter<<". ";
        localcounter++;
        cin>>word;
        newfile<<word<<'\n';
    }
}
void open_file()
{
    string word;
    string name;
    system("cls");
    cout<<"Enter the name of the file.\n";
    cin>>name;
    ifstream openfile(name.c_str());
    system("cls");
    cout<<"These are the words you loaded."<<endl;
    int localcounter=1;
    openfile>>word;
    while (word!="end")
    {
        words.push_back(word);
        cout<<localcounter<<". "<<word<<endl;
        localcounter++;
        openfile>>word;
    }
    press_space_to_continue();
}
void setup()
{
    srand(time(0));
    int n;
    cout<<"Enter the duration of each turn in seconds.\n";
    cin>>maxseconds;
    system("cls");
    cout<<"Enter the number of players.\n";
    cin>>n;
    system("cls");
    string teamname;
    cout<<"Each team consists of two or more people. Enter the names of the teams. End by typing 'end'.\n";
    cin>>teamname;
    while (teamname!="end")
    {
        teamcount++;
        teams.push_back(teamname);
        score.push_back(0);
        wins.push_back(0);
        sortteams.push_back(0);
        cin>>teamname;
    }
    currentteam=0;
    system("cls");
    cout<<"If you want the rounds to end when the words end, press 'e', if you don't, press space."<<endl;
    char ch=getch();
    while(ch!=' ' && ch!='e')
    {
        ch=getch();
    }
    system("cls");
    if (ch==' ')
    {
        cout<<"Enter the number of rotations in each round.\n";
        cin>>rotationsinround;
    }
    else
    {
        rotationsinround=0;
    }
    system("cls");
    string command;
    for (int i=0;i<n;i++)
    {
        cout<<"Enter 'new' to create a new file and 'open' to open a file.\n";
        cin>>command;
        while(command!="new" && command!="open")
        {
            cout<<"Wrong command.\n";
            cin>>command;
        }
        if (command=="new") new_file();
        else open_file();
        system("cls");
    }
}
string new_word()
{
    int currentword;
    currentword=rand()%(words.size()-usedwords)+usedwords;
    swap(words[currentword],words[usedwords]);
    currentword=usedwords;
    usedwords++;
    usedwords%=words.size();
    return words[currentword];
}
void unuse_word()
{
    usedwords--;
    if(usedwords==-1) usedwords=words.size()-1;
}
int words_left()
{
    return words.size()-usedwords;
}
int display_words_left()
{
    return words_left()%words.size()+1;
}
int turn()
{
    int right=0;
    bool nowords=0;
    string word;
    char ch;
    system("cls");
    cout<<"Explain as many words as possible in "<<maxseconds<<" seconds. Press space to start. When your teammates guess a word right press space for a new one.\n";
    press_space_to_continue();
    clock_t start=clock();
    clock_t current;
    int second=0, previoussecond=-1;
    system("cls");
    word=new_word();
    while (second<maxseconds)
    {
        current=clock()-start;
        second=(float)current/CLOCKS_PER_SEC;
        if (second!=previoussecond)
        {
            system("cls");
            cout<<word<<"\n"<<maxseconds-second<<" seconds left."<<endl;
            if (rotationsinround==0) cout<<display_words_left()<<" words left."<<endl;
            previoussecond=second;
        }
        if (kbhit())
        {
            ch=getch();
            system("cls");
            if (ch==' ')
            {
                right++;
                usedword=1;
                if (rotationsinround==0 && words_left()==words.size())
                {
                    cout<<"No more words left.\n";
                    press_space_to_continue();
                    nowords=1;
                    break;
                }
                word=new_word();
            }
            cout<<word<<"\n"<<maxseconds-second<<" seconds left."<<endl;
            if (rotationsinround==0) cout<<display_words_left()<<" words left."<<endl;
        }
    }
    if (!nowords) unuse_word();
    system("cls");
    cout<<"You guessed "<<right<<" words right.\n";
    press_space_to_continue();
    return right;
}
int round()
{
    for (int i=0;i<teamcount;i++)
    {
        score[i]=0;
        sortteams[i]=i;
    }
    system("cls");
    for (int rotations=0;rotations<rotationsinround;rotations++)
    {
        for (int j=0;j<teamcount;j++)
        {
            cout<<"It's \""<<teams[currentteam]<<"\"'s turn.\n";
            press_space_to_continue();
            score[currentteam]+=turn();
            currentteam++;
            currentteam%=teamcount;
            system("cls");
        }
    }
    if (rotationsinround==0)
    {
        usedword=0;
        while (words_left()!=words.size() || usedword==0)
        {
            cout<<"It's \""<<teams[currentteam]<<"\"'s turn.\n";
            press_space_to_continue();
            score[currentteam]+=turn();
            system("cls");
            currentteam++;
            currentteam%=teamcount;
        }
    }
    sort(sortteams.begin(),sortteams.end(),cmp_by_score);
    cout<<"\""<<teams[sortteams[0]]<<"\" wins with "<<score[sortteams[0]]<<" points.\n";
    for (int i=1;i<teamcount;i++)
    {
        cout<<i+1<<". "<<teams[sortteams[i]]<<" with "<<score[sortteams[i]]<<" points.\n";
    }
    press_space_to_continue();
    return sortteams[0];
}
void play()
{
    setup();
    char ch;
    int winner;
    do
    {
        winner=round();
        cout<<winner<<" "<<wins[winner]<<endl;
        int p;
        cin>>p;
        wins[winner]++;
        system("cls");
        cout<<"If you want to play another round press space, if you don't press 'e'."<<endl;
        ch=getch();
        while(ch!=' ' && ch!='e')
        {
            ch=getch();
        }
    }
    while (ch!='e');
    for (int i=0;i<teamcount;i++)
    {
        sortteams[i]=i;
    }
    sort(sortteams.begin(),sortteams.end(),cmp_by_wins);
    system("cls");
    cout<<"\""<<teams[sortteams[0]]<<"\" wins with "<<wins[sortteams[0]]<<" wins.\n";
    for (int i=1;i<teamcount;i++)
    {
        cout<<i+1<<". "<<teams[sortteams[i]]<<" with "<<wins[sortteams[i]]<<" wins.\n";
    }
    press_space_to_continue();
}
int main()
{
    play();
    return 0;
}
