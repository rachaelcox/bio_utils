import csv
import argparse
from Bio import SeqIO

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Converts sequences in a FASTA file to uppercase.")
    parser.add_argument("--fasta_file", action="store", required=True,
                                        help="FASTA file with lowercase sequences to convert")
    inputs = parser.parse_args()
    
    fasta_file = inputs.fasta_file

formatted_file = fasta_file.replace('.fasta','')

with open('{}_not_orthomapped.txt'.format(formatted_file),"w") as f:

    for record in SeqIO.parse(open(fasta_file,"r"), "fasta"):

        if not record.id.startswith("ENOG"):
        
            print(record.id)
        
            f.write(record.id+'\n')
