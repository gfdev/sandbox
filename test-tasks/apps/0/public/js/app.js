requirejs.config({
  baseUrl: "js/lib",
  paths: {
    app: "../app",
    jquery: "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min",
    "jquery-ui": "//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min"
  }
});

requirejs(["app/main"]);
