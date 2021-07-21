#Create error report
echo
echo "Creating error log"

#create log file
echo `date +"%Y%m%d_%H%M"` > error_log.txt

#check if run completed successful, if so print successful message
#otherwise print error longs
errors="$(grep -i "error in" *_RBL3.out | wc -l)"
if [ $errors == "0" ]
then
    echo "Pipeline has successfully completed" >> error_log.txt
    echo "Pipeline has successfully completed"
else
    echo "The following errors were found in rules." >> error_log.txt
    grep -i "error in" *_RBL3.out | sort --unique >> error_log.txt
    echo "view error log to determine which rules failed by running: cat error_log.txt"
    echo
fi