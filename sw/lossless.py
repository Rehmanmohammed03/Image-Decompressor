#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import numpy as np

class LosslessCoder:

	LUMA_ZZ_SEQUENCE = np.array([
		0, 1, 16, 32, 17, 2, 3, 18, 33, 48, 64, 49, 34, 19, 4, 5,
		20, 35, 50, 65, 80, 96, 81, 66, 51, 36, 21, 6, 7, 22, 37, 52,
		67, 82, 97, 112, 128, 113, 98, 83, 68, 53, 38, 23, 8, 9, 24, 39,
		54, 69, 84, 99, 114, 129, 144, 160, 145, 130, 115, 100, 85, 70, 55, 40,
		25, 10, 11, 26, 41, 56, 71, 86, 101, 116, 131, 146, 161, 176, 192, 177,
		162, 147, 132, 117, 102, 87, 72, 57, 42, 27, 12, 13, 28, 43, 58, 73,
		88, 103, 118, 133, 148, 163, 178, 193, 208, 224, 209, 194, 179, 164, 149, 134,
		119, 104, 89, 74, 59, 44, 29, 14, 15, 30, 45, 60, 75, 90, 105, 120,
		135, 150, 165, 180, 195, 210, 225, 240, 241, 226, 211, 196, 181, 166, 151, 136,
		121, 106, 91, 76, 61, 46, 31, 47, 62, 77, 92, 107, 122, 137, 152, 167,
		182, 197, 212, 227, 242, 243, 228, 213, 198, 183, 168, 153, 138, 123, 108, 93,
		78, 63, 79, 94, 109, 124, 139, 154, 169, 184, 199, 214, 229, 244, 245, 230,
		215, 200, 185, 170, 155, 140, 125, 110, 95, 111, 126, 141, 156, 171, 186, 201,
		216, 231, 246, 247, 232, 217, 202, 187, 172, 157, 142, 127, 143, 158, 173, 188,
		203, 218, 233, 248, 249, 234, 219, 204, 189, 174, 159, 175, 190, 205, 220, 235,
		250, 251, 236, 221, 206, 191, 207, 222, 237, 252, 253, 238, 223, 239, 254, 255
	], dtype=np.uint8)

	CHROMA_ZZ_SEQUENCE = np.array([
		0, 8, 1, 2, 9, 16, 24, 17, 10, 3, 4, 11, 18, 25, 32, 40,
		33, 26, 19, 12, 5, 6, 13, 20, 27, 34, 41, 48, 56, 49, 42, 35,
		28, 21, 14, 7, 15, 22, 29, 36, 43, 50, 57, 58, 51, 44, 37, 30,
		23, 31, 38, 45, 52, 59, 60, 53, 46, 39, 47, 54, 61, 62, 55, 63
	], dtype=np.uint8)

	def __init__(self, quant_index=0):
		self.buffer = 0
		self.pointer = 0
		self.stream = bytearray()
		self.byte_pos = 0
		self.quant_index = quant_index

	def _write_bits(self, bits, length):
		self.buffer = (self.buffer << length) | bits
		self.pointer += length
		while self.pointer >= 8:
			self.stream.append((self.buffer >> (self.pointer - 8)) & 0xFF)
			self.pointer -= 8
			self.byte_pos += 1

	def _flush(self):
		if self.byte_pos % 2:
			self._write_bits(0, 8 - self.pointer)
		elif self.pointer > 0:
			self._write_bits(0, 16 - self.pointer)

	def _zz_traverse(self, block):
		flat = np.empty(self.block_height * self.block_width, dtype=np.int16)
		rows, cols = divmod(self.ZZ_SEQUENCE, self.block_width)
		flat[:] = block[rows, cols]

		return flat

	def _encode_block(self, flat):
		i = 0
		while i < self.block_height * self.block_width:
			j = 0
			while i + j < self.block_height * self.block_width and flat[i + j] == 0:
				j += 1
			if i + j < self.block_height * self.block_width:
				if j > 0:
					run = j
					while run >= 4:
						self._write_bits(0, 4)
						run -= 4
					if run > 0:
						self._write_bits(0 | run, 4)
				val = flat[i + j]
				if -2 <= val < 2:
					self._write_bits(4 | (val & 3), 4)
				else:
					self._write_bits(1024 | (val & 511), 11)
			else:
				self._write_bits(3, 2)
			i += j + 1

	def encode_to_file(self, y_blocks, u_blocks, v_blocks, filename):
		bit_offset = [0] * 3
		segment_offsets = [0] * 3
		header_prefix = [(2025 >> 8) & 0xFF, 2025 & 0xFF, 19 & 0x3F, self.quant_index,
					(144 >> 8) & 0xFF, 144 & 0xFF, (192 >> 8) & 0xFF, 192 & 0xFF]
		self.stream = bytearray(bytearray(header_prefix) + bytearray(12))
		for c, blocks in enumerate([y_blocks, u_blocks, v_blocks]):
			self.block_height = 8 if c > 0 else 16
			self.block_width = 8 if c > 0 else 16
			self.ZZ_SEQUENCE = LosslessCoder.CHROMA_ZZ_SEQUENCE if c > 0 else LosslessCoder.LUMA_ZZ_SEQUENCE
			segment_offsets[c], bit_offset[c] = len(self.stream), self.pointer
			for block in blocks:
				self._encode_block(self._zz_traverse(block))
		self._flush()
		for c in range(3):
			offset, boffset = segment_offsets[c], bit_offset[c]
			self.stream[8 + 4 * c + 0] = (offset >> 16) & 0xFF
			self.stream[8 + 4 * c + 1] = (offset >> 8) & 0xFF
			self.stream[8 + 4 * c + 2] = offset & 0xFF
			self.stream[8 + 4 * c + 3] = boffset & 0xFF
		with open(filename, "wb") as f:
			f.write(self.stream)
		print(f"Lossless bitstream written to {filename}")

	def _read_bits(self, compressed_data, length):
		if length <= 0:
			return 0

		while self.pointer >= 16:
			if self.byte_pos + 1 < len(compressed_data):
				read_val = ((compressed_data[self.byte_pos] << 8) | compressed_data[self.byte_pos + 1]) & 0xFFFF
			else:
				read_val = 0
			self.buffer |= read_val << (self.pointer - 16)
			self.pointer -= 16
			self.byte_pos += 2
		bits = (self.buffer >> (32 - length)) & ((1 << length) - 1)
		self.buffer = (self.buffer << length) & 0xFFFFFFFF
		self.pointer += length

		return bits

	def decode_from_stream(self, compressed_data, header_data):
		yo, yb, uo, ub, vo, vb = header_data['y_offset'], header_data['y_bit'], header_data['u_offset'], header_data['u_bit'], header_data['v_offset'], header_data['v_bit']
		luma_blocks_per_row, luma_blocks_per_column = 9, 12
		chroma_blocks_per_row, chroma_blocks_per_column = 18, 12
		self.byte_pos, self.pointer, self.buffer = 0, 32, 0
		block_bits = 0
		decoded_planes = []
		seg_offsets, seg_bits = [0] * 3, [0] * 3
		for c, blocks_per_column in enumerate([luma_blocks_per_column, chroma_blocks_per_column, chroma_blocks_per_column]):
			seg_offsets[c], seg_bits[c] = yo + block_bits // 8, block_bits % 8		# there are 8 bits per byte
			self.block_height = 8 if c > 0 else 16
			self.block_width = 8 if c > 0 else 16
			self.ZZ_SEQUENCE = LosslessCoder.CHROMA_ZZ_SEQUENCE if c > 0 else LosslessCoder.LUMA_ZZ_SEQUENCE
			blocks_per_row = chroma_blocks_per_row if c > 0 else luma_blocks_per_row
			blocks = []
			for _ in range(blocks_per_row * blocks_per_column):
				block = np.zeros((self.block_height, self.block_width), dtype=np.int16)
				k = 0
				while k < self.block_height * self.block_width:
					block_bits += 2
					code = self._read_bits(compressed_data, 2)
					if code == 0:
						block_bits += 2
						run = self._read_bits(compressed_data, 2)
						end_of_run = k + (run if run else 4)
						for i in range(k, end_of_run):
							block[divmod(self.ZZ_SEQUENCE[i], self.block_width)] = 0
						k = end_of_run
					elif code == 2:
						block_bits += 9
						code_val = self._read_bits(compressed_data, 9)
						code_val -= 512 if code_val >= 256 else 0
						block[divmod(self.ZZ_SEQUENCE[k], self.block_width)] = code_val
						k += 1
					elif code == 1:
						block_bits += 2
						code_val = self._read_bits(compressed_data, 2)
						code_val -= 4 if code_val >= 2 else 0
						block[divmod(self.ZZ_SEQUENCE[k], self.block_width)] = code_val
						k += 1
					elif code == 3:
						end_of_run = self.block_height * self.block_width
						for i in range(k, end_of_run):
							block[divmod(self.ZZ_SEQUENCE[i], self.block_width)] = 0
						k = end_of_run
					else:
						raise ValueError("Unrecognized code in bitstream")
				blocks.append(block)
			decoded_planes.append(blocks)

		if (yo, yb) != (seg_offsets[0], seg_bits[0]):
			print(f"Y offset mismatch: header=({yo},{yb}) vs stream=({seg_offsets[0]},{seg_bits[0]})")
		if (uo, ub) != (seg_offsets[1], seg_bits[1]):
			print(f"U offset mismatch: header=({uo},{ub}) vs stream=({seg_offsets[1]},{seg_bits[1]})")
		if (vo, vb) != (seg_offsets[2], seg_bits[2]):
			print(f"V offset mismatch: header=({vo},{vb}) vs stream=({seg_offsets[2]},{seg_bits[2]})")

		return decoded_planes
