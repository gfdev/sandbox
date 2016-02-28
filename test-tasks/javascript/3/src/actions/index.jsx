export const ADD_COMPONENT = 'ADD_COMPONENT';
export const DELETE_COMPONENT = 'DELETE_COMPONENT';
export const MOVE_COMPONENT = 'MOVE_COMPONENT';

export function addComponent(id) {
    return { type: ADD_COMPONENT, id };
}

export function deleteComponent(id) {
    return { type: DELETE_COMPONENT, id };
}

export function moveComponent(id, idTo) {
    return { type: MOVE_COMPONENT, id, idTo };
}
