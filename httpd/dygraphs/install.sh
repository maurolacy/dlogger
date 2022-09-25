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
  <script>
    var gIsLog = 0;
    var gIsZoomed = "";
    var g6;
    var desired_range = null;
    var orig_range = [ 1279324800000, 1664064000000 ];

//    function update_hash(hash) {
//      if (hash.length <= 1) {
//        hash = location.pathname;
//        if (window.location.hash <=1 ){
//          return;
//        }
//      }
//
//      if (history.pushState) {
//        if(window.location.hash != hash) {
//          history.pushState(null, null, hash);
//        }
//      }
//    }

    function updateZoom(zoomlevel) {
      var update = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : true;

      if (parseInt(zoomlevel) >= 0 && parseInt(zoomlevel) <= 1095) {
        zoom(parseInt(zoomlevel));

        if (zoomlevel==1) {
          gIsZoomed="1d";
        } else if (zoomlevel==7) {
          gIsZoomed="1w";
        } else if (zoomlevel==30) {
          gIsZoomed="1m";
        } else if (zoomlevel==90) {
          gIsZoomed="3m";
        } else if (zoomlevel==180) {
          gIsZoomed="6m";
        } else if (zoomlevel==365) {
          gIsZoomed="1y";
        } else if (zoomlevel==1095) {
          gIsZoomed="3y";
        } else {
          gIsZoomed="alltime";
        }
      } else {
        zoom(0);
        gIsZoomed="alltime";
      }
      // TODO: update_hash, get_gHash
//      if (update) {
//        update_hash("#"+get_gHash());
//      }
    }

    function approach_range() {
      if (!desired_range) return;

      var range = g6.xAxisRange();
      if (Math.abs(desired_range[0] - range[0]) < 60 && Math.abs(desired_range[1] - range[1]) < 60) {
        g6.updateOptions({dateWindow: desired_range});
      } else {
        var new_range;
        new_range = [0.5 * (desired_range[0] + range[0]), 0.5 * (desired_range[1] + range[1])];
        g6.updateOptions({dateWindow: new_range});
        animate();
      }
    }

    function animate() {
      setTimeout(approach_range, 25);
    }

    function zoom(days) {
      var w = g6.xAxisExtremes();
      $(".zoom").removeClass('btn-inverse').removeClass('active');
      $("#zoom"+days).addClass('btn-inverse');
      res = days * 86400;
      if (days != 0) {
        desired_range = [ w[1] - res * 1000, w[1] ];
      } else {
        desired_range = orig_range;
      }
      animate();
    }
  </script>
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
<style>
</style>
  .btn-group {position:relative;display:inline-block;font-size:0;white-space:nowrap;vertical-align:middle}
  .btn-group-my {margin:2px}
  .btn {display:inline-block;padding:4px 12px;margin-bottom:0;font-size:14px;line-height:20px;color:#333;text-align:center;text-shadow:rgba(255,255,255,0.74902) 0 1px 1px;vertical-align:middle;cursor:pointer;border-width:1px;border-style:solid;border-color:rgba(0,0,0,0.0980392) rgba(0,0,0,0.0980392) #b3b3b3;border-top-left-radius:4px;border-top-right-radius:4px;border-bottom-right-radius:4px;border-bottom-left-radius:4px;-webkit-box-shadow:rgba(255,255,255,0.2) 0 1px 0 inset,rgba(0,0,0,0.0470588) 0 1px 2px;box-shadow:rgba(255,255,255,0.2) 0 1px 0 inset,rgba(0,0,0,0.0470588) 0 1px 2px;background-image:linear-gradient(#fff,#e6e6e6);background-color:#f5f5f5;background-repeat:repeat-x}
  .btn-mini {padding:0 3px;font-size:10.5px;border-top-left-radius:3px;border-top-right-radius:3px;border-bottom-right-radius:3px;border-bottom-left-radius:3px}
  .btn:hover, .btn:focus, .btn:active, .btn.active, .btn.disabled, .btn[disabled] {color:#333;background-color:#e6e6e6}
  .btn.disabled, .btn[disabled] {cursor:default;opacity:.65;-webkit-box-shadow:none;box-shadow:none;background-image:none}
  .btn-group>.btn {position:relative;border-top-left-radius:0;border-top-right-radius:0;border-bottom-right-radius:0;border-bottom-left-radius:0}
  .btn-group>.btn, .btn-group>.dropdown-menu, .btn-group>.popover {font-size:14px}
  .btn-group>.btn-mini {font-size:10.5px;margin:3px 0px;}
  .btn-group>.btn:first-child {margin-left:0;border-bottom-left-radius:4px;border-top-left-radius:4px}
  .btn-group>.btn + .btn {margin-left:-1px}
  .btn-group>.btn:last-child, .btn-group>.dropdown-toggle {border-top-right-radius:4px;border-bottom-right-radius:4px}
  .btn-group-my {margin:2px}
  .btn:hover, .btn:focus {color:#333;text-decoration:none;transition:background-position .1s linear;-webkit-transition:background-position .1s linear;background-position:0 -15px}
  .btn:focus {outline:-webkit-focus-ring-color auto 5px;outline-offset:-2px}
  .btn.active, .btn:active {outline:0;-webkit-box-shadow:rgba(0,0,0,0.14902) 0 2px 4px inset,rgba(0,0,0,0.0470588) 0 1px 2px;box-shadow:rgba(0,0,0,0.14902) 0 2px 4px inset,rgba(0,0,0,0.0470588) 0 1px 2px;background-image:none}
  .btn-primary.active, .btn-warning.active, .btn-danger.active, .btn-success.active, .btn-info.active, .btn-inverse.activel {color:rgba(255,255,255,0.74902)}
  .btn-inverse {color:#fff;text-shadow:rgba(0,0,0,0.247059) 0 -1px 0;border-color:rgba(0,0,0,0.0980392) rgba(0,0,0,0.0980392) rgba(0,0,0,0.247059);background-image:linear-gradient(#333,#111);background-color:#363636;background-repeat:repeat-x}
  .dark .btn-inverse:hover, .dark .btn-inverse:focus, .dark .btn-inverse:active, .dark .btn-inverse.active, .dark .btn-inverse.disabled,.dark .btn-inverse[disabled] {color:#fff;background-color:#222}
  .btn-group>.btn:hover, .btn-group>.btn:focus, .btn-group>.btn:active, .btn-group>.btn.active {z-index:2}
  .muted{color:#999}
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
  <div class="row">
    <div class="column" id="temp2"></div>
    <div class="column" id="mean_temperature"></div>
  </div>
  <td style="text-align:right">
    <div class="btn-group-my">
      <div style="display:inline-block" class="muted">Zoom: </div>
      <div class="btn-group" data-toggle="buttons-checkbox">
        <button type="button" id="zoom1" onclick="updateZoom(1);" class="btn btn-mini zoom">1 day</button>
        <button type="button" id="zoom7" onclick="updateZoom(7);" class="btn btn-mini zoom">1 week</button>
        <button type="button" id="zoom30" onclick="updateZoom(30);" class="btn btn-mini zoom">1 month</button>
        <button type="button" id="zoom90" onclick="updateZoom(90);" class="btn btn-mini zoom">3 months</button>
        <button type="button" id="zoom180" onclick="updateZoom(180);" class="btn btn-mini zoom">6 months</button>
        <button type="button" id="zoom365" onclick="updateZoom(365);" class="btn btn-mini zoom">1 year</button>
        <button type="button" id="zoom1095" onclick="updateZoom(1095);" class="btn btn-mini zoom btn-inverse">3 years</button>
        <button type="button" id="zoom0" onclick="updateZoom(0);" class="btn btn-mini zoom">all time</button>
      </div>
    </div>
  </td>

  <script type="text/javascript">
    g1 = new Dygraph(document.getElementById("pressure"), "pressure.txt", {
      legend: 'always',
      title: 'Atmospheric Pressure',
      showRoller: true,
      rollPeriod: 7,
      ylabel: 'Pressure [hPa]',
      color: 'violet'
    });

    g2 = new Dygraph(document.getElementById("humidity"), "humidity.txt", {
      legend: 'always',
      title: 'Relative Humidity',
      showRoller: true,
      rollPeriod: 7,
      ylabel: 'Humidity [%RH]',
      color: 'blue'
    });

    g3 = new Dygraph(document.getElementById("temp"), "temp.txt", {
      legend: 'always',
      title: 'Temperature (from Pressure sensor)',
      showRoller: true,
      rollPeriod: 7,
      ylabel: 'Temperature [ºC]',
      color: 'green'
    });

    g4 = new Dygraph(document.getElementById("temperature"), "temperature.txt", {
      legend: 'always',
      title: 'Temperature (from Humidity sensor)',
      showRoller: true,
      rollPeriod: 7,
      ylabel: 'Temperature [ºC]',
      color: 'rgb(0,0,128)',
    });

    g5 = new Dygraph(document.getElementById("temp2"), "temp2.txt", {
      legend: 'always',
      title: 'Temperature (from both sensors)',
      showRoller: true,
      rollPeriod: 7,
      ylabel: 'Temperature [ºC]',
    });

    g6 = new Dygraph(document.getElementById("mean_temperature"), "mean_temperature.txt", {
      legend: 'always',
      title: 'Mean Temperature (from both sensors)',
      showRoller: true,
      rollPeriod: 7,
      customBars: true,
      ylabel: 'Temperature [ºC]',
      color: 'orange'
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

*/5 *    * * *   root   test -x $BASE/httpd/dygraphs/pubpressure.sh && $BASE/httpd/dygraphs/pubpressure.sh >/dev/null
*/5 *    * * *   root   test -x $BASE/httpd/dygraphs/pubhumidity.sh && $BASE/httpd/dygraphs/pubhumidity.sh >/dev/null
*/5 *    * * *   root   test -x $BASE/httpd/dygraphs/pubtemperature.sh && $BASE/httpd/dygraphs/pubtemperature.sh >/dev/null
*/5 *    * * *   root   test -x $BASE/httpd/dygraphs/pubtemp.sh && $BASE/httpd/dygraphs/pubtemp.sh >/dev/null
*/5 *    * * *   root   test -x $BASE/httpd/dygraphs/tempavg/tempavg.py && sleep 10 && $BASE/httpd/dygraphs/tempavg/tempavg.py $DATA/temp.txt $DATA/temperature.txt -a -o $DATA/mean_temperature.txt
*/5 *    * * *   root   test -x $BASE/httpd/dygraphs/pubtemp2.sh && sleep 20 && $BASE/httpd/dygraphs/pubtemp2.sh >/dev/null
EOF
sudo service cron restart
echo "done."
