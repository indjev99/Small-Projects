#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>
#define PI 3.15159265358979323846
using namespace std;
int SAMPLE_RATE=8000;
unsigned long long last;
double lastA;
void seed(unsigned long long a)
{
    srand(a);
    lastA=-1;
}
double random(double a)
{
    if (a!=lastA)
    {
        lastA=a;
        last=rand();
    }
    return double(last)/RAND_MAX;
}
double mod(double a, double b)
{
    return a-floor(a/b)*b;
}
double mod1(double a)
{
    return a-floor(a);
}
unsigned char doubleToUnsignedChar(double a)
{
    a=floor((a+1)*128);
    if (a>=256) a=255;
    return a;
}
char doubleToSignedChar(double a)
{
    a=floor(a*128);
    if (a>=128) a=127;
    return a;
}
double waveSawtooth(double a)
{
    return 2*mod1(a)-1;
}
double waveTriangle(double a)
{
    a=4*mod1(a)-1;
    if (a<=1) return a;
    else return 2-a;
}
double waveSquare(double a)
{
    a=mod1(a);
    if (a<0.5) return -1;
    else return 1;
}
double waveHalfSine(double a)
{
    return sin(mod1(a)*PI)*2-1;
}
double waveSine(double a)
{
    return sin(a*2*PI);
}
double waveCosine(double a)
{
    return cos(a*2*PI);
}
double waveNoise(double a)
{
    return waveSquare(a)*random(floor(fabs(a*2)));
}
double waveWhiteNoise(double a)
{
    return 2*random(a)-1;
}
double waveWithFrequency(double (*wave)(double), double frequency, double &a)
{
    a+=frequency/SAMPLE_RATE;
    return wave(a-frequency/SAMPLE_RATE);
}
double amplitudeModulation(double value, double (*wave)(double), double frequency, double &a)
{
    return (0.5+value/2)*waveWithFrequency(wave,frequency,a);
}
double frequencyModulation(double value, double (*wave)(double), double min_frequency, double range, double &a)
{
    return waveWithFrequency(wave,min_frequency+(0.5+value/2)*range,a);
}
int main()
{
    srand(0);
    ios::sync_with_stdio(0);
    ofstream audio("audio");
    double a;
    a=0;
    for (int i=0;i<10*SAMPLE_RATE;++i)
    {
        audio<<int(doubleToUnsignedChar(waveWithFrequency(waveSine,440,a)))<<'\n';
    }
    return 0;
}
