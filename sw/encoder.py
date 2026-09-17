#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import os
from reader import PPMReader
from converter import RGB_YUV_Converter
from xsampler import Downsampler
from transform import Transform
from quantizer import Quantizer
from lossless import LosslessCoder
from support import get_blocks

class MICEncoder:
	def __init__(self, ppm_filepath, quant_index):
		self.ppm_filepath = ppm_filepath
		self.quant_index = quant_index
		self._update_filepaths()

	def _update_filepaths(self):
		base, _ = os.path.splitext(self.ppm_filepath)
		suffix = f"_{self.quant_index}"
		self.mic_filepath = base + suffix + ".mic19"

	def encode(self):
		print("Starting encoding process ...")
		reader = PPMReader(self.ppm_filepath)
		image, resized_filepath = reader.read_image()
		converter = RGB_YUV_Converter()
		yuv = converter.rgb_to_yuv(image)
		y_rows, u_rows, v_rows = yuv[:, :, 0], yuv[:, :, 1], yuv[:, :, 2]
		print(f"Color space conversion from RGB to YUV completed for an image of size 192 x 144")

		downsampler = Downsampler()
		u_down, v_down = [downsampler.horizontal_downsample(rows) for rows in (u_rows, v_rows)]
		print(f"Downsampling applied to U and V image planes (96 downsampled columns)")

		pre_dct_y, pre_dct_u, pre_dct_v = [
			get_blocks(plane, 16 if c == 0 else 8, 16 if c == 0 else 8)
			for c, plane in enumerate((y_rows, u_down, v_down))
		]
		print(f"Y blocks: {len(pre_dct_y)}, U blocks: {len(pre_dct_u)}, V blocks: {len(pre_dct_v)}")

		block_transform = Transform()
		post_dct_y, post_dct_u, post_dct_v = [
			[block_transform.forward(block, luma=(c == 0)) for block in blocks]
			for c, blocks in enumerate((pre_dct_y, pre_dct_u, pre_dct_v))
		]
		print("DCT applied to all blocks")

		quantizer = Quantizer(self.quant_index)
		post_quant_y, post_quant_u, post_quant_v = [
			[quantizer.quantize(block, luma=(c == 0)) for block in blocks]
			for c, blocks in enumerate((post_dct_y, post_dct_u, post_dct_v))
		]
		print("Quantization completed")

		coder = LosslessCoder(self.quant_index)
		coder.encode_to_file(
			post_quant_y, post_quant_u, post_quant_v, self.mic_filepath
		)
		uncompressed_filepath = self.ppm_filepath if resized_filepath is None else resized_filepath
		print(f"Compression ratio: {(os.path.getsize(uncompressed_filepath)/os.path.getsize(self.mic_filepath)):.2f}")
