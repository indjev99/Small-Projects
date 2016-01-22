#include<iostream>
#include<fstream>
#include<vector>
#include<algorithm>
using namespace std;
vector<string> dictionary;

//Functions for loading the dictionary
void parseAndAddLine(string line)
{
    string word="";
    for (int i=0;i<line.size();++i)
    {
        if (line[i]>='A' && line[i]<='Z') line[i]+='a'-'A';
        if ((line[i]>='a' && line[i]<='z') || (line[i]>='0' && line[i]<='9') || line[i]=='\'' || line[i]=='-' || line[i]=='_') word+=line[i];
        else
        {
            if (word!="") dictionary.push_back(word);
            word="";
        }
    }
    if (word!="") dictionary.push_back(word);
}
void loadFile(string file_name)
{
    string line;
    ifstream file(file_name.c_str());
    while (file)
    {
        getline(file,line);
        parseAndAddLine(line);
    }
}
void loadDictionary()
{
    string file_name;
    cin>>file_name;
    while (file_name!="END")
    {
        loadFile(file_name);
        cin>>file_name;
    }
    sort(dictionary.begin(),dictionary.end());
}

//String compare functions
bool stringCMPShort(string a, string b)
{
    int s=min(a.size(),b.size());
    for (int i=0;i<s;++i)
    {
        if (a[i]<b[i]) return 1;
        else if (a[i]>b[i]) return 0;
    }
    return a.size()<b.size();
}
bool stringCMPLong(string a, string b)
{
    int s=min(a.size(),b.size());
    for (int i=0;i<s;++i)
    {
        if (a[i]<b[i]) return 1;
        else if (a[i]>b[i]) return 0;
    }
    return b.size()<a.size();
}

//Word processing functions
string invertWord(string word)
{
    int ws=word.size();
    string ans;
    ans.resize(ws);
    for (int i=0;i<ws;++i)
    {
        ans[i]=word[ws-1-i];
    }
    return ans;
}
string fixFix(string fix)
{
    if (fix=="/") fix="";
    for (int i=0;i<fix.size();++i)
    {
        if (fix[i]>='A' && fix[i]<='Z') fix[i]+='a'-'A';
    }
    return fix;
}

//Dictionary processing functions
vector<int> invertDictionary(vector<string> &dictionary, int first, int last)
{
    vector<pair<string, int> > ansWithWord(last-first);
    vector<int> ans(last-first);
    for (int i=first;i<last;++i)
    {
        ansWithWord[i-first].first=invertWord(dictionary[i]);
        ansWithWord[i-first].second=i;
    }
    sort(ansWithWord.begin(),ansWithWord.end());
    for (int i=0;i<last-first;++i)
    {
        ans[i]=ansWithWord[i].second;
    }
    return ans;
}
//Search functions
int findFirstOccurrence(vector<string> &dictionary, string prefix)
{
    int l,r;
    int m;
    l=0;
    r=dictionary.size();
    while (l<r)
    {
        m=(l+r)/2;
        if (stringCMPShort(dictionary[m],prefix)) l=m+1;
        else r=m;
    }
    return l;
}
int findLastOccurrence(vector<string> dictionary, string prefix)
{
    int l,r;
    int m;
    l=0;
    r=dictionary.size();
    while (l<r)
    {
        m=(l+r)/2;
        if (stringCMPLong(dictionary[m],prefix)) l=m+1;
        else r=m;
    }
    return l;
}
vector<int> findWordsEndingWith(vector<string> &dictionary, string suffix)
{
    int first,last;
    vector<int> all=invertDictionary(dictionary,0,dictionary.size());
    vector<string> new_dictionary(all.size());
    for (int i=0;i<all.size();++i)
    {
        new_dictionary[i]=invertWord(dictionary[all[i]]);
    }
    suffix=invertWord(suffix);
    first=findFirstOccurrence(new_dictionary,suffix);
    last=findLastOccurrence(new_dictionary,suffix);
    vector<int> ans(last-first);
    for (int i=first;i<last;++i)
    {
        ans[i-first]=all[i];
    }
    sort(ans.begin(),ans.end());
    return ans;
}
void printDictionary(vector<string> &dictionary, int first, int last);
void printDictionary(vector<string> &dictionary, vector<int> &all);
vector<int> findWords(vector<string> &dictionary, string prefix, string suffix)
{
    int first,last;
    vector<int> all;
    vector<int> ans;
    first=findFirstOccurrence(dictionary,prefix);
    last=findLastOccurrence(dictionary,prefix);
    all=findWordsEndingWith(dictionary,suffix);
    for (int i=0;i<all.size();++i)
    {
        if (all[i]>=first && all[i]<last) ans.push_back(all[i]);
    }
    return ans;
}

//Output functions
void printDictionary(vector<string> &dictionary, int first, int last)
{
    if (last>dictionary.size()) return;
    for (int i=first;i<last;++i) cout<<dictionary[i]<<'\n';
}
void printDictionary(vector<string> &dictionary, vector<int> &all)
{
    for (int i=0;i<all.size();++i)
    {
        if (all[i]>=dictionary.size()) continue;
        cout<<dictionary[all[i]]<<'\n';
    }
}

//Runs the program
void run()
{
    vector<int> all;
    string prefix;
    string suffix;
    while (1)
    {
        cout<<"prefix: ";
        cin>>prefix;
        cout<<"suffix: ";
        cin>>suffix;
        prefix=fixFix(prefix);
        suffix=fixFix(suffix);
        all=findWords(dictionary,prefix,suffix);
        printDictionary(dictionary,all);
    }
}

//Starts the program
int main()
{
    ios::sync_with_stdio(0);
    cout<<"Enter the names of all dictionary files ending with END.\n";
    loadDictionary();
    cout<<"If you don't want a prefix or a suffix put a / in its place.\n";
    run();
    return 0;
}
