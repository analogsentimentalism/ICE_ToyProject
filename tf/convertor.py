import struct
import os

src_path = os.path.dirname(os.path.realpath(__file__))+"\\..\\original_text\\"
dst_path = os.path.dirname(os.path.realpath(__file__))+"\\..\\txt\\"

def float_to_hex(f):
    return hex(struct.unpack('<I', struct.pack('<f', f))[0])

file_list = os.listdir(src_path)
print(file_list)
for file in file_list:
	with open(src_path + file, "r") as filestream:
		with open(dst_path + file, "w") as filestreamtwo:
			for line in filestream:
				currentline = line.split(", ")
				print(currentline)
				for	item in currentline:
					if item == "\n":
						continue
					print(float_to_hex(float(item))[2:].upper(), end=" ")
					filestreamtwo.write(float_to_hex(float(item))[2:].upper() + " ")