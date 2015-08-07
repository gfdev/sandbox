'use strict';

define(['react'], function (React) {
    var Test = React.createClass({
        render: function () {
            return (
              <div>
                <p>Hello, React!</p>
              </div>
            );
        }
    });
    
    return React.render(
        <Test />, document.body
    );
    
});