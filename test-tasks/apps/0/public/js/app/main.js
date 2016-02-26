require(["jquery", "jquery-ui", "app/square"], function($, ui, square) {
  var ws = new WebSocket("ws://offset.ath.cx:3000/ws");
  
  ws.onopen = function(e) {
    ws.send(JSON.stringify({ cmd: "reg" }));
    ws.send(JSON.stringify({ cmd: "list" }));
  };
  
  ws.onmessage = function(e) {
    var res = JSON.parse(e.data),
      cmd   = res.cmd,
      data  = res.data;
    
    switch (cmd) {
      case "reg":
        window.id = data.id;
      break;
      case "list":
        for (i in data) square.create(data[i]);
      break;
      case "add":
        square.create(data);
      break;
      case "clr":
        $("#" + data.id).css("background-color", data.color);
      break;
      case "del":
        $("#" + data.id).remove();
      break;
      case "move":
        $("#" + data.id).css({ left: data.x, top: data.y });
      break;
    }
  };
  
  $("#add-square").click(function() {
    $(this).attr("disabled", true).next().attr("disabled", false).next().attr("disabled", false);
    
    var opts = square.create(window.id);
    
    $("#" + window.id).draggable({
      drag: function(e, ui) {
        ws.send(JSON.stringify({ cmd: "move", x: ui.position.left, y: ui.position.top }));
      }
    });
    
    ws.send(JSON.stringify({ cmd: "add", x: opts.x, y: opts.y, color: opts.color }));
  });
  
  $("#remove-square").click(function() {
    square.remove();
    
    ws.send(JSON.stringify({ cmd: "del" }));
    
    $(this).attr("disabled", true).prev().attr("disabled", true).prev().attr("disabled", false);
  });
  
  $("#change-square-color").click(function() {
    ws.send(JSON.stringify({ cmd: "clr", color: square.changeColor() }));
  });
});
