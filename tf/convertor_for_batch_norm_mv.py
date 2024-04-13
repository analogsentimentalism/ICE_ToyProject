import struct
import os
import math

src_path = os.path.dirname(os.path.realpath(__file__))+"\\..\\original_text\\"
dst_path = os.path.dirname(os.path.realpath(__file__))+"\\..\\txt\\"

def float_to_hex(f):
    return hex(struct.unpack('<I', struct.pack('<f', f))[0])

with open(src_path + "batch_normalization_moving_variance.txt", "r") as filestream:
	with open(dst_path + "batch_normalization_denominator.txt", "w") as filestreamtwo:
		for line in filestream:
			currentline = line.split(", ")
			for	item in currentline:
				if item == "\n":
					continue
				print(float_to_hex(float(item))[2:].upper(), end=" ")
				filestreamtwo.write(float_to_hex(math.sqrt((float(item) + 0.001)))[2:].upper() + " ")