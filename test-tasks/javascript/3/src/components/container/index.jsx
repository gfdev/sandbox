import { Component } from 'react';
import { connect } from 'react-redux';
import { DragSource, DropTarget } from 'react-dnd';

import { deleteComponent, moveComponent } from '../../actions/';

import flow from 'lodash/flow';

const containerSource = {
    beginDrag(props) {
        return { id: props.id };
    }
};

const containerTarget = {
    drop(props, monitor) {
        if (!monitor.didDrop()) {
            let data = monitor.getItem();

            props.dispatch(moveComponent(data.id, props.id))
        }
    }
};

class Container extends Component {
    render() {
        const { dispatch, connectDragSource, connectDropTarget } = this.props;

        return connectDragSource(connectDropTarget(
            <div className="container border" style={{ cursor: this.props.id !== 0 ? 'move' : '' }}>
                {this.props.name}
                {this.props.id != 0
                    ? <button style={{ float: 'right' }} onClick={() => dispatch(deleteComponent(this.props.id))}>DELETE</button>
                    : null
                }
                {this.props.children}
            </div>
        ));
    }
}

export default connect(state => state)(flow(
    DragSource('item', containerSource, (connect) => ({
        connectDragSource: connect.dragSource()
    })),
    DropTarget('item', containerTarget, (connect) => ({
        connectDropTarget: connect.dropTarget()
    }))
)(Container));
