import csv
import argparse
from Bio import SeqIO

def extract_GI_nums(input_fasta):

    # set up renamed output file
    database_file = input_fasta
    database = database_file.replace('.fasta','')

    # open file to write and specify headers
    with open("{}_GInums.txt".format(database),"w") as f:

        # loop through the fasta file and extract protein ID(s) and lengths
        for record in SeqIO.parse(open(database_file,"r"), "fasta"):
            ids = (record.id).split('|')
            GI_num = ids[1]
            print(ids[1])
            
            # write the ID to the open csv
            f.write("%s\n"%(GI_num))

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Takes a Xenbase FASTA file and generates list of GI numbers")
    parser.add_argument("--input_fasta", action="store", required=True,
                                        help="Filename of .fasta input")
    inputs = parser.parse_args()
    print(inputs)
    outputs = extract_GI_nums(inputs.input_fasta)
    #print(outputs)
