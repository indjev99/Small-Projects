import math
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

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

def play(fish_strat, v=None, max_t=DEF_MAX_T):
    if v is None:
        v = find_max_v(fish_strat)
        print('Max V:', v)

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

def find_max_v(fish_strat, max_t=DEF_MAX_T):
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

def animate(succ, fish_xys, cat_xys, speed=0.2):
    steps = len(fish_xys)

    print('Time:', (steps - 1) * dt)
    print('Escaped:', succ)

    fig, ax = plt.subplots(1, 1)
    ax.set_aspect('equal')
    ax.set_xlim((-1.1, 1.1))
    ax.set_ylim((-1.1, 1.1))

    fps = 30
    sim_secs_per_sec = speed

    steps_per_frame = max(round(sim_secs_per_sec / fps / dt), 1)
    msec_per_frame = steps_per_frame * dt / sim_secs_per_sec / fps * 1000

    frames = (steps + steps_per_frame - 1) // steps_per_frame

    def draw_frame(frame):
        next_step = min((frame + 1) * steps_per_frame, len(fish_xys))
        ax.clear()
        ax.set_aspect('equal')
        ax.set_xlim((-1.1, 1.1))
        ax.set_ylim((-1.1, 1.1))
        ax.plot(*zip(*fish_xys[ : next_step]), color='blue', label='fish')
        ax.plot(*fish_xys[next_step - 1], color='blue', label='fish_curr', marker='o')
        ax.plot(*zip(*cat_xys[ : next_step]), color='orange', label='cat')
        ax.plot(*cat_xys[next_step - 1], color='orange', label='cat_curr', marker='o')

    ani = FuncAnimation(fig, draw_frame, frames=frames, interval=msec_per_frame, repeat=False)
    plt.show()

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

def fish_opposite_dash(v, fx, fy, ca):
    if v < EPS or get_norm(fx, fy) < 1 / v:
        return fish_opposite(v, fx, fy, ca)
    else:
        return fish_dash(v, fx, fy, ca)

def fish_opposite_greedy(v, fx, fy, ca):
    if v < EPS or get_norm(fx, fy) < 1 / v:
        return fish_opposite(v, fx, fy, ca)
    else:
        return fish_greedy(v, fx, fy, ca)

fishes = [
    ('fish_runaway', fish_runaway),
    ('fish_dash', fish_dash),
    ('fish_opposite', fish_opposite),
    ('fish_greedy', fish_greedy),
    ('fish_opposite_dash', fish_opposite_dash),
    ('fish_opposite_greedy', fish_opposite_greedy)
]

def main():
    print('Select fish: ')
    for i, (name, strat) in enumerate(fishes):
        print(i, name)
    sel = int(input())
    fish_strat = fishes[sel][1]
    print('Enter cat speed (`max` for max winnable):')
    v = input()
    if v == 'max':
        v = None
    else:
        v = float(v)
    animate(*play(fish_strat, v))

if __name__ == '__main__':
    main()
