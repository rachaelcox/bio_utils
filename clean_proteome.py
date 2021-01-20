import csv
import argparse
from Bio import SeqIO

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Convert all sequences to upper case, \
                                    remove sequences with <20 amino acids and sequences, \
                                    and remove sequences containing >30% X")
    parser.add_argument("-f", "--input_fasta", action="store", required=True,
                                        help="Filename for FASTA with trash entries")
    parser.add_argument("-t", "--keep_trash", action="store_true", required=False,
                                        help="Specify this argument to output the discarded entries to a separate file")
    args = parser.parse_args()

input_fasta = args.input_fasta
writefile = input_fasta.replace(".fasta",'')

def write_fasta_entry(ID, seq, file):
    file.write('>'+ID+'\n')
    file.write(str(seq)+'\n')
    print('>'+ID)
    print(seq)

def write_trash_entry(writefile, ID, seq, file):
    with open("{}_trash.fasta".format(writefile), "a+") as file:
        write_fasta_entry(ID, seq, file)

with open("{}_clean.fasta".format(writefile), "w") as f:

    seq_lookup = set([])
    seq_trash = []

    for record in SeqIO.parse(open(input_fasta,"r"), "fasta"):
        sequence = str(record.seq.upper())
        sequence = sequence.replace('*','')

        if sequence not in seq_lookup:
            
            if len(sequence) > 20:

                X_count = sequence.count('X')
                X_perc = (X_count/len(sequence))*100

                if X_perc < 30:
                    seq_lookup.add(sequence)
                    write_fasta_entry(record.id, sequence, f)

                elif args.keep_trash == True:
                    write_trash_entry(writefile, record.id, sequence, 't')

            elif args.keep_trash == True:
                write_trash_entry(writefile, record.id, sequence, 't')

        elif args.keep_trash == True:
            write_trash_entry(writefile, record.id, sequence, 't')






                    

