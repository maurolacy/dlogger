set xdata time
#set timefmt "%s"
set timefmt "%Y-%m-%d %H:%M:%S"
#set format x '%m/%y'
#set format x '%j'
#set format y "%t"
set format x '%d/%m'
set xlabel "Date"
set ytics nomirror autofreq tc lt 1
set ylabel "Magnetic field intensity [Gauss]" tc lt 1
#set angles degrees
set datafile separator "\t"
set title "Magnetic Field Components. %MONTH_YEAR%" offset 0,-1
#set term png transparent size 1280, 800
set term png size 1024, 768
set grid ytics lt 0 lw 1
plot "%FIELD1%_%DATE%.txt" using 1:($2/10) with lines linetype 1 lc rgb "red" title "X/10", "%FIELD2%_%DATE%.txt" using 1:($2) with lines linetype 1 lc rgb "green" title "Y", "%FIELD3%_%DATE%.txt" using 1:($2) with lines linetype 1 lc rgb "blue" title "Z"
