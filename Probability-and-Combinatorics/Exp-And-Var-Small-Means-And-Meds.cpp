/** Finds expected value and variance of small means/medians versus the actual expected value and variance. */

#include <iostream>
#include <algorithm>
#include <stdlib.h>
#include <time.h>
#include <fstream>
#include <vector>
#include <set>

const std::string FILE_NAME="fileName.csv";
const int SAMPLES=1e6;
const int BATCH_SIZE=5;

std::vector<double> vals;
std::vector<double> means;
std::vector<double> medians;

unsigned long long random_number()
{
    unsigned long long r=0;
    r=r*(RAND_MAX+1)+rand();
    r=r*(RAND_MAX+1)+rand();
    r=r*(RAND_MAX+1)+rand();
    return r;
}

void read_data(std::string fileName)
{
    std::ifstream file(fileName);
    double curr;
    while (file)
    {
        file>>curr;
        vals.push_back(curr);
    }
}

double find_mean(const std::vector<double>& v)
{
    double sum=0;
    for (int i=0;i<v.size();++i)
    {
        sum+=v[i];
    }
    return sum/v.size();
}

double find_median(std::vector<double>& v)
{
    std::sort(v.begin(),v.end());
    if (v.size()%2) return v[v.size()/2];
    else return (v[v.size()/2]+v[v.size()/2-1])/2;
}

std::pair<double,double> find_exp_and_var(const std::vector<double>& v)
{
    double exp=find_mean(v);
    double var=0;
    for (int i=0;i<v.size();++i)
    {
        var+=(v[i]-exp)*(v[i]-exp);
    }
    var/=v.size();
    return {exp,var};
}

void generate_sample(int entries)
{
    std::vector<double> selected;
    std::set<int> added;
    int entry;
    for (int i=0;i<entries;++i)
    {
        do
        {
            entry=random_number()%vals.size();
        }
        while(added.find(entry)!=added.end());
        added.insert(entry);
        selected.push_back(vals[entry]);
    }
    means.push_back(find_mean(selected));
    medians.push_back(find_median(selected));
}

void generate_samples(int samples, int batchSize)
{
    for (int i=0;i<samples;++i)
    {
        generate_sample(batchSize);
    }
}

void find_stats()
{
    std::pair<double,double> expAndVarOfVals=find_exp_and_var(vals);
    std::pair<double,double> expAndVarOfMeans=find_exp_and_var(means);
    std::pair<double,double> expAndVarOfMedians=find_exp_and_var(medians);

    std::cout<<"Values:  "<<"Expected: "<<expAndVarOfVals.first<<" Variance: "<<expAndVarOfVals.second<<std::endl;
    std::cout<<"Means:  "<<"Expected: "<<expAndVarOfMeans.first<<" Variance: "<<expAndVarOfMeans.second<<std::endl;
    std::cout<<"Medians:  "<<"Expected: "<<expAndVarOfMedians.first<<" Variance: "<<expAndVarOfMedians.second<<std::endl;
}

int main()
{
    srand(time(0));
    read_data(FILE_NAME);
    generate_samples(SAMPLES,BATCH_SIZE);
    find_stats();

    return 0;
}
