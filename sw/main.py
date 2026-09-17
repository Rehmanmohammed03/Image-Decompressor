#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
from encoder import MICEncoder
from decoder import MICDecoder
from parser import ArgParser
from support import ImageCompare

if __name__ == "__main__":

	parser = ArgParser()
	operation, input_file, reference_file, quant_index = parser.parse_args()

	if operation == "-encode":
		encoder = MICEncoder(input_file, quant_index)
		encoder.encode()
		print("Encoding completed!")
	elif operation == "-decode":
		decoder = MICDecoder(input_file)
		decoder.decode()
		print("Decoding completed!")
	elif operation == "-compare":
		ImageCompare(input_file, reference_file)
		print("Comparison completed!")
