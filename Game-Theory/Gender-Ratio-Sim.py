
import random

class Chicken:
    def __init__(self, is_f, prob_f):
        self.is_f = is_f
        self.prob_f = prob_f

SURV_F = 1.0
SURV_M = 0.1
POP_SIZE = 1000

def apply_surv(ind):
    surv = SURV_F if ind.is_f else SURV_M
    if random.random() > surv:
        return None
    return ind

def make_random():
    is_f = random.random() < 0.5
    prob_f = random.random()

    return apply_surv(Chicken(is_f, prob_f))

def make_child(mother, father):
    is_f = random.random() < mother.prob_f
    prob_f = mother.prob_f if random.random() < 0.5 else father.prob_f

    prob_f += (random.random() - 0.5) * 0.1
    prob_f = max(prob_f, 0.0)
    prob_f = min(prob_f, 1.0)

    return apply_surv(Chicken(is_f, prob_f))

def main():

    chickens = []

    while len(chickens) < POP_SIZE:
        ind = make_random()
        if ind is  None:
            continue
        chickens.append(ind)

    while True:
        idx_f = random.randrange(POP_SIZE)
        idx_m = random.randrange(POP_SIZE)
        idx_c = random.randrange(POP_SIZE)

        mother = chickens[idx_f]
        father = chickens[idx_m]

        if not mother.is_f:
            continue

        if father.is_f:
            continue

        child = make_child(mother, father)

        if child is None:
            continue

        chickens[idx_c] = child

        if random.random() < 0.01:
            mean_is_f = sum(chicken.is_f for chicken in chickens) / POP_SIZE
            mean_prob_f = sum(chicken.prob_f for chicken in chickens) / POP_SIZE

            print(mean_is_f, mean_prob_f)

if __name__ == '__main__':
    main()
