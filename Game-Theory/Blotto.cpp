#include <iostream>
#include <iomanip>
#include <vector>
#include <algorithm>
#include <set>
#include <numeric>
#include <random>
#include <assert.h>
#include <time.h>

std::mt19937 generator;

int randNum(int lb, int ub)
{
    std::uniform_int_distribution<int> distribution(lb, ub - 1);
    return distribution(generator);
}

const bool USE_MULT = false;
const int TOTAL_MULT = 1;

struct Strategy
{
    static int currId;

    int id;
    std::vector<int> castleSoldiers;
    std::vector<int> mults;
    long long totalScore;
    int numBattles;
    double avgScore;

    Strategy():
        id(currId++),
        totalScore(0),
        numBattles(0),
        avgScore(0) {}

    Strategy(int numCastles, int numSoldiers):

        id(currId++),
        castleSoldiers(numCastles, 0),
        mults(castleSoldiers.size(), TOTAL_MULT),
        totalScore(0),
        numBattles(0),
        avgScore(0)
    {
        for (int i = 0; i < numSoldiers; ++i)
        {
            ++castleSoldiers[randNum(0, numCastles)];
        }
    }

    Strategy(const Strategy& strat, int numMutations):
        id(currId++),
        castleSoldiers(strat.castleSoldiers),
        mults(castleSoldiers.size(), TOTAL_MULT),
        totalScore(0),
        numBattles(0),
        avgScore(0)
    {
        for (int i = 0; i < numMutations; ++i)
        {
            if (randNum(1, 100) < 98)
            {
                int from = randNum(0, castleSoldiers.size());
                int to = randNum(0, castleSoldiers.size() - 1);
                if (to == from) ++to;
                if (castleSoldiers[from] > 0)
                {
                    --castleSoldiers[from];
                    ++castleSoldiers[to];
                }
                else --i;
            }
            else if (randNum(1, 2) == 1)
            {
                int to = randNum(0, castleSoldiers.size());
                int n = randNum(5, 65);
                for (int i = 0; i < n; ++i)
                {
                    int pos = randNum(0, castleSoldiers.size());
                    if (castleSoldiers[pos] > 0) --castleSoldiers[pos];
                    else --i;
                }
                castleSoldiers[to] += n;
            }
            else
            {
                int from = randNum(0, castleSoldiers.size());
                int n = castleSoldiers[from];
                if (n > 0)
                {
                    castleSoldiers[from] = 0;
                    for (int i = 0; i < n; ++i)
                    {
                        ++castleSoldiers[randNum(0, castleSoldiers.size())];
                    }
                }
                else --i;
            }
        }
    }

    Strategy(std::initializer_list<int> castleSoldiers):
        id(currId++),
        castleSoldiers(castleSoldiers),
        mults(castleSoldiers.size(), TOTAL_MULT),
        totalScore(0),
        numBattles(0),
        avgScore(0) {}

    void resetScore()
    {
        totalScore = 0;
        numBattles = 0;
        avgScore = 0;
    }

    void findAvgScore()
    {
        if (numBattles > 0) avgScore = totalScore * 1.0 / numBattles / TOTAL_MULT;
        else avgScore = 0;
    }
};

namespace std
{
    void swap(Strategy& a, Strategy& b)
    {
        std::swap(a.id, b.id);
        std::swap(a.castleSoldiers, b.castleSoldiers);
        std::swap(a.mults, b.mults);
        std::swap(a.totalScore, b.totalScore);
        std::swap(a.numBattles, b.numBattles);
        std::swap(a.avgScore, b.avgScore);
    }
}

int Strategy::currId = 0;

bool operator<(const Strategy& left, const Strategy& right)
{
    return left.avgScore < right.avgScore;
}

bool operator>(const Strategy& left, const Strategy& right)
{
    return left.avgScore > right.avgScore;
}

#define NONE 0
#define LEFT 1
#define RIGHT 2
#define BOTH 3

struct RuleSet
{
    const int numCastles;
    const int numSoldiers;
    const std::vector<int> castleScores;
    const int totalScore;

    RuleSet(int numCastles, int numSoldiers, std::initializer_list<int> castleScores):
        numCastles(numCastles),
        numSoldiers(numSoldiers),
        castleScores(castleScores),
        totalScore(std::accumulate(castleScores.begin(), castleScores.end(), 0))
    {
        assert(castleScores.size() == numCastles);
    }

    bool validate(Strategy& strat)
    {
        if (strat.castleSoldiers.size() != numCastles) return false;
        int sum = 0;
        for (int soldiers : strat.castleSoldiers)
        {
            if (soldiers < 0) return false;
            sum += soldiers;
        }
        if (sum > numSoldiers) return false;
        findMults(strat);
        return true;
    }

    virtual void resolve(Strategy& left, Strategy& right)
    {
        resetState();
        ++left.numBattles;
        ++right.numBattles;
        for (int i = 0; i < numCastles; ++i)
        {
            const int leftSoldiers = left.castleSoldiers[i];
            const int rightSoldiers = right.castleSoldiers[i];
            const int currScore = castleScores[i];
            const int res = resolveOne(leftSoldiers, rightSoldiers);
            switch (res)
            {
            case NONE:
                break;
            
            case LEFT:
                if constexpr (USE_MULT) left.totalScore += currScore * left.mults[i];
                else left.totalScore += currScore;
                break;
            
            case RIGHT:
                if constexpr (USE_MULT) right.totalScore += currScore * right.mults[i];
                else right.totalScore += currScore;
                break;
            
            case BOTH:
                if constexpr (USE_MULT)
                {
                    left.totalScore += currScore * left.mults[i] / 2;
                    right.totalScore += currScore * right.mults[i] / 2;
                }
                else
                {
                    std::cerr << "Warning: dividing by two for tie with no mults." << std::endl;
                    left.totalScore += currScore / 2;
                    right.totalScore += currScore/ 2;
                }
                break;
            
            default:
                std::cerr << "Error: Unknown result code from resolveOne: " << res << std::endl;
            }
        }
    }

protected:

    virtual void findMults(Strategy& strat) {}

    virtual void resetState() {}

    virtual int resolveOne(int leftSoldiers, int rightSoldiers)
    {
        if (leftSoldiers > rightSoldiers) return LEFT;
        if (leftSoldiers < rightSoldiers) return RIGHT;
        return NONE;
    }
};

struct ExampleRuleSet : public RuleSet
{
    ExampleRuleSet(): RuleSet(10, 100, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}) {}
};

struct Round1RuleSet : public RuleSet
{
    Round1RuleSet(): RuleSet(10, 100, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}) {}

protected:

    int maxLeftVictory;
    int maxRightVictory;

    void resetState() override
    {
        maxLeftVictory = 1;
        maxRightVictory = 1;
    }

    int resolveOne(int leftSoldiers, int rightSoldiers) override
    {
        int leftVictory = leftSoldiers - rightSoldiers;
        int rightVictory = rightSoldiers - leftSoldiers;
        if (leftVictory >= maxLeftVictory)
        {
            maxLeftVictory = leftVictory;
            return LEFT;
        }
        if (rightVictory >= maxRightVictory)
        {
            maxRightVictory = rightVictory;
            return RIGHT;
        }
        return NONE;
    }
};

struct Round2RuleSet : public RuleSet
{
    Round2RuleSet(): RuleSet(10, 100, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}) {}

private:
    
    void findMults(Strategy& strat) override
    {
        std::set<int> armySizes;
        double sum = 0;
        for (int i = 0; i < numCastles; ++i)
        {
            armySizes.insert(strat.castleSoldiers[i]);
            strat.mults[i] = TOTAL_MULT / armySizes.size();
            sum += strat.mults[i] * 1.0 / TOTAL_MULT * (i + 1);
        }
    }

};

struct Round3RuleSet : public RuleSet
{
    Round3RuleSet(): RuleSet(10, 100, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}) {}

protected:
    
    void findMults(Strategy& strat) override
    {
        std::vector<int > mxPos;
        int mxArmy = -1;
        for (int i = 0; i < numCastles; ++i)
        {
            if (strat.castleSoldiers[i] > mxArmy)
            {
                mxArmy = strat.castleSoldiers[i];
                mxPos.clear();
                mxPos.push_back(i);
            }
            else if (strat.castleSoldiers[i] == mxArmy)
            {
                mxPos.push_back(i);
            }
        }
        for (int i = 0; i < numCastles; ++i)
        {
            int minDist = numCastles * 2;
            for (int p : mxPos)
            {
                int dist = abs(i - p);
                minDist = std::min(minDist, dist);
            }
            strat.mults[i] = minDist;
        }
    }
};

struct Round4RuleSet : public RuleSet
{
    Round4RuleSet(): RuleSet(10, 100, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}) {}

    void resolve(Strategy& left, Strategy& right) override
    {
        resetState();
        ++left.numBattles;
        ++right.numBattles;
        int leftWins = 0;
        int rightWins = 0;
        for (int i = 0; i < numCastles; ++i)
        {
            if (leftWins == 2 && rightWins == 2) return;
            const int leftSoldiers = left.castleSoldiers[i];
            const int rightSoldiers = right.castleSoldiers[i];
            const int currScore = castleScores[i];
            const int res = resolveOne(leftSoldiers, rightSoldiers);
            switch (res)
            {
            case NONE:
                break;
            
            case LEFT:
                ++leftWins;
                left.totalScore += currScore;
                break;
            
            case RIGHT:
                ++rightWins;
                right.totalScore += currScore;
                break;
            
            default:
                std::cerr << "Error: Unknown result code from resolveOne: " << res << std::endl;
            }
        }
    }
};

struct Round5RuleSet : public RuleSet
{
    Round5RuleSet(): RuleSet(10, 100, {10, 9, 8, 7, 6, 5, 4, 3, 2, 1}) {}

    void resolve(Strategy& left, Strategy& right) override
    {
        resetState();
        ++left.numBattles;
        ++right.numBattles;
        int leftWins = 0;
        int rightWins = 0;
        for (int i = 0; i < numCastles; ++i)
        {
            const int leftSoldiers = left.castleSoldiers[i];
            const int rightSoldiers = right.castleSoldiers[i];
            const int currScore = castleScores[i];
            const int res = resolveOne(leftSoldiers, rightSoldiers);
            switch (res)
            {
            case NONE:
                break;
            
            case LEFT:
                if (leftWins < 2) left.totalScore += leftWins; 
                else left.totalScore += currScore;
                ++leftWins;
                break;
            
            case RIGHT:
                if (rightWins < 2) right.totalScore += rightWins;
                else right.totalScore += currScore;
                ++rightWins;
                break;
            
            default:
                std::cerr << "Error: Unknown result code from resolveOne: " << res << std::endl;
            }
        }
    }
};

struct Round6RuleSet : public RuleSet
{
    Round6RuleSet(): RuleSet(10, 100, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}) {}

protected:

    int minLeftVictory;
    int minRightVictory;

    void resetState() override
    {
        minLeftVictory = numSoldiers * 2;
        minRightVictory = numSoldiers * 2;
    }

    int resolveOne(int leftSoldiers, int rightSoldiers) override
    {
        int leftVictory = leftSoldiers - rightSoldiers;
        if (leftVictory > 0 && leftVictory <= minLeftVictory)
        {
            minLeftVictory = leftVictory;
            return LEFT;
        }
        int rightVictory = rightSoldiers - leftSoldiers;
        if (rightVictory > 0 && rightVictory <= minRightVictory)
        {
            minRightVictory = rightVictory;
            return RIGHT;
        }
        return NONE;
    }
};

struct Round7RuleSet : public RuleSet
{
    Round7RuleSet(): RuleSet(10, 100, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}) {}

    void resolve(Strategy& left, Strategy& right) override
    {
        resetState();
        ++left.numBattles;
        ++right.numBattles;
        for (int i = 0; i < numCastles; ++i)
        {
            const int leftSoldiers = left.castleSoldiers[i];
            const int rightSoldiers = right.castleSoldiers[i];
            const int currScore = castleScores[i];
            if (leftSoldiers > rightSoldiers)
            {
                if (leftSoldiers > 2 * rightSoldiers) left.totalScore += currScore * currScore;
                else left.totalScore += currScore;
            }
            else if (rightSoldiers > leftSoldiers)
            {
                if (rightSoldiers > 2 * leftSoldiers) right.totalScore += currScore * currScore;
                else right.totalScore += currScore;
            }
        }
    }
};

struct StrategyPool
{
    RuleSet * const ruleSet;
    float replacementRate;
    int minMutations;
    int maxMutations;
    std::vector<Strategy> pool;

    StrategyPool(RuleSet* ruleSet, float replacementRate, int minMutations, int maxMutations, int numStrats=0):
        ruleSet(ruleSet),
        replacementRate(replacementRate),
        minMutations(minMutations),
        maxMutations(maxMutations)
    {
        for (int i = 0; i < numStrats; ++i)
        {
            addRandomStrategy();
        }
    }

    void oneRound()
    {
        for (int i = 0; i < pool.size(); ++i)
        {
            pool[i].resetScore();
        }
        for (int i = 0; i < pool.size(); ++i)
        {
            for (int j = i + 1; j < pool.size(); ++j)
            {
                ruleSet->resolve(pool[i], pool[j]);
            }
        }
        for (int i = 0; i < pool.size(); ++i)
        {
            pool[i].findAvgScore();
        }
        std::sort(pool.begin(), pool.end(), std::greater<Strategy>());
    }

    void clearPool()
    {
        pool.clear();
    }

    void replaceWeakest()
    {
        int toReplace = std::round(pool.size() * replacementRate);
        int toKeep = pool.size() - toReplace;
        for (int i = 0; i < toReplace; ++i)
        {
            pool.pop_back();
        }
        for (int i = 0; i < toReplace; ++i)
        {
            addChildStrategy(randNum(0, toKeep));
        }
    }

    int addRandomStrategy()
    {
        pool.emplace_back(ruleSet->numCastles, ruleSet->numSoldiers);
        if (!ruleSet->validate(pool.back()))
        {
            std::cerr << "Invalid strategy added" << std::endl;
            pool.pop_back();
            return -1;
        }
        return pool.back().id;
    }

    int addChildStrategy(int i)
    {
        pool.emplace_back(pool[i], randNum(minMutations, maxMutations + 1));
        if (!ruleSet->validate(pool.back()))
        {
            std::cerr << "Invalid strategy added" << std::endl;
            pool.pop_back();
            return -1;
        }
        return pool.back().id;
    }

    int addStrategy(std::initializer_list<int> castleSoldiers)
    {
        pool.emplace_back(castleSoldiers);
        if (!ruleSet->validate(pool.back()))
        {
            std::cerr << "Invalid strategy added" << std::endl;
            pool.pop_back();
            return -1;
        }
        return pool.back().id;
    }

    int addStrategy(const Strategy& strat)
    {
        pool.emplace_back(strat, 0);
        if (!ruleSet->validate(pool.back()))
        {
            std::cerr << "Invalid strategy added" << std::endl;
            pool.pop_back();
            return -1;
        }
        return pool.back().id;
    }

    void printPool(int cnt=-1, int start=0)
    {
        int last;
        if (cnt < 0) last = pool.size();
        else last = std::min(start + cnt, (int) pool.size());
        for (int i = start; i < last; ++i)
        {
            std::cout << std::setw(2) << i + 1 << ". ";
            std::cout << std::setprecision(2) << std::fixed << std::setw(5) << pool[i].avgScore;
            std::cout << " - {";
            bool first = true;
            for (int soldiers : pool[i].castleSoldiers)
            {
                if (!first) std::cout << ", ";
                else first = false;
                std::cout << std::setw(2) << soldiers;
            }
            std::cout << "}" << std::endl;
        }
        std::cout << std::endl;
    }

    void printStrategySpecial(int idx)
    {
        std::cout << "bestStrategyPool.addStrategy({";
        bool first = true;
        for (int soldiers : pool[idx].castleSoldiers)
        {
            if (!first) std::cout << ", ";
            else first = false;
            std::cout << std::setw(2) << soldiers;
        }
        std::cout << "});" << std::endl;

    }

    void printStrategy(int id)
    {
        int idx;
        for (idx = 0; idx < pool.size(); ++idx)
        {
            if (pool[idx].id == id) break;
        }
        if (idx == pool.size()) std::cerr << "No strategy with this id" << std::endl;
        printPool(1, idx);
    }
};

const int MIN_NUM_GENS = 2000;
const int MAX_NUM_GENS = 10000;
int NUM_GENS;

void oneThoughtProcess(RuleSet* ruleSet, StrategyPool& bestStrategyPool)
{
    std::cout << "One thought process:" << std::endl << std::endl;

    StrategyPool strategyPool(ruleSet, 0.15, 1, 2, 1000);
    StrategyPool bigStrategyPool(ruleSet, 0, 0, 0);

    strategyPool.oneRound();
    for (int i = 0; i < NUM_GENS; ++i)
    {
        if (i == NUM_GENS / 2)
        {
            bigStrategyPool.oneRound();
            bestStrategyPool.addStrategy(bigStrategyPool.pool.front());
            bigStrategyPool.printStrategySpecial(0);
        }
        strategyPool.replaceWeakest();
        strategyPool.oneRound();
        bigStrategyPool.addStrategy(strategyPool.pool.front());
    }

    bigStrategyPool.oneRound();
    bestStrategyPool.addStrategy(bigStrategyPool.pool.front());
    bigStrategyPool.printStrategySpecial(0);
    std::cout << std::endl;
}

int runSimulation(RuleSet* ruleSet)
{
    StrategyPool bestStrategyPool(ruleSet, 0, 0, 0);

    while (true)
    {
        int val = randNum(sqrt(MIN_NUM_GENS * 10), sqrt(MAX_NUM_GENS * 10));
        NUM_GENS = val * val / 10;

        oneThoughtProcess(ruleSet, bestStrategyPool);

        std::cout << "Current Best Leaderboard:" << std::endl << std::endl;

        bestStrategyPool.oneRound();
        bestStrategyPool.printPool(30);
    }
}

void finalTest(RuleSet* ruleSet)
{
    std::vector<Strategy> strats;

    std::cerr << "Total strats: " << strats.size() << std::endl;

    std::vector<int> goodIds = {};
    std::vector<bool> isGood(strats.size(), true);
    std::vector<double> totals(strats.size());
    std::vector<int> tries(strats.size());
    std::vector<double> avgs(strats.size());
    std::vector<bool> used(strats.size());

    for (int id : goodIds)
    {
        isGood[id] = true;
    }
    
    const int TRIALS = 1e7;
    const int GROUP_SIZE = 18;
    const int TOP_RANKS = 3;

    for (int i = 0; i < TRIALS; ++i)
    {
        StrategyPool strategyPool(ruleSet, 0, 0, 0, 0);
        std::fill(used.begin(), used.end(), false);

        for (int j = 0; j < GROUP_SIZE; ++j)
        {
            int k = 0;
            do
            {
                k = randNum(0, strats.size());
            }
            while (used[k] || !isGood[k]);
            used[k] = true;
            ++tries[k];
            strategyPool.addStrategy(strats[k]);
            strategyPool.pool.back().id = k;
        }
        strategyPool.oneRound();

        for (int j = 0; j < TOP_RANKS; ++j)
        {
            totals[strategyPool.pool[j].id] += 1;
        }
    }

    std::vector<std::pair<double, int>> toSort;
    for (int j = 0; j < strats.size(); ++j)
    {
        if (!isGood[j]) continue;
        avgs[j] = totals[j] / tries[j];
        toSort.push_back({-avgs[j], j});
    }
    StrategyPool strategyPool(ruleSet, 0, 0, 0, 0);

    std::sort(toSort.begin(), toSort.end());
    double totalTotal = 0, totalTries = 0, totalAvgs = 0;
    for (int i = 0; i < toSort.size(); ++i)
    {
        int j = toSort[i].second;
        totalTotal += totals[j];
        totalTries += tries[j];
        totalAvgs += avgs[j];
        strategyPool.addStrategy(strats[j]);
        strategyPool.pool.back().totalScore = totals[j];
        strategyPool.pool.back().numBattles = tries[j];
        strategyPool.pool.back().avgScore = avgs[j];
        strategyPool.pool.back().id = j;
    }
    strategyPool.printPool();
    std::cerr << " tt tt ta : " << totalTotal << " " << totalTries << " " << totalAvgs << std::endl << std::endl;
    
    const double CUTOFF = 0.15;

    std::cout << "{";
    bool first = true;
    for (const Strategy& strat : strategyPool.pool)
    {
        if (strat.avgScore < CUTOFF) break;
        if (!first) std::cout << ", ";
        std::cout << strat.id;
        first = false;
    }
    std::cout<<"}";
}

int main()
{
    generator.seed(time(nullptr));

    ExampleRuleSet exampleRuleSet;
    Round1RuleSet round1RuleSet;
    Round2RuleSet round2RuleSet;
    Round3RuleSet round3RuleSet;
    Round4RuleSet round4RuleSet;
    Round5RuleSet round5RuleSet;
    Round6RuleSet round6RuleSet;

    runSimulation(&exampleRuleSet);

    //finalTest(&exampleRuleSet);
    
    return 0;
}