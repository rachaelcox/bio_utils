import csv
import argparse
import re
from Bio import SeqIO

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Filter entries from a FASTA file, given a \
    									file with entries desired")
    parser.add_argument("-f", "--input_fasta", action="store", required=True,
                                        help="Filename for FASTA to be filtered")
    parser.add_argument("-e", "--entry_list", action="store", required=True,
                                        help="Filename for text file with desired entry filtrate")
    parser.add_argument("-o", "--out", action="store", required=False,
                                        help="Name for outfile (optional)")
    args = parser.parse_args()


desired_entries = args.entry_list
input_fasta = args.input_fasta

if args.out == None:
    writefile = input_fasta.replace(".fasta",'')
else:
    writefile = args.out

def write_fasta_entry(ID, seq, file):
    file.write('>'+ID+'\n')
    file.write(str(seq)+'\n')
    print('>'+ID)
    print(seq)

lookup = set([])
with open(desired_entries, "r") as f:
    for entry in f:
        print(entry)
        lookup.add(entry.strip())
    print(lookup)

with open("{}_filtered.fasta".format(writefile), "w") as f:
    for record in SeqIO.parse(open(input_fasta,"r"), "fasta"):
        sequence = str(record.seq.upper())
        #sequence_id = re.search(r'(?<=\|)(.*)(?=\|)',str(record.id)).group()
        #print(sequence_id)
        #if sequence_id in lookup:
        # 	write_fasta_entry(record.id, sequence, f)
        if any(entry in record.id for entry in lookup) == True:
        	write_fasta_entry(record.id, sequence, f)

