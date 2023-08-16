import csv
import argparse
import re
from Bio import SeqIO

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Filter entries from a FASTA by length")
    parser.add_argument("-f", "--input_fasta", action="store", required=True,
                                        help="Filename for FASTA to be filtered")
    parser.add_argument("-l", "--length", action="store", required=True,
                                        help="Filter entries longer than this specified length")
    parser.add_argument("-o", "--out", action="store", required=False,
                                        help="Name for outfile (optional)")
    args = parser.parse_args()


length_cutoff = long(args.length)
fasta = args.input_fasta

if args.out == None:
    writefile = fasta.replace(".fasta",'')
else:
    writefile = args.out

def write_fasta_entry(ID, seq, file):
    file.write('>'+ID+'\n')
    file.write(str(seq)+'\n')
    print('>'+ID)
    print(seq)

with open("{}_{}cutoff.fasta".format(writefile,length_cutoff), "w") as f:
    for record in SeqIO.parse(open(fasta,"r"), "fasta"):
        length = long(len(record.seq))
        if length < length_cutoff and length != 0:
        	write_fasta_entry(record.id, record.seq, f)