// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery.metisMenu.js
//= require js-persian-cal.min
//= require dygraph-combined
//= require interaction-api
//= require responsiveslides

var persianNumberArray={0:'۰',1:'۱',2:'۲',3:'۳',4:'۴',5:'۵',6:'۶',7:'۷',8:'۸',9:'۹'};
var persianMonths = {1: 'فروردین', 2: 'اردیبهشت', 3: 'خرداد', 4: 'تیر', 5: 'مرداد', 6: 'شهریور', 7: 'مهر', 8: 'آبان', 9: 'آذر', 10: 'دی', 11: 'بهمن', 12: 'اسفند'};
var persianDays = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];
function toPersianNumber(str){
  str = str.toString();
  var ret = '', l = str.length;
  for (var i=0; i<l; i++) {
    ret += persianNumberArray[str[i]] || str[i];
  }
  return ret;
}

function xaxeLabelFormatter(d, gran) {
  var jdate = jd_to_persian(gregorian_to_jd(d.getFullYear(),d.getMonth()+1,d.getDate()));
  switch(gran) {
    case Dygraph.MONTHLY:
      return toPersianNumber(jdate[0])+" "+persianMonths[jdate[1]];
    case Dygraph.WEEKLY:
      return toPersianNumber(jdate[2])+" "+persianMonths[jdate[1]];
    case Dygraph.DAILY:
      return toPersianNumber(jdate[2])+" "+persianMonths[jdate[1]];
    case Dygraph.SIX_HOURLY:
    case Dygraph.TWO_HOURLY:
    case Dygraph.HOURLY:
      minutes = d.getMinutes();
      hours = d.getHours();
      return toPersianNumber(""+(hours > 9 ? hours : "0"+hours)+":"+(minutes > 9 ? minutes : "0"+minutes));
    default:
      minutes = d.getMinutes();
      hours = d.getHours();
      seconds = d.getSeconds();
      return toPersianNumber(""+(hours > 9 ? hours : "0"+hours)+":"+(minutes > 9 ? minutes : "0"+minutes)+":"+(seconds > 9 ? seconds : "0"+seconds));
  }
}

function persianDate(d) {
  var minutes = d.getMinutes();
  var hours = d.getHours();
  var seconds = d.getSeconds();
  var jdate = jd_to_persian(gregorian_to_jd(d.getFullYear(),d.getMonth()+1,d.getDate()));
  return toPersianNumber(
            ""+(hours > 9 ? hours : "0"+hours)+":"+
            (minutes > 9 ? minutes : "0"+minutes)+":"+
            (seconds > 9 ? seconds : "0"+seconds)+" - "+
            jdate.join("/")
        );
}

// چهارشنبه ۱۸ تیر ۱۳۹۳ - ۰۸:۳۵
function persianDateFull(d) {
  var minutes = d.getMinutes();
  var hours = d.getHours();
  var seconds = d.getSeconds();
  var jdate = jd_to_persian(gregorian_to_jd(d.getFullYear(),d.getMonth()+1,d.getDate()));
  return toPersianNumber(
            ""+persianDays[(d.getDay() + 1)%7]+" "+jdate[2]+" "+persianMonths[jdate[1]]+" "+jdate[0]+" "+
            (hours > 9 ? hours : "0"+hours)+":"+
            (minutes > 9 ? minutes : "0"+minutes)+":"+
            (seconds > 9 ? seconds : "0"+seconds)
        );
}

function xaxeValueFormatter(ms) {
  return persianDate(new Date(ms));
}

var graphData;

$(function() {
  var line, i, j, l, max, group;
  if (window.chart) {
    var tableData = "", c = 1, jdate, minutes, hours, seconds;
    var range = function() {
          var w = [ chart[0][0].valueOf(), chart[chart.length - 1][0].valueOf() ], tol = (w[1] - w[0])/20;
          return [w[0] - tol, w[1] + tol];
        };
    var scale = [];
    var groupedData = {};
    var chartLength = chart[0].length;
    for (j=0; j<chartLength; j++) {
      groupedData[j] = [];
    }
    for (i=0, l=chart.length; i<l; i++) {
      for (j=0; j<chartLength; j++) {
        groupedData[j].push(chart[i][j]);
      }
    }
    if (chart[0] && chart[0].length > 2) {
      var maxes = [];
      for (j=1; j<chartLength; j++) {
        maxes[j-1] = Math.max.apply(null, groupedData[j]);
      }
      max = Math.max.apply(null, maxes);
      scale[0] = -1;
      for (i=0; i<chartLength-1; i++) {
        scale[i+1] = maxes[i] ? Math.ceil((max/maxes[i])*10)/10 : 1;
        // scale[i+1] = maxes[i] ? max/maxes[i] : 1;
      }
      graphData = [];
      for (i=0, l=chart.length; i<l; i++) {
        graphData[i] = [chart[i][0]];
        for (j=1; j<chartLength; j++) {
          graphData[i].push(chart[i][j]*scale[j]);
        }
      }
    } else {
      scale = [-1, 1];
      graphData = chart;
    }
    var highlight_start, highlight_end;
    window.graph = new Dygraph($(".chart")[0], graphData, {
      connectSeparatedPoints: true,
      showRangeSelector: true,
      width: "600px",
      labels: window.chartLabels,
      legend: 'always',
      // logscale: true,
      highlightCircleSize: 3,
      strokeWidth: 2.5,
      highlightSeriesOpts: {
        strokeWidth: 3.5,
        strokeBorderWidth: 2,
        highlightCircleSize: 4,
      },
      labelsDivStyles: {
        'backgroundColor': 'rgba(188, 245, 120, 0.75)',
        'padding': '2px',
        'border': '1px solid black',
        'borderRadius': '3px',
        'right': '-200px',
        'width': '200px',
        'direction': 'ltr'
      },
      labelsSeparateLines: true,
      dateWindow: range(),
      colors: ['#284785', '#EE1111', '#00DD55', '#DA60EE'],
      avoidMinZero: true,
      interactionModel: {
        mousedown: downV3,
        mousemove: moveV3,
        mouseup: upV3,
        click: clickV3,
        // dblclick: dblClickV3,
        // mousewheel: scrollV3
      },
      clickCallback: function() {
        if (graph.isSeriesLocked()) {
          graph.clearSelection();
          $('.table col.success').removeClass('success');
        } else {
          graph.setSelection(graph.getSelection(), graph.getHighlightSeries(), true);
          $('.table col[data-name="'+graph.getHighlightSeries()+'"').addClass('success');
        }
      },
      // underlayCallback: window.lastValue ? function(canvas, area, g) {
      //   var bottom_left = g.toDomCoords(highlight_start, -20);
      //   var top_right = g.toDomCoords(highlight_end, +20);

      //   var left = bottom_left[0];
      //   var right = top_right[0];

      //   canvas.fillStyle = "rgba(255, 255, 102, 1.0)";
      //   canvas.fillRect(left, area.y, right - left, area.h);
      // } : null,
      axes: {
        x: {
          valueFormatter: xaxeValueFormatter,
          axisLabelFormatter: xaxeLabelFormatter
        },
        y: {
          valueFormatter: function(y, opts, series_name) {
            var scaleIndex = chartLabels.indexOf(series_name);
            var currScale = scale[scaleIndex];
            if (currScale === 1) {
              return toPersianNumber(y);
            } else {
              return toPersianNumber(Math.round(y/currScale*100)/100);
            }
          },
          axisLabelFormatter: function(number) {
            return toPersianNumber(parseFloat(number.toPrecision(7)));
          }
        }
      },
    });
    var colGroup = '<colgroup><col></col>';
    for (i=0; i<chartLabels.length; i++) {
      colGroup += '<col span=1 data-name="'+chartLabels[i]+'"></col>';
    }
    colGroup += '</colgroup>';
    $('.table').prepend(colGroup);
    var headData = '<th class="text-center no-col">ردیف</th>';
    var hasCol = false;
    for (i=0; i<chartLabels.length; i++) {
      if (hasCol) {
        headData += '<th class="text-center">'+chartLabels[i]+'</th>';
      } else {
        headData += '<th class="text-center no-col">'+chartLabels[i]+'</th>';
        hasCol = true;
      }
    }
    $('.chartHead').html(headData);
    $('.chartHead th').click(function() {
      var $this = $(this);
      if ($this.hasClass('no-col')) return;
      var $col = $('.table colgroup col.success');
      if ($col.attr('data-name') === $this.html()) {
        $col.removeClass('success');
        graph.clearSelection();
      } else {
        $col.removeClass('success');
        $('.table colgroup col[data-name="'+$this.html()+'"').addClass('success');
        graph.setSelection(false, $this.html(), true);
      }
    });
    if (window.lastValue) {
      for (i=chart.length-1; i >= 0; i--) {
        line = chart[i];
        if(line && line.length && line.length > 1) {
          datestr = persianDate(new Date(line[0]));
          tableData += '<tr class="text-center"><td class="td-tier">' + toPersianNumber(c++) + '</td><td>' + datestr + '</td>';
          for (j=1; j<line.length; j++) {
            tableData += '<td>'+toPersianNumber(line[j])+'</td>';
          }
          tableData += '</tr>';
        }
      }
    }
    else {
      for (i=0; i<chart.length; i++) {
        line = chart[i];
        if(line && line.length && line.length > 1) {
          datestr = persianDate(new Date(line[0]));
          tableData += '<tr class="text-center"><td class="td-tier">' + toPersianNumber(c++) + '</td><td>' + datestr + '</td>';
          for (j=1; j<line.length; j++) {
            tableData += '<td>'+toPersianNumber(line[j])+'</td>';
          }
          tableData += '</tr>';
        }
      }
    }
    $('.chartTable').html(tableData);
    if(window.lastValue) {
      var lastChart = window.chart[window.chart.length-1];
      highlight_start = lastChart ? lastChart[0] : new Date(window.lastValue);
      var $update = $('.last-update'),
          updateTime = function() {
            lastChart = window.chart[window.chart.length-1];
            $('.last-value').html(persianDateFull(lastChart[0]));
            highlight_end = lastChart[0];
          };
      setInterval(function() {
        $update.removeClass('text-success text-danger').addClass('text-warning').find('strong').html('در حال بروزرسانی');
        $.get(refreshUrl, {last: window.lastValue, channel: window.channel}).done(function(resp) {
          if(resp.values && resp.values.length > 0) {
            var values = [], v, l = resp.values.length, x, tableData;
            for (x = 0; x < l; x++) {
              values.push([new Date(resp.values[x][0]*1000), resp.values[x][1]]);
            }
            for (x = 0; x < l; x++) {
              tableData += '<tr class="text-center success"><td class="td-tier"></td><td>' +
                            persianDate(values[x][0]) + '</td>' + '<td>' +
                            toPersianNumber(values[x][1])+'</td>' + '</tr>';
            }
            setTimeout(function() {
              $('tr.success').removeClass('success');
            }, 10000);
            $('.chartTable').prepend(tableData);
            $('.td-tier').each(function(i, el) {
              el.innerHTML = toPersianNumber(i+1);
            });
            values.reverse();
            Array.prototype.push.apply(window.chart, values);
            updateTime();
            window.graph.updateOptions({ file: window.chart, dateWindow: range() });
            window.lastValue = resp.last;
          }
          $update.addClass('text-success').removeClass('text-warning').find('strong').html(persianDate(new Date()));
        }).fail(function() {
          $update.addClass('text-danger').removeClass('text-warning').find('strong').html('خطا در دریافت داده');
        });
      }, 30000);
    }
  }
  $('#side-menu').metisMenu();

  $('.pcal').each(function() {
    var $this = $(this);
    new AMIB.persianCalendar( $this.attr('id') );
  });

  $("#slider").responsiveSlides({
    auto: false,
    pager: true,
    fade: 500,
    maxwidth: 800
  });

});
