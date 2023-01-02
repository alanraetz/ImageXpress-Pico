
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
table <- read.csv("test3.csv")

unique(table$condition)
unique(table$row)
unique(table$column)

hist(table$NucAvg2, breaks=1000)
hist(table$NucAvg3, breaks=1000)
table <- table[table$NucAvg2 <= 300, ]
table <- table[table$NucAvg3 <= 150, ]

DAPI <- dplyr::summarise(dplyr::group_by(table,table$condition),median(NucArea))
names = dplyr::summarise(dplyr::group_by(table,table$condition),median(NucAvg2))[1]
a = dplyr::summarise(dplyr::group_by(table,table$condition),median(NucAvg2))[2]
b = dplyr::summarise(dplyr::group_by(table,table$condition),    sd(NucAvg2))[2]
c = dplyr::summarise(dplyr::group_by(table,table$condition),median(NucAvg3))[2]
d = dplyr::summarise(dplyr::group_by(table,table$condition),    sd(NucAvg3))[2]
repair = (c/a)*100
fl = cbind(names,a,b,c,d,repair) 
colnames(fl) = c('names','gfp','gfp_sd','red','red_sd','repair')  
write.table(fl, file='C:\\Users\\alanr\\OneDrive\\Chien Lab Postdoc\\Data\\Ovarian Cancer Inhibitors\\ImmunoFluorescence-ImageXpress\\2021-10-24_HCR-Carbo-OVSAHO-siRad51\\dyply-results-table.csv', sep=',')
     
table$ordered <- 
  factor(table$condition,
         levels = c( # unique(table$condition) into file.txt and run convert-list.pl on file.txt
           "siCntl_Carb0000", "siRad51_Carb0000", 
           "siCntl_Carb0015", "siRad51_Carb0015", 
           "siCntl_Carb0050", "siRad51_Carb0050", 
           "siCntl_Carb0150", "siRad51_Carb0150", 
           "siCntl_Carb0500", "siRad51_Carb0500",  
           "siCntl_Carb1500", "siRad51_Carb1500"
         ))
# table <- table %>% filter(!is.na(ordered)) # remove rows that are not in specified levels

table$repair <- 100*(table$NucAvg3/table$NucAvg2)


ggplot(table, aes(x=ordered,y=repair)) + 
  geom_violin() +    ylim(10,40) +
# display median and quartile range  
#ggplot(data = table) +
#    geom_violin() +
    stat_summary(
    mapping = aes(x = ordered, y = repair),
    fun.min = function(z) { quantile(z,0.25) },
    fun.max = function(z) { quantile(z,0.75) },
    fun = median) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) 

# analysis of untreated plasmid (siCntl vs. siRad51) red/green scatterplot of individual cells
table <- table[table$NucAvg2 > 1500, ]
table <- table[table$NucAvg3 > 300, ]
#table <- table[table$NucAvg3 + table$NucAvg3 > 1200, ]
Carb0 = subset(table,table$column=='Carb0000')
ggplot(Carb0, aes(x=NucAvg2, y=NucAvg3, color=row)) + geom_point() 

xdensity <- ggplot(Carb0, aes(NucAvg3, color=row)) +
  geom_density(alpha=.5) #+ 
xdensity


ggsave('mCherry-histogram_siCntl-vs-siRad51_2021-10-24.png')

library(stats)

sink(file="CB5083xDrug_Feb12-redo_t-test_results.txt")

for ( DD_treat in unique(filtered$row) ) {
  
    print(paste(DD_treat))
  
    for ( CB1 in unique(filtered$column) ) {
      
      #for ( CB2 in unique(filtered$column) ) {
        
          if (CB1=='CB0') { next }
        
          tt <- t.test(
              filtered[ (filtered$column==CB1 & filtered$row==DD_treat), "NucInt2"],
              filtered[ (filtered$column=="CB0" & filtered$row==DD_treat), "NucInt2"]
          )
          
          test = median(filtered[ (filtered$column==CB1 & filtered$row==DD_treat),"NucInt2"])
          base = median(filtered[ (filtered$column=="CB0" & filtered$row==DD_treat),"NucInt2"])
          print(paste('Drug-Only-CB0 =',base,',',CB1,'=',test,'=',tt$p.value))
      }    
   }


sink()
stop()
