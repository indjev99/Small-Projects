/*
N pirates are dividing up a treasure consisting of K indivisible gold coins of equal worth.
The pirates have a total-order hierarchy, i.e. one pirate is above all others, the next one is above all others except the first and so on.
The process works like this: The highest ranking pirate who is still alive proposes how he would like to divide the treasure.
Then all living pirates (including him) vote on the proposal. If at least/more than half of the pirates alive vote for the proposal,
then it is accepted, otherwise the pirate who made the proposal is killed and the process is repeated.
The pirates are perfectly intelligent, logical and rational. Each pirate's priorities are, in this order: Survival,
wealth (getting the highest number of coins possible), bloodthirstiness (seeing as many pirates killed as possible, other than himself).
In other words a pirate will always choose an outcome in which he lives over one in which he dies.
Given two outcomes in which he lives, he will choose the one where he gets more coins.
And given two outcomes in which he lives and gets the same number of coins he will choose the one in which the highest number of other pirates die.
How will the gold coins be divided?
*/
#include<iostream>
#include<algorithm>
using namespace std;
const int MAX_N=1000000;
int curr_offer[MAX_N]; //the current offer for each pirate
struct offer
{
    int old_ind;
    int offer;
};
bool operator<(offer a, offer b)
{
    return a.offer<b.offer;
}
offer new_offer[MAX_N];
int n;
int k;
void input()
{
    cin>>n>>k;
}
void output(int a)
{
    for (int i=0;i<a;i++)
    {
        cout<<i<<": "<<curr_offer[i]<<"\n";
    }
}
void calc(int a)
{
    ++a;
    int a2;
    a2=(a-1)/2;
    //a2=a/2;
    /*
    Choose between one of those 2.
    The first one means that at least half of the votes are needed and the second one means that more than half are needed.
    */
    int cur_g=k;
    for (int i=0;i<a;++i)
    {
        new_offer[i].offer=curr_offer[i];
        new_offer[i].old_ind=i;
    }
    sort(new_offer,new_offer+a-1); //sort the pirates by their current offer
    for (int i=0;i<a2;++i) //increase the offer to half of the pirates (the cheapest half) so that they vote for the current pirate
    {
        ++new_offer[i].offer;
        cur_g-=new_offer[i].offer;
        if (cur_g<0) break;
    }
    if (cur_g<0) //there isn't enough gold for that so he dies
    {
        curr_offer[a-1]=-1;
        return;
    }
    for (int i=a2;i<a;i++) //set the offer to the other half to 0
    {
        new_offer[i].offer=0;
    }
    for (int i=0;i<a;i++) //update the new offers
    {
        curr_offer[new_offer[i].old_ind]=new_offer[i].offer;
    }
    curr_offer[a-1]=cur_g;
}
void solve()
{
    for (int i=0;i<n;i++)
    {
        calc(i);
    }
}
int main()
{
    input();
    solve();
    output(n);
    return 0;
}
