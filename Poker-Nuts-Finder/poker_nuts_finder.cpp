#include <iostream>
#include <vector>
#include <cassert>
#include <set>
#include <algorithm>
#include <random>

const int COMBO_SIZE = 5;

const int NUM_SUITES = 4;
const int FIRST_VALUE = 2;
const int LAST_VALUE = 14;

#define ACE 14
#define KING 13
#define QUEEN 12
#define JACK 11

#define CLUBS 0
#define DIAMONDS 1
#define HEARTS 2
#define SPADES 3

#define HIGH_CARD 0
#define ONE_PAIR 1
#define TWO_PAIR 2
#define THREE_OAK 3
#define STRAIGHT 4
#define FLUSH 5
#define FULL_HOUSE 6
#define FOUR_OAK 7
#define STRAIGHT_FLUSH 8

const std::string comboNames[] = {
    "High Card",
    "Pair",
    "Two Pairs",
    "Three of a kind",
    "Straight",
    "Flush",
    "Full House",
    "Four of a kind",
    "Straight Flus"
};

const std::string valueNames[] = {
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "J",
    "Q",
    "K",
    "A"
};

const std::string suiteNames[] = {
    "c",
    "d",
    "h",
    "s"
};

struct PokerCombo
{
    int combo;
    std::vector<int> vals;

    void print() const
    {
        std::cout << comboNames[combo] << ":";
        for (int val : vals)
        {
            std::cout << " " << valueNames[val - FIRST_VALUE];
        }
        std::cout << std::endl;
    }
};

struct Card
{
    int value;
    int suite;

    void print() const
    {
        std::cout << valueNames[value - FIRST_VALUE] << suiteNames[suite];
    }
};

bool operator<(const Card& left, const Card& right)
{
    if (left.value != right.value) return left.value < right.value;
    return left.suite < right.suite;
}

bool operator<(const PokerCombo& left, const PokerCombo& right)
{
    if (left.combo != right.combo) return left.combo < right.combo;
    assert(left.vals.size() == right.vals.size());
    return left.vals < right.vals;
}

std::vector<int> cardVals(const std::vector<Card>& cards)
{
    std::vector<int> vals;

    for (const Card& card: cards)
    {
        vals.push_back(card.value);
    }

    return vals;
}

PokerCombo findCombo(std::vector<Card> cards)
{
    assert(cards.size() == COMBO_SIZE);
    std::sort(cards.begin(), cards.end());
    std::reverse(cards.begin(), cards.end());


    bool isFlush = true;
    int flushSuite = cards[0].suite;

    for (const Card& card : cards)
    {
        if (card.suite != flushSuite)
        {
            isFlush = false;
            break;
        }
    }

    bool isStraight = true;
    int straightTo = cards[0].value;

    for (int i = 1; i < COMBO_SIZE; ++i)
    {
        if (cards[i].value != cards[i - 1].value - 1)
        {
            isStraight = false;
            break;
        }
    }

    if (!isStraight && cards[0].value == ACE)
    {
        isStraight = true;
        straightTo = cards[1].value;
        for (int i = 1; i < COMBO_SIZE; ++i)
        {
            if (cards[i].value != 6 - i)
            {
                isStraight = false;
                break;
            }
        }
    }

    int streak = 0;
    int prev = 0;

    // streak, value
    std::vector<std::pair<int, int>> matching;

    for (int i = 0; i < COMBO_SIZE; ++i)
    {
        if (cards[i].value != prev)
        {
            if (streak > 1) matching.push_back({streak, prev});

            prev = cards[i].value;
            streak = 1;
        }
        else ++streak;
    }

    if (streak > 1) matching.push_back({streak, prev});

    std::sort(matching.begin(), matching.end());
    std::reverse(matching.begin(), matching.end());

    std::vector<int> vals;
    for (const auto& mp : matching)
    {
        vals.push_back(mp.second);
    }
    for (const Card& card : cards)
    {
        if (std::find(vals.begin(), vals.end(), card.value) == vals.end())
        {
            vals.push_back(card.value);
        }
    }

    if (isStraight && isFlush) return {STRAIGHT_FLUSH, {straightTo}};

    if (matching.size() == 1 && matching[0].first == 4) return {FOUR_OAK, vals};
    if (matching.size() == 2 && matching[0].first == 3 && matching[1].first == 2) return {FULL_HOUSE, vals};

    if (isFlush)
    {
        std::vector<int> vals;
        for (const Card& card: cards)
        {
            vals.push_back(card.value);
        }
        return {FLUSH, vals};
    }

    if (isStraight) return {STRAIGHT, {straightTo}};

    if (matching.size() == 1 && matching[0].first == 3) return {THREE_OAK, vals};
    if (matching.size() == 2 && matching[0].first == 2 && matching[1].first == 2) return {TWO_PAIR, vals};
    if (matching.size() == 1 && matching[0].first == 2) return {ONE_PAIR, vals};
    if (matching.size() == 0) return {HIGH_CARD, vals};

    std::cerr << "NO COMBO FOUND" << std::endl;
}

PokerCombo recFCWH(std::vector<Card>& taken, const std::vector<Card>& deal, int pos)
{
    if (taken.size() == COMBO_SIZE) return findCombo(taken);

    taken.push_back(deal[pos]);
    PokerCombo combo1 = recFCWH(taken, deal, pos + 1);
    taken.pop_back();

    if (taken.size() + deal.size() - pos > COMBO_SIZE)
    {
        PokerCombo combo2 = recFCWH(taken, deal, pos + 1);
        return std::max(combo1, combo2);
    }
    else return combo1;
}

PokerCombo findComboWithHand(const std::vector<Card>& deal, const std::vector<Card>& hand)
{
    assert(hand.size() < COMBO_SIZE);
    assert(hand.size() + deal.size() >= COMBO_SIZE);

    std::vector<Card> taken = hand;

    return recFCWH(taken, deal, 0);
}

std::vector<Card> deck;

void initDeck()
{
    deck.clear();

    for (int suite = 0; suite < NUM_SUITES; ++suite)
    {
        for (int value = FIRST_VALUE; value <= LAST_VALUE; ++value)
        {
            deck.push_back({value, suite});
        }
    }

    std::sort(deck.begin(), deck.end());
    std::reverse(deck.begin(), deck.end());
}

bool recIN(std::vector<Card>& taken, const std::vector<Card>& deal, const std::set<Card> used, const PokerCombo& combo, int handSize, int pos)
{
    if (taken.size() == handSize)
    {
        PokerCombo other = findComboWithHand(deal, taken);
        if (combo < other) return false;
        return true;
    }

    if (pos == deck.size()) return true;

    if (used.find(deck[pos]) == used.end())
    {
        taken.push_back(deck[pos]);
        if (!recIN(taken, deal, used, combo, handSize, pos + 1)) return false;
        taken.pop_back();
    }

    return recIN(taken, deal, used, combo, handSize, pos + 1);
}

bool isNuts(const std::vector<Card>& deal, const std::vector<Card>& hand)
{
    PokerCombo combo = findComboWithHand(deal, hand);
    std::set<Card> used;

    for (const Card& card : deal)
    {
        used.insert(card);
    }
    for (const Card& card : hand)
    {
        used.insert(card);
    }

    std::vector<Card> taken;
    return recIN(taken, deal, used, combo, hand.size(), 0);
}

void recFN(std::vector<Card>& taken, const std::vector<Card>& deal, const std::set<Card> used, int handSize, int pos, std::vector<std::vector<Card>>& nuts)
{
    if (taken.size() == handSize)
    {
        if (isNuts(deal, taken)) nuts.push_back(taken);
        return;
    }

    if (pos == deck.size()) return;

    if (used.find(deck[pos]) == used.end())
    {
        taken.push_back(deck[pos]);
        recFN(taken, deal, used, handSize, pos + 1, nuts);
        taken.pop_back();
    }

    recFN(taken, deal, used, handSize, pos + 1, nuts);
}

std::vector<std::vector<Card>> findNuts(const std::vector<Card>& deal, int handSize)
{
    std::set<Card> used;

    for (const Card& card : deal)
    {
        used.insert(card);
    }

    std::vector<Card> taken;
    std::vector<std::vector<Card>> nuts;
    recFN(taken, deal, used, handSize, 0, nuts);

    return nuts;
}

std::mt19937 generator(0);

std::vector<std::vector<Card>> randomDeals(int base, const std::vector<int>& conts)
{
    std::vector<Card> shuffledDeck = deck;
    std::shuffle(shuffledDeck.begin(), shuffledDeck.end(), generator);

    std::vector<std::vector<Card>> deals(conts.size());

    int curr = 0;
    for (int j = 0; j < base; ++j)
    {
        for (int i = 0; i < conts.size(); ++i)
        {
            deals[i].push_back(shuffledDeck[curr]);
        }
        ++curr;
    }

    for (int i = 0; i < conts.size(); ++i)
    {
        for (int k = 0; k < conts[i]; ++k)
        {
            deals[i].push_back(shuffledDeck[curr++]);
        }
    }

    return deals;
}

std::vector<std::vector<Card>> findCommonNuts(std::vector<std::vector<Card>> deals, int handSize)
{
    std::vector<std::vector<Card>> common;

    for (int i = 0; i < deals.size(); ++i)
    {
        std::vector<std::vector<Card>> nuts = findNuts(deals[i], handSize);
        std::sort(nuts.begin(), nuts.end());

        if (i == 0) common = nuts;
        else 
        {
            std::vector<std::vector<Card>> intersect;
            std::set_intersection(nuts.begin(), nuts.end(), common.begin(), common.end(), std::back_inserter(intersect));
            common = intersect;
        }
    }

    return common;
}

bool testRandomDeals(int base, const std::vector<int>& conts, int handSize)
{
    std::vector<std::vector<Card>> deals = randomDeals(base, conts);
    std::vector<std::vector<Card>> commonNuts = findCommonNuts(deals, handSize);

    for (const std::vector<Card>& deal : deals)
    {
        for (const Card& card : deal)
        {
            card.print();
            std::cout << " ";
        }
        std::cout << std::endl;
    }

    if (!commonNuts.empty())
    {
        std::cout << "Common Nuts:" << std::endl;
        for (const std::vector<Card>& nut : commonNuts)
        {
            for (const Card& card : nut)
            {
                card.print();
                std::cout << " ";
            }
            std::cout << std::endl;
        }
    }

    std::cout << std::endl;

    return !commonNuts.empty();
}

int main()
{
    initDeck();

    int hadCommon = 0;
    int trials = 0;
    while (true)
    {
        ++trials;
        hadCommon += testRandomDeals(3, {2, 2}, 2);

        std::cout << trials << ": " << hadCommon * 100.0 / trials << std::endl;

        std::cout << std::endl;
    }

    /*std::vector<Card> deal = {
        {5, SPADES},
        {ACE, SPADES},
        {6, CLUBS},
        {5, HEARTS},
        {QUEEN, SPADES}
    };

    std::vector<std::vector<Card>> nuts = findNuts(deal, 2);

    for (const auto& nut : nuts)
    {
        for (const Card& card : nut)
        {
            card.print();
            std::cout << " ";
        }
        std::cout << std::endl;

        PokerCombo combo = findComboWithHand(deal, nut);
        combo.print();
        std::cout << std::endl;
    }*/

    return 0;
}