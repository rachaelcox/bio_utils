import csv
import argparse
import pandas as pd
import re

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Format emapper's (v1) output to something more amenable.")
	parser.add_argument("-f", "--filename", dest="filename", required=True, help="Input eggnog_mapper output, .annotations file output by emapper.py")
	parser.add_argument("-o", "--output_filename", action="store", dest="output_filename", help="Output filename for ProteinID - groupID mapping tsv", default="outfile.txt")
	args = parser.parse_args()

	########### maybe add these functionalities later ###########
	#parser$add_argument("-s", "--search_type", action="store", required=TRUE,
	                        #dest="search_type", choices=c('diamond', 'hmmer', 'maxrecall'), help="hmmer, diamond, or bestmatch (hmmer), or maxrecall (hmmer + diamond). ")

	#parser$add_argument("-l", "--level", action="store",
	                        #dest="level_sel", default=NULL, help="Output a specific phylogenetic level for diamond search")
	##############################################################

def fmt_IDs(eggnogIDs):
	fmt_IDs = []
	for i in eggnogIDs:
		if i.startswith('KOG'):
			fmt_IDs.append(i)
		else:
			fmt_IDs.append('ENOG41'+i)
	return fmt_IDs

# read in file
df = pd.read_csv(args.filename, sep='\t', skiprows=2, skipfooter=3)
print(df)

# format dataframe
df_best = df[['#query_name','bestOG|evalue|score']]
df_best = df_best.rename(columns={'#query_name':'ProteinID','bestOG|evalue|score':'results'})
df_best[['bestOG','evalue','bitscore']] = df_best.results.apply(lambda x: pd.Series(str(x).split("|")))

print(df_best)

df_output = df_best[['ProteinID','bestOG']].rename(columns={'bestOG':'ID'})
#df_output['ID'] = 'ENOG41' + df_output['ID'].astype(str)
df_output['ID'] = fmt_IDs(df_output['ID'])

print(df_output)

# write output
df_output.to_csv(args.output_filename, sep='\t', header=True, index=False)
print(df_output)


