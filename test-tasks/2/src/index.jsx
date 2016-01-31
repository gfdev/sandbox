require('./app.scss');

let storage = require('amplify-store')
    , LinkedStateMixin = require('react-addons-linked-state-mixin')
    , { Grid, Row, Col, Panel, Button, Input, Table, Glyphicon } = require('react-bootstrap')
    ;

function _getDaySeconds() {
    let now = new Date();

    return now.getHours() * 60 + now.getMinutes();
}

function _formatPhone(phone) {
    return phone.match(/((?:00)?\d{3})/g).join(' ');
}

function _formatTime(time) {
    let hr = parseInt(time / 60)
        , mm = parseInt(time % 60)
        ;

    return [ hr > 9 ? hr : '0' + hr, mm > 9 ? mm : '0' + mm ].join(':');
}

const CallsNext = React.createClass({
    propTypes: {
        calls: React.PropTypes.instanceOf(Immutable.List).isRequired,
        now: React.PropTypes.number.isRequired
    },
    shouldComponentUpdate(props, state) {
        return !Immutable.is(props.calls, this.props.calls);
    },
    render() {
        let calls = this.props.calls.filter(item => item.get('time') >= this.props.now)
            , call = null
            ;

        if (calls.size) call = calls.sortBy(item => item.get('time')).first();

        return (
            <Row style={{ width: '95%' }}>
                <Panel>
                    <h2 className="center" style={{ marginTop: 0 }}>Next call</h2>
                    <Input>
                        <Row>
                            <Col xs={6}>
                                <input type="text"
                                    className="form-control"
                                    value={call && call.get('name')}
                                    disabled />
                            </Col>
                            <Col xs={4}>
                                <input type="text"
                                    className="form-control"
                                    value={call && _formatPhone(call.get('phone'))}
                                    disabled />
                            </Col>
                            <Col xs={2}>
                                <input type="text"
                                    className="form-control"
                                    value={call && _formatTime(call.get('time'))}
                                    disabled />
                            </Col>
                        </Row>
                    </Input>
                </Panel>
            </Row>
        );
    }
});

const CallsAdd = React.createClass({
    mixins: [
        LinkedStateMixin
    ],
    getInitialState() {
        return { name: 'Bob', phone: '0064654564', time: '15:41' };
    },
    handleClickAdd() {
        if (!/^[a-z.\-'\s]{1,30}$/i.test(this.state.name)) {
            alert('Name is incorrect!');
            return;
        }

        if (!this._checkPhone()) {
            alert('Phone is incorrect!');
            return;
        }

        if (!this._checkTime()) {
            alert('Time is incorrect!');
            return;
        }

        this.props.handleCallAdd(this.state);

        this.setState(this.getInitialState());
    },
    _checkTime() {
        if (!/^\d{2}:\d{2}$/.test(this.state.time)) return false;

        let [ h, m ] = this.state.time.split(':');
        if (+h < 0 || +h > 23 || +m < 0 || +m > 59) return false;

        return true;
    },
    _checkPhone() {
        if (!/^(?:\+|00)[0-9()-\s]+$/.test(this.state.phone)) return false;

        let check = true;

        for (let symbol of [ '(', ')', '-' ]) {
            let re = new RegExp('\\' + symbol, 'g');
            if ((this.state.phone.match(re) || []).length > 1) check = false;

            let pos = this.state.phone.indexOf(symbol);
            if (pos !== -1 && (pos < 1 || pos > 7)) check = false;
        }

        return check;
    },
    render() {
        return (
            <Row style={{ width: '95%' }}>
                <Panel header="Add call">
                    <Row style={{ marginBottom: "10px" }}>
                        <Input>
                            <Col xs={6}>
                                <input type="text"
                                    className="form-control"
                                    valueLink={this.linkState('name')} />
                            </Col>
                            <Col xs={4}>
                                <input type="text"
                                    className="form-control"
                                    valueLink={this.linkState('phone')} />
                            </Col>
                            <Col xs={2}>
                                <input type="text"
                                    className="form-control"
                                    placeholder="mm:ss" valueLink={this.linkState('time')} />
                            </Col>
                        </Input>
                    </Row>
                    <Row>
                        <Col xs={10} />
                        <Col xs={2}>
                            <Button bsStyle="primary"
                                onClick={this.handleClickAdd}
                                block>
                                    Add <Glyphicon glyph="plus" />
                            </Button>
                        </Col>
                    </Row>
                </Panel>
            </Row>
        );
    }
});

const CallsList = React.createClass({
    propTypes: {
        calls: React.PropTypes.instanceOf(Immutable.List).isRequired,
        now: React.PropTypes.number.isRequired
    },
    getInitialState() {
        return { visibility: 'all', sort: 'time', asc: true };
    },
    render() {
        let calls = this.props.calls.filter(item => this.state.visibility === 'next'
            ? (item.get('time') > this.props.now)
            : this.state.visibility === 'finished'
            ? (item.get('time') <= this.props.now)
            : true
        ).sortBy(item => item.get(this.state.sort));

        if (!this.state.asc) calls = calls.reverse();

        return (
            <Row style={{ width: '95%' }}>
                <Row>
                    <Table striped bordered hover responsive>
                        <thead>
                        <tr>
                            <th>
                                <a href="#" onClick={() => { this.setState({ sort: 'name', asc: !this.state.asc }) }}>
                                    <Row>
                                        <Col xs={6}>Name</Col>
                                        <Col xs={6} style={{ textAlign: 'right' }}>
                                            {this.state.sort === 'name' &&
                                                <Glyphicon glyph={this.state.asc ? 'triangle-bottom' : 'triangle-top'} />
                                            }
                                        </Col>
                                    </Row>
                                </a>
                            </th>
                            <th>Phone number</th>
                            <th>
                                <a href="#" onClick={() => { this.setState({ sort: 'time', asc: !this.state.asc }) }}>
                                    <Row>
                                        <Col xs={6}>Time</Col>
                                        <Col xs={6} style={{ textAlign: 'right' }}>
                                            {this.state.sort === 'time' &&
                                                <Glyphicon glyph={this.state.asc ? 'triangle-bottom' : 'triangle-top'} />
                                            }
                                        </Col>
                                    </Row>
                                </a>
                            </th>
                            <th />
                            <th />
                        </tr>
                        </thead>
                        <tbody>
                            {calls.map((item) => {
                                let hash = item.hashCode();

                                return (
                                    <tr key={hash}>
                                        <td>{item.get('name')}</td>
                                        <td>{_formatPhone(item.get('phone'))}</td>
                                        <td>{_formatTime(item.get('time'))}</td>
                                        <td className="center">
                                            <a href="#" onClick={this.props.handleCallRemove.bind(null, hash)}>delete</a>
                                        </td>
                                        <td className="center">
                                            <input type="checkbox" disabled checked={item.get('time') < this.props.now} />
                                        </td>
                                    </tr>
                                    );
                            })}
                        </tbody>
                    </Table>
                </Row>
                <Row>
                    <Col xs={4}>
                        <Button bsStyle="primary"
                            onClick={() => { this.setState({ visibility: 'all' }); }}
                            disabled={this.state.visibility === 'all'}
                            block>
                                All
                        </Button>
                    </Col>
                    <Col xs={4}>
                        <Button bsStyle="primary"
                            onClick={() => { this.setState({ visibility: 'next' }); }}
                            disabled={this.state.visibility === 'next'}
                            block>
                                Next
                        </Button>
                    </Col>
                    <Col xs={4}>
                        <Button bsStyle="primary"
                            onClick={() => { this.setState({ visibility: 'finished' }); }}
                            disabled={this.state.visibility === 'finished'}
                            block>
                                Finished
                        </Button>
                    </Col>
                </Row>
            </Row>
        );
    }
});

const App = React.createClass({
    getInitialState() {
        var calls = storage('calls');

        if (calls) {
            return {
                calls: Immutable.fromJS(storage('calls') || {}),
                now: _getDaySeconds()
            };
        } else {
            return {
                calls: Immutable.List(),
                now: _getDaySeconds()
            };
        }
    },
    componentWillUpdate(props, state) {
        storage('calls', state.calls.toJS());
    },
    handleCallRemove(hash) {
        let index = this.state.calls.findIndex(item => item.hashCode() == hash);

        this.setState({ calls: this.state.calls.remove(index), now: _getDaySeconds() });
    },
    handleCallAdd(data) {
        let [ h, m ] = data.time.split(':')
            , phone = data.phone.replace(/^\+/, '00').replace(/\D/g, '')
            , record = Immutable.Map({
                name: data.name,
                phone: phone,
                time: 60 * +h + +m
            })
        ;

        if (this.state.calls.size === 0) {
            this.setState({
                calls: this.state.calls.push(record),
                now: _getDaySeconds()
            });
        } else {
            let index = this.state.calls.findIndex(item => item.hashCode() == record.hashCode());

            if (index === -1) this.setState({
                calls: this.state.calls.push(record),
                now: _getDaySeconds()
            });
        }
    },
    render() {
        return (
            <Grid fluid>
                <Row>
                    <Col xs={6}>
                        <CallsNext {...this.state} />
                    </Col>
                    <Col xs={6}>
                        <CallsAdd handleCallAdd={this.handleCallAdd} />
                        <CallsList {...this.state} handleCallRemove={this.handleCallRemove} />
                    </Col>
                </Row>
            </Grid>
        );
    }
});

module.exports = App;
