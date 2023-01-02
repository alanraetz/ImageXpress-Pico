
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
T1_1hr   <- read.csv("T1_ExperimentCellData.csv")
T2_15min <- read.csv("T2_ExperimentCellData.csv")

T1_1hr$ordered <- 
  factor(T1_1hr$condition,
         levels = c( # unique(table$condition) into file.txt and run convert-list.pl on file.txt
           "PARP1_cntl",
           "PARP1_MMS",
           "PARP1_MMS+CB",
           "PARP1_MMS+TZ",
           "PARP1_CB+TZ",
           "PARP1_MMS+CB+TZ"
         ))

T2_15min$ordered <- 
  factor(T2_15min$condition,
         levels = c( # unique(table$condition) into file.txt and run convert-list.pl on file.txt
           "PARP1_cntl",
           "PARP1_MMS",
           "PARP1_MMS+CB",
           "PARP1_MMS+TZ",
           "PARP1_CB+TZ",
           "PARP1_MMS+CB+TZ"
         ))

fifteen_minutes  <- dplyr::summarise(dplyr::group_by(T2_15min,T2_15min$ordered),median(NucAvg1))
sixty_minutes    <- dplyr::summarise(dplyr::group_by(T1_1hr,T1_1hr$ordered),median(NucAvg1))

unique(table$condition)
unique(table$row)
unique(table$column)

hist(table$NucArea, breaks=1000)
hist(table$NucAvg1, breaks=1000)
T1_1hr   <- T1_1hr[T1_1hr$NucArea <= 300, ]
T2_15min <- T2_15min[T2_15min$NucArea <= 300, ]

table$one_hour <- T1_1hr$NucAvg1
table$fifteen  <- T2_15min$NucAvg2


T2_15min$ordered <- 
  factor(T2_15min$condition,
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

# This won't work. The underlying data has a different set of rows, can't be merged...
fifteen_minutes  <- dplyr::summarise(dplyr::group_by(table,table$ordered),median(NucAvg1))
sixty_minutes    <- dplyr::summarise(dplyr::group_by(table,table$ordered),median(NucAvg1))

ggplot(table, aes(x=ordered,y=NucAvg1)) + 
  geom_violin() +
  stat_summary(
  mapping = aes(x = ordered, y = NucAvg1),
  fun.min = function(z) { quantile(z,0.25) },
  fun.max = function(z) { quantile(z,0.75) },
  fun = median) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)
        +
          geom_text(aes(label=table$green)) #, vjust = 1.5)
          )

ggsave('PARP1-MMS-CB-Talazoparib-1hour_ordered_2022-03-30.png')

#####################################
  
  library(stats)
  sink(file="PARP1_15minute_t-test_results.txt")
  pairwise.t.test(table$NucAvg1,table$ordered,p.adjust.method="BH",pool.sd=FALSE)
  sink()
  stop()
  
