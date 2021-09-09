library(readxl)
library(dplyr)

get_merged_data <- function(data_path_list) {
  get_data <- function(data_path) {
    df <- read_excel(data_path, sheet = "검색결과", skip = 1)
    return(df)
  }
  
  all_df <- NULL
  for (data_path in data_path_list) {
    df <- get_data(data_path)
    df <- subset(df, '기준년도'==2020)
    if (is.null(all_df)) {
      all_df <- df
    } else {
      all_df <- rbind(all_df, df)
    }
  }
  return(all_df)
}


data_path_list <- list.files(path = '.')
all_df <- get_merged_data(data_path_list)
table(all_df$기준년도)


filter_cond <- all_df$기준년도 == 2020
filterd_df <- subset(all_df, subset = filter_cond)
filterd_df %>% 
  summarise(total_cnt = n(), unique_work = n_distinct(과제고유번호))

if (1==0) {
  filterd_df %>% 
    arrange(과제고유번호) %>% 
    View()
}

unqiue_df <- filterd_df %>%
  distinct(과제고유번호, .keep_all = T) %>%
  filter(!is.na(연구내용요약)) %>% 
  rename(과제명_국문=`과제명(국문)`) %>% 
  select('사업명',
         '과제고유번호',
         '과제명_국문',
         '과학기술표준_연구분야분류1',
         '연구목표요약',
         '연구내용요약',
         '기대효과요약',
         '한글키워드') %>% 
  group_by(과제고유번호) %>% 
  mutate(full_text = paste(연구목표요약, 연구내용요약, 기대효과요약),
         full_text_with_proj_title = paste(과제명_국문, 연구목표요약, 연구내용요약, 기대효과요약))

# 990건
unqiue_df %>% 
  write.table("r&d_2020.tsv", sep = '\t', quote = T, row.names = F) 