#include <iostream>
#include <vector>
#include <stack>
#include <unordered_map>
#include <algorithm>
using namespace std;

// Operators
#define NUM 0
#define ADD 1
#define SUB 2
#define UPL 3
#define UMI 4
#define MUL 5
#define DIV 6
#define MOD 7
#define POW 8
#define EQ  9
#define LT  10
#define GT  11
#define LEQ 12
#define GEQ 13
#define NEQ 14
#define NOT 15
#define AND 16
#define OR  17
#define IMP 18
#define BMP 19
#define LBR 20
#define RBR 21

// Types
#define INTEGER 0
#define BOOLEAN 1
#define NONE 2

// Exceptions
#define UNKNOWN_TOKEN 0
#define FEW_OPERANDS  1
#define INVAL_BRACKS  2
#define ASSOC_ERROR   3
#define INCOMPLETE_EX 4
#define TYPE_ERROR    5

struct OpProps
{
    int prec;
    int numIns;
    int inType;
    int outType;
    bool leftAssoc;
    bool rightAssoc;
    string str;
};

struct Node
{
    int op;
    int lchild, rchild;
    int numIdx;

    Node(int numIdx):
        op(NUM),
        numIdx(numIdx) {}

    Node(int op, int child):
        op(op),
        lchild(child) {}

    Node(int op, int lchild, int rchild):
        op(op),
        lchild(lchild),
        rchild(rchild) {}
};

const int BASE = 10;

const unordered_map<string, int> ops = {
    {"+",  ADD},
    {"-",  SUB},
    {"*",  MUL},
    {"/",  DIV},
    {"%",  MOD},
    {"^",  POW},
    {"=",   EQ},
    {"==",  EQ},
    {"<",   LT},
    {">",   GT},
    {"<=", LEQ},
    {">=", GEQ},
    {"!=", NEQ},
    {"<>", NEQ},
    {"!",  NOT},
    {"&&", AND},
    {"||",  OR},
    {"->", IMP},
    {"<->",BMP},
    {"(",  LBR},
    {")",  RBR},
};

const vector<OpProps> opProps = {
    {-9, 0, NONE,    INTEGER, false, false,   ""},  // NUM
    {1,  2, INTEGER, INTEGER, true,  true,   "+"},  // ADD
    {1,  2, INTEGER, INTEGER, true,  false,  "-"},  // SUB
    {0,  1, INTEGER, INTEGER, true,  false,  "+"},  // UPL
    {0,  1, INTEGER, INTEGER, true,  false,  "-"},  // UMI
    {2,  2, INTEGER, INTEGER, true,  true,   "*"},  // MUL
    {2,  2, INTEGER, INTEGER, true,  false,  "/"},  // DIV
    {2,  2, INTEGER, INTEGER, true,  false,  "%"},  // MOD
    {1,  2, INTEGER, INTEGER, false,  true,  "^"},  // POW
    {4,  2, INTEGER, BOOLEAN, false, false,  "="},  //  EQ
    {4,  2, INTEGER, BOOLEAN, false, false,  "<"},  //  LT
    {4,  2, INTEGER, BOOLEAN, false, false,  ">"},  //  GT
    {4,  2, INTEGER, BOOLEAN, false, false, "<="},  // LEQ
    {4,  2, INTEGER, BOOLEAN, false, false, ">="},  // GEQ
    {4,  2, INTEGER, BOOLEAN, false, false, "!="},  // NEQ
    {0,  1, BOOLEAN, BOOLEAN, true,  false,  "!"},  // NOT
    {5,  2, BOOLEAN, BOOLEAN, true,  true,  "&&"},  // AND
    {6,  2, BOOLEAN, BOOLEAN, true,  true,  "||"},  //  OR
    {7,  2, BOOLEAN, BOOLEAN, false, true,  "->"},  // IMP
    {8,  2, BOOLEAN, BOOLEAN, true,  true, "<->"},  // BMP
    {10, 0, NONE,    NONE   , false, false,  "("},  // LBR
    {10, 0, NONE,    NONE   , false, false,  ")"}   // RBR
};

// Input numbers
vector<string> numReps;

// Input expression tree
vector<Node> tree;
int treeRoot;

// All variable digits
vector<char> digits;
vector<vector<int>> numIdxs;
vector<bool> isInit;

// Values of digits and numbers
vector<int> digVals;
vector<long long> nums;

// Saved for optimization
vector<int> prevDigVals;

// Used for parsing
stack<Node> nodeStack;
stack<int> opStack;
bool typesFine;
bool lastOp;

string expressionString(int idx, bool printVals=false, int parOp=LBR, bool isLeft=true)
{
    const Node& node = tree[idx];
    string str = "";
    int parPrec = opProps[parOp].prec;
    int currPrec = opProps[node.op].prec;
    bool bracks = parPrec < currPrec;
    bracks |= parPrec == currPrec &&
              ((isLeft && !opProps[parOp].leftAssoc) ||
               (!isLeft && !opProps[parOp].rightAssoc));
    if (bracks) str += "(";
    if (node.op == NUM)
    {
        if (printVals) str += to_string(nums[node.numIdx]);
        else str += numReps[node.numIdx];
    }
    else if (opProps[node.op].numIns == 1)
    {
        str += opProps[node.op].str;
        str += expressionString(node.lchild, printVals, node.op, true);
    }
    else if (opProps[node.op].numIns == 2)
    {
        str += expressionString(node.lchild, printVals, node.op, true);
        str += " ";
        str += opProps[node.op].str;
        str += " ";
        str += expressionString(node.rchild, printVals, node.op, false);
    }
    else str += "ERROR";
    if (bracks) str += ")";
    return str;
}

long long qpow(long long a, long long n)
{
    if (n == 0) return 1;
    if (n == 1) return a;
    long long rest = qpow(a, n / 2);
    if (n % 2 == 0) return rest * rest;
    else return a * rest * rest;
}

long long evalExpression(int idx, bool &error)
{
    const Node& node = tree[idx];
    long long lnum, rnum;
    if (opProps[node.op].numIns >= 1) lnum = evalExpression(node.lchild, error);
    if (error) return 0;
    if (opProps[node.op].numIns >= 2) rnum = evalExpression(node.rchild, error);
    if (error) return 0;

    switch (node.op)
    {
    case NUM:
        return nums[node.numIdx];
    case ADD:
        return lnum + rnum;
    case SUB:
        return lnum - rnum;
    case UPL:
        return lnum;
    case UMI:
        return -lnum;
    case MUL:
        return lnum * rnum;
    case DIV:
        if (rnum == 0) return error = 0;
        return lnum / rnum;
    case MOD:
        if (rnum == 0) return error = 0;
        return (lnum % rnum + rnum) % rnum;
    case POW:
        if (rnum < 0) return error = 0;
        return qpow(lnum, rnum);
    case EQ:
        return lnum == rnum;
    case LT:
        return lnum < rnum;
    case GT:
        return lnum > rnum;
    case LEQ:
        return lnum <= rnum;
    case GEQ:
        return lnum >= rnum;
    case NEQ:
        return lnum != rnum;
    case NOT:
        return !lnum;
    case AND:
        return lnum && rnum;
    case OR:
        return lnum || rnum;
    case IMP:
        return lnum <= rnum;
    case BMP:
        return lnum == rnum;
    default:
        cerr << "ERROR: Unknown operator " << node.op << "!" << endl;
        return error = 0;
    }
}

void popFromStack()
{
    int next = opStack.top();
    opStack.pop();
    if (nodeStack.size() < opProps[next].numIns) throw FEW_OPERANDS;
    for (int i = 0; i < opProps[next].numIns; ++i)
    {
        if (opProps[nodeStack.top().op].outType != opProps[next].inType) typesFine = false;
        tree.push_back(nodeStack.top());
        nodeStack.pop();
    }
    Node newNode = Node(next, tree.size() - 1, tree.size() - 2);
    nodeStack.push(newNode);
}

void pushToStack(int op)
{
    switch (op)
    {
    case LBR:
        opStack.push(op);
        break;

    case RBR:
        while (!opStack.empty() && opStack.top() != LBR)
        {
            popFromStack();
        }
        if (opStack.empty()) throw INVAL_BRACKS;
        opStack.pop();
        break;

    default:
        while (!opStack.empty() && (opProps[opStack.top()].prec < opProps[op].prec ||
               (opProps[opStack.top()].prec == opProps[op].prec && opProps[op].leftAssoc)))
        {
            popFromStack();
        }
        if (!opStack.empty() && opProps[opStack.top()].prec == opProps[op].prec && !opProps[op].rightAssoc)
        {
            throw ASSOC_ERROR;
        }
        opStack.push(op);
    }
}

void processToken(const string& token)
{
    if (token == "") return;
    if (isalnum(token[0]))
    {
        nodeStack.push(Node(numReps.size()));
        numReps.push_back(token);
        lastOp = false;
        return;
    }
    int len;
    int op;
    for (len = token.size(); len > 0; --len)
    {
        string prefix = token.substr(0, len);
        auto it = ops.find(prefix);
        if (it != ops.end())
        {
            op = it->second;
            break;
        }
    }
    if (len == 0) throw UNKNOWN_TOKEN;
    if (op == ADD && lastOp) op = UPL;
    if (op == SUB && lastOp) op = UMI;
    lastOp = op != RBR;
    if (op != UPL) pushToStack(op);
    processToken(token.substr(len, token.size() - len));
}

void parseExpression(const string& str)
{
    lastOp = true;
    typesFine = true;
    numReps.clear();
    tree.clear();
    while (!nodeStack.empty()) nodeStack.pop();
    while (!opStack.empty()) opStack.pop();
    bool tokenType;
    string token = "";
    processToken("(");
    for (char c : str)
    {
        bool currType = isalnum(c);
        if (isspace(c) || currType != tokenType)
        {
            processToken(token);
            token = "";
        }
        if (!isspace(c))
        {
            token += c;
            tokenType = currType;
        }
    }
    processToken(token);
    processToken(")");
    if (!opStack.empty()) throw INVAL_BRACKS;
    if (nodeStack.size() != 1) throw INCOMPLETE_EX;
    treeRoot = tree.size();
    tree.push_back(nodeStack.top());
    nodeStack.pop();
    if (opProps[tree[treeRoot].op].outType != BOOLEAN) typesFine = false;
    if (!typesFine) throw TYPE_ERROR;
}

bool enterExpression()
{
    string str = "";
    while (str == "") getline(cin, str);
    try { parseExpression(str); }
    catch (int e)
    {
        cout << "Invalid expression entered: ";
        switch (e)
        {
        case UNKNOWN_TOKEN:
            cout << "Unknown operator!" << endl;
            break;

        case FEW_OPERANDS:
            cout << "Operator has too few operands!" << endl;
            break;

        case INVAL_BRACKS:
            cout << "Invalid bracketing!" << endl;
            break;

        case ASSOC_ERROR:
            cout << "Missing brackets around non associative operator!" << endl;
            break;

        case INCOMPLETE_EX:
            cout << "Expression is incomplete!" << endl;
            break;

        case TYPE_ERROR:
            cout << "Type error!" << endl;
            break;

        default:
            cout << "Unknown error!" << endl;
        }
        return false;
    }
    return true;
}

void preprocess()
{
    digits.clear();
    isInit.clear();
    numIdxs.resize(numReps.size());
    for (int i = 0; i < numReps.size(); ++i)
    {
        numIdxs[i].clear();
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
            if (k == 0 && numReps[i].size() > 1) isInit[j] = true;
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
    bool error = false;
    long long res = evalExpression(treeRoot, error);
    return !error && res == 1;
}

void printSolution()
{
    cout << expressionString(treeRoot, true) << endl;
}

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
    if (digits.size() > BASE)
    {
        cout << "Too many different digits!" << endl;
        return;
    }
    digVals.resize(BASE);
    iota(digVals.begin(), digVals.end(), 0);
    prevDigVals.resize(digits.size());
    fill(prevDigVals.begin(), prevDigVals.end(), -1);
    nums.resize(numReps.size());
    long long numSols = 0;
    bool first = true;
    do
    {
        if (stillSame() && !first) continue;
        if (checkSolution())
        {
            ++numSols;
            printSolution();
        }
        first = false;
    }
    while (next_permutation(digVals.begin(), digVals.end()));
    if (numSols == 0) cout << "No solutions found." << endl;
    if (numSols == 1) cout << "1 solution found." << endl;
    else cout << numSols << " solutions found." << endl;
}

int main()
{
    while (true)
    {
        if (enterExpression())
        {
            preprocess();
            solve();
        }
    }
    return 0;
}
