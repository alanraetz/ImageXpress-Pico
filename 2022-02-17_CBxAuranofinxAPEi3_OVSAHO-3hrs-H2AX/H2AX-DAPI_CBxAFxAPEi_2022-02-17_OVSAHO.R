
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
table <- read.csv("labeledData.csv")

unique(table$condition)
unique(table$row)
unique(table$column)

hist(table$NucArea, breaks=1000)
hist(table$NucAvg2, breaks=1000)
table <- table[table$NucArea <= 230, ]
table <- table[table$NucAvg2 <= 100, ]

table$ordered <- 
  factor(table$condition,
         levels = c( # unique(table$condition) into file.txt and run convert-list.pl on file.txt
           "cntl_cntl",
           "cntl_AF",
           "CB_AF",
           "cntl_APEi",
           "CB_APEi"
         ))
table <- table %>% filter(!is.na(ordered)) # remove rows that are not in specified levels

# table$repair <- 100*(table$NucAvg3/table$NucAvg2)

# analysis of untreated plasmid (siCntl vs. siRad51) red/green scatterplot of individual cells
Carb0 = subset(table,table$column=='Carb0000')
siCntl   = Carb0[ Carb0$row=='siCntl',]
siRad51  = Carb0[ Carb0$row=='siRad51',]
siCntl_count  = nrow( siCntl )
siRad51_count = nrow( siRad51 ) 
# equal the total number of data points between groups by truncation of larger group
if ( siCntl_count > siRad51_count ) { siCntl  = siCntl [ 1:siRad51_count, ] }
if ( siRad51_count > siCntl_count)  { siRad51 = siRad51[ 1:siCntl_count,  ] }

# x-y scatterplot shown as two colors
ggplot(table, aes(x=NucArea, y=NucAvg2, color=condition)) + geom_point() 
# histogram of NucAvg3 (red=Carbo-treated mCherry)
ggplot(Carb0, aes(NucAvg3, color=row)) + geom_density(alpha=.5) #+ 

ggsave('equalized-50-100_mCherry-histogram_Carb0-siCntl-vs-siRad51_2021-10-24.png')


ggplot(table, aes(x=ordered,y=NucAvg2)) + 
  geom_violin() +
stat_summary(
  mapping = aes(x = ordered, y = NucAvg2),
  fun.min = function(z) { quantile(z,0.25) },
  fun.max = function(z) { quantile(z,0.75) },
  fun = median) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

  #+    ylim(10,40) +
  # display median and quartile range  
  #ggplot(data = table) +
  #    geom_violin() +
  stat_summary(
    mapping = aes(x = ordered, y = repair),
    fun.min = function(z) { quantile(z,0.25) },
    fun.max = function(z) { quantile(z,0.75) },
    fun = median) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) 

#####################################
  
  library(stats)
  
  sink(file="H2AX_t-test_results.txt")
  pairwise.t.test(K48$NucAvg2,K48$K48_cond,p.adjust.method="BH",pool.sd=FALSE)
  pairwise.t.test(K63$NucAvg2,K63$K63_cond,p.adjust.method="BH",pool.sd=FALSE)
  pairwise.t.test(filtered$NucAvg3,filtered$column,p.adjust.method="BH",pool.sd=FALSE)
  sink()
  stop()
  
