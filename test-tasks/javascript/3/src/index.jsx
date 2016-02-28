import './index.css';

import { createStore } from 'redux';
import { Provider } from 'react-redux';

import Index from './containers/';
import Reducers from './reducers/';

ReactDOM.render(
    <Provider store={createStore(Reducers)}>
        <Index />
    </Provider>,
    document.getElementById('root')
);
