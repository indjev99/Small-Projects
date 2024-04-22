#include <iostream>
#include <deque>
#include <iterator>
#include <cassert>

template <class T, bool Min>
struct CHT
{
private:

    struct Line
    {
        T m;
        T b;

        Line(T m, T b)
            : m(m)
            , b(b)
        {}

        T eval(T x) const
        {
            return m * x + b;
        }
    };

    static Line makeLine(T m, T b)
    {
        if constexpr (Min) return Line(m, b);
        else return Line(-m, -b);
    }

    static T getRes(T res)
    {
        if constexpr (Min) return res;
        else return -res;
    }

    static bool shouldPopMid(const Line& left, const Line& mid, const Line& right)
    {
        return (mid.m - left.m) * (right.b - mid.b) - (right.m - mid.m) * (mid.b - left.b) >= 0;
    }

    std::deque<Line> hull;

public:

    using Iter = class std::deque<Line>::iterator;

    void addRight(T m, T b)
    {
        Line line = makeLine(m, b);
        if (!hull.empty()) assert(hull.back().m >= line.m);
        if (!hull.empty() && hull.back().m == line.m)
        {
            if (hull.back().b <= line.b) return;
            else hull.pop_back();
        }
        while (hull.size() >= 2 && shouldPopMid(hull[hull.size() - 2], hull.back(), line))
        {
            hull.pop_back();
        }
        hull.push_back(line);
    }

    void addLeft(T m, T b)
    {
        Line line = makeLine(m, b);
        if (!hull.empty()) assert(hull.front().m <= line.m);
        if (!hull.empty() && hull.front().m == line.m)
        {
            if (hull.front().b <= line.b) return;
            else hull.pop_back();
        }
        while (hull.size() >= 2 && shouldPopMid(line, hull.front(), hull[2]))
        {
            hull.pop_front();
        }
        hull.push_front(line);
    }

    T query(T x)
    {
        int left = 0;
        int right = hull.size();
        // Inv: left <= ans < right
        while (right - left > 1)
        {
            int mid = (left + right) / 2;
            // left < mid < right
            int prev = mid - 1;
            if (hull[prev].eval(x) < hull[mid].eval(x)) right = mid;
            else left = mid;
        }
        return getRes(hull[left].eval(x));
    }

    // For monotonic queries
    // Won't generally work, depends on lines added

    Iter getLeftIter()
    {
        assert(!hull.empty());
        return hull.begin();
    }

    Iter getRightIter()
    {
        assert(!hull.empty());
        return std::prev(hull.end());
    }

    T queryMonRight(T x, Iter& iter)
    {
        while (std::next(iter) != hull.end() && std::next(iter)->eval(x) < iter->eval(x))
        {
            ++iter;
        }
        return getRes(iter->eval(x));
    }

    T queryMonLeft(T x, Iter& iter)
    {
        while (iter != hull.begin() && std::prev(iter)->eval(x) < iter->eval(x))
        {
            --iter;
        }
        return getRes(iter->eval(x));
    }

    void debugPrint() const
    {
        for (const Line& line : hull)
        {
            std::cerr << line.m << " " << line.b << std::endl;
        }
    }
};

int main()
{
    CHT<int, true> cht;

    int n, q, m, b, x;

    std::cin >> n >> q;
    for (int i = 0; i < n; ++i)
    {
        std::cin >> m >> b;
        cht.addRight(m, b);
    }

    for (int i = 0; i < q; ++i)
    {
        std::cin >> x;
        std::cout << cht.query(x) << std::endl;
    }

    return 0;
}