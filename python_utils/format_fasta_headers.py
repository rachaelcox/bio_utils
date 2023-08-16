import csv
import argparse
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Format weird FASTA headers (where accessions are split with '|') so it will play nice with Proteome Discoverer.")
    parser.add_argument("-f", "--fasta", action="store", required=True, dest="fasta",
                                        help="FASTA file to be collapsed")
    parser.add_argument("-o", "--out", action="store", required=False, dest="out",
                                        help="Name for outfile (optional)")

    args = parser.parse_args()

if args.out == None:
	writefile = args.fasta.replace('.fasta','_fmt.fasta')
else:
	writefile = args.out

fasta = args.fasta

def write_fasta_entry(ID, seq, file):
    file.write('>'+ID+'\n')
    file.write(str(seq)+'\n')
    print('>'+ID)
    print(seq)

with open(writefile, 'w') as f:
    
    for record in SeqIO.parse(open(fasta,'r'), 'fasta'):
        original_id = record.id
        sequence = str(record.seq.upper())
        
        if original_id.startswith('ENOG'):
        	write_fasta_entry(original_id, sequence, f)

        else:
            new_id = original_id.split('|')[1]
            write_fasta_entry(new_id, sequence, f)