#include <iostream>
#include <algorithm>
#include <stdlib.h>
#include <time.h>
#include <vector>
using namespace std;

const int MAX_N=3;
const int STATES=5;

struct Algorithm
{
private:
    vector<pair<int,int>> actions;
    int random_action() const
    {
        if (rand()%4) return rand()%2;
        else return rand()%2-MAX_N;
    }

public:
    void randomize(int states)
    {
        actions.resize(2*states);
        for (int i=0;i<actions.size();++i)
        {
            actions[i].first=rand()%states;
            actions[i].second=random_action();
        }
    }
    pair<int, int> get_action(int state, bool light) const
    {
        return actions[2*state+light];
    }
};
struct Prisoner
{
private:
    int state;
    bool light,next_light;
    const Algorithm* alg;

public:
    void init(const Algorithm& alg)
    {
        state=0;
        light=false;
        this->alg=&alg;
    }
    int get_action()
    {
        pair<int,int> action=alg->get_action(state,light);
        light=next_light;
        state=action.first;
        return action.second;
    }
    void see_light(bool light)
    {
        next_light=light;
    }
};
struct Prison
{
private:
    int n;
    Algorithm leader,pleb;
    vector<Prisoner> prisoners;

public:
    void randomize(int states)
    {
        leader.randomize(states);
        pleb.randomize(states);
    }
    void init(int n)
    {
        this->n=n;
        prisoners.resize(n);
        if (n) prisoners[0].init(leader);
        for (int i=1;i<n;++i)
        {
            prisoners[i].init(pleb);
        }
    }
    int update()
    {
        random_shuffle(prisoners.begin(),prisoners.end());
        int action;
        int ret=0;
        for (int i=0;i<n;++i)
        {
            action=prisoners[i].get_action();
            if (action<0)
            {
                if (action!=-n) ret=-1;
                else if (ret==0) ret=1;
            }
            else prisoners[(i+1)%n].see_light(action);
        }
        return ret;
    }
    bool run(int maxIter)
    {
        int ret=0;
        int iter=0;
        while (!ret && iter<maxIter)
        {
            ret=update();
            ++iter;
        }
        if (ret==1) return true;
        else return false;
    }
};

int main()
{
    Prison p;
    srand(1337);
    bool fail;
    while (true)
    {
        p.randomize(STATES);
        fail=false;
        for (int i=0;i<100;++i)
        {
            p.init(MAX_N-rand()%2);
            if (!p.run(1000))
            {
                fail=true;
                cerr<<"Failed on "<<i<<".\n";
                break;
            }
        }
        if (!fail)
        {
            std::cerr<<"Passed 100 trials successfully at "<<clock()*1.0/CLOCKS_PER_SEC<<".\n";
            system("pause");
        }
    }
    return 0;
}
