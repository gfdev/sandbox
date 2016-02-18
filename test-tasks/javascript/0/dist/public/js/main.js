$(document).ready(function() {
    var uri = "http://www.json-generator.com/api/json/get/bUsRkvEmHm?indent=2",
        requestData;
    
    $("#btn-show-data").on("click", function() {
        var $table = $("#table-data"),
            $thead = $table.children(":first").children(":first"),
            $tbody = $thead.closest("thead").next(),
            keys = [];
        
        $thead.empty();
        $tbody.empty();
            
        $("#page-select-data").hide(0, function() {
            $("#form-checkboxes input:checked").each(function() {
                $("<td class='table-header'>" + this.id + "</td>").appendTo($thead);
                
                keys.push(this.id);
            });
            
            for (var i in requestData) {
                var $tr = $("<tr/>");
                
                for (var c = 0, l = keys.length; c < l; c++) {
                    var str = requestData[i][keys[c]];
                    
                    $("<td>" + (typeof str === "object" ? JSON.stringify(str) : str) + "</td>")
                        .appendTo($tr);
                }
                
                $tr.appendTo($tbody);
            }
            
            $(".table-header").each(function(){
                var $th = $(this),
                    index = $th.index(),
                    inverse = false;
                
                $th.click(function(){
                    $table.find("tbody td").filter(function() {
                        return $(this).index() === index;
                    }).sortElements(function(a, b) {
                        return $.text([a]) > $.text([b])
                            ? inverse ? -1 : 1
                            : inverse ? 1 : -1;
                    }, function() {
                        return this.parentNode; 
                    });
                    
                    inverse = ! inverse;
                });
            });
        }).next().show();
    });
    
    $("#btn-request-data").on("click", function() {
        $.ajax({
            url: uri,
            dataType: "json",
            beforeSend: function(xhr) {
                $("#page-request").hide().next().show();
            }
        }).done(function(data) {
            requestData = data;
            
            $("#page-spinner").hide().next().show();
            
            var $form = $("#form-checkboxes"),
                $block = $("#block-checkboxes").detach().removeAttr("id").show(),
                $item = $block.children(":first").detach(),
                i = 0;
            
            for (var name in data[0]) {
                $item.clone()
                    .appendTo($block)
                    .children(":first")
                    .attr("id", name)
                    .next()
                    .attr("for", name)
                    .html(name);
                
                i++;
                
                if (i % 6 == 0) {
                    $form.append($block);
                    
                    $block = $block.clone().empty();
                }
            }
            
            if (i % 6 != 0) $form.append($block);
        }).fail(function() {
            $("#page-spinner").hide().prev().show();
            
            alert("Can't get data!");
        });
    });
    
    $("#btn-back").on("click", function() {
        $("#page-data").hide().prev().show();
    });
    
    $("#btn-select-all").on("click", function() {
        $("#form-checkboxes").find("input[type='checkbox']").each(function() {
            if (! this.checked) this.checked = true;
        });
    });
    
    $("#btn-clear-all").on("click", function() {
        $("#form-checkboxes").find("input[type='checkbox']").each(function() {
            this.checked = false;
        });
    });
});
