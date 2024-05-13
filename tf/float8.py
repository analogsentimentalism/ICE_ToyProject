import struct
import os

def nib(string):
    if string == '0000':
        return '0'

    if string == '0001':
        return '1'

    if string == '0010':
        return '2'

    if string == '0011':
        return '3'

    if string == '0100':
        return '4'

    if string == '0101':
        return '5'

    if string == '0110':
        return '6'

    if string == '0111':
        return '7'

    if string == '1000':
        return '8'

    if string == '1001':
        return '9'

    if string == '1010':
        return "A"

    if string == '1011':
        return "B"

    if string == '1100':
        return "C"

    if string == '1101':
        return "D"

    if string == '1110':
        return "E"

    if string == '1111':
        return "F"

def float_to_float8(num):
    temp_num = ''.join('{:0>8b}'.format(c) for c in struct.pack('!f', num))
    result = ''
    
    result += str(temp_num[0])
    
    exp=0
    for i in range (1, 9):
        exp += int(temp_num[i])<<(8-i)
    exp -= 127
    
    exp += 7
    
    if (exp<=15 and exp >= 0):
        for i in range (0,4):
            result += str(int(exp / (1<<(3-i))))
            exp %= 1<<(3-i)
        result += temp_num[9:12]
    elif (exp >= 15):
        result += '1110111'
    else:
        result+= '0000001'
    
       
    return nib(result[0:4]) + nib(result[4:8])

src_path = os.path.dirname(os.path.realpath(__file__))+"\\..\\original_text\\"
dst_path = os.path.dirname(os.path.realpath(__file__))+"\\..\\txt\\"

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
					print(float_to_float8(float(item)), end=" ")
					filestreamtwo.write(float_to_float8(float(item))+" ")