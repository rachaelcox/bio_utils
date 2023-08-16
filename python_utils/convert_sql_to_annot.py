from __future__ import print_function
import argparse
import pandas as pd
 
def conversion(infilename, outfilename):

    df = pd.read_csv(infilename, sep="\t", header=None, index_col=False)
    df.columns = ['Group', 'GroupID', 'Species', 'Score', 'Acc', 'Percent']

    grouped = df.groupby(['Group', 'Species']).head(1)
    grouped = grouped[['GroupID', 'Species', 'Acc']]

   
    spec1 = grouped[grouped['Species']=="C.reinhardtii"]
    spec2 = grouped[grouped['Species']=="H.sapiens"]
   
    spec1 = spec1.set_index(['GroupID'])
    spec2 = spec2.set_index(['GroupID'])

    wide = pd.concat([spec1, spec2], axis=1)
    wide.columns  = ['Spec1', 'chlre', 'Spec2', 'human']

    wide = wide[['chlre', 'human']]
    wide.to_csv(outfilename, sep="\t", index=False)
 

def main():
    parser = argparse.ArgumentParser(description='Get the closest ortholog from inparanoid sql output')
    parser.add_argument('infilename', action="store", type=str)
    parser.add_argument('outfilename', action="store", type=str)
 

    inputs = parser.parse_args()
    conversion(inputs.infilename, inputs.outfilename)

main()









































