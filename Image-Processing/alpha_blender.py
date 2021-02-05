import numpy as np
import matplotlib.image as mpimg

num_layers = 9

layers = np.array([mpimg.imread('layers/layer_' + str(i + 1) + '.png')
                   for i in range(num_layers)])

rgbs = layers[:, :, :, :3]
alphas = layers[:, :, :, 3]
scaled_rgbs = rgbs * alphas[:, :, :, None]
summed_rgbs = np.sum(scaled_rgbs, axis=0)
summed_alphas = np.sum(alphas, axis=0)
result_rgbs = summed_rgbs / summed_alphas[:, :, None]
clean_rgbs = np.nan_to_num(result_rgbs)

mpimg.imsave('result_raw.png', clean_rgbs)
