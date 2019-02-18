#include<iostream>
#include<iomanip>
#include<vector>
#include<math.h>
using namespace std;

typedef long double ld;

class Function
{
private:
    bool derivativeSet=false;
protected:
    Function* derivative;
    virtual void setDerivative()
    {
        derivative=nullptr;
    }
public:
    Function* getDerivative()
    {
        if (!derivativeSet)
        {
            setDerivative();
            derivativeSet=true;
        }
        return derivative;
    }
    bool hasDerivative()
    {
        if (!derivativeSet)
        {
            setDerivative();
            derivativeSet=true;
        }
        return derivative;
    }
    virtual bool isZero() const
    {
        return false;
    }
    virtual bool isConst() const
    {
        return false;
    }
    virtual ld getConst() const {}
    static Function* Zero;
    static Function* One;
    static Function* Identity;
    static Function* Sin;
    virtual ld eval(ld x) const = 0;
};

class ZeroFunction : public Function
{
public:
    void setDerivative()
    {
        derivative=this;
    }
    ld eval(long double x) const
    {
        return 0;
    }
};

class ConstFunction : public Function
{
protected:
    ld c;
public:
    ConstFunction(ld c): c(c) {}
    void setDerivative()
    {
        derivative=Zero;
    }
    ld eval(ld x) const
    {
        return c;
    }
    bool isConst() const
    {
        return true;
    }
    ld getConst() const
    {
        return c;
    }
};

class IdentityFunction : public Function
{
public:
    void setDerivative()
    {
        derivative=One;
    }
    ld eval(ld x) const
    {
        return x;
    }
};

class FunctionScaled : public Function
{
protected:
    Function* f;
    ld scalar;
public:
    FunctionScaled(Function* f, ld scalar): f(f), scalar(scalar) {}
    void setDerivative()
    {
        if (!f->hasDerivative()) return;
        derivative=new FunctionScaled(f->getDerivative(),scalar);
    }
    ld eval(ld x) const
    {
        return scalar*f->eval(x);
    }
};

class FunctionSum : public Function
{
protected:
    Function* f;
    Function* g;
public:
    FunctionSum(Function* f, Function* g): f(f), g(g) {};
    void setDerivative()
    {
        if (!f->hasDerivative()) return;
        if (!g->hasDerivative()) return;
        derivative=new FunctionSum(f->getDerivative(), g->getDerivative());
    }
    ld eval(ld x) const
    {
        return f->eval(x)+g->eval(x);
    }
};

class FunctionProduct : public Function
{
protected:
    Function* f;
    Function* g;
public:
    FunctionProduct(Function* f, Function* g): f(f), g(g) {};
    void setDerivative()
    {
        if (!f->hasDerivative()) return;
        if (!g->hasDerivative()) return;
        derivative=new FunctionSum(new FunctionProduct(f->getDerivative(),g),
                                   new FunctionProduct(f,g->getDerivative()));
    }
    ld eval(ld x) const
    {
        return f->eval(x)*g->eval(x);
    }
};

class FunctionComposition : public Function
{
protected:
    Function* f;
    Function* g;
public:
    FunctionComposition(Function* f, Function* g): f(f), g(g) {};
    void setDerivative()
    {
        if (!f->hasDerivative()) return;
        if (!g->hasDerivative()) return;
        derivative=new FunctionProduct(new FunctionComposition(f->getDerivative(),g),
                                       g->getDerivative());
    }
    ld eval(ld x) const
    {
        return f->eval(g->eval(x));
    }
};

class PowerFunction : public Function
{
protected:
    ld power;
public:
    PowerFunction(ld power): power(power) {};
    void setDerivative()
    {
        derivative=new FunctionScaled(new PowerFunction(power-1),power);
    }
    ld eval(ld x) const
    {
        return pow(x,power);
    }
};

class SinFunction : public Function
{
public:
    void setDerivative()
    {
        derivative=new FunctionComposition(new PowerFunction(0.5),
                   new FunctionSum(new FunctionScaled(new FunctionComposition
                   (new PowerFunction(2),this),-1),One));
    }
    ld eval(ld x) const
    {
        return sin(x); ///make with ld
    }
};

Function* Function::Zero=new ZeroFunction;
Function* Function::One=new ConstFunction(1);
Function* Function::Identity=new IdentityFunction;
Function* Function::Sin=new SinFunction;

class FunctionSumMany : public Function
{
protected:
    vector<Function*> fs;
public:
    FunctionSumMany(const vector<Function*>& f): fs(fs) {};
    void addFunction(Function* f)
    {
        fs.push_back(f);
    }
    void setDerivative()
    {
        vector<Function*> df(fs.size());
        for (int i=0;i<fs.size();++i)
        {
            if (!fs[i]->hasDerivative()) return;
            df[i]=fs[i]->getDerivative();
        }
        derivative=new FunctionSumMany(df);
    }
    ld eval(ld x) const
    {
        ld ans;
        for (int i=0;i<fs.size();++i)
        {
            ans+=fs[i]->eval(x);
        }
        return ans;
    }
};



class Integral : public Function
{
public:
    ld pivot;
    Function* integrand;
    Integral(Function* integrand, ld pivot): integrand(integrand), pivot(pivot) {}
};

class IntegralNumeric : public Integral
{
protected:
    long long precision;
public:
    using Integral::Integral;
    void setPrecision(long long precision)
    {
        this->precision=precision;
    }
};

class IntegralSimpson : public IntegralNumeric
{
public:
    using IntegralNumeric::IntegralNumeric;
    ld eval(ld x) const
    {
        long long n=(precision+1)/2;
        ld width=x-pivot;
        ld ans=0;
        ans+=integrand->eval(pivot);
        ans+=integrand->eval(x);
        for (long long i=1;i<n;++i)
        {
            if (i%2) ans+=4*integrand->eval(pivot+width*i/n);
            else ans+=2*integrand->eval(pivot+width*i/n);
        }
        ans*=(x-pivot)/(3*n);
        return ans;
    }
};

int main()
{
    auto f = new PowerFunction(1);
    auto g = f->getDerivative();
    auto d = g->getDerivative();
    cout<<f->eval(2)<<" "<<g->eval(2)<<" "<<d->eval(2)<<endl;
}
