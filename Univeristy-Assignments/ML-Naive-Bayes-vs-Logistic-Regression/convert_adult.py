from numpy import loadtxt

import argparse
import _pickle as cp
import numpy as np


def load_raw_data(filename):
    raw_data = loadtxt(filename, delimiter=',', skiprows=0, dtype=str)
    return raw_data


def process_data(raw_data, feature_types, ugly=False, include_missing=False):
    N_data = raw_data.shape[0]
    N_features = raw_data.shape[1] - 1

    # Find possible values of categorical features
    feature_dicts = list()
    for i in range(0, N_features + 1):
        if i == N_features or feature_types[i] != 'r':
            unique = np.unique(raw_data[:, i])
            feature_dicts.append(unique[unique != ' ?'])
        else:
            feature_dicts.append(np.array([]))
    feature_dicts = np.array(feature_dicts)

    complete = np.ones(N_data, dtype=bool)

    # Add data as np arrays
    if ugly:
        X = np.full([N_data, N_features], 'ERRORERRORERRORERRORERROR')
        y = np.full(N_data, 'ERRORERRORERRORERRORERROR')
        for i in range(N_data):
            y[i] = raw_data[i][-1][1:]
            X[i, 0] = raw_data[i][0]
            for j in range(1, N_features):
                X[i, j] = raw_data[i][j][1:]
    else:
        X = np.zeros([N_data, N_features])
        y = np.zeros(N_data)
        for i in range(N_data):
            y[i] = np.where(feature_dicts[-1] == raw_data[i, -1])[0][0]
            for j in range(0, N_features):
                if raw_data[i, j] == ' ?':
                    X[i, j] = -1.
                    complete[i] = False
                elif feature_types[j] == 'r':
                    X[i, j] = float(raw_data[i, j])
                else:
                    X[i, j] = np.where(feature_dicts[j] == raw_data[i, j])[0][0]

    # Shuffle data before storing
    np.random.seed(0)
    shuffle = np.random.permutation(N_data)
    X = X[shuffle]
    y = y[shuffle]
    complete = complete[shuffle]

    if (ugly or include_missing) is True:
        return (X, y)
    else:
        return (X[complete], y[complete])

name = 'adult'
feature_types = 'rcrcrcccccrrrc'

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--ugly', dest='ugly',
                        action='store_true')
    parser.set_defaults(ugly=False)
    parser.add_argument('--include-missing', dest='include_missing',
                        action='store_true')
    parser.set_defaults(include_missing=False)
    args = parser.parse_args()

    if args.ugly is True:
        filename = name + '_ugly'
    elif args.include_missing is True:
        filename = name + '_full'
    else:
        filename = name

    input_filename = name + '.data'

    raw_data = load_raw_data(input_filename)

    adult = process_data(raw_data, feature_types, ugly=args.ugly, include_missing=args.include_missing)

    ff_file = open(filename + '.pickle', 'wb')
    cp.dump(adult, ff_file)
