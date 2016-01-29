require('./app.scss');

let App = React.createClass({
    displayName: 'App',
    render: function() {
        return (
            <div>
                <h2>Test Task 11</h2>
            </div>
        );
    }
});

ReactDOM.render(<App />, document.getElementById('body'));
