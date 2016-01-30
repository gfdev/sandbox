require('./app.scss');

var { Grid, Row, Col, Jumbotron, Button, Input, Table } = require('react-bootstrap');

var App = React.createClass({
    displayName: 'App',
    render: function() {
        return (
            <Grid fluid={true}>
                <Row style={{ "text-align": "center" }}>
                    <Col xs={6}>
                        <h1>Next call</h1>
                        <Input>
                            <Row>
                                <Col xs={4}>
                                    <input type="text" className="form-control" />
                                </Col>
                                <Col xs={4}>
                                    <input type="text" className="form-control" />
                                </Col>
                                <Col xs={4}>
                                    <input type="text" className="form-control" />
                                </Col>
                            </Row>
                        </Input>
                    </Col>
                    <Col xs={6}>
                        <Input>
                            <Row>
                                <Col xs={4}>
                                    <input type="text" className="form-control" />
                                </Col>
                                <Col xs={4}>
                                    <input type="text" className="form-control" />
                                </Col>
                                <Col xs={4}>
                                    <input type="text" className="form-control" />
                                </Col>
                                <Button block>Add</Button>
                            </Row>
                            <Row>
                                <Table striped bordered condensed hover>
                                    <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Phone number</th>
                                        <th>Time</th>
                                        <th></th>
                                        <th></th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <tr>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                    </tr>
                                    </tbody>
                                </Table>
                                <Button>All</Button>
                                <Button>Next</Button>
                                <Button>Finished</Button>
                            </Row>
                        </Input>
                    </Col>
                </Row>
            </Grid>
        );
    }
});

ReactDOM.render(<App />, document.getElementById('body'));
