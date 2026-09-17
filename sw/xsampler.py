#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import numpy as np

class Downsampler:
	def _downsample_row(self, row, coeffs):
		cols = len(row)
		center = len(coeffs) // 2
		offsets = np.arange(-center, center + 1)
		indices = np.clip(np.arange(0, cols, 2)[:, None] + offsets, 0, cols - 1)
		values = row[indices]
		downsampled = np.dot(values, coeffs)
		downsampled = np.floor(downsampled / 8192)
		downsampled = np.clip(downsampled, 0, 255).astype(np.uint8)
		return downsampled

	def horizontal_downsample(self, image_plane):
		coeffs = np.array([0, 71, 0, -180, 0, 360, 0, -771, 0, 2568, 4096, 2568, 0, -771, 0, 360, 0, -180, 0, 71, 0], dtype=np.int32)
		return np.array([self._downsample_row(row, coeffs) for row in image_plane], dtype=np.uint8)


class Upsampler:
	def _upsample_row(self, even_samples, coeffs):
		upsampled = np.empty(len(even_samples) * 2, dtype=np.int32)
		upsampled[0::2] = even_samples
		center = len(coeffs) // 2
		offsets = np.arange(-center + 1, center + 1)
		indices = np.clip(np.arange(len(even_samples))[:, None] + offsets, 0, len(even_samples) - 1)
		values = even_samples[indices]
		odd_samples = np.dot(values, coeffs)
		odd_samples += 2048
		odd_samples = np.floor(odd_samples / 4096)
		upsampled[1::2] = np.clip(odd_samples, 0, 255).astype(np.uint8)
		return upsampled

	def horizontal_upsample(self, downsampled_plane):
		coeffs = np.array([36, -98, -233, 528, 1815, 1815, 528, -233, -98, 36], dtype=np.int32)
		return np.array([self._upsample_row(row, coeffs) for row in downsampled_plane], dtype=np.uint8)
