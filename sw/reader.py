#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import numpy as np
from PIL import Image
import os

class PPMReader:
	def __init__(self, filepath):
		self.filepath = filepath

	def read_image(self):
		print(f"Reading PPM image from {self.filepath}")
		with open(self.filepath, 'rb') as f:
			magic_number = f.readline().strip()
			if magic_number != b'P6':
				raise ValueError("Unsupported PPM format. Expected P6.")
			while True:
				line = f.readline().strip()
				if line.startswith(b'#'):
					continue
				width, height = map(int, line.split())
				break
			max_value = int(f.readline().strip())
			if max_value != 255:
				raise ValueError("Unsupported max color value. Expected 255.")

			pixel_data = f.read()
			image = np.frombuffer(pixel_data, dtype=np.uint8).reshape((height, width, 3))

			resized_filepath = None
			if (width != 192) or (height != 144):
				print(f"\n*** Warning: Image dimensions {width}x{height} do not match the expected dimensions 192x144. Resizing ... ***")
				img = Image.fromarray(image, mode='RGB')
				img_resized = img.resize((192, 144), resample=Image.BICUBIC)
				image = np.asarray(img_resized)
				base, ext = os.path.splitext(self.filepath)
				resized_filepath = f"{base}_192x144{ext}"
				img_resized.save(resized_filepath, format='PPM')
				print(f"*** Resized image saved to: {resized_filepath} ***\n")

			print(f"Image read successfully with shape: {image.shape}")
			return image, resized_filepath

class MICReader:
	def __init__(self, filepath):
		self.filepath = filepath

	def read(self):
		print(f"Reading bitstream from {self.filepath}")
		with open(self.filepath, 'rb') as f:
			data = f.read()

			if len(data) < 20:
				raise ValueError("Invalid .mic file: header too short")

			year = (data[0] << 8) | data[1]
			if year != 2025:
				raise ValueError(f"Unsupported year: {year} (expected 2025)")
			version = data[2] & 0x3F
			if version != 19:
				raise ValueError(f"Unsupported version: {version} (expected 19)")
			height = (data[4] << 8) | data[5]
			if height != 144:
				raise ValueError(f"Unsupported height: {height} (expected 144)")
			width  = (data[6] << 8) | data[7]
			if width != 192:
				raise ValueError(f"Unsupported width: {width} (expected 192)")

			header_data = {
				'quant_index': data[3],
				'y_offset': (data[8] << 16) | (data[9] << 8) | data[10],
				'y_bit': data[11],
				'u_offset': (data[12] << 16) | (data[13] << 8) | data[14],
				'u_bit': data[15],
				'v_offset': (data[16] << 16) | (data[17] << 8) | data[18],
				'v_bit': data[19]
			}

			encoded_data = data[20:]
			return header_data, encoded_data
