#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import numpy as np

class RGB_YUV_Converter:
	def rgb_to_yuv(self, image):
		matrix = np.array([
			[8421, 16515, 3211],
			[-4850, -9535, 14385],
			[14385, -12059, -2326]
		], dtype=np.int32)
		offsets = np.array([16, 128, 128])
		yuv = image.reshape(-1, 3) @ matrix.T
		yuv += ((offsets * 2) << 14)
		yuv = np.floor(yuv / 32768)
		yuv = np.clip(yuv, 0, 255)
		return yuv.reshape(image.shape)

class YUV_RGB_Converter:
	def yuv_to_rgb(self, Y, U, V):
		yuv = np.stack([Y, U, V], axis=-1).astype(np.int32)
		offsets = np.array([16, 128, 128])
		yuv -= offsets
		matrix = np.array([
			[38142, 0, 52298],
			[38142, -12845, -26640],
			[38142, 66093, 0]
		], dtype=np.int32)
		rgb = yuv @ matrix.T + 16384
		rgb = np.floor(rgb / 32768)
		return np.clip(rgb, 0, 255).astype(np.uint8)
