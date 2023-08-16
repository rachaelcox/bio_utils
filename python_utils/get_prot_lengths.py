import csv
import argparse
import pandas as pd
from Bio import SeqIO

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Takes a FASTA file and get protein lengths")
    parser.add_argument("-f", "--input_fasta", action="store", required=True,
                                    help="Filename of .fasta input")
    parser.add_argument("-o", "--out", action="store", required=False, dest="out",
                                    help="Name for outfile (optional; default = protlens.csv)")
    parser.add_argument("-avg", "--average", action="store", required=False, nargs="?", const=1000, type=int,
    								help="Calculate average length for N longest proteins (default N=1000)")
    args = parser.parse_args()

#########################################################
# functions
#########################################################
def get_lens(fasta, writefile):
	len_list = []
	index = 0
	total_len = 0
	longest_len = 0

	for record in SeqIO.parse(open(fasta,"r"), "fasta"):
		
		prot_id = record.id
		#prot_seq = str(record.seq.upper())
		prot_len = len(record.seq)
		len_list.append([prot_id, prot_len])
		
		index += 1
		total_len += prot_len

		if prot_len > longest_len:
			longest_len = prot_len
			longest_id = prot_id

	avg_len = total_len/index
	print("average protein length = {} aa".format(avg_len))
	print("{} is the longest entry with {} aa".format(longest_id, longest_len))

	len_df = pd.DataFrame(len_list)
	len_df.columns=['ProteinID','ProteinLength']
	sorted_df = len_df.sort_values('ProteinLength', ascending=False)
	sorted_df.to_csv(writefile+'.csv', index=False)
	print(sorted_df)

	return(sorted_df)

def longest_average(sorted_df, num_prots):
	prot_lens = sorted_df.nlargest(num_prots, 'ProteinLength')
	print("top {} longest proteins are:".format(num_prots))
	print(prot_lens)

	len_mean = prot_lens['ProteinLength'].mean()
	print("the mean length of the top {} proteins is:".format(num_prots))
	print(len_mean)

	len_median = prot_lens['ProteinLength'].median()
	print("the median length of the top {} proteins is:".format(num_prots))
	print(len_median)

#########################################################
# execution
#########################################################

if args.out == None:
	writefile = "protlengths"
else:
	writefile = args.out

fasta = args.input_fasta
num_prots = args.average

prot_lengths = get_lens(fasta, writefile)
if args.average != None:
	longest_average(prot_lengths, num_prots)

#########################################################
# without pandas (archived)
#########################################################

#with open("{}_lengths.txt".format(writefile),"w") as f:
#	f.write("{}\t{}\n".format("ProteinID","ProteinLength"))
#	
#	for record in SeqIO.parse(open(fasta,"r"), "fasta"):
#		
#		prot_id = record.id
#		#prot_seq = str(record.seq.upper())
#		prot_len = len(record.seq)
#		#len_list.append([prot_id, prot_len])
#		
#		index += 1
#		total_len += prot_len
#
#		if prot_len > longest_len:
#			longest_len = prot_len
#			longest_id = prot_id
#
#        # write the ID(s) and lengths to the open csv 
#		f.write("{}\t{}\n".format(prot_id,prot_len))