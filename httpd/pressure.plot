set xdata time
#set timefmt "%s"
set timefmt "%Y-%m-%d %H:%M:%S"
#set format x '%m/%y'
#set format x '%j'
#set format y "%t"
set format x '%d/%m'
set xlabel "Date"
set ylabel "Pressure [hPa]"
#set angles degrees
set datafile separator "\t"
set title "Atmospheric Pressure. %MONTH_YEAR%" offset 0,-1
#set term png transparent size 1280, 800
set term png size 1440, 900
set grid
plot "%FIELD%_%DATE%.txt" using 1:($2) with lines title "P"
