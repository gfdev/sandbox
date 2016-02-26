define(["jquery"], function($) {
  function _getX() {
    return (0 + Math.random() * ($(window).width() - 100)) ^ 0;
  }
  
  function _getY() {
    return (34 + Math.random() * ($(window).height() - 100 - 34)) ^ 0;
  }
  
  function _getRandomColor() {
    return "#" + ((1 << 24) * Math.random() | 0).toString(16);
  }
  
  return {
    create: function(opts) {
      var opts = opts || {},
        x      = opts.x || _getX(),
        y      = opts.y || _getY(),
        color  = opts.color || _getRandomColor();
      
      $("<div></div>").css({
        position: "absolute",
        left: x,
        top: y,
        "background-color": color
      }).addClass("square").attr("id", typeof opts === "string" ? opts : opts.id).show(0).appendTo("body");
      
      return {
        x:     x,
        y:     y,
        color: color
      };
    },
    remove: function() {
      $("#" + window.id).remove();
    },
    changeColor: function() {
      var color = _getRandomColor();
      
      $("#" + window.id).css("background-color", color);
      
      return color;
    }
  };
});
