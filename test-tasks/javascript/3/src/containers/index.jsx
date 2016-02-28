import { Component } from 'react';
import { connect } from 'react-redux';
import { DragDropContext } from 'react-dnd';

import HTML5Backend from 'react-dnd-html5-backend';

import { Container, Leaf } from '../components/';

function _findParent(id, children, parent) {
    for (let node of children) {
        if (node.props.type === 'leaf') continue;
        if (node.props.id == id) {
            parent = node;
        } else if (node.props.children.length) {
            parent = _findParent(id, node.props.children, parent);
        }
    }

    return parent;
}

function _addNode(node, children) {
    let props = { id: node.id, key: node.id, type: node.type, name: node.name };

    children.push(
        node.type === 'container' ? <Container {...props} children={[]} /> : <Leaf {...props} />
    );
}

class Index extends Component {
    render() {
        let children = [],
            clone = JSON.parse(JSON.stringify(this.props.nodes)).sort((a, b) => a.type === 'container' ? 0 : 1);

        while (clone.length) {
            let node = clone.shift();

            if (node.parent === 0) {
                _addNode(node, children);
            } else {
                if (children.length === 0) {
                    clone.push(node);
                } else {
                    let parent = _findParent(node.parent, children);

                    if (!parent) {
                        clone.push(node);
                    } else {
                        _addNode(node, parent.props.children);
                    }
                }
            }
        }

        return (
            <Container id={0} name="root" children={children} />
        );
    }
}

export default connect(state => state)(DragDropContext(HTML5Backend)(Index));
