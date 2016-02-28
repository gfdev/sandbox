import { ADD_COMPONENT, DELETE_COMPONENT, MOVE_COMPONENT } from '../actions/';

const initialState = {
    nodes: [
        { id: 1, type: 'container', name: 'screen', parent: 0 },
        { id: 2, type: 'leaf', name: 'scroll', parent: 0 },
        { id: 3, type: 'leaf', name: 'one', parent: 0 },
        { id: 4, type: 'container', name: 'two', parent: 0 },
        { id: 5, type: 'container', name: 'three', parent: 4 },
        { id: 6, type: 'container', name: 'four', parent: 5 },
        { id: 7, type: 'leaf', name: 'five', parent: 5 },
        { id: 8, type: 'leaf', name: 'six', parent: 5 },
        { id: 9, type: 'leaf', name: 'seven', parent: 6 }
    ]
};

export default function(state = initialState, action) {
    switch (action.type) {
        case DELETE_COMPONENT:
            let node = state.nodes.filter(item => item.id == action.id).shift();

            if (node.type == 'leaf') {
                return {
                    nodes: [...state.nodes.filter(item => item.id != node.id)]
                };
            } else if (node.type == 'container') {
                let nodes = [...state.nodes.filter(item => item.id != node.id && item.parent != node.id)];
                let id = node.id;

                while (true) {
                    let children = [];

                    for (let node of state.nodes) {
                        if (node.type == 'container' && node.parent == id) {
                            nodes = [...nodes.filter(item => item.parent != node.id)];

                            id = node.id;

                            children.push(node.id);

                            break;
                        }
                    }

                    if (!children.length) break;
                }

                return {
                    nodes: nodes
                };
            }
        case ADD_COMPONENT:
            return state;
        case MOVE_COMPONENT:
            return {
                nodes: [...state.nodes.map(item => { if (item.id == action.id) item.parent = action.idTo; return item })]
            };
        default:
            return state;
    }
}
