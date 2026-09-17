#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import sys, math
import numpy as np
from PIL import Image

def get_blocks(image_plane, block_height=8, block_width=8):
	valid_block_height = [8, 16]
	valid_block_width = [8, 16]
	if block_height not in valid_block_height or block_width not in valid_block_width:
		raise ValueError(f"Invalid block size: both {block_height} and {block_width} must be in {valid_block_height}x{valid_block_width}.")
	h, w = image_plane.shape
	return [
		image_plane[row:row+block_height, col:col+block_width]
		for row in range(0, h, block_height)
		for col in range(0, w, block_width)
		if image_plane[row:row+block_height, col:col+block_width].shape == (block_height, block_width)
	]

def reconstruct_rows_from_blocks(blocks, plane_width):
	if not blocks:
		return np.array([], dtype=np.int16)
	block_height, block_width = blocks[0].shape
	blocks_per_row = plane_width // block_width
	rows = len(blocks) // blocks_per_row
	plane = np.zeros((rows * block_height, plane_width), dtype=blocks[0].dtype)
	for idx, block in enumerate(blocks):
		row_block = idx // blocks_per_row
		col_block = idx % blocks_per_row
		row_index = row_block * block_height
		col_index = col_block * block_width
		plane[row_index:row_index+block_height, col_index:col_index+block_width] = block
	return plane

def dump_all_rows(y_rows, u_rows=None, v_rows=None, filename="rows_dump.bin", debug_level=None):

	if debug_level not in (0, 1):
		raise ValueError("debug_level must be 0 or 1.")
	# SRAM memory with 18 address lines and two bytes per location has 524288 bytes
	buffer = bytearray(524288)

	y = y_rows.astype(np.uint8)
	dumped_bytes = y.tobytes()
	if debug_level == 0:
		if u_rows is not None or v_rows is not None:
			raise ValueError("u_rows and v_rows must be None when debug_level is 0.")
		# RGB pixel data is stored from the SRAM memory location 220672 to the last SRAM memory location 262143
		# Note: hardware memory has two bytes per location - the buffer in the software model has one byte per entry
		buffer[441344:524288] = dumped_bytes
	else:
		if u_rows is None or v_rows is None:
			raise ValueError("u_rows and v_rows must be provided when debug_level is 1.")
		u = u_rows.astype(np.uint8)
		v = v_rows.astype(np.uint8)
		dumped_bytes += u.tobytes() + v.tobytes()
		# Post-IDCT / pre-upsampling and colour space conversion data is stored as follows in the SRAM:
		# Y data:	       0	->	   13823
		# U data:	   13824	->	   20735
		# V data:	   20736	->	   27647
		# Note: hardware memory has two bytes per location - the buffer in the software model has one byte per entry
		buffer[0:55296] = dumped_bytes

	with open(filename, "wb") as f:
		f.write(buffer)
	print(f"Debug level {debug_level} data dumped to {filename} (8-bit unsigned)")

def dump_all_blocks(y_blocks, u_blocks, v_blocks, filename="blocks_dump.bin", debug_level=None):

	if debug_level != 2:
		raise ValueError("debug_level must be 2.")
	buffer = bytearray(524288)

	y, u, v = reconstruct_rows_from_blocks(y_blocks, 192), reconstruct_rows_from_blocks(u_blocks, 96), reconstruct_rows_from_blocks(v_blocks, 96)
	yuv_bytes = y.astype(">i2").tobytes() + u.astype(">i2").tobytes() + v.astype(">i2").tobytes()

	# Pre-IDCT / post-requantization data is stored as follows in the SRAM:
	# Y data:	   27648	->	   55295
	# U data:	   55296	->	   69119
	# V data:	   69120	->	   82943
	# Note: hardware memory has two bytes per location - the buffer in the software model has one byte per entry
	buffer[55296:165888] = yuv_bytes

	with open(filename, "wb") as f:
		f.write(buffer)
	print(f"Debug level {debug_level} data dumped to {filename}")

def ImageCompare(img1_path, img2_path):
	print(img1_path, img2_path)
	img1 = Image.open(img1_path)
	img2 = Image.open(img2_path)
	if img1.size != img2.size:
		print("Image dimensions do not match:")
		print(f" - {img1_path}: {img1.size}")
		print(f" - {img2_path}: {img2.size}")
		sys.exit(1)
	arr1 = np.array(img1.convert('RGB'), dtype=np.uint8)
	arr2 = np.array(img2.convert('RGB'), dtype=np.uint8)
	if arr1.shape != arr2.shape:
		raise ValueError("Image dimensions do not match")
	mse = np.mean((arr1.astype(np.float32) - arr2.astype(np.float32)) ** 2)
	if mse == 0:
		print("PSNR is infinity - images are identical")
		sys.exit()
	psnr = 10 * math.log10((255 ** 2) / mse)
	print(f"PSNR: {psnr:.2f} dB")
