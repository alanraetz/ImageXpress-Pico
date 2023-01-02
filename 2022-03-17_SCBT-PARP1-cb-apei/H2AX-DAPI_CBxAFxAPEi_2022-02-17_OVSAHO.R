
#install.packages("readr")
#install.packages("dplyr")
#install.packages("gridExtra")
library(ggplot2)
library(gridExtra)
library(car)
library(lattice)
library(dplyr)
library(forcats)

# processed raw output file from ImageExpress Pico with Perl script 
# to pad zeros of well number (01 instead of 1)
# and maps experiment conditions to wells (rows and column labels)
table <- read.csv("ExperimentCellData.csv")

unique(table$condition)
unique(table$row)
unique(table$column)

hist(table$NucArea, breaks=1000)
hist(table$NucAvg1, breaks=1000)
table <- table[table$NucArea <= 300, ]
table <- table[table$NucAvg1 <= 500, ]

table$ordered <- 
  factor(table$condition,
         levels = c( # unique(table$condition) into file.txt and run convert-list.pl on file.txt
           "PARP1_cntl",
           "PARP1_MMS",
           "PARP1_MMS+CB",
           "PARP1_MMS+TZ",
           "PARP1_CB+TZ",
           "PARP1_MMS+CB+TZ"
         ))
table <- table %>% filter(!is.na(ordered)) # remove rows that are not in specified levels

# store intermediate results in same table
# table$repair <- 100*(table$NucAvg2/table$NucAvg1)

ggplot(table, aes(x=ordered,y=NucAvg1)) + 
  geom_violin() +
  stat_summary(
  mapping = aes(x = ordered, y = NucAvg1),
  fun.min = function(z) { quantile(z,0.25) },
  fun.max = function(z) { quantile(z,0.75) },
  fun = median) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)
        )

ggsave('PARP1-MMS-CB-Talazoparib-ordered_2022-03-30.png')

#####################################
  
  library(stats)
  sink(file="PARP1_t-test_results.txt")
  pairwise.t.test(table$NucAvg1,table$ordered,p.adjust.method="BH",pool.sd=FALSE)
  sink()
  stop()
  
