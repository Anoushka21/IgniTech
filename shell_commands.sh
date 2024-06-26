# FIRE INCIDENTS 

### Write dataset on HDFS
hdfs dfs -mkdir Fire_Incident_original
hdfs dfs -put ./Fire_Incident.csv Fire_Incident_original

## Data Cleaning Job
javac -classpath `hadoop classpath` DataCleaning*.java
jar cvf fire1.jar DataCleaning*.class
hadoop fs -mkdir fire_outputs
hadoop jar fire1.jar DataCleaning Fire_Incident_original/Fire_Incident.csv fire_outputs/output_1

### Profiling Jobs

## Invalid Entry Profiling Job
javac -classpath `hadoop classpath` InvalidEntries*.java
jar cvf invalid_entries.jar InvalidEntries*.class
hadoop jar invalid_entries.jar InvalidEntries Fire_Incident_original/Fire_Incident.csv fire_outputs/output_invalid_entries

## Word Counter Profiling Job
javac -classpath `hadoop classpath` WordCounter*.java
jar cvf wc.jar WordCounter*.class
hadoop jar wc.jar WordCounter fire_outputs/output_1/part-r-00000 fire_outputs/output_1_borough 0
hadoop jar wc.jar WordCounter fire_outputs/output_1/part-r-00000 fire_outputs/output_1_inc_class 4
hadoop jar wc.jar WordCounter fire_outputs/output_1/part-r-00000 fire_outputs/output_1_inc_grp_class 3

## Numerical Summarization Profiling Job
javac -classpath `hadoop classpath` NumericalSummarization*.java
jar cvf numerical.jar NumericalSummarization*.class
hadoop jar numerical.jar NumericalSummarization fire_outputs/output_1/part-r-00000 fire_outputs/output_1_numer 7


### Weather Data
- Weather Raw Data Profiler <br>
`hadoop jar WeatherProfiler.jar WeatherProfiler weather_profile/NYC_Weather_data.txt weather_profile/output`
- Data Profiler commands <br>
`hadoop jar yearTemp.jar YearTemp YearTemp_profile/NYC_Weather_data.txt YearTemp_profile/output` <br>
`hadoop jar monthTemp.jar MonthTemp MonthTemp_profile/NYC_Weather_data.txt MonthTemp_profile/output` <br>
- Data cleaning <br>
`hadoop jar WeatherFilter.jar WeatherFilter WeatherFilter/NYC_Weather_data.txt WeatherFilter/output`

### Decennial Data
- Command to clean run data cleaning map reduce job and aggreagte population and housing units data <br>
`hadoop jar DecennialCombiner.jar DecennialCombiner DecennialCombiner/population.txt DecennialCombiner/housing.txt DecennialCombiner/output`

### Mean Income Data Cleaning
`hadoop jar MeanIncome.jar MeanIncome MeanIncome MeanIncome/output`

### Mean Income Data Profiler
`hadoop jar meanProfiler.jar MeanProfiler meanProfiler/alldata_clean.txt meanProfiler/output`

### Median Income Data Cleaning
`hadoop jar MedianIncome.jar MedianIncome MedianIncome MediaanIncome/output`

### Age Gender Data Cleaning
`hadoop jar AgeGender.jar AgeGender AgeGender AgeGender/output`

### Data Combiner map reduce for mean,median and age gender data
`hadoop jar DataCombiner.jar DataCombiner DataCombiner/meanIncome_clean.txt DataCombiner/medianIncome_clean.txt DataCombiner/ageGender_clean.txt DataCombiner/output`


###HYDRANTS DATA CLEANING

###(IN HYDRANT DIRECTORY)
#cd HYDRANT

#vi hmap.java
#vi hreduce.java
#vi hdrive.java

hadoop fs -mkdir hydrants
hdfs dfs -put hydrants.txt hydrants
javac -classpath `hadoop classpath` *.java
jar cvf hydrants.jar *.class
hadoop fs -rm -r /user/dp3635_nyu_edu/hydrants/output
hadoop jar zipareas.jar hdriver hydrants/hydrants.txt hydrants/output
hadoop fs -cat hydrants/output/part-r-00000

hadoop fs -getmerge hydrants/output /home/dp3635_nyu_edu/cleanHydrant.txt


###HYDRANTS DATA PROFILING ON RAW DATA

#vi profilehmap.java
#vi profilehreduce.java
#vi profilehdriver.java

hadoop fs -mkdir hydrantprofile
javac -classpath `hadoop classpath` *.java
jar cvf hydrantprofile.jar *.class
hadoop fs -rm -r /user/dp3635_nyu_edu/hydrantprofile/output
hadoop jar hydrantprofile.jar profilehdriver hydrants/hydrants.txt hydrantprofile/output
hadoop fs -ls hydrantprofile/output
hadoop fs -cat hydrantprofile/output/part-r-00000
hadoop fs -getmerge hydrantprofile/output /home/dp3635_nyu_edu/profiledrawhydrant.txt

###MATCHING- used geocoding api

###(IN MATCH DIRECTORY)

#cd MATCH

#vi hmi.java
#vi hri.java
#vi hd.java

hadoop fs -mkdir match
javac -classpath `hadoop classpath` *.java
jar cvf match.jar *.class
hadoop fs -rm -r /user/dp3635_nyu_edu/match/output
hadoop jar match.jar hd hydrants/output/part-r-00000 match/output
hadoop fs -ls match/output
hadoop fs -cat match/output/part-r-00000
hadoop fs -getmerge match/output /home/dp3635_nyu_edu/ziphydrant.txt

### DATA CLEANING ON ziphydrant.txt

#vi matchclean.java
#vi matchcleanMap.java
#vi matchcleanReduce.java

hadoop fs -mkdir matchclean
hdfs dfs -put ../ziphydrant.txt matchclean
javac -classpath `hadoop classpath` *.java
jar cvf matchclean.jar *.class
hadoop fs -rm -r /user/dp3635_nyu_edu/matchclean/output
hadoop jar matchclean.jar matchclean matchclean/ziphydrant.txt matchclean/output 
hadoop fs -ls matchclean/output
hadoop fs -cat matchclean/output/part-r-00000

hadoop fs -getmerge matchclean/output /home/dp3635_nyu_edu/cleanZipHydrant.txt

###PROFILING HYDRANTS ON FINAL CLEANED DATA

###BOROUGH-WISE

#vi boroughProfile.java
#vi boroughProfileMap.java
#vi boroughProfileReduce.java

hadoop fs -mkdir boroughHydrantprofile
hdfs dfs -put ../cleanZipHydrant.txt boroughHydrantprofile
javac -classpath `hadoop classpath` *.java
jar cvf boroughProfile.jar *.class
hadoop fs -rm -r /user/dp3635_nyu_edu/boroughHydrantprofile/output
hadoop jar boroughProfile.jar boroughProfile boroughHydrantprofile/cleanZipHydrant.txt boroughHydrantprofile/output
hadoop fs -ls boroughHydrantprofile/output
hadoop fs -cat boroughHydrantprofile/output/part-r-00000
hadoop fs -getmerge boroughHydrantprofile/output /home/dp3635_nyu_edu/borough-profiled-hydrant.txt

###ZIPCODE

#vi zipProfile.java
#vi zipProfileMap.java
#vi zipProfileReduce.java

hadoop fs -mkdir zipHydrantprofile
hdfs dfs -put ../cleanZipHydrant.txt zipHydrantprofile
javac -classpath `hadoop classpath` *.java
jar cvf zipProfile.jar *.class
hadoop fs -rm -r /user/dp3635_nyu_edu/zipHydrantprofile/output
hadoop jar zipProfile.jar zipProfile zipHydrantprofile/cleanZipHydrant.txt zipHydrantprofile/output
hadoop fs -ls zipHydrantprofile/output
hadoop fs -cat zipHydrantprofile/output/part-r-00000
hadoop fs -getmerge zipHydrantprofile/output /home/dp3635_nyu_edu/zip-profiled-hydrant.txt


###INSPECTION CLEANING

#vi IMap.java
#vi IReduce.java
#vi Inspection

hadoop fs -mkdir insp
hdfs dfs -put inspection.txt insp
hadoop fs -rm -r /user/dp3635_nyu_edu/insp/output
javac -classpath `hadoop classpath` *.java
jar cvf inspection.jar *.class
hadoop jar inspection.jar Inspection insp/inspection.txt insp/output
hadoop fs -ls insp/output
hadoop fs -cat insp/output/part-r-00000

hadoop fs -getmerge insp/output /home/dp3635_nyu_edu/cleanInspection.txt


###INSPECTION PROFILING OF RAW DATA

#vi boroProfileIDriver.java
#vi boroProfileIMap.java
#vi boroProfileIReduce.java

hadoop fs -mkdir inspprofileraw
hadoop fs -rm -r /user/dp3635_nyu_edu/inspprofileraw/output
javac -classpath `hadoop classpath` *.java
jar cvf inspprofileraw.jar *.class
hadoop jar inspprofileraw.jar boroProfileIDriver insp/inspection.txt inspprofileraw/output
hadoop fs -ls inspprofileraw/output
hadoop fs -cat inspprofileraw/output/part-r-00000

###INSPECTION PROFILING OF BOROUGH WISE CLEANED DATA
### (same files as that of raw cleaning, just directory changed)

hadoop fs -mkdir inspprofile
hadoop fs -cp insp/output/part-r-00000 inspprofile/cleanInspection.txt
hdfs dfs -put cleanInspection.txt inspprofile
hadoop fs -rm -r /user/dp3635_nyu_edu/inspprofile/output
javac -classpath `hadoop classpath` *.java
jar cvf inspprofile.jar *.class
hadoop jar inspprofile.jar boroProfileIDriver inspprofile/cleanInspection.txt inspprofile/output
hadoop fs -ls inspprofile/output
hadoop fs -cat inspprofile/output/part-r-00000
hadoop fs -getmerge inspprofile/output /home/dp3635_nyu_edu/boroProfInsp.txt

# For yearwise just change mapper YearBoroughIMap.java, use same commands and store results using:
hadoop fs -getmerge inspprofile/output /home/dp3635_nyu_edu/yearboroProfInsp.txt

###INSPECTION PROFILING OF ZIPCODE WISE CLEANED DATA

#vi zipProfileIMap.java
#vi zipProfileIReduce.java
#vi zipProfileIDriver.java

hadoop fs -mkdir zipProfInsp
hadoop fs -cp insp/output/part-r-00000 zipProfInsp/cleanInsp.txt
hdfs dfs -put cleanInspection.txt zipProfInsp
hadoop fs -rm -r /user/dp3635_nyu_edu/zipProfInsp/output
javac -classpath `hadoop classpath` *.java
jar cvf zipProfInsp.jar *.class
hadoop jar zipProfInsp.jar zipProfileIDriver zipProfInsp/cleanInsp.txt zipProfInsp/output
hadoop fs -ls zipProfInsp/output
hadoop fs -cat zipProfInsp/output/part-r-00000
hadoop fs -getmerge zipProfInsp/output /home/dp3635_nyu_edu/zipProfInsp.txt

# For yearwise just change mapper YearZipcodeIMap.java, use same commands and store results using:
hadoop fs -getmerge zipProfInsp/output /home/dp3635_nyu_edu/yearzipProfInsp.txt
