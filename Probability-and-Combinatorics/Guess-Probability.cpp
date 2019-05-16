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
    E[s^2] = integral{0,1}(f_p(x) * (x^2 - (1-x)^2)^2 * dx)  // Empiric testing has shown there is a mistake here
    E[S^2] = E[s^2]^n                                        //
    Var[S] = E[S^2] - E[S]^2
           = E[S^2] * (1 - E[S]^2 / E[S^2])
    SD[S] = Sqrt(Var[S])
    Devs  = (S - E[S]) / SD[S]
          = S / SD[S] - E[S] / SD[S]
    Due to working with small numbers we will usually work in log-scale to improve accuracy. */

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
        double sp=x*x+(1-x)*(1-x);
        elems.push_back(coinGenerator->pdf(x)*sp*step);
    }
    double s=safe_sum(elems);
    return log(s)*n;
}

double find_ln_expected_score_squared(const CoinGenerator* coinGenerator, int n, int STEPS)
{
    std::vector<double> elems;
    double step=1.0/STEPS;
    for (int i=0;i<STEPS;++i)
    {
        double x=step/2+step*i;
        double sp=x*x+(1-x)*(1-x);
        elems.push_back(coinGenerator->pdf(x)*sp*sp*step);
    }
    double s=safe_sum(elems);
    return log(s)*n;
}

const int N=50;
const int STEPS=1e5;

#include <conio.h>
int main()
{
    CoinGenerator* coinGeneratorUniform=new CoinGeneratorUniform();
    Predictor* predictorCorrect=new PredictorCorrect();
    Predictor* predictorBiased=new PredictorBiased(1);


    double lnScore;
    double lnExpScore;
    double lnExpScore2;
    double lnExp2Score;
    double lnVarScore;
    double lnSDScore;
    double lnEoverSD;
    double lnSoverSD;
    double devs;


    lnExpScore=find_ln_expected_score(coinGeneratorUniform,N,STEPS);
    lnExpScore2=find_ln_expected_score_squared(coinGeneratorUniform,N,STEPS);
    lnExp2Score=lnExpScore*2;
    lnVarScore=lnExpScore2+log(1-exp(lnExp2Score-lnExpScore2));
    lnSDScore=lnVarScore/2;
    lnEoverSD=lnExpScore-lnSDScore;


    std::cout<<"E[S]: "<<lnExpScore<<' '<<exp(lnExpScore)<<std::endl;
    std::cout<<"E[S^2]: "<<lnExpScore2<<' '<<exp(lnExpScore2)<<std::endl;
    std::cout<<"E[S]^2: "<<lnExp2Score<<' '<<exp(lnExp2Score)<<std::endl;
    std::cout<<"Var[S]: "<<lnVarScore<<' '<<exp(lnVarScore)<<std::endl;
    std::cout<<"SD[S]: "<<lnSDScore<<' '<<exp(lnSDScore)<<std::endl;
    std::cout<<"E[S] / SD[S]: "<<lnEoverSD<<' '<<exp(lnEoverSD)<<std::endl;


    int cnt=0;
    std::vector<double> expVect;
    std::vector<double> exp2Vect;
    std::vector<double> varVect;

    for (int i=0;i<1e7;++i)
    {
        lnScore=find_ln_score(coinGeneratorUniform,predictorBiased,N);
        lnSoverSD=lnScore-lnSDScore;
        devs=exp(lnSoverSD)-exp(lnEoverSD);

        /*std::cout<<std::endl;
        std::cout<<"S: "<<lnScore<<' '<<exp(lnScore)<<std::endl;
        std::cout<<"S / SD[S]: "<<lnSoverSD<<' '<<exp(lnSoverSD)<<std::endl;
        std::cout<<"(S - E[S]) / SD[S]: "<<devs<<std::endl;*/

        ++cnt;
        double diff=exp(lnScore)-exp(lnExpScore);
        expVect.push_back(exp(lnScore));
        exp2Vect.push_back(exp(lnScore*2));
        varVect.push_back(diff*diff);
    }

    double empExpScore=safe_sum(expVect)/cnt;
    double empExpScore2=safe_sum(exp2Vect)/cnt;
    double empExp2Score=empExpScore*empExpScore;
    double empVarScore=safe_sum(varVect)/cnt;

    std::cout<<std::endl;
    std::cout<<"Empiric E[S]: "<<empExpScore<<std::endl;
    std::cout<<"Empiric E[S^2]: "<<empExpScore2<<std::endl;
    std::cout<<"Empiric E[S]^2: "<<empExp2Score<<std::endl;
    std::cout<<"Empiric Var[S]2: "<<empExpScore2-empExp2Score<<std::endl;
    std::cout<<"Empiric Var[S]: "<<empVarScore<<std::endl;
    std::cout<<"Empiric SD[S]: "<<sqrt(empVarScore)<<std::endl;


    return 0;
}
