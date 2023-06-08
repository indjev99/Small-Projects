from dataclasses import dataclass, field
import numpy as np
import random

PERF_STD = 2050

POINTS_IN_GAME = 4
POINTS_IN_SET_TIEBREAK_GAME = 7
MIN_POINTS_DIFF = 2
GAMES_IN_SET = 6
MIN_GAMES_DIFF = 2
SETS_IN_MATCH = 2

@dataclass
class Player:
    serve_elo: float
    receive_elo: float

LEFT = 0
RIGHT = 1
UNKNOWN = -1

def empty_score():
    return [0, 0]

@dataclass
class GameResult:
    winner: int = UNKNOWN
    points: [int] = field(default_factory=empty_score)
    points_list: [int] = field(default_factory=list)

@dataclass
class SetResult:
    winner: int = UNKNOWN
    games: [int] = field(default_factory=empty_score)
    games_list: [GameResult] = field(default_factory=list)

@dataclass
class MatchResult:
    winner: int = UNKNOWN
    sets: [int] = field(default_factory=empty_score)
    sets_list: [SetResult] = field(default_factory=list)

def get_server(server: int) -> int:
    if server == UNKNOWN:
        server = random.choice([LEFT, RIGHT])
    return server

def other_server(server: int) -> int:
    return 1 - server

def get_elo(player: Player, is_server) -> float:
    if is_server:
        return player.serve_elo
    else:
        return player.receive_elo

def sim_point(left: Player, right: Player, server=UNKNOWN) -> int:
    server = get_server(server)
    l_perf = np.random.normal(get_elo(left, server == LEFT), PERF_STD)
    r_perf = np.random.normal(get_elo(right, server == RIGHT), PERF_STD)
    if l_perf > r_perf:
        return LEFT
    else:
        return RIGHT

def sim_game(left: Player, right: Player, server=UNKNOWN) -> GameResult:
    server = get_server(server)
    res = GameResult()
    while (
        max(res.points) < POINTS_IN_GAME or
        abs(res.points[LEFT] - res.points[RIGHT]) < MIN_POINTS_DIFF
    ):
        pr = sim_point(left, right, server)
        res.points_list.append(pr)
        res.points[pr] += 1
    res.winner = np.argmax(res.points)
    return res

def sim_tiebreak_game(left: Player, right: Player, server=UNKNOWN) -> GameResult:
    server = get_server(server)
    res = GameResult()
    while (
        max(res.points) < POINTS_IN_SET_TIEBREAK_GAME or
        abs(res.points[LEFT] - res.points[RIGHT]) < MIN_POINTS_DIFF
    ):
        pr = sim_point(left, right, server)
        res.points_list.append(pr)
        res.points[pr] += 1
        if len(res.points_list) % 2 == 1:
            server = other_server(server)
    res.winner = np.argmax(res.points)
    return res

def sim_set(left: Player, right: Player, server=UNKNOWN) -> SetResult:
    server = get_server(server)
    res = SetResult()
    while min(res.games) < GAMES_IN_SET and (
            max(res.games) < GAMES_IN_SET or
            abs(res.games[LEFT] - res.games[RIGHT]) < MIN_GAMES_DIFF
    ):
        gr = sim_game(left, right, server)
        res.games_list.append(gr)
        res.games[gr.winner] += 1
        server = other_server(server)
    if res.games[LEFT] == res.games[RIGHT]:
        gr = sim_tiebreak_game(left, right, server)
        res.games_list.append(gr)
        res.games[gr.winner] += 1
    res.winner = np.argmax(res.games)
    return res

def sim_match(left: Player, right: Player, server=UNKNOWN) -> MatchResult:
    server = get_server(server)
    res = MatchResult()
    while max(res.sets) < SETS_IN_MATCH:
        sr = sim_set(left, right, server)
        res.sets_list.append(sr)
        res.sets[sr.winner] += 1
        if len(sr.games_list) % 2 == 1:
            server = other_server(server)
    res.winner = np.argmax(res.sets)
    return res

def sim_big_game(left: Player, right: Player, server=UNKNOWN) -> GameResult:
    server = get_server(server)
    res = GameResult()
    while (
        max(res.points) < 77 or
        abs(res.points[LEFT] - res.points[RIGHT]) < MIN_POINTS_DIFF
    ):
        pr = sim_point(left, right, server)
        res.points_list.append(pr)
        res.points[pr] += 1
        if len(res.points_list) % 2 == 1:
            server = other_server(server)
    res.winner = np.argmax(res.points)
    return res


use_big_game = False

a = Player(800 + 0, 0)
b = Player(800 + 0, 0)

won = 0
points_played = 0

for i in range(int(1e9)):
    if not use_big_game:
        res = sim_match(a, b, LEFT)
        for set_res in res.sets_list:
            for game_res in set_res.games_list:
                points_played += len(game_res.points_list)
    else:
        res = sim_big_game(a, b, LEFT)
        points_played += len(res.points_list)
    if res.winner == LEFT:
        won += 1
    cnt = i + 1
    if cnt % 1000 == 0:
        prob = won / cnt
        std = (prob * (1 - prob) / cnt) ** 0.5
        num_stds = (prob - 0.5) / std
        mean_points_played = points_played / cnt
        print(cnt, prob, num_stds, mean_points_played)
