#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import sys

class ArgParser:
	def __init__(self):
		self.operation = None
		self.input_file = None
		self.reference_file = None
		self.quant_index = None

	def print_usage(self):
		print("Usage:")
		print("  Encoding:  python main.py -encode input.ppm [0|1]")
		print("  Decoding:  python main.py -decode input.mic19")
		print("  Compare:   python main.py -compare original.ppm decoded.ppm")
		sys.exit(1)

	def parse_args(self):
		if len(sys.argv) < 3:
			print("Error: Missing arguments.")
			self.print_usage()

		self.operation = sys.argv[1]

		if self.operation not in ["-encode", "-decode", "-compare"]:
			print("Error: Operation must be -encode, -decode, or -compare.")
			self.print_usage()

		if self.operation == "-encode":
			self.input_file = sys.argv[2]
			if not self.input_file.endswith(".ppm"):
				print("Error: Input file must have .ppm extension for encoding.")
				self.print_usage()

			if len(sys.argv) == 4:
				try:
					self.quant_index = int(sys.argv[3])
					if self.quant_index not in [0, 1]:
						raise ValueError
				except ValueError:
					print("Error: Quantization must be 0 or 1.")
					self.print_usage()
			else:
				self.quant_index = 0
				print("No quantization index specified. Defaulting to Q0.")

			print(f"Encoding mode selected. Using Quantization Matrix Q{self.quant_index}")

		elif self.operation == "-decode":
			if len(sys.argv) != 3:
				print("Error: Decoding requires exactly 1 argument.")
				self.print_usage()

			self.input_file = sys.argv[2]
			if not self.input_file.endswith(".mic19"):
				print("Error: Input file must have .mic19 extension for decoding.")
				self.print_usage()

			print("Decoding mode selected.")

		elif self.operation == "-compare":
			if len(sys.argv) != 4:
				print("Error: Comparison requires two .ppm files.")
				self.print_usage()

			self.input_file = sys.argv[2]
			self.reference_file = sys.argv[3]
			if not (self.input_file.endswith(".ppm") and self.reference_file.endswith(".ppm")):
				print("Error: Both files must have .ppm extension for comparison.")
				self.print_usage()

			print("Comparison mode selected.")

		return self.operation, self.input_file, self.reference_file, self.quant_index
