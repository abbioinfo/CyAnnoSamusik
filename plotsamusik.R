## plot the samusik results ##
## author @abhinav kaushik
## Usage: Rscript plotsamusik.R [PATH TO SAMUSIK OUTPUT DIRECTORY]
## Example: Rscript plotsamusik.R Samusik__26_2_2021_15_26/



library(dplyr)
library(ggplot2)

args = commandArgs(trailingOnly=TRUE)

dname = args[0]
#dname = "Samusik__26_2_2021_15_26/"


df = read.csv(paste(dname,"Method_x__Acc_stats.csv", sep="/"))
ggdf = df[,c("SampleID","SampleF1","Type")] %>% dplyr::filter(Type == "With_UnGated") %>% dplyr::group_by(SampleID,Type) %>% dplyr::summarise_all(mean)
ggdf$Method = "CyAnno (Sample F1)"
png(paste(dname,"/SampleF1Samusik.png", sep=""))
g <- ggplot(ggdf, aes(x="", y=SampleF1)) + 
  geom_boxplot(position = position_dodge(width = 0.2), alpha = 0.5,outlier.color = NA) +
  geom_point(position = position_dodge(width=0.3), size=4.5, color="#000000") +
  scale_color_manual(values = c("#FB664D","#000000")) + facet_grid(~Method) +
  scale_fill_manual(values = c("#FB664D","#C9B008"))  + xlab("") +
  ylab(label = "F1 score")  + xlab(label = "") + theme_bw(base_size = 20) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, vjust = 0.7),
        axis.title.y = element_text(size = 15), strip.background = element_rect(fill="white"))
print(g)
dev.off()


ggdf = df[,c("SampleID","CellType","F1","Type")] %>% dplyr::filter(Type == "With_UnGated") %>% dplyr::group_by(SampleID,CellType,Type) %>% dplyr::summarise_all(mean)
ggdf$Method = "CyAnno (Cell type specific F1)"


png(paste(dname,"/CellTypeF1Samusik.png", sep=""))
g <- ggplot(ggdf, aes(x=CellType, y=F1)) + 
  geom_boxplot(position = position_dodge(width = 0.2), alpha = 0.5,outlier.color = NA) +
  geom_point(position = position_dodge(width=0.3), size=4.5, color="#000000") +
  scale_color_manual(values = c("#FB664D","#000000")) + facet_grid(~Method) +
  scale_fill_manual(values = c("#FB664D","#C9B008"))  + xlab("") +
  ylab(label = "F1 score")  + xlab(label = "") + theme_bw(base_size = 20) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, vjust = 0.7, angle = 90),
        axis.title.y = element_text(size = 15), strip.background = element_rect(fill="white"))
print(g)
dev.off()
