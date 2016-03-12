<?php include("htmltop.php") ?>

<?php
  // http://www.test.com/battery.php?entry=2013,11,25,19,55,8833,8440,6,1000&apikey=a5b1c3d2

  //require API key
  if( isset($_GET['apikey']) && file_exists("./.batteryapikey") ){
    if( strcmp( trim( file_get_contents( "./.batteryapikey"), "\t\n\r\0\x0B" )
                ,$_GET['apikey'] ) == 0) {

      //api key matches, process the entry
      if( isset($_GET['entry']) ){
        $entry = $_GET['entry'];
        $entries = explode("," , $entry);

        //validate input before saving to local file
        if( count($entries) == 9 ){
          // TODO: clean up any trailing comma or new line return for the entry?
          file_put_contents("batteryHistory.csv" , PHP_EOL.$entry, FILE_APPEND);

          //clear url to make sure duplicate data isn't submitted if someone just types something in a browser

        }
      }
    }
  }
?>

    <title>Battery</title> 
    
<?php include("header.php") ?>

  <h3></h3>

    <script type="text/javascript" src="fuelly/jquery.js"></script>
    <script type="text/javascript">
      jQuery.noConflict();
    </script>
    
    <!-- Chart Data -->
    <script type="text/javascript">
      (function($){ // encapsulate jQuery
        $(function () {
          
          var designCapacity = 8440;
          var EOLCapacity = designCapacity * 0.8;

          //define all the options for the chart
          var options = {
              chart: {
                  renderTo: 'container',
                  type: 'spline',
                  zoomType: 'x'
              },
              title: {
                  text: 'Late 2013 MacbookPro Battery Cycles'
              },
              xAxis: {
                  type: 'datetime'
              },
              yAxis: [{
                  labels: {
                    formatter: function() {
                        return this.value ;
                    },
                    style: {
                        color: '#9c0371'
                    } 
                  },
                  title: {
                      text: 'Cycles',
                      style: {
                        color: '#9c0371'
                    },
                  },
                  opposite: true,
                  min: 0,
                  max: 1000
              },{
                  labels: {
                    formatter: function() {
                        return this.value ;
                    },
                    style: {
                        color: '#03719c'
                    }
                  },
                  title: {
                      text: 'Battery Capacity (mAh)',
                      style: {
                        color: '#03719c'
                    }
                  },
                  plotLines: [{
                      color: '#0495ce',
                      dashStyle: 'Dash',
                      width: 3,
                      label: {
                        text: 'Design Capacity',
                        style: {
                          color: '#0495ce'
                        },
                        y: 20
                      }, 
                      value: designCapacity,
                      zIndex: 5
                  },{
                      color: '#024d6a',
                      dashStyle: 'Dash',
                      width: 3,
                      label: {
                        text: 'End of Life Capacity',
                        style: {
                          color: '#024d6a'
                        },
                        y: -5
                      }, 
                      value: EOLCapacity,
                      zIndex: 5
                  }],
                  min: EOLCapacity,
                  max: Math.ceil(designCapacity/1000)*1000
              }],
              tooltip: {
                  shared: true,
                  borderWidth: 0,
              },
              legend: {enabled:false},
              plotOptions:{
                  series:{turboThreshold:5000}
              },
              credits: {enabled:false},
              series: [{
                      name: 'Cycles',
                      yAxis: 0, //this is very important!
                      color: '#9c0371',
                      data: []
                  }, {
                      name: 'Capacity',
                      yAxis: 1, //this is very important!
                      color: '#03719c',
                      data: []
                  }]
          }; //end options

          //load chart data from csv file
          $.get("batteryHistory.csv", function(data) {

              // Split the lines
              var lines = data.split('\n');

              // Iterate over the lines and add categories or series
              $.each(lines, function(lineNo, line) {
                  var items = line.split(',');
                  
                  //example line of data this chart expects in the csv, NO newline return!
                  //2013,11,25,19,55,8833,8440,6,1000
                  //year,mth,day,hr,mins,capacity,designCapacity,cycles,designCycles

                  //add cycle data
                  options.series[0].data.push({x:parseFloat(Date.UTC(items[0],items[1]-1,items[2],items[3],items[4])), y:parseFloat(items[7])} );

                  //add capacity data
                  options.series[1].data.push({x:parseFloat(Date.UTC(items[0],items[1]-1,items[2],items[3],items[4])), y:parseFloat(items[5])} );
                  
              });

              // Create the chart
              var chart = new Highcharts.Chart(options);

          }); //end get

        });
      })(jQuery);
    </script>

    <div id="content">
         
      <script src="fuelly/highcharts.js"></script>
      <div id="container" style="min-width: 400px; height: 400px; margin: 0 auto">
      </div>
    </div><!-- e: content -->

    <p>Bash, PHP and javascript micro project to upload my battery cycles and mAh over time for a new laptop. Rudamentary apikey implementation as well as cached offline history if PHP script doesn't respond to current curl call. Modified to display more than <b>1,000</b> data points per data series using highcharts plotOptions: series: turboThreshold:NEW_MAX api option.</p>
    <p>Code is available on <a href="https://bitbucket.org/derek_neil/batteryendurance/">bitbucket</a> and <a href="https://github.com/derekneil/batteryEndurance/">github</a>.</p>

<?php include("footer.php") ?>
