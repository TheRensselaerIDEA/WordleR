# Just figures out file version and writes an Rds
version <-as.data.frame(matrix(nrow=1,ncol=1))
colnames(version) <- c("date")
version$date <- Sys.time()
write.csv(version, "version.csv")