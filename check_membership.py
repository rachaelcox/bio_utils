import argparse

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Compare two lists")
    parser.add_argument("-i1", "--input1", action="store", required=True,
                                        help="File with first list")
    parser.add_argument("-i2", "--input2", action="store", required=True,
                                        help="File with second list")
    args = parser.parse_args()


set1file = args.input1
set2file = args.input2

set1 = set([])
with open(set1file, "r") as f:
	for entry in f:
		set1.add(entry.strip())
#print(set1)

set2 = set([])
with open(set2file, "r") as f:
	for entry in f:
		set2.add(entry.strip())


print(set1 & set2)
intersection = set1 & set2
with open("intersection.txt", "w") as f:
	for i in intersection:
		f.write(i+'\n')
