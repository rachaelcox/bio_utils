useful bits of bash code

## find out where large files are
du -Sh * > du.[date]

## find files bigger than 24 MB (github file size limit = 25MB)
find . -type f -size +24M

## grab 20 random files from a directory and copy to a new dir
find -L /MS/processed/leca/luca_level/arath/iex_1/mzXML -type f -name "*.mzXML" -print0 | xargs -0 shuf -e -n 20 -z | xargs -0 cp -vt /project/rmcox/misc/press.files/
find -L /MS/processed/leca/luca_level/human/iex_18/mzXML -type f -name "*.mzXML" -print0 | xargs -0 shuf -e -n 20 -z | xargs -0 cp -vt /project/rmcox/misc/press.files/
find -L /MS/processed/leca/luca_level/tetts/sec_2/mzXML/ -type f -name "*.mzXML" -print0 | xargs -0 shuf -e -n 20 -z | xargs -0 cp -vt /project/rmcox/misc/press.files/
find -L /MS/processed/leca/luca_level/halsa/sec_1/mzXML -type f -name "*.mzXML" -print0 | xargs -0 shuf -e -n 20 -z | xargs -0 cp -vt /project/rmcox/misc/press.files/
find -L /MS/processed/leca/luca_level/euggr/sec_1/mzXML -type f -name "*.mzXML" -print0 | xargs -0 shuf -e -n 20 -z | xargs -0 cp -vt /project/rmcox/misc/press.files/

## rename files sequentially
ls -v Euglena* | cat -n | while read n f; do mv -n "$f" "euggr_$n.mzXML"; done
# with padding
ls -1prt Euglena* | grep -v "/$" | cat -n | while read n f; do mv -n "${f}" "euggr_$(printf "%03d" $n).${f#*.}"; done
ls -1prt PH* | grep -v "/$" | cat -n | while read n f; do mv -n "${f}" "human_$(printf "%03d" $n).${f#*.}"; done
ls -1prt AT* | grep -v "/$" | cat -n | while read n f; do mv -n "${f}" "arath_$(printf "%03d" $n).${f#*.}"; done
ls -1prt Tet* | grep -v "/$" | cat -n | while read n f; do mv -n "${f}" "tetts_$(printf "%03d" $n).${f#*.}"; done
ls -1prt Halo* | grep -v "/$" | cat -n | while read n f; do mv -n "${f}" "halsa_$(printf "%03d" $n).${f#*.}"; done

## extract tar.gz files
tar -xvzf file.tar.gz

## sample top and bottom from files in a directory
for f in *mzXML; do echo "head -c200000 $f | tail -c100000 > sampled/${f%%.mzXML}_sampled.mzXML"; done > ../cmds/parallel_sample_mzxml.sh
cat ../cmds/parallel_sample_mzxml.sh | parallel -j36
tar -zcvf proteomic_files_sampled.tar.gz sampled

## find hidden things like /t or /n
cat -vet file.txt

## get line by line info
while IFS=$'\t' read -r -a x; do
    echo "species: ${x[0]} | exp: ${x[1]}"
done < ms_exp_list.txt

## find a file
find . -type f -name '*Tetrahymena_cilia_IEX*raw'

## find a specific directory across the entire file system
find / -type d -name 'OP_Tetrahymena_cilia_IEX_20170609'

find /stor/work/Marcotte/MS/ -type d -name 'Lumos_Marcotte'

## delete all file names that do not match specified pattern
find . -type f ! -name '*trimmed.paired.fastq.*' -delete

## match and symlink files bigger than 100 blocks (50KB)
find /stor/work/Marcotte/NGS/fastq/2020_06.rcox_dandelion/JA19407/SA19175/ -name "*.gz" -size +100 | xargs ln -s -f -t .

## linux fundamentals
https://wikis.utexas.edu/display/CoreNGSTools/Linux+fundamentals

## find user info
grep 'kx748' /etc/passwd/

## rename a lot of files with one extension
for i in *elut.ordered; do
	filename=${i%.*}
	ext=${i##*.}
	new_ext="ext"
	new_name="${i/$ext/$new_ext}"
	#mv -- "$i" "$new_name" # don't uncomment until you're sure it's correct
	echo "old filename = ${filename}, old ext = ${ext}"
	echo "new filename = ${new_name}"
	echo
done

## rename a lot of files with multiple .extensions
for i in *elut.ordered; do
	filename=${i%%.*}  # multiple % --> remove multiple .exts
	ext=${i#*.}  # one # --> keep multiple .exts
	echo "filename = ${filename}, ext = ${ext}"
	new_ext="ext"
	new_name="${i/$ext/$new_ext}"
	#mv -- "$i" "$new_name" # don't uncomment until you're sure it's correct
	echo "old filename = ${filename}, old ext = ${ext}"
	echo "new filename = ${new_name}"
	echo
done

## rename a lot of files with known extensions
for i in *elut.ordered*; do
	ext=".elut.ordered.pkl"
	new_ext=".ordered.elut.pkl"
	filename=${i%${ext}}
	new_name="${i/$ext/$new_ext}"
	mv -- "$i" "$new_name"
	echo "old filename = ${filename}, old ext = ${ext}"
	echo "new filename = ${new_name}"
	echo
done

#########################################
# TACC
######################################### 
showq # look at jobs running/waiting; will change if you have largemem module loaded
squeue -u rmcox # look at your jobs
module load TACC-largemem  # access largemem nodes
module spider  # look at all available packages
module spider cd-hit  # search for packages containing term "cd-hit"

# from Benni; put this in ~/.profile:
export PATH="$PATH:/work/projects/BioITeam/common/bin"
export PYTHONPATH=$PYTHONPATH:/corral-repl/utexas/BioITeam/lib/python2.7/site-packages
# inherited commands:
kyoo list  # list all available nodes
kyoo largemem512GB  # list specific node details
launcher_creator.py -n name_of_job -a allocation_code -q node_desired -t hours:min:seconds -m 'module load name_of_package' -e your_email -b 'name_of_executable -arguments -options etc' # template script for making slurm files
launcher_creator.py -n 071520_cdhit -a A-cm10 -q largemem512GB -t 4:00:00 -m 'module load cd-hit/ctr-4.6.8--0' -e rachaelcox@utexas.edu -b 'cd-hit-est -o /scratch/05819/rmcox/dandelions/trinity_combined_reads/cdhit.fasta -c 0.98 -i /scratch/05819/rmcox/dandelions/trinity_combined_reads/Trinity.fasta -p 1 -d 0 -b 3 -T 10' # example

# idev session
idev

# put this in ~/.bashrc to color code outputs and PWD on command line:
LS_COLORS='rs=0:di=1;35:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';

export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LS_COLORS

PS1='\w\$ '
######################################### 

## remove header from file
tail -n +2

## rename all file endings in the wd from .txt to .fasta
rename .txt .fasta *
rename 's/.txt/.fasta/g' *

# remove all empty lines in a file
sed -i '/^$/d' file.txt

# print last 2 columns of a file
awk -F',' '{print $(NF-1),"\t",$NF}' file
awk -F',' '{if ($NF == 1) print $1,"\t",$NF}' file

## count the number of lines that start with ">"
grep -c '^>' file.txt

## grep between 2 strings
grep -oP '(?<=Average).*(?=Fix random)' file.txt

## grep between 2 lines
sed -n '/Average/,/Fix random/p' file.txt

## turn off terminal beeps forever
modprobe -r pcspkr
blacklist pcspkr

## pull all lines that do not contain "string"
grep -v "string"

## kill process containing name...
pkill python3
pkill muscle
pkill <text>

# kill user processes
kill `ps -aux | grep 'rmcox' | awk '{print $2}'`

## add (sym linked) program executables to your PATH
# in /home1/05819/rmcox/bin:
ln -s /stor/work/Marcotte/project/rmcox/programs/usearch11.0.667 usearch

## rename a bunch of files to the name of their top-level directory
ls > domainlist.txt
while read domain; do echo "cp ${domain}/model/initial.fas ${domain}.fasta"; done < domainlist.txt > rename_hom_fastas.sh
cat rename_hom_fastas.sh | wc -l
cat rename_hom_fastas.sh | parallel -j21

## turn files in a directory into a comma-separated list
for x in *.fasta; do echo "${x}" | awk -v ORS=, '{print $1}'; done  # or:
ls *fasta | tr '\n' ',' | sed 's/.$/\n/'

## count and identify the non-unique entries in a file
cat file.txt | cut -f 3 | sort | uniq -c | sort -k1,1nr | head
cat file.txt | awk -F',' '{print $3}' | sort | uniq -c | sort -k1,1nr | head

## count number of columns
wc -

## create a list of numbers & write to a file
seq 12 > numlist.txt

## copy or move everything that does NOT match a specified expression
shopt -s extglob  # turn on extended globbing operators
cp /stor/work/Marcotte/project/rmcox/dandelions/data/raw/!(ToLeaf*) .  # copy everything that does NOT start with "ToLeaf"
shopt -u extglob  # turn off extended globbing operators

## extract kmers for desired subset(s) of proteins from large kmer file
while read exp; do echo "grep -G \"${exp}[0-9]\" /stor/work/Marcotte/project/rmcox/deBruijn_protein_maps/node_files/oma-seqs_nodes_10mer_allproteins.csv > ${exp}_10mers.csv"; done < exp_list.txt > grep_extract_kmers_1by1.sh

## format kmer file from csv to white-space separated (markov clustering pipeline)
while read exp; do echo "sed 's/,/ /g' /stor/work/Marcotte/project/rmcox/deBruijn_protein_maps/eukarya_analysis/individual_species/${exp}_10mers.csv > /stor/work/Marcotte/project/rmcox/deBruijn_protein_maps/eukarya_analysis/markov_clustering/${exp}_10mers_formatted.csv"; done < exp_list.txt > format_kmers_for_mcl.sh

## initialize markov clustering on kmer files (markov clustering pipeline)
while read exp; do echo "nohup mcl /stor/work/Marcotte/project/rmcox/deBruijn_protein_maps/eukarya_analysis/markov_clustering/${exp}_10mers_formatted.csv -I 7.0 -o /stor/work/Marcotte/project/rmcox/deBruijn_protein_maps/eukarya_analysis/markov_clustering/${exp}_10mers_mcl.csv --abc &> nohup_${exp}_10mers_mcl.out&"; done < exp_list.txt > run_mcl_1by1.sh

## collapse extracted kmers into uniques, while aggregating associated proteins (3rd column) and counting their number (4th column)
while read exp; do echo "python /stor/work/Marcotte/project/rmcox/scripts/collapse_uniques.py --input_file ${exp}_10mers.csv"; done < exp_list.txt > collapse_uniques_1by1.sh

## alphabetize kmers and then collapse into uniques (LGL pipeline)
while read exp; do echo "python /stor/work/Marcotte/project/rmcox/scripts/alphabetize_collapse_uniques.py --input_file ${exp}_10mers.csv"; done < exp_list.txt > alph_collapse_uniques_1by1.sh

## pull kmer columns from alphabetized/uniqued file where column 1 =/= column 2, then erase the header (LGL pipeline)
while read exp; do echo "awk -F',' '\$1!=\$2{print \$1,\$2}' ${exp}_10mers_alph_uniques.csv | tail -n +2 > ${exp}_10mers_lgl.ncol"; done < exp_list.txt > csv_to_ncol_1by1.sh

## create conf files appropriately edited for each experiment (LGL pipeline)
while read exp; do echo "sed 's/exp/${exp}_10mers/g' conf_file_template > conf_file_${exp}_10mers"; done < exp_list.txt > conf_file_edit_1by1.sh

## initialize LGL script for each experiment (LGL pipeline)
while read exp; do echo "nohup /stor/work/Marcotte/project/rmcox/programs/LGL/bin/lgl.pl -c conf_file_${exp}_10mers &> nohup_${exp}_10mers.out&"; done < exp_list.txt > nohup_generateLGLs_1by1.sh

## download A. thaliana promoters from a database
while read exp; do echo "wget -qO-  https://agris-knowledgebase.org/AtcisDB/getpromseq.html?id=${exp} | sed -e 's/<[^>]*>//g' | grep -e "^[TGCA]" | tr -d '\n' > ${exp}"; done < constitutive_locus_ids.txt > get_promoter_seqs.sh

cat get_promoter_seqs.sh | parallel -j32

while read exp; do echo "wget -qO-  https://agris-knowledgebase.org/AtcisDB/getpromseq.html?id=${exp} | sed -e 's/<[^>]*>//g' | grep -e "^[TGCA]" | tr -d '\n' > ${exp}"; done < inducible_locus_ids.txt > get_promoter_seqs.sh

cat get_promoter_seqs.sh | parallel -j64