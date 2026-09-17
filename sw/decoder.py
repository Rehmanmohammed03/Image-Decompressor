#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import os
from reader import MICReader
from converter import YUV_RGB_Converter
from xsampler import Upsampler
from transform import Transform
from quantizer import Quantizer
from lossless import LosslessCoder
from support import reconstruct_rows_from_blocks, dump_all_rows, dump_all_blocks

class MICDecoder:

	def __init__(self, mic_filepath):
		self.mic_filepath = mic_filepath
		self._update_filepaths()

	def _update_filepaths(self):
		base, _ = os.path.splitext(self.mic_filepath)
		suffix = f"_sw"
		self.ppm_filepath = base + suffix + ".ppm"
		self.milestone2_input_filepath = base + ".sram_d2"
		self.milestone1_input_filepath = base + ".sram_d1"
		self.milestone1_output_filepath = base + ".sram_d0"

	def decode(self):

		print("Starting decoding process ...")
		reader = MICReader(self.mic_filepath)
		header_data, encoded_data = reader.read()
		quant_index = header_data['quant_index']

		coder = LosslessCoder()
		pre_requant_y, pre_requant_u, pre_requant_v = coder.decode_from_stream(encoded_data, header_data)
		print("Lossless decoding completed")

		quantizer = Quantizer(quant_index)
		pre_idct_y, pre_idct_u, pre_idct_v = [[quantizer.requantize(block, luma=(c == 0)) for block in blocks] \
						for c, blocks in enumerate((pre_requant_y, pre_requant_u, pre_requant_v))]
		print("Requantization completed")

		dump_all_blocks(pre_idct_y, pre_idct_u, pre_idct_v, filename=self.milestone2_input_filepath, debug_level=2)

		block_transform = Transform()
		post_idct_y, post_idct_u, post_idct_v = [
			[block_transform.inverse(block, luma=(c == 0), c=c, i=i) for i, block in enumerate(blocks)]
			for c, blocks in enumerate((pre_idct_y, pre_idct_u, pre_idct_v))
		]
		print("IDCT applied to all blocks")

		y_rows = reconstruct_rows_from_blocks(post_idct_y, 192)
		u_down, v_down = [reconstruct_rows_from_blocks(blocks, 96) \
					for blocks in (post_idct_u, post_idct_v)]

		dump_all_rows(y_rows, u_down, v_down, filename=self.milestone1_input_filepath, debug_level=1)

		upsampler = Upsampler()
		u_rows, v_rows = [upsampler.horizontal_upsample(down_rows) for down_rows in (u_down, v_down)]
		print(f"Upsampling applied to U and V image planes ({len(u_rows[0])} columns per row)")

		converter = YUV_RGB_Converter()
		rgb = converter.yuv_to_rgb(y_rows, u_rows, v_rows)

		with open(self.ppm_filepath, "wb") as f:
			header = f"P6\n192 144\n255\n"
			f.write(header.encode("ascii"))
			f.write(rgb.tobytes())

		dump_all_rows(rgb, None, None, filename=self.milestone1_output_filepath, debug_level=0)

		print(f"Saved image to {self.ppm_filepath} in PPM format")
