set xdata time
#set timefmt "%s"
set timefmt "%Y-%m-%d %H:%M:%S"
#set format x '%m/%y'
#set format x '%j'
#set format y "%t"
set format x '%H:%M'
set xlabel "Hora (UTC)"
set ylabel "Densidad [µg/m³]"
#set angles degrees
set datafile separator "\t"
set title "Fuente: www.ifa.org.ar   Equipo E-Sampler MetOne  Partículas en TSP. Aeropuerto Bariloche. %DAY_MONTH_YEAR%" offset 0,-1
#set term png transparent size 1280, 800
set term png size 1024, 768
set grid
plot "particulas_%DATE%.txt" using 1:($2) with lines title "SAZS"
