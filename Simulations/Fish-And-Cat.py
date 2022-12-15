import math
import matplotlib.pyplot as plt

EPS = 1e-5
DEF_MAX_T = 2

dt = 1e-3

def get_norm(x, y):
    return (x ** 2 + y ** 2) ** 0.5

def get_xy(a):
    return math.cos(a), math.sin(a)

def get_a(x, y):
    return math.atan2(y, x)

def normalize(x, y, only_shrink=False):
    norm = get_norm(x, y)
    assert norm > EPS or only_shrink
    if not only_shrink or norm > 1:
        return x / norm, y / norm
    else:
        return x, y

def angle_diff(alpha, beta):
    pi2 = 2 * math.pi
    diff = ((alpha - beta) % pi2 + pi2) % pi2
    if diff > math.pi:
        diff -= pi2
    return diff

def cat_strat(v, fx, fy, ca):
    if get_norm(fx, fy) <= EPS:
        return 0
    nfx, nfy = normalize(fx, fy)
    fa = get_a(fx, fy)
    diff = angle_diff(fa, ca)
    if abs(diff) < v * dt:
        return diff / dt
    else:
        return v * abs(diff) / diff

def play(fish_strat, v, max_t = DEF_MAX_T):
    def get_dfxy(fx, fy, ca):
        return normalize(*fish_strat(v, fx, fy, ca), only_shrink=True)
    def get_ca(fx, fy, ca):
        dca = cat_strat(v, fx, fy, ca)
        assert abs(dca) < v + EPS
        return dca

    fx, fy = 0, 0
    old_ca = ca = 0
    fish_xys = []
    cat_xys = []
    t = 0
    while True:
        cx, cy = get_xy(ca)
        fish_xys.append((fx, fy))
        cat_xys.append((cx, cy))
        if t > max_t:
            succ = False
            break
        if get_norm(fx, fy) >= 1:
            fx, fy = normalize(fx, fy)
            succ = get_norm(cx - fx, cy - fy) > EPS
            break
        dfx, dfy = get_dfxy(fx, fy, old_ca)
        fx, fy = fx + dfx * dt, fy + dfy * dt
        old_ca = ca
        dca = get_ca(fx, fy, ca)
        ca = ca + dca * dt
        t = t + dt
    return succ, fish_xys, cat_xys

def find_max_v(fish_strat, max_t = DEF_MAX_T):
    left = 0
    right = 20
    while right - left > EPS:
        mid = (left + right) / 2
        succ, *_ = play(fish_strat, mid, max_t)
        if succ:
            left = mid
        else:
            right = mid
    return left

def plot(fish_strat, v, max_t = DEF_MAX_T):
    succ, fish_xys, cat_xys = play(fish_strat, v, max_t)
    print('Time:', (len(fish_xys) - 1) * dt)
    print('Escaped:', succ)
    
    plt.axis('square')
    plt.xlim((-1.1, 1.1))
    plt.ylim((-1.1, 1.1))
    plt.plot(*zip(*fish_xys), label='fish')
    plt.plot(*zip(*cat_xys), label='cat')
    plt.show()

def plot_max_v(fish_strat, max_t = DEF_MAX_T):
    max_v = find_max_v(fish_strat, max_t)
    print('Max V:', max_v)
    plot(fish_strat, max_v, max_t)

def get_fa(fx, fy, ca):
    cx, cy = get_xy(ca)
    if get_norm(fx, fy) > EPS:
        return get_a(fx, fy)
    else:
        return get_a(fx - cx, fy - cy)

def fish_runaway(v, fx, fy, ca):
    cx, cy = get_xy(ca)
    return normalize(fx - cx, fy - cy)

def fish_dash(v, fx, fy, ca):
    return get_xy(get_fa(fx, fy, ca))

def fish_opposite(v, fx, fy, ca):
    fa = get_fa(fx, fy, ca)
    left = fa - math.pi / 2
    right = fa + math.pi / 2
    # print(fx, fy, fa, '/', ca)
    while right - left > EPS:
        mid1 = (2 * left + right) / 3
        mid2 = (left + 2 * right) / 3
        dfx1, dfy1 = get_xy(mid1)
        dfx2, dfy2 = get_xy(mid2)
        fx1, fy1 = fx + dfx1 * dt, fy + dfy1 * dt
        fx2, fy2 = fx + dfx2 * dt, fy + dfy2 * dt
        fa1 = get_a(fx1, fy1)
        fa2 = get_a(fx2, fy2)
        diff1 = angle_diff(fa1, ca)
        diff2 = angle_diff(fa2, ca)
        # print()
        # print('  ', mid1, dfx1, dfy1, '->', fx1, fy1, fa1, '->', diff1)
        # print('  ', mid2, dfx2, dfy2, '->', fx2, fy2, fa2, '->', diff2)
        if abs(diff1) > abs(diff2):
            right = mid2
        else:
            left = mid1
    return get_xy((left + right) / 2)

def fish_greedy(v, fx, fy, ca):
    fa = get_fa(fx, fy, ca)
    left = fa - math.pi / 2
    right = fa + math.pi / 2
    while right - left > EPS:
        mid1 = (2 * left + right) / 3
        mid2 = (left + 2 * right) / 3
        dfx1, dfy1 = get_xy(mid1)
        dfx2, dfy2 = get_xy(mid2)
        fx1, fy1 = fx + dfx1 * dt, fy + dfy1 * dt
        fx2, fy2 = fx + dfx2 * dt, fy + dfy2 * dt
        dist1 = abs(1 - get_norm(fx1, fy1))
        dist2 = abs(1 - get_norm(fx2, fy2))
        fa1 = get_a(fx1, fy1)
        fa2 = get_a(fx2, fy2)
        diff1 = angle_diff(fa1, ca)
        diff2 = angle_diff(fa2, ca)
        time1 = abs(diff1) / v - dist1
        time2 = abs(diff2) / v - dist2
        if time1 > time2:
            right = mid2
        else:
            left = mid1
    return get_xy((left + right) / 2)

def fish_oppdash(v, fx, fy, ca):
    if v < EPS or get_norm(fx, fy) < 1 / v:
        return fish_opposite(v, fx, fy, ca)
    else:
        return fish_dash(v, fx, fy, ca)

def fish_oppgreedy(v, fx, fy, ca):
    if v < EPS or get_norm(fx, fy) < 1 / v:
        return fish_opposite(v, fx, fy, ca)
    else:
        return fish_greedy(v, fx, fy, ca)

# plot_max_v(fish_oppgreedy)
plot(fish_oppgreedy, v=4.1415)
