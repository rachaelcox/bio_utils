import csv
import argparse
import re
from Bio import SeqIO

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Take a FASTA and output entry descriptions \
                                                  to a tab-limited file w/ entry name & its annotation")
    parser.add_argument("-f", "--input_fasta", action="store", required=True,
                                        help="Filename for input FASTA")
    args = parser.parse_args()

input_fasta = args.input_fasta
writefile = input_fasta.replace(".fasta",'')

def write_annotation(ID, description, file):
    desc_fmt = re.search(r'[ \t].*', description).group()
    print(ID+'\t'+desc_fmt)
    file.write(ID+'\t'+desc_fmt+'\n')
    #print(ID+'\t'+desc_fmt)

with open("{}_descriptions.tsv".format(writefile), "w") as f:
    lookup = set([])
    for record in SeqIO.parse(open(input_fasta,"r"), "fasta"):
        if record.id not in lookup:
            lookup.add(record.id)
            write_annotation(record.id, record.description, f)
    #print(lookup)