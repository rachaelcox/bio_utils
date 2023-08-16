setwd("/stor/work/Marcotte/project/rmcox/")

MS_data <- read_csv("xenla_concat_xbup_test.prot_count_mFDRpsm001_unweighted.tidy") %>% 
  filter(!grepl("Prick", FractionID))

MS_data_sum <- MS_data %>% 
  mutate(FractionID_new = str_extract(FractionID, regex(".*(?=_[a|b|c|d]$)"))) %>%
  select(-FractionID) %>% 
  group_by(FractionID_new, ProteinID) %>%
  summarize(PSM_sum = sum(SpectralCounts))
