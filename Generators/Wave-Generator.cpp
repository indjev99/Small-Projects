#include<iostream>
#include<fstream>
#include<math.h>
#define PI 3.15159265358979323846
using namespace std;
const unsigned long long A=18054258203;
const unsigned long long B=22897202357;
const unsigned long long C=17275599613;
const unsigned long long M=86042711;
unsigned long long randomLL(unsigned long long a)
{
    return (A*a*a+B*a+C)%M;
}
unsigned long long last;
unsigned long long lastA;
void seed(unsigned long long a)
{
    last=a;
    lastA=-1;
}
double random(unsigned long long a)
{
    if (a!=lastA)
    {
        lastA=a;
        last=randomLL(last);
    }
    return double(last)/M;
}
double mod(double a, double b)
{
    return a-floor(a/b)*b;
}
double mod1(double a)
{
    return a-floor(a);
}
char doubleToUnsignedChar(double a)
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
    return waveSquare(a)*random(fabs(a*2));
}
double waveWhiteNoise(double a)
{
    return 2*random(fabs(a*2))-1;
}
double waveWithFrequency(double (*wave)(double), double frequency, double &a)
{
    a=a+frequency;
    return wave(a-frequency);
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
    int SAMPLE_RATE=44100;
    ios::sync_with_stdio(0);
    //ofstream test("test.txt");
    //ofstream test2("test2.txt");
    ofstream audio("audio");
    ofstream audio1("audio1");
    ofstream audio2("audio2");
    ofstream audio3("audio3");
    double a1,a2,a3,a4,a5,val;
    char c;
    a1=0;
    a2=0;
    a3=0;
    a4=0;
    a5=0;
    for (int i=0;i<(1<<24);++i)
    {
        val=waveWithFrequency(waveSine,4.1/SAMPLE_RATE,a1)*0.4+waveWithFrequency(waveSine,6.34/SAMPLE_RATE,a2)*0.35,+waveWithFrequency(waveSine,12.32/SAMPLE_RATE,a3)*0.25;
        audio1<<doubleToSignedChar(val);
        audio2<<doubleToSignedChar(amplitudeModulation(val,waveSine,500.0/SAMPLE_RATE,a4));
        audio3<<doubleToSignedChar(frequencyModulation(val,waveSine,25.0/SAMPLE_RATE,25.0/SAMPLE_RATE,a5));
    }
    return 0;
}
