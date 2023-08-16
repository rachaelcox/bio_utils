import re
import csv
import argparse
import pandas as pd
from Bio import SeqIO

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Filters duplicates from a transcriptome assembly using metrics from a BLASTp search.")
    parser.add_argument("--blastp_tsv", action="store", required=True,
                                        help="Filename of tab-separated ouput from a blastp search")
    parser.add_argument("--db_file", action="store", required=True,
                                        help="Reference database given to BLAST")
    parser.add_argument("--assembly_file", action="store", required=False,
                                        help="Raw assembly file to filter")
    parser.add_argument("--sep", action="store", required=False, default='\t',
                                        help="Column separator for blastp file, default=\t")
    
    inputs = parser.parse_args()

blastp_df = pd.read_csv(blastp_tsv, sep='\t', header=0)
blastp_size = len(blastp_df.index)

blastp_df.rename(columns = {'X1':'transcript_id',
                                 'X2':'uniprot_id',
                                 'X3':'perc_identical',
                                 'X4':'align_length',
                                 'X5':'num_mismatch',
                                 'X6':'gaps_open',
                                 'X7':'tscript_start',
                                 'X8':'tscript_stop',
                                 'X9':'match_start',
                                 'X10':'match_stop',
                                 'X11':'expect_value',
                                 'X12':'bit_score'}

match_lengths_df = pd.Dataframe(columns=['uniprot_id', 'match_prot_length'])

for record in SeqIO.parse(open(db_file,'r'), 'fasta'):
    uniprot_id = record.id
    prot_length = len(record.seq)
    match_lengths_df = match_lengths_df.append(uniprot_id, prot_length)
    
print("reference protein size df =",match_lengths_df)
print("avg protein length of 1000 longest proteins in DB =",avg_prot_length)
    
avg_prot_length_df = match_lengths_df.sort_values('match_prot_length', ascending=False).\
    head(1000)

avg_prot_length = avg_prot_length_df['match_prot_length'].mean()

print("raw blastp results (input):\n",blastp_output_df)
print("...")
print("# protein predictions =\n",blastp_size)

sorted_df = blastp_df.sort_values(['match_start','match_stop','num_mismatch'],\
                      ascending=[True,False,True])

filtered_df = sorted_df.groupby('uniprot_id').head(1)
filtered_size = len(filtered_df.index)

filt_avg_prot_len_df = filtered_df.join(match_lengths_df, on=uniprot_id, how='left', sort=False).\
    sort_values('match_prot_length', ascending=False).\
    head(1000)

filt_avg_prot_len = filt_avg_prot_len_df['match_prot_length'].mean()

print("filtered blastp results:\n",filtered_df)
print("...")
print("# protein predictions after filtering =", filtered_size)
print("avg protein length of 1000 longest proteins in filtered assembly =",filt_avg_prot_len):
