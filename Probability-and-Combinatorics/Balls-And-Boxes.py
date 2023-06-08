import math
import random

def iterP(K, p):
    q = (1 - p) / K
    total = 0
    for i in range(0, K + 1):
        total += math.comb(K, i) * q ** i * (1 - q) ** (K - i) / (2 + i)
    return total

ITERS = 100

def stableP(K):
    p = 0.4
    for i in range(ITERS):
        p = iterP(K, p)
    return p

def oneSim(N):
    boxes = [1] * N
    cnt = 0
    total = 0
    for i in range(N):
        curr = boxes[i]
        p = 1 / (1 + curr)
        if True:
            cnt += 1
            total += p
        if random.random() > p and i < N - 1:
            j = random.randint(i + 1, N - 1)
            boxes[j] += 1
    return total / cnt

NUMSIMS = 1000

def sim(N):
    total = 0
    for i in range(NUMSIMS):
        total += oneSim(N)
    return total / NUMSIMS

K = 500
N = 10000

def main():
    print(K, ':', stableP(K))
    print(N, ':', sim(N))

main()
