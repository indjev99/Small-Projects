#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

const int BASE = 10;

vector<char> digits;
vector<vector<int>> numIdxs;
vector<bool> isInit;

vector<int> digVals;
vector<long long> nums;

/// Parameters

const vector<string> numReps = {
    "FORTY",
    "TEN",
    "SIXTY"
};

bool checkEquation()
{
    return nums[0] + nums[1] + nums[1] == nums[2];
}

string equationString()
{
    return to_string(nums[0]) + " + " + to_string(nums[1]) + " + " +
           to_string(nums[1]) + " = " + to_string(nums[2]);
}

/// End Parameters

void preprocess()
{
    numIdxs.resize(numReps.size());
    for (int i = 0; i < numReps.size(); ++i)
    {
        for (int k = 0; k < numReps[i].size(); ++k)
        {
            const char dig = numReps[i][k];
            if (dig >= '0' && dig <= '9')
            {
                numIdxs[i].push_back('0' - dig - 1);
                continue;
            }
            int j;
            for (j = 0; j < digits.size(); ++j)
            {
                if (digits[j] == dig) break;
            }
            if (j == digits.size())
            {
                digits.push_back(dig);
                isInit.push_back(false);
            }
            numIdxs[i].push_back(j);
            if (k == 0) isInit[j] = true;
        }
    }
}

int getDigVal(int idx)
{
    if (idx < 0) return -(idx + 1);
    else return digVals[idx];
}

bool checkSolution()
{
    for (int i = 0; i < digits.size(); ++i)
    {
        if (isInit[i] && digVals[i] == 0) return false;
    }
    for (int i = 0; i < numReps.size(); ++i)
    {
        nums[i] = 0;
        for (int idx : numIdxs[i])
        {
            nums[i] = nums[i] * BASE + getDigVal(idx);
        }
    }
    return checkEquation();
}

void printSolution()
{
    cout << equationString() << endl;
}

vector<int> prevDigVals;

bool stillSame()
{
    bool same = true;
    for (int i = 0; i < digits.size(); ++i)
    {
        if (prevDigVals[i] != digVals[i])
        {
            prevDigVals[i] = digVals[i];
            same = false;
        }
    }
    return same;
}

void solve()
{
    digVals.resize(BASE);
    iota(digVals.begin(), digVals.end(), 0);
    prevDigVals.resize(digits.size());
    fill(prevDigVals.begin(), prevDigVals.end(), -1);
    nums.resize(numReps.size());
    do
    {
        if (stillSame()) continue;
        if (checkSolution()) printSolution();
    }
    while (next_permutation(digVals.begin(), digVals.end()));
}

int main()
{
    preprocess();
    solve();
    return 0;
}
