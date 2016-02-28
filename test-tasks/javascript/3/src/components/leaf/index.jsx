import { Component } from 'react';
import { DragSource } from 'react-dnd';
import { connect } from 'react-redux';

import { deleteComponent } from '../../actions/';

const source = {
    beginDrag(props) {
        return { id: props.id };
    }
};

class Leaf extends Component {
    render() {
        const { dispatch, connectDragSource } = this.props;

        return connectDragSource(
            <div className="leaf border" style={{ cursor: 'move' }}>
                {this.props.name}
                <button style={{ float: 'right' }} onClick={() => dispatch(deleteComponent(this.props.id))}>DELETE</button>
            </div>
        );
    }
}

export default connect(state => state)(DragSource('item', source, (connect) => ({
    connectDragSource: connect.dragSource()
}))(Leaf));
