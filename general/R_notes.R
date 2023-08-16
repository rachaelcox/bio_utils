# color libs
library(RColorBrewer)
library(colorspace)

# formate emapper output
/project/cmcwhite/pipelines/MS_grouped_lookup/scripts/lookup_utils/format_emapper_output.R

# global options
library(tidyverse)
opts_chunk$set(fig.align = "center")
theme_set(theme_cowplot())

# install R package from github
devtools::install_github("sfirke/janitor")

# install Bioconductor packages with an old version of R
source("https://bioconductor.org/biocLite.R")
BiocInstaller::biocLite("ggtree")

# list unique identifiers in a column
sort(unique(df_name$col_name))

# separate a uniprot ID 
separate(ProteinID, into = c("tmp", "ProteinID", "tmp2"), sep = "[|]") %>% select(-tmp, -tmp2)


# read in file with variable white space between columns
up_codes <- read_table("qfo_tree/annotations/uniprot_speclist.fmt.txt",
                       col_names = FALSE)

# unnest delimited list
df_unnested <- df_nested %>%
  mutate(entry = str_split(as.character(entry), pattern = ',')) %>%
  unnest(entry)

# grep for a column name
zcol <- grep('joint_zscore', names(df), value = TRUE)

# grep between two characters
mutate(uniprot_ID = str_extract(X2,'(?<=\\|)(.*)(?=\\|)'))

# search for rows matching values from another object
labels <- read_csv(label_file, col_names = FALSE)
label_subset <- df %>%
  filter(grepl(paste(labels$X1, collapse = "|"), 
    get(acol), ignore.case = TRUE))

# troubleshooting N/As
filter(is.na(col_name)) # get N/As
na.omit() # remove N/As
replace(is.na(.), as.numeric("0")) # replace N/As with 0
df[is.na(df)] <- 0 # replace N/As with 0
df %>% replace_na(col_name = "text replacement") # for character replacement
mutate(across(c(annual_target_bonus, annual_equity), na_if,
                "Not Applicable/None")) # for changing strings --> NA
df[df == 0] <- NA  # change 0 back to NA

# fix plot window
dev.off()

# make a "not in" function
`%!in%` = Negate(`%in%`)

# add a new column and fill it in conditionally
mutate(new_col = case_when(score > 0 ~ "yes",
                            score == 0 ~ "no"))

# loop along enumerated list in R
fmt_data <- function(files){
  
  dfs <- list()
  
  for (i in seq_along(files)){
    print(paste(i,files[[i]]))
    df <- read_csv(files[[i]])
    df <- df %>%
      mutate(fold = paste0('GroupKFold ',i))
    dfs[[i]] <- df
  }
  
  return(dfs) 
  
}

# get summary stats from a model
calc_r2 <- function(df, exp){
  
  df <- filter(df, exp == exp)
  
  fit <- lm(probability ~ mean_ppi_score, df)
  r2 <- summary(fit)$adj.r.squared
  pval <- summary(fit)$coef[2,4]
  slope <- fit$coef[[2]]
  intercept <- fit$coef[[1]]
  
  return(r2)
  
}

# collapse and aggregate a column
df %>%
  group_by(col) %>%
  summarize_all(funs(paste(unique(.), collapse = ', ')))

# ggplot color palettes ------------------------------------------------------

palette_OkabeIto <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999", "#000000")

palette_bgy <- c("#FFFFCC","#A1DAB4","#41B6C4","#2C7FB8","#253494")
palette_viridis_7 <- c("#4B0055", "#353E7C", "#007094", "#009B95", "#00BE7D", "#96D84B", "#FDE333")
palette_viridis_5 <- c("#4B0055", "#00588B", "#009B95", "#53CC67", "#FDE333")
palette_plasma <- c("#001889","#72008D","#AB1488","#D24E71","#E8853A","#ECC000","#DAFF47")
palette_inferno <- c("#040404","#381B46","#782867","#B5456F","#E67651","#F5B84C","#FFFE9E")
palette_pretty <- rep(c("#0072B2","#E69F00","#009E24","#FF0000", "#979797","#5530AA"), 8)

palette_pretty <- c("#0072B2","#E69F00","#009E24","#FF0000", "#979797","#5530AA")
palette_bgy <- c("#FFFFCC","#A1DAB4","#41B6C4","#2C7FB8","#253494")
palette_wine <- c("#bcb37b", "#9e934d", "#8f8023", "#790000", "#5b0b0b") 
palette_wine2 <- c("#790000", "#9e934d")
palette_cb <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", 
  "#0072B2", "#D55E00", "#CC79A7", "#999999")

palette_npg <- c("#E64B35", "#4DBBD5", "#00A087", "#3C5488",
                 "#F39B7F", "#8491B4", "#91D1C2", "#DC0000",
                 "#7E6148", "#B09C85")

pal_npr <- c("#096264", "#5CC3AF", "#E7E1BD", "#ECA24D", "#DD3D00")


library(RColorBrewer)
display.brewer.pal(n=4, name="Dark2")
display.brewer.pal(n=4, name="Set2")

library(wesanderson)
display.wes.palette(5, "Zissou")

## ggplot syntax
ggplot(data, aes(x=, y=)) +
  geom_point(aes(color=, label=))


## ggsave syntax
final_plot %>% ggsave("relative_start_plot.tiff", ., device = "tiff", 
                      width = 4.5, height = 3.5, units = "in")

final_plot %>% ggsave("relative_start_plot.pdf", ., device = "pdf", 
                      width = 4.5, height = 3.5, units = "in")

final_plot %>% ggsave("relative_start_plot.png", ., device = "png", 
                      width = 4.5, height = 3.5, units = "in")


# squish ggplot axis with custom transformation function
trans <- function(x){
  ifelse(x > 0.9, x - 0.25, ifelse(x < 0.9, x + 0.25, x/4))
}

inv <- function(x){
  ifelse(x > 0.1, x + 0.25, ifelse(x < 0.1, x - 0.25, x*4))
}
    
axis_trans <- trans_new("my_trans", trans, inv)

# shrink between 0.1 and 0.9 by an order of 4 (i think)
final_plot <- final_plot +
  theme(strip.text.x = element_text(size = 9, color = "white"),
        strip.text.y = element_text(size = 18, color = "white")) +
  scale_y_continuous(trans = axis_trans,
                     breaks = seq(0, 1, by = .25))

# rotate axis labels
theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))


# make a heat map from a set of ragged character data ------------------------------------------------------

# get data in tidy format
df <- read_csv("file.csv")
df_tidy <- df %>%
  rownames_to_column() %>%
  mutate(rownames = as.numeric(rownames))
  gather(strain, status, -rownames) %>%
  filter(!is.na(status)) %>%   ## most important for an uneven number of observations (ragged data)
  mutate(silique = case_when(status == "f" ~ "failed",
                              status == "s" ~ "success")) %>%
  separate(strain, into = c("strainname", "plantnum"), remove = FALSE)

# plot heat map
df_tidy %>%
  ggplot(aes(x = strain, y = rownames, value = silique, fill = silique)) +
    geom_tile() +
    scale_fill_manual(values = color_palette) +
    theme(axis.text.x = element_blank()) + ## change x axis label
    scale_y_continuous(expand = c(0,0)) +  ## start at bottom axis
    ylab("Silique position") +
    xlab("Plant")

# plot multiple sorted heat maps concatenated
df_tidy %>%
  ggplot(aes(x = fct_reorder(strain, desc(rownames)), y = rownames, value = silique, fill = silique)) +
    geom_tile() +
    scale_fill_manual(values = color_palette) +
    theme(axis.text.x = element_blank()) + ## change x axis label
    scale_y_continuous(expand = c(0,0)) +  ## start at bottom axis
    ylab("Silique position") +
    xlab("Plant") +
    facet_grid(-strainname, scales = "free_x", space = "free") ## use facet_grid instead of facet_wrap for uneven sample sizes
    theme(strip.background = element_blank())

# specify node file, color gradient -------------------------------------------------------------------------------

node_df <- read_csv("actin_orthogroup_nodes_7mer_allproteins_formatted_alph_uniques.csv")

num_edges = 6773
highest_prot_count = 144

colfunc <- colorRampPalette(c("dark blue", "light green", "white"))

palette <- colfunc(highest_prot_count)

palette_LGL_format <- as_tibble(t(col2rgb(palette))) %>% rownames_to_column() %>%
  mutate(red = red/255) %>%
  mutate(green = green/255) %>%
  mutate(blue = blue/255)
  rename(ProteinCount = rowname) %>% 
  mutate(ProteinCount = as.numeric(ProteinCount))

color_file_protcount <- node_df %>%
  left_join(palette_LGL_format, by=c("ProteinCount")) %>%
  left_join(orthogroupIDs, by=c("ProteinID"))


# geom_text_repel() example
c16orf71_enriched_pc %>%
arrange(positive_control) %>% 
  ggplot(aes(x=mean_abundance, y=abundance_log2fc, label=HUMAN_GeneNames_Primary, shape=PSM_signif_hit)) +
    geom_point(alpha = 0.75, size = 3, aes(color=positive_control)) +
    geom_text_repel(
        data = subset(c16orf71_enriched_pc, positive_control=="TRUE"),
        size = 8/.pt, # font size 9 pt
        alpha = 1.0,
        hjust = 0,
        point.padding = 0.5, 
        box.padding = 0.5,
        segment.size = 0.35,
        segment.alpha = 0.9,
        segment.color = palette_viridis[1],
        colour = palette_viridis[1],
        set.seed(3333)) +
    geom_hline(yintercept = 0) + 
    scale_x_continuous(trans='log2') +
    scale_color_manual(values=c("grey70",palette_viridis[1]))

# PRIMARY PACKAGES
install.packages("tidyverse")
install.packages("yaml")
install.packages("ggthemes")