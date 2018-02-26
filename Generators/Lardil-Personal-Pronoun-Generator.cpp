#include<iostream>
#include<vector>
using namespace std;
string removeDashes(string word)
{
	string word2;
	for (int i=0;i<word.size();++i)
	{
		if (word[i]!='-')
		{
			word2+=word[i];
		}
	}
	return word2;
}
vector<string> splitToPhonemes(string word)
{
	vector<string> phs;
	string c;
	string last="0";
	for (int i=0;i<word.size();++i)
	{
		c=word[i];
		if (c=="p" || c=="m" || c=="w" || c=="l" || c=="d" || c=="j" || c=="k")
		{
			if (last!="0")
			{
				phs.push_back(last);
				last="0";
			}
			phs.push_back(c);
			continue;
		}
		if (c=="i" || c=="e" || c=="u" || c=="a")
		{
			if (last==c)
			{
				phs.push_back(last+c);
				last="0";
				continue;
			}
			if (last!="0")
			{
				phs.push_back(last);
				last="0";
			}
			last=c;
			continue;
		}
		if (c=="h" || c=="g")
		{
			phs.push_back(last+c);
			last="0";
			continue;
		}
		if (c=="y")
		{
			if (last=="n")
			{
				phs.push_back(last+c);
				last="0";
				continue;
			}
			if (last!="0")
			{
				phs.push_back(last);
				last="0";
			}
			phs.push_back(c);
			continue;
		}
		if (c=="r")
		{
			if (last!="0")
			{
				phs.push_back(last);
				last="0";
			}
			last=c;
			continue;
		}
		if (c=="n" || c=="t")
		{
			if (last=="r")
			{
				phs.push_back(last+c);
				last="0";
				continue;
			}
			if (last!="0")
			{
				phs.push_back(last);
				last="0";
			}
			last=c;
			continue;
		}
	}
	if (last!="0")
	{
		phs.push_back(last);
		last="0";
	}
	return phs;
}
string mergePhonemes(vector<string> phs)
{
	string word="";
	for (int i=0;i<phs.size();++i)
	{
		word+=phs[i];
	}
	return word;
}
int syllables(string word)
{
	int ans=0;
	for (int i=0;i<word.size();++i)
	{
		if (word[i]=='i' || word[i]=='e' || word[i]=='u' || word[i]=='a') ++ans;
	}
	return ans;
}
bool endInNasal(string word)
{
	word=removeDashes(word);

	int l=word.size()-1;
	if (word[l]=='m' || (word[l-1]=='n' && word[l]=='h') || word[l]=='n' || (word[l-1]=='n' && word[l]=='ny')
		|| (word[l-1]=='r' && word[l]=='n') || (word[l-1]=='n' && word[l]=='g'))
	{
		return 1;
	}
	else return 0;
}
string generate_(int person, int number, int harmonic, int case_, bool mode)
{
	/// person: 0-4; number: 1-3, harmonic: -1,0,1; case_: 0-4; mode: 0,1
	string word="";

	if ((harmonic==1 || number==1) && case_>2)
	{
		word=generate_(person,number,harmonic,case_-2,mode);
		goto final_case_suffix;
	}

	if (person==1)
	{
		if (number==1)
		{
			if (case_==0) word+="ngat";
			else if (case_==1) word+="ngithang";
			else word+="ngithu"; //case_=2
		}
		else word+="ngaku";
	}
	else if (person==0) word+="nya";
	else if (person==2)
	{
		if (number==1 && case_>0) word+="ngimpeng";
		else if ((number==2 && harmonic==0) || (number==1 && case_==0)) word+="nying";
		else word+="ki";
	}
	else //person=3
	{
		if ((number==2 && harmonic==0) || number==1) word+="ni";
		else word+="pi";
	}

	if (number>1 && mode) word+="-";
	if (number==2 && harmonic==0)
	{
		if (syllables(word)>1) word+="ning";
		else if (case_==0) word+="ngin";
		else word+="nging";
	}
	else if (number==3 && harmonic==0) word+="lmung";
	else if (number==2 && harmonic==1) word+="d";
	else if (number==3 && harmonic==1) word+="l";

	if (case_>0 && (harmonic==1 || (number==1 && person==3)))
	{
		if (mode) word+="-";
		word+="weng";
	}

	final_case_suffix:
	if (case_>0 && mode) word+="-";
	if (case_==1)
	{
		if (harmonic==1 || number==1) word+="intha";
		else word+="in";
	}
	else if (case_==2)
	{
		if (harmonic==1 || number==1) word+="n";
		else word+="ngan";
	}
	else if (case_==3)
	{
		if (endInNasal(word)) word+="kur";
		else word+="ur";
	}
	else if (case_==4) word+="ad";

	return word;
}
string generate_(string code, int case_, bool mode)
{
	int l=code.size()-1;
	int person;
	int number;
	int harmonic=-1;

	if (code[l]=='0') number=1;
	else number=l;

	person=code[0]-'0';
	if (number>1)
	{
		if (person==1 && code[1]=='3') person=0;

		if (code[l]=='h') harmonic=1;
		else harmonic=0;
	}

	return generate_(person,number,harmonic,case_,mode);
}
bool isFront(string ph)
{
	if (ph[0]=='i' || ph[0]=='e') return 1;
	return 0;
}
bool isVowel(string ph)
{
	if (ph[0]=='i' || ph[0]=='e' || ph[0]=='u' || ph[0]=='a') return 1;
	return 0;
}
bool isLongVowel(string ph)
{
	if (ph=="ii" || ph=="ee" || ph=="uu" || ph=="aa") return 1;
	return 0;
}
bool isApical(string ph)
{
	if (ph[0]=='r' || ph=="t" || ph=="n" || ph=="l" || ph=="d") return 1;
	return 0;
}
bool isNasal(string ph)
{
	if (ph[0]=='m' || ph[0]=='n' || (ph.size()>1 && ph[1]=='n')) return 1;
	return 0;
}
int syllables(vector<string> phs)
{
	int ans=0;
	for (int i=0;i<phs.size();++i)
	{
		if (isVowel(phs[i])) ++ans;
	}
	return ans;
}
int longSyllables(vector<string> phs)
{
	int ans=0;
	for (int i=0;i<phs.size();++i)
	{
		if (isLongVowel(phs[i])) ++ans;
	}
	return ans;
}
vector<string> degemination(vector<string> phs)
{
	vector<string> phs2;
	for (int i=0;i<phs.size();++i)
	{
		if (i==0 || phs[i]!=phs[i-1] || isVowel(phs[i])) phs2.push_back(phs[i]);
	}
	return phs2;
}
vector<string> MNACD(vector<string> phs)
{
	vector<string> phs2;
	for (int i=0;i<phs.size();++i)
	{
		if (i==phs.size()-1 || isVowel(phs[i]) || isApical(phs[i]) || !isApical(phs[i+1])) phs2.push_back(phs[i]);
	}
	return phs2;
}
vector<string> apocope(vector<string> phs)
{
	if (phs.size()>0 && isVowel(phs[phs.size()-1])) phs.pop_back();
	return phs;
}
vector<string> clusterReduction(vector<string> phs)
{
	if (phs.size()>1 && !isVowel(phs[phs.size()-1]) && !isVowel(phs[phs.size()-2])) phs.pop_back();
	return phs;
}
vector<string> NACT(vector<string> phs)
{
	if (phs.size()>0 && !isApical(phs[phs.size()-1])) phs.pop_back();
	return phs;
}
vector<string> augmentation(vector<string> phs)
{
	if (syllables(phs)==1 && longSyllables(phs)==0)
	{
		phs.push_back("a");
	}
	return phs;
}
vector<string> pronounAugmentation(vector<string> phs, bool force)
{
	if (force || (phs.size()>0 && (phs[phs.size()-1]=="n" || phs[phs.size()-1]=="l" || phs[phs.size()-1]=="d")))
	{
		if (phs.size()>0 && isNasal(phs[phs.size()-1])) phs.push_back("k");
		phs.push_back("i");
	}
	return phs;
}
vector<string> glideInsertion(vector<string> phs)
{
	vector<string> phs2;
	bool first=true;
	for (int i=0;i<phs.size();++i)
	{
		phs2.push_back(phs[i]);
		if (isVowel(phs[i]) && first)
		{
			first=false;
			if (i<phs.size()-1 && isVowel(phs[i+1]))
			{
				if (isFront(phs[i])) phs2.push_back("y");
				else phs2.push_back("w");
			}
		}
	}
	return phs2;
}
vector<string> vowelMerger(vector<string> phs)
{
	vector<string> phs2;
	bool first=true;
	for (int i=0;i<phs.size();++i)
	{
		if (i<phs.size()-1 && isVowel(phs[i]) && isVowel(phs[i+1]) && phs[i][0]==phs[i+1][0])
		{
			string a="";
			a+=phs[i][0];
			a+=phs[i][0];
			phs2.push_back(a);
			++i;
		}
		else phs2.push_back(phs[i]);
	}
	return phs2;
}
vector<string> vowelDeletion(vector<string> phs)
{
	vector<string> phs2;
	for (int i=0;i<phs.size();++i)
	{
		if (i==0 || !isVowel(phs[i]) || !isVowel(phs[i-1])) phs2.push_back(phs[i]);
	}
	return phs2;
}
vector<string> vowelLengthening(vector<string> phs, bool stressed)
{
	vector<string> phs2;
	for (int i=0;i<phs.size();++i)
	{
		if (i>=phs.size()-3 || !isVowel(phs[i]) || phs[i+1]!="ng" || phs[i+2]!="i" || !isNasal(phs[i+3])) phs2.push_back(phs[i]);
		else
		{
			if (stressed)
			{
				string a="";
				a+=phs[i][0];
				a+=phs[i][0];
				phs2.push_back(a);
			}
			else phs2.push_back(phs[i]);
			i+=2;
		}
	}
	return phs2;
}
void printPhonemes(vector<string> phs)
{
	for (int i=0;i<phs.size();++i)
	{
		//cerr<<phs[i]<<" ";
	}
	//cerr<<endl;
}
string applyRules(string word, bool allowAugmenation=0, int allowPronounAugmentation=0, bool stressed=0)
{
	vector<string> phs;
	phs=splitToPhonemes(word);
	printPhonemes(phs);

    phs=degemination(phs);
    //cerr<<"Degemination: ";
	printPhonemes(phs);

    phs=MNACD(phs);
    //cerr<<"MNACD: ";
	printPhonemes(phs);

	if (syllables(phs)>1)
	{
		phs=apocope(phs);
		//cerr<<"Apocope: ";
		printPhonemes(phs);

		phs=clusterReduction(phs);
		//cerr<<"Cluster Reduction: ";
		printPhonemes(phs);

		phs=NACT(phs);
		//cerr<<"NACT: ";
		printPhonemes(phs);
	}

	if (allowAugmenation)
	{
		phs=augmentation(phs);
		//cerr<<"Augmentation: ";
		printPhonemes(phs);

		phs=vowelMerger(phs);
		//cerr<<"Vowel Merger: ";
		printPhonemes(phs);
	}

	if (allowPronounAugmentation)
	{
		phs=pronounAugmentation(phs,allowPronounAugmentation-1);
		//cerr<<"Pronoun Augmentation: ";
		printPhonemes(phs);

		phs=vowelMerger(phs);
		//cerr<<"Vowel Merger: ";
		printPhonemes(phs);
	}

	phs=glideInsertion(phs);
    //cerr<<"Glide Insertion: ";
	printPhonemes(phs);

	phs=vowelDeletion(phs);
	phs=vowelMerger(phs);
    //cerr<<"Vowel Deletion: ";
	printPhonemes(phs);

	phs=vowelLengthening(phs,stressed);
	phs=vowelMerger(phs);
	phs=vowelLengthening(phs,stressed);
	phs=vowelMerger(phs);
	phs=vowelLengthening(phs,stressed);
	phs=vowelMerger(phs);
    //cerr<<"Vowel Lengthening: ";
	printPhonemes(phs);

	word=mergePhonemes(phs);
	return word;
}
string encode(int person, int number, bool harmonic)
{
	string code;

    if (number==1)
	{
		if (person==1) code="10";
		else if (person==2) code="20";
		else code="30"; //person=3
	}
	else if (number==2)
	{
		if (person==0) code="13";
		else if (person==1) code="12";
		else if (person==2) code="22";
		else code="33"; //person=3
	}
	else //number=3
	{
		if (person==0) code="133";
		else if (person==1) code="122";
		else if (person==2) code="222";
		else code="333"; //person=3
	}
	if (number>1)
	{
		if (harmonic==1) code+="h";
		else code+="d";
	}
	return code;
}
vector<string> codes={"10", "20", "30", "13d", "12d", "22d", "33d", "133d", "122d", "222d", "333d", "13h", "12h", "22h", "33h", "133h", "122h", "222h", "333h"};
int main()
{
	string code;
	int case_;
	string word;
	/*while (1)
	{
		cin>>code>>case_;
		cout<<generate_(code,case_,1)<<endl;
	}*/
	for (int k=0;k<codes.size();++k)
	{
		code=codes[k];
		cout<<" "<<code;
		for (case_=0;case_<5;++case_)
		{
			cout<<" & "<<applyRules(generate_(code,case_,1),(code=="10" || code=="30"),(case_==0?(code=="20"?2:1):0),(case_==1 || code=="13d" || code=="22d" || code=="33d"));
		}
		cout<<" \\\\"<<endl;
		cout<<" \\hline"<<endl;
	}

	/*int a,b;
	while (1)
	{
		cin>>word>>a>>b;
		word=applyRules(word,a,b);
		cout<<word<<endl;
	}*/

	return 0;
}
