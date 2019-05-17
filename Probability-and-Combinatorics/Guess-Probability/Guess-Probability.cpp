/** A draws random coin with probability of heads p_1, which has p.d.f f_p.
    Then B guesses q_1, which he claims is equal to p_1.
    The coin is flipped and after that it is discarded.
    The process is repeated n times, where p_1 .. p_n are independent.
    Assuming a null hypothesis that B's claim is correct,
    what is the probability of having this (or a more extreme)
    result from the coin flips (the p-value)?

    We start with designing a metric S to judge B, which measures the
    probability of getting this exact result assuming the null hypothesis.
    For each coin i the probability of landing heads is q_i, and tails (1-q_i).
    Therefore, the product of q-s and (1-q)s (depending on how the coin landed)
    is the probability of getting those results from the flips given that q_i = p_i.
    Notice that this metric is maximized when q_i = p_i, therefore B has no incentive to lie.

    We want to know which percentile the result B got is in (the p-value).
    We first try to model the distribution as a normal distribution,
    and find the number of standard deviations below the mean (Z test).

    We need to find E[S] and SD[S].
    Some algebraic transformations are needed to improve numerical accuracy.
    Also we will usually work in log-scale.

    Let s be the score from one flip.
    s | H = p
      | T = 1-p
    E_p[s] = p^2 + (1-p)^2
    E[s] = integral{0,1}(f_p(x) * (x^2 + (1-x)^2) * dx)
    S = s_1 * s_2 * ... * s_n
    E[S] = E[s]^n.
    Var[S] = E[S^2] - E[S]^2
    s^2 | H = p^2
        | T = (1-p)^2
    E_p[s] = p^3 + (1-p)^3
    E[s^2] = integral{0,1}(f_p(x) * (x^3 + (1-x)^3) * dx)
    S^2 = (s_1 * s_2 * ... * s_n)^2
        = s_1^2 * s_2^2 * ... * s_n^2
    E[S^2] = E[s^2]^n
    Var[S] = E[S^2] - E[S]^2
           = E[S^2] * (1 - E[S]^2 / E[S^2])
    SD[S] = sqrt(Var[S])
    Devs  = (S - E[S]) / SD[S]
          = S / SD[S] - E[S] / SD[S]

    The problem with this approach is that S has a very skewed distribution.
    It is nowhere near a normal distribution, so the result we get is not useful at all.

    However, we can see that log(S) approximately forms a normal distribution, so we can do a Z test to it.
    The larger N is the closer it is to a normal distribution.

    E_p[log(s)] = p * log(p) + (1-p) * log(1-p)
    E[log(s)] = integral{0,1}(f_p(x) * (x * log(x) + (1-x) * log(1-x)) * dx)
    S = s_1 * s_2 * ... * s_n
    log(S) = log(s_1) + log(s_2) + ... + log(s_n)
    E[log(S)] = E[log(s)] * n
    E[log(s)^2] = integral{0,1}(f_p(x) * (x * log(x)^2 + (1-x) * log(1-x)^2) * dx)
    log(S)^2 = (log(s_1) + log(s_2) + ... + log(s_n))^2
    E[log(S)^2] = E[log(s)^2] * n + E[log(s_1)*log(s_2)] * n * (n-1)
                = E[log(s)^2] * n + E[log(s)]^2 * n * (n-1)
    Var[log(S)] = E[log(S)^2] - E[log(S)]^2
    SD[log(S)] = sqrt(Var[log(S)])

    Z = (log(S) - E[log(S)]) / SD[log(S)]
    p = 2 * Phi(-|Z|)

    Assuming the p.d.f. that we have is correct:
    If Z < 0, a low p-value means that B does not know the probabilities.
    If Z > 0, a low p-value means that B can predict the future. */

#include <iostream>
#include <algorithm>
#include <math.h>
#include <random>

std::default_random_engine generator;

struct CoinGenerator
{
public:
    virtual double pdf(double x) const =0;
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
    double pdf(double x) const
    {
        return 1;
    }
    double sample()
    {
        return uniform(generator);
    }
};

struct CoinGeneratorTriangular : CoinGenerator
{
    std::uniform_real_distribution<double> uniform;
public:
    CoinGeneratorTriangular()
    {
        uniform=std::uniform_real_distribution<double>(0,1);
    }
    double pdf(double x) const
    {
        return 2*x;
    }
    double sample()
    {
        return sqrt(uniform(generator));
    }
};

struct CoinGeneratorFairish : CoinGenerator
{
    std::uniform_real_distribution<double> uniform;
    double range;
public:
    CoinGeneratorFairish(double range): range(range)
    {
        uniform=std::uniform_real_distribution<double>(0.5-range/2,0.5+range/2);
    }
    double pdf(double x) const
    {
        if (x<0.5-range/2 || x>0.5+range/2) return 0;
        return 1/range;
    }
    double sample()
    {
        return uniform(generator);
    }
};

struct Predictor
{
public:
    virtual double predict(CoinGenerator* coinGenerator, double p) =0;
};

struct PredictorCorrect : Predictor
{
public:
    double predict(CoinGenerator* coinGenerator, double p)
    {
        return p;
    }
};

struct PredictorSometimes : Predictor
{
    std::uniform_real_distribution<double> uniform;
    const double knowledge;
public:
    PredictorSometimes(double knowledge): knowledge(knowledge)
    {
        uniform=std::uniform_real_distribution<double>(0,1);
    }
    double predict(CoinGenerator* coinGenerator, double p)
    {
        if (uniform(generator)<knowledge) return p;
        return coinGenerator->sample();
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

double find_ln_score(CoinGenerator* coinGenerator, Predictor* predictor, int n)
{
    std::vector<double> elems;
    for (int i=0;i<n;++i)
    {
        double p=coinGenerator->sample();
        double q=predictor->predict(coinGenerator,p);
        int f=flip(p);
        /*if (f) q=0.9;
        else q=0.1;*/
        //std::cerr<<" Coin: "<<p<<" Guess: "<<q<<" Flip: "<<f<<std::endl;
        elems.push_back(log(f ? q : 1-q));
    }
    return safe_sum(elems);
}

double find_ln_expected_score(const CoinGenerator* coinGenerator, int n, int STEPS)
{
    std::vector<double> elems;
    double step=1.0/STEPS;
    for (int i=0;i<STEPS;++i)
    {
        double x=step/2+step*i;
        double s=x*x+(1-x)*(1-x);
        elems.push_back(coinGenerator->pdf(x)*s*step);
    }
    double es=safe_sum(elems);
    return log(es)*n;
}

double find_ln_expected_score_squared(const CoinGenerator* coinGenerator, int n, int STEPS)
{
    std::vector<double> elems;
    double step=1.0/STEPS;
    for (int i=0;i<STEPS;++i)
    {
        double x=step/2+step*i;
        double s2=x*x*x+(1-x)*(1-x)*(1-x);
        elems.push_back(coinGenerator->pdf(x)*s2*step);
    }
    double es2=safe_sum(elems);
    return log(es2)*n;
}

double find_expected_ln_score(const CoinGenerator* coinGenerator, int n, int STEPS)
{
    std::vector<double> elems;
    double step=1.0/STEPS;
    for (int i=0;i<STEPS;++i)
    {
        double x=step/2+step*i;
        double lns=x*log(x)+(1-x)*log(1-x);
        elems.push_back(coinGenerator->pdf(x)*lns*step);
    }
    double elns=safe_sum(elems);
    return elns*n;
}

double find_expected_ln_score_squared(const CoinGenerator* coinGenerator, int n, int STEPS)
{
    std::vector<double> elems;
    std::vector<double> elems2;
    double step=1.0/STEPS;
    for (int i=0;i<STEPS;++i)
    {
        double x=step/2+step*i;
        double lns=x*log(x)+(1-x)*log(1-x);
        double lns2=x*log(x)*log(x)+(1-x)*log(1-x)*log(1-x);
        elems.push_back(coinGenerator->pdf(x)*lns*step);
        elems2.push_back(coinGenerator->pdf(x)*lns2*step);
    }
    double elns=safe_sum(elems);
    double elns2=safe_sum(elems2);
    return elns2*n + elns*elns*n*(n-1);
}

const int N=1e5;
const int STEPS=1e6;
const int TRIALS=10;

#include <conio.h>
#include <fstream>
int main()
{
    // Initialize objects

    CoinGenerator* coinGeneratorUniform=new CoinGeneratorUniform();
    CoinGenerator* coinGeneratorTriangular=new CoinGeneratorTriangular();
    CoinGenerator* coinGeneratorFairish=new CoinGeneratorFairish(0.5);
    Predictor* predictorCorrect=new PredictorCorrect();
    Predictor* predictorSometimes=new PredictorSometimes(0.99);


    CoinGenerator* coinGenerator=coinGeneratorFairish;
    Predictor* predictor=predictorSometimes;

    // Find theoretic results for S

    double lnExpScore;
    double lnExpScore2;
    double lnExp2Score;
    double lnVarScore;
    double lnSDScore;
    double lnEoverSD;
    double lnSoverSD;

    lnExpScore=find_ln_expected_score(coinGenerator,N,STEPS);
    lnExpScore2=find_ln_expected_score_squared(coinGenerator,N,STEPS);
    lnExp2Score=lnExpScore*2;
    lnVarScore=lnExpScore2+log(1-exp(lnExp2Score-lnExpScore2));
    lnSDScore=lnVarScore/2;
    lnEoverSD=lnExpScore-lnSDScore;

    /*std::cout<<"E[S]: "<<lnExpScore<<' '<<exp(lnExpScore)<<std::endl;
    std::cout<<"Var[S]: "<<lnVarScore<<' '<<exp(lnVarScore)<<std::endl;
    std::cout<<"SD[S]: "<<lnSDScore<<' '<<exp(lnSDScore)<<std::endl;
    std::cout<<std::endl;*/


    // Find theoretic results for log(S)

    double expLnScore;
    double expLnScore2;
    double exp2LnScore;
    double varLnScore;
    double SDLnScore;

    expLnScore=find_expected_ln_score(coinGenerator,N,STEPS);
    expLnScore2=find_expected_ln_score_squared(coinGenerator,N,STEPS);
    exp2LnScore=expLnScore*expLnScore;
    varLnScore=expLnScore2-exp2LnScore;
    SDLnScore=sqrt(varLnScore);

    std::cout<<"E[log(S)]: "<<expLnScore<<std::endl;
    std::cout<<"Var[log(S)]: "<<varLnScore<<std::endl;
    std::cout<<"SD[log(S)]: "<<SDLnScore<<std::endl;
    std::cout<<std::endl;


    // Find empiric results

    double lnScore;
    double empExpScore;
    double empVarScore;

    double empExpLnScore;
    double empVarLnScore;

    std::vector<double> expSVect;
    std::vector<double> varSVect;

    std::vector<double> expLnSVect;
    std::vector<double> varLnSVect;

    std::ofstream dataOut("data.txt");

    for (int i=0;i<TRIALS;++i)
    {
        lnScore=find_ln_score(coinGenerator,predictor,N);
        lnSoverSD=lnScore-lnSDScore;

        dataOut<<lnScore<<'\t'<<exp(lnScore)<<'\n';

        /*std::cout<<"S: "<<exp(lnScore)<<std::endl;
        std::cout<<"S - E[S]: "<<exp(lnScore)-exp(lnExpScore)<<std::endl;
        std::cout<<"Z: "<<exp(lnSoverSD)-exp(lnEoverSD)<<std::endl;
        std::cout<<std::endl;*/

        std::cout<<"log(S): "<<lnScore<<std::endl;
        std::cout<<"log(S) - E[log(S)]: "<<lnScore-expLnScore<<std::endl;
        std::cout<<"Z log: "<<(lnScore-expLnScore)/SDLnScore<<std::endl;
        std::cout<<std::endl;

        expSVect.push_back(exp(lnScore));

        expLnSVect.push_back(lnScore);
    }
    //std::cout<<std::endl;

    empExpScore=safe_sum(expSVect)/TRIALS;

    empExpLnScore=safe_sum(expLnSVect)/TRIALS;

    for (int i=0;i<TRIALS;++i)
    {
        double diff=expSVect[i]-empExpScore;
        varSVect.push_back(diff*diff);

        diff=expLnSVect[i]-empExpLnScore;
        varLnSVect.push_back(diff*diff);
    }

    empVarScore=safe_sum(varSVect)/TRIALS;

    empVarLnScore=safe_sum(varLnSVect)/TRIALS;

    /*std::cout<<"Empiric E[S]: "<<empExpScore<<std::endl;
    std::cout<<"Empiric Var[S]: "<<empVarScore<<std::endl;
    std::cout<<"Empiric SD[S]: "<<sqrt(empVarScore)<<std::endl;
    std::cout<<std::endl;*/

    std::cout<<"Empiric E[log(S)]: "<<empExpLnScore<<std::endl;
    std::cout<<"Empiric Var[log(S)]: "<<empVarLnScore<<std::endl;
    std::cout<<"Empiric SD[log(S)]: "<<sqrt(empVarLnScore)<<std::endl;
    std::cout<<std::endl;


    return 0;
}
