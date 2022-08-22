:

. /etc/dlogger.conf

echo -n "Creating data dir '$DATA'..."
sudo mkdir -p $DATA
sudo chown pi $DATA
echo "done."


echo -n "Creating index.html..."
cat <<EOF | sudo tee $DATA/index.html
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <script src="//cdnjs.cloudflare.com/ajax/libs/dygraph/2.1.0/dygraph.min.js"></script>
  <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/dygraph/2.1.0/dygraph.min.css" />
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
* {
  box-sizing: border-box;
}

/* Create two equal columns that floats next to each other */
.column {
  float: left;
  width: 50%;
  padding: 10px;
  height: 300px; /* Should be removed. Only for demonstration */
}

/* Clear floats after the columns */
.row:after {
  content: "";
  display: table;
  clear: both;
}
</style>
</head>
<body>
  <div class="row">
  <div class="column" id="pressure"></div>
  <div class="column" id="humidity"></div>
  </div>
  <div class="row">
    <div class="column" id="temp"></div>
    <div class="column" id="temperature"></div>
  </div>

  <script type="text/javascript">
    g1 = new Dygraph(document.getElementById("pressure"), "pressure.txt", {
      legend: 'always',
      title: 'Atmospheric Pressure',
      ylabel: 'Pressure [hPa]',
      color: 'violet'
    });

    g2 = new Dygraph(document.getElementById("humidity"), "humidity.txt", {
      legend: 'always',
      title: 'Relative Humidity',
      ylabel: 'Humidity [%RH]',
      color: 'blue'
    });

    g3 = new Dygraph(document.getElementById("temp"), "temp.txt", {
      legend: 'always',
      title: 'Temperature (from Pressure sensor)',
      ylabel: 'Temperature [ºC]',
      color: 'red'
    });

    g4 = new Dygraph(document.getElementById("temperature"), "temperature.txt", {
      legend: 'always',
      title: 'Temperature (from Humidity sensor)',
      ylabel: 'Temperature [ºC]',
      color: 'red'
    });
  </script>
</body
EOF
echo "done."

echo -n "Creating cron entry..."
cat <<EOF | sudo tee /etc/cron.d/dygraph-pub
# /etc/cron.d/part: crontab entries for dygraphs data publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/dygraphs/pubpressure.sh && $BASE/httpd/dygraphs/pubpressure.sh >/dev/null
*/15 *    * * *   root   test -x $BASE/httpd/dygraphs/pubhumidity.sh && $BASE/httpd/dygraphs/pubhumidity.sh >/dev/null
*/15 *    * * *   root   test -x $BASE/httpd/dygraphs/pubtemperature.sh && $BASE/httpd/dygraphs/pubtemperature.sh >/dev/null
*/15 *    * * *   root   test -x $BASE/httpd/dygraphs/pubtemp.sh && $BASE/httpd/dygraphs/pubtemp.sh >/dev/null
EOF
sudo service cron restart
echo "done."
