/*
Finds P(A|B).
*/
#include<iostream>
#include<time.h>
#include<stdlib.h>
using namespace std;
int rand_gen() //generates a random test
{
    return rand()%50;
}
bool meets_requirements(long long a) //tests if B is true
{
    return a%6;
}
bool is_successful(long long a) //tests if A is true
{
    return !(a%3);
}
int test() //test if a random number is divisible by 3 given that it is not divisible by 6
{
    long long r=rand_gen();
    if (!meets_requirements(r)) return -1; //the test did not meet the requirements (B is false)
    if (is_successful(r)) return 1; //the test met the requirements and was successful (B is true and A is true)
    return 0; //the test met the requirements and was not successful (B is true but A is false)
}
int main()
{
    long long n,s=0,nv=0;
    int r;
    double p;
    cout<<"Number of simulations: ";
    cin>>n;
    srand(time(NULL));
    for (long long i=0;i<n;i++)
    {
        r=test();
        if (r==1) s++; //the test met the requirements and was successful
        if (r==-1) //the test did not meet the requirements
        {
            nv++; //ignores the test
            //i--; //repeats the test
            //Both should give the same result. The first one ignores tests that do no meet the requirements and the second one redoes them.
        }
    }
    p=double(s)/double(n-nv);
    cout<<s<<" / "<<n-nv<<"\n"<<p<<"\n";
    return 0;
}
