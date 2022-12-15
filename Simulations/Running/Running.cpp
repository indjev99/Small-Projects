#include<iostream>
using namespace std;

const double DISTANCE=50;
const double TIME=6.7;

const double DELTA_T=1e-4;
const double EPS=1e-6;

struct Human
{
    double mass;
    double a,b;
};

double drag(double speed, Human &human)
{
    return 0.55*1.2*1.2*speed*speed/2/human.mass;
}

double acceleration(double speed, Human &human)
{
    return (speed*human.a+human.b)/human.mass;
}

double runDistance(double dist, Human &human, double wind)
{
    ///returns the time

    double t=0;
    double d=0;
    double v=0;

    while (d<dist)
    {
        //cerr<<t<<" "<<v<<" "<<d<<endl;
        t+=DELTA_T;
        d+=v*DELTA_T;
        v+=(acceleration(v,human)+((v>wind)?-1:1)*drag(v-wind,human))*DELTA_T;
    }

    return t;
}

double runTime(double time, Human &human, double wind)
{
    ///returns the distance

    double t=0;
    double d=0;
    double v=0;

    while (t<time)
    {
        t+=DELTA_T;
        d+=v*DELTA_T;
        v+=(acceleration(v,human)+((v>wind)?-1:1)*drag(v-wind,human))*DELTA_T;
    }

    return d;
}
double findB(double max_speed, double a)
{
    return -max_speed*a;
}
Human &findAB(double time, double dist, double mass, double max_speed, double wind)
{
    Human human;
    human.mass=mass;

    double curr_t;
    double l=0.01,r=50000;

    while (r-l>EPS)
    {
        human.a=-(r+l)/2;
        human.b=findB(max_speed,human.a);
        curr_t=runDistance(dist,human,wind);
        //cerr<<l<<" "<<r<<" "<<curr_t<<endl;
        if (curr_t<time) r=-human.a;
        else l=-human.a;
    }

    return human;
}

int main()
{
    Human student;
    student=findAB(6.7,50,75,9,0);
    cout<<runDistance(50,student,-5)<<endl;

    return 0;
}
