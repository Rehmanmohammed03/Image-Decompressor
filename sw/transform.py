#
# Comp Eng 3DQ5 - Digital Systems Design - Fall 2025
# Department of Electrical and Computer Engineering
# McMaster University, Ontario, Canada
#
# This file is part of the copyrighted software model distribution for the
# course project on the hardware implementation of the .mic19 decompressor.
#
import numpy as np
import sys

class Transform:

	C_16x16 = np.array([
		[128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128],
		[180, 173, 159, 139, 114, 85, 52, 17, -17, -52, -85, -114, -139, -159, -173, -180],
		[177, 150, 100, 35, -35, -100, -150, -177, -177, -150, -100, -35, 35, 100, 150, 177],
		[173, 114, 17, -85, -159, -180, -139, -52, 52, 139, 180, 159, 85, -17, -114, -173],
		[167, 69, -69, -167, -167, -69, 69, 167, 167, 69, -69, -167, -167, -69, 69, 167],
		[159, 17, -139, -173, -52, 114, 180, 85, -85, -180, -114, 52, 173, 139, -17, -159],
		[150, -35, -177, -100, 100, 177, 35, -150, -150, 35, 177, 100, -100, -177, -35, 150],
		[139, -85, -173, 17, 180, 52, -159, -114, 114, 159, -52, -180, -17, 173, 85, -139],
		[128, -128, -128, 127, 128, -127, -127, 127, 127, -127, -127, 127, 128, -127, -128, 127],
		[114, -159, -52, 180, -17, -173, 85, 139, -139, -85, 173, 17, -180, 52, 159, -114],
		[100, -177, 35, 150, -150, -35, 177, -100, -100, 177, -35, -150, 150, 35, -177, 100],
		[85, -180, 114, 52, -173, 139, 17, -159, 159, -17, -139, 173, -52, -114, 180, -85],
		[69, -167, 167, -69, -69, 167, -167, 69, 69, -167, 167, -69, -69, 167, -167, 69],
		[52, -139, 180, -159, 85, 17, -114, 173, -173, 114, -17, -85, 159, -180, 139, -52],
		[35, -100, 150, -177, 177, -150, 100, -35, -35, 100, -150, 177, -177, 150, -100, 35],
		[17, -52, 85, -114, 139, -159, 173, -180, 180, -173, 159, -139, 114, -85, 52, -17]
	], dtype=np.int32)

	C_8x8 = np.array([
		[181, 181, 181, 181, 181, 181, 181, 181],
		[251, 212, 142, 49, -49, -142, -212, -251],
		[236, 97, -97, -236, -236, -97, 97, 236],
		[212, -49, -251, -142, 142, 251, 49, -212],
		[181, -181, -181, 181, 181, -181, -181, 181],
		[142, -251, 49, 212, -212, -49, 251, -142],
		[97, -236, 236, -97, -97, 236, -236, 97],
		[49, -142, 212, -251, 251, -212, 142, -49]
	], dtype=np.int32)

	def forward(self, block, luma=False):
		block = block.astype(np.int32)
		PRE_C = Transform.C_16x16 if luma else Transform.C_8x8
		POST_C = Transform.C_16x16 if luma else Transform.C_8x8
		Temp = np.floor((block @ POST_C.T) / 32)
		Result = np.floor((PRE_C @ Temp + 4096) / 8192)
		return Result.astype(np.int16)

	def inverse(self, block, luma=False, c=0, i=0):
		index = 0
		luma_or_chroma = 0
		block = block.astype(np.int32)
		
		hex_sp = np.vectorize(lambda x : f"0x{x:08x}")(block.astype(np.uint32))
		if(c == luma_or_chroma and i == index): 
			print("+++++++ S PRIME VALUES ++++++++++++")
			print(hex_sp)
			print("--------------------------------------------------------")
		PRE_C = Transform.C_16x16 if luma else Transform.C_8x8
		POST_C = Transform.C_16x16 if luma else Transform.C_8x8
		
		hex_c = np.vectorize(lambda x: f"0x{x:08x}")(POST_C.astype(np.uint32))
		if(c == luma_or_chroma and i == index): 
			print("========== C VALUES ===============")
			print(hex_c)
			print("============================================")
		Temp = np.floor((block @ POST_C) / 32)
		
		if(c == luma_or_chroma and i == index): 
			print("============== T VALUES ===============")
			print(np.int32(Temp))
			print("========================================")
		Result = np.floor((PRE_C.T @ Temp + 4096) /8192)

		if(c == luma_or_chroma and i == index):
			print("============== S Values ===============")
			print(np.int32(Result))
			print("========================================")

		return np.clip(Result, 0, 255).astype(np.uint8)
