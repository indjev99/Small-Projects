/** A draws random coin with probability of heads p_1, which has p.d.f f_p.
    Then B guesses q_1, which he claims is equal to p_1.
    The coin is flipped and after that it is discarded.
    The process is repeated n times, where p_1 .. p_n are independent.
    Assuming a null hypothesis that B's claim is correct,
    what is the probability of having this (or a more extreme)
    result from the coin flips (the p-value)? */

/** We start with designing a metric S to judge B, which measures the
    probability of getting this exact result assuming the null hypothesis.
    For each coin i the probability of landing heads is q_i, and tails (1-q_i).
    Therefore, the product of q-s and (1-q)s (depending on how the coin landed)
    is the probability of getting those results from the flips given that q_i = p_i.
    Notice that this metric is maximized when q_i = p_i, therefore B has no incentive to lie.*/

/** Now we want to know the expected value of S - E[S] and find the difference.
    Then we need to divide that by the standard deviation of S and finally covert to a p-value.
    Let s be the score from one flip.
    E[s] = integral{0,1}(f_p(x) * (x^2 - (1-x)^2) * dx)
    E[S] = E[s]^n.
    Var[S] = E[S^2] - E[S]^2
    E[s^2] = integral{0,1}(f_p(x) * (x^2 - (1-x)^2)^2 * dx)
    E[S^2] = E[s^2]^n
    Due to working with small numbers we will usually work in log-scale to improve accuracy. */

#include <iostream>
#include <algorithm>
#include <math.h>
#include <random>

std::default_random_engine generator;

struct CoinGenerator
{
public:
    virtual double pdf(double x) =0;
    virtual double sample() =0;
};

struct CoinGeneratorUniform : CoinGenerator
{
    std::uniform_real_distribution<double> uniform;
public:
    CoinGeneratorUniform()
    {
        uniform=std::uniform_real_distribution<double>(0,1);
    }
    double pdf(double x)
    {
        return 1;
    }
    double sample()
    {
        return uniform(generator);
    }
};

struct Predictor
{
public:
    virtual double predict(double p) const =0;
};

struct PredictorCorrect : Predictor
{
public:
    double predict(double p) const
    {
        return p;
    }
};

struct PredictorBiased : Predictor
{
    const double bias;
public:
    PredictorBiased(double bias): bias(bias) {}
    double predict(double p) const
    {
        return p*bias;
    }
};

double flip(double p)
{
    std::discrete_distribution<int> coin{1-p,p};
    return coin(generator);
}

bool cmpByAbs(double a, double b)
{
    return std::abs(a)<std::abs(b);
}

// Function to minimize error when summing a list of numbers.
double safe_sum(std::vector<double>& v)
{
    std::sort(v.begin(),v.end(),cmpByAbs);
    double total=0;
    for (int i=0;i<v.size();++i)
    {
        total+=v[i];
    }
    return total;
}

double find_ln_score(CoinGenerator* coinGenerator, const Predictor* predictor, int n)
{
    std::vector<double> elems;
    for (int i=0;i<n;++i)
    {
        double p=coinGenerator->sample();
        double q=predictor->predict(p);
        int flipResult=flip(p);
        elems.push_back(log(flipResult ? q : 1-q));
    }
    return safe_sum(elems);
}

#include <conio.h>
int main()
{
    CoinGenerator* coinGeneratorUniform=new CoinGeneratorUniform();
    Predictor* predictorCorrect=new PredictorCorrect();
    Predictor* predictorBiased=new PredictorBiased(0.9);

    double lnScore;
    while (1)
    {
        lnScore=find_ln_score(coinGeneratorUniform,predictorCorrect,10000);
        std::cout<<lnScore<<' '<<exp(lnScore)<<'\n';
        getch();
    }


    return 0;
}
