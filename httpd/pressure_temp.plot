set xdata time
#set timefmt "%s"
set timefmt "%Y-%m-%d %H:%M:%S"
#set format x '%m/%y'
#set format x '%j'
#set format y "%t"
set format x '%d/%m'
set xlabel "Date"
set ytics autofreq tc lt 1
set ylabel "Pressure [hPa]" tc lt 1
set y2tics autofreq tc lt 2
set y2label "Temperature [°C]" tc lt 2
#set angles degrees
set datafile separator "\t"
set title "Atmospheric Pressure and Temperature. %MONTH_YEAR%" offset 0,-1
#set term png transparent size 1280, 800
set term png size 1024, 768
set grid
plot "%FIELD1%_%DATE%.txt" using 1:($2) with lines linetype 1 title "P", "%FIELD2%_%DATE%.txt" using 1:($2) with lines linetype 2 title "T" axes x1y2
